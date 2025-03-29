import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/utils/medication_provider.dart';

class DynamicMedicationsScreen extends StatefulWidget {
  final String userEmail;
  final String userInitials;

  const DynamicMedicationsScreen({
    Key? key,
    required this.userEmail,
    required this.userInitials,
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

    // Load human medications and categories on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final medicationProvider =
          Provider.of<MedicationProvider>(context, listen: false);
      medicationProvider.loadMedications(medicationType: 'human');
      medicationProvider.loadCategories(medicationType: 'human');
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
        title: const Text('Human Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final medicationProvider =
                  Provider.of<MedicationProvider>(context, listen: false);
              medicationProvider.loadMedications(medicationType: 'human');
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
                            searchQuery: '', medicationType: 'human');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (value) {
                Provider.of<MedicationProvider>(context, listen: false)
                    .loadMedications(
                        searchQuery: value, medicationType: 'human');
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
                                medicationType: 'human',
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
                              medicationType: 'human',
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Medications grid
          Expanded(
            child: Consumer<MedicationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.medications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null &&
                    provider.medications.isEmpty) {
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
                            provider.loadMedications(medicationType: 'human');
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.medications.isEmpty) {
                  return const Center(
                    child: Text(
                      'No medications found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
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
                    String imageUrl = '/static/images/default_medication.jpg';

                    // Check if medication has an image
                    if (medication['images'] != null &&
                        medication['images'].isNotEmpty) {
                      for (var image in medication['images']) {
                        if (image['is_primary'] == true) {
                          imageUrl = image['url'];
                          break;
                        }
                      }

                      // If no primary image, use the first one
                      if (imageUrl == '/static/images/default_medication.jpg' &&
                          medication['images'].isNotEmpty) {
                        imageUrl = medication['images'][0]['url'];
                      }
                    }

                    // Make sure the URL is absolute
                    if (imageUrl.startsWith('/')) {
                      imageUrl = '$baseUrl$imageUrl';
                    }

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
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.image_not_supported,
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
                                        '\$${medication['price'].toStringAsFixed(2)}',
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
}
