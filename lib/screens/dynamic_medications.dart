import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/utils/medication_provider.dart';
import 'package:winal_front_end/providers/cart_provider.dart';
import 'package:winal_front_end/models/product.dart';
import 'dart:developer' as developer;

class DynamicMedicationsScreen extends StatefulWidget {
  final String userEmail;
  final String userInitials;
  final String medicationType;
  final String screenTitle;

  const DynamicMedicationsScreen({
    Key? key,
    required this.userEmail,
    required this.userInitials,
    required this.medicationType,
    required this.screenTitle,
  }) : super(key: key);

  @override
  State<DynamicMedicationsScreen> createState() =>
      _DynamicMedicationsScreenState();
}

class _DynamicMedicationsScreenState extends State<DynamicMedicationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    print(
        '==== DynamicMedicationsScreen initialized for ${widget.medicationType} ====');

    // Load medications and categories on init based on the medication type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Loading medications and categories for ${widget.medicationType}');
      final medicationProvider =
          Provider.of<MedicationProvider>(context, listen: false);

      medicationProvider.loadMedications(medicationType: widget.medicationType);
      medicationProvider.loadCategories(medicationType: widget.medicationType);
    });

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final medicationProvider =
            Provider.of<MedicationProvider>(context, listen: false);
        if (!medicationProvider.isLoading && medicationProvider.hasMorePages) {
          medicationProvider.loadMedications(resetPage: false);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.screenTitle),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      _showCartDialog(context, cartProvider);
                    },
                  ),
                  if (cartProvider.totalItems > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartProvider.totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              developer.log(
                  '🔄 Refreshing medications for type: ${widget.medicationType}');
              final medicationProvider =
                  Provider.of<MedicationProvider>(context, listen: false);
              medicationProvider.loadMedications(
                  medicationType: widget.medicationType);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search medications...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<MedicationProvider>(context, listen: false)
                        .loadMedications(
                            searchQuery: '',
                            medicationType: widget.medicationType);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (value) {
                Provider.of<MedicationProvider>(context, listen: false)
                    .loadMedications(
                        searchQuery: value,
                        medicationType: widget.medicationType);
              },
            ),
          ),

          // Categories horizontal list
          SizedBox(
            height: 50,
            child: Consumer<MedicationProvider>(
                builder: (context, provider, child) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount:
                    provider.categories.length + 1, // +1 for "All" category
                itemBuilder: (context, index) {
                  // "All" category
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                            provider.loadMedications(
                              categoryId: null,
                              medicationType: widget.medicationType,
                            );
                          }
                        },
                      ),
                    );
                  }

                  // Category chips
                  final category = provider.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category['name']),
                      selected: _selectedCategoryId == category['id'],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryId = category['id'];
                          });
                          provider.loadMedications(
                            categoryId: category['id'],
                            medicationType: widget.medicationType,
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),

          // Medications grid
          Expanded(
            child: Consumer<MedicationProvider>(
              builder: (context, provider, child) {
                developer.log(
                    '📊 Provider state: isLoading=${provider.isLoading}, hasError=${provider.errorMessage != null}, medicationsCount=${provider.medications.length}');

                if (provider.isLoading && provider.medications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null &&
                    provider.medications.isEmpty) {
                  developer.log('❌ Error: ${provider.errorMessage}',
                      error: provider.errorMessage);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.loadMedications(
                                medicationType: widget.medicationType);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.medications.isEmpty) {
                  developer.log(
                      '⚠️ No medications found for type: ${widget.medicationType}');
                  return const Center(
                    child: Text(
                      'No medications found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                developer.log(
                    '✅ Showing ${provider.medications.length} medications');
                // Log the first medication to see its structure
                if (provider.medications.isNotEmpty) {
                  developer
                      .log('📋 First medication: ${provider.medications[0]}');
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.medications.length +
                      (provider.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= provider.medications.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final medication = provider.medications[index];
                    final baseUrl = provider.baseUrl;
                    String imageUrl =
                        'assets/images/SYRUP.jpeg'; // Default fallback image

                    // Check if medication has an image
                    if (medication['images'] != null &&
                        medication['images'].isNotEmpty) {
                      for (var image in medication['images']) {
                        if (image['is_primary'] == true) {
                          // Check both 'url' and 'image_url' fields for compatibility
                          String? url = image['url'] ?? image['image_url'];
                          if (url != null) {
                            // If image url starts with 'assets/', use it directly as an asset
                            if (url.startsWith('assets/')) {
                              imageUrl = url;
                            } else {
                              // Otherwise treat as a network image
                              imageUrl = url;
                              if (imageUrl.startsWith('/')) {
                                imageUrl = '$baseUrl$imageUrl';
                              }
                            }
                            break;
                          }
                        }
                      }

                      // If no primary image, use the first one
                      if (imageUrl == 'assets/images/SYRUP.jpeg' &&
                          medication['images'].isNotEmpty) {
                        String? url = medication['images'][0]['url'] ??
                            medication['images'][0]['image_url'];
                        if (url != null) {
                          if (url.startsWith('assets/')) {
                            imageUrl = url;
                          } else {
                            imageUrl = url;
                            if (imageUrl.startsWith('/')) {
                              imageUrl = '$baseUrl$imageUrl';
                            }
                          }
                        }
                      }
                    } else {
                      // If no images array, check for a direct image_url field
                      if (medication['image_url'] != null) {
                        String url = medication['image_url'];
                        if (url.startsWith('assets/')) {
                          imageUrl = url;
                        } else {
                          imageUrl = url;
                          if (imageUrl.startsWith('/')) {
                            imageUrl = '$baseUrl$imageUrl';
                          }
                        }
                      }
                    }

                    // Determine if this is a network image or an asset image
                    final bool isNetworkImage = !imageUrl.startsWith('assets/');

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/medication_detail',
                            arguments: {'medicationId': medication['id']},
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medication image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: isNetworkImage
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/SYRUP.jpeg',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                                Icons.image_not_supported,
                                                size: 40),
                                          );
                                        },
                                      ),
                              ),
                            ),

                            // Medication details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medication['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (medication['category_name'] != null)
                                    Text(
                                      medication['category_name'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'UGX ${medication['price'].toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              medication['stock_quantity'] > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          medication['stock_quantity'] > 0
                                              ? 'In Stock'
                                              : 'Out of Stock',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shopping Cart'),
        content: SizedBox(
          width: double.maxFinite,
          child: cartProvider.cart.isEmpty
              ? const Text('Your cart is empty')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200, // Fixed height for the list
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cartProvider.cart.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cart[index];
                          return ListTile(
                            title: Text(item.product.name),
                            subtitle: Text('UGX ${item.product.price}'),
                            trailing: Text('x${item.quantity}'),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'UGX ${cartProvider.totalPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          if (cartProvider.cart.isEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          else
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    cartProvider.clearCart();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Cart'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Checkout successful! Your order is being processed.'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                    cartProvider.clearCart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Checkout'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
