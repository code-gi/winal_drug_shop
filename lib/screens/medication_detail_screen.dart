import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/utils/medication_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:winal_front_end/models/product.dart';
import 'package:winal_front_end/providers/cart_provider.dart';

class MedicationDetailScreen extends StatefulWidget {
  final int medicationId;

  const MedicationDetailScreen({
    super.key,
    required this.medicationId,
  });

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Load medication details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final medicationProvider =
          Provider.of<MedicationProvider>(context, listen: false);
      medicationProvider.loadMedicationDetails(widget.medicationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
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
              final medicationProvider =
                  Provider.of<MedicationProvider>(context, listen: false);
              medicationProvider.loadMedicationDetails(widget.medicationId);
            },
          ),
        ],
      ),
      body: Consumer<MedicationProvider>(builder: (context, provider, child) {
        // First get the provider and medication information
        final baseUrl = provider.baseUrl;
        final medication = provider.selectedMedication;

        // Then handle loading and error states
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
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
                    provider.loadMedicationDetails(widget.medicationId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (medication == null) {
          return const Center(
            child: Text('Medication not found'),
          );
        }

        // Prepare images for carousel
        List<dynamic> images = medication['images'] ?? [];
        if (images.isEmpty) {
          // If no images, add a placeholder
          images = [
            {'url': '/static/images/default_medication.jpg', 'is_primary': true}
          ];
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image carousel
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 250,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: images.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: images.map((image) {
                      String imageUrl = image['url'] ??
                          image['image_url'] ??
                          '/static/images/default_medication.jpg';

                      // Handle asset images
                      if (imageUrl.startsWith('assets/')) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 64),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      // Handle network images
                      if (imageUrl.startsWith('/')) {
                        imageUrl = '$baseUrl$imageUrl';
                      }

                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child:
                                      Icon(Icons.image_not_supported, size: 64),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),

                  // Pagination indicator
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),

              // Medication details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            medication['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'UGX ${(medication['price'] ?? 0.0).toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (medication['stock_quantity'] ?? 0) > 0
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (medication['stock_quantity'] ?? 0) > 0
                                    ? 'In Stock: ${medication['stock_quantity']}'
                                    : 'Out of Stock',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Prescription required badge
                    if (medication['requires_prescription'] == true)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.medical_services,
                                color: Colors.red, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Prescription Required',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Category
                    if (medication['category_name'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.category,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Category: ${medication['category_name']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                    // Description
                    if (medication['description'] != null &&
                        medication['description'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          medication['description'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                    // Divider
                    const Divider(),

                    // Detailed information sections
                    const SizedBox(height: 16),
                    Text(
                      'About This Medication',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),

                    // Full details
                    if (medication['full_details'] != null &&
                        medication['full_details'].toString().isNotEmpty)
                      _buildInfoSection(
                        title: 'Full Details',
                        content: medication['full_details'],
                        icon: Icons.info_outline,
                      ),

                    // Dosage instructions
                    if (medication['dosage_instructions'] != null &&
                        medication['dosage_instructions'].toString().isNotEmpty)
                      _buildInfoSection(
                        title: 'Dosage Instructions',
                        content: medication['dosage_instructions'],
                        icon: Icons.medication_outlined,
                      ),

                    // Side effects
                    if (medication['side_effects'] != null &&
                        medication['side_effects'].toString().isNotEmpty)
                      _buildInfoSection(
                        title: 'Side Effects',
                        content: medication['side_effects'],
                        icon: Icons.warning_amber_outlined,
                      ),

                    // Contraindications
                    if (medication['contraindications'] != null &&
                        medication['contraindications'].toString().isNotEmpty)
                      _buildInfoSection(
                        title: 'Contraindications',
                        content: medication['contraindications'],
                        icon: Icons.not_interested,
                      ),

                    // Storage instructions
                    if (medication['storage_instructions'] != null &&
                        medication['storage_instructions']
                            .toString()
                            .isNotEmpty)
                      _buildInfoSection(
                        title: 'Storage Instructions',
                        content: medication['storage_instructions'],
                        icon: Icons.inventory_2_outlined,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Consumer2<MedicationProvider, CartProvider>(
        builder: (context, medicationProvider, cartProvider, child) {
          final medication = medicationProvider.selectedMedication;
          if (medication == null || medicationProvider.isLoading) {
            return const SizedBox.shrink();
          }

          final bool inStock = (medication['stock_quantity'] ?? 0) > 0;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: inStock
                    ? () {
                        // Convert medication to Product and add to cart
                        final product = _convertMedicationToProduct(medication);
                        cartProvider.addToCart(product);

                        // Show confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${medication['name']} added to cart'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            width: 280,
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(
                  inStock ? 'Add to Cart' : 'Out of Stock',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Helper method to convert medication Map to Product
  Product _convertMedicationToProduct(Map<String, dynamic> medication) {
    // Find the image URL - first try to use the primary image
    String imageUrl = 'assets/images/SYRUP.jpeg'; // Default fallback

    if (medication['images'] != null && medication['images'].isNotEmpty) {
      // First try to find the primary image
      for (var image in medication['images']) {
        if (image['is_primary'] == true) {
          imageUrl = image['url'] ?? image['image_url'] ?? imageUrl;
          break;
        }
      }

      // If no primary image found, use the first image
      if (imageUrl == 'assets/images/SYRUP.jpeg' &&
          medication['images'].isNotEmpty) {
        imageUrl = medication['images'][0]['url'] ??
            medication['images'][0]['image_url'] ??
            imageUrl;
      }
    }

    return Product(
      id: medication['id'] ?? 0,
      name: medication['name'] ?? 'Unknown',
      price: (medication['price'] ?? 0).toInt(),
      image: imageUrl,
      color: Colors.blue[50] ?? Colors.blue.shade50, // Light blue background
      type: medication['medication_type'] ?? 'unknown',
    );
  }
}
