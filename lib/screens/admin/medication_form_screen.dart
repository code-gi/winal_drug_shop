import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/medication_provider.dart';
import '../../models/medication.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;
  final String? medicationType;

  const MedicationFormScreen({
    Key? key,
    this.medication,
    this.medicationType,
  }) : super(key: key);

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;

  String _selectedCategory = '';
  String _selectedType = 'human';
  List<String> _categories = [];
  bool _isLoading = false;

  // Additional state variables for image preview
  bool _isValidImageUrl = false;
  bool _isValidatingImage = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    _nameController =
        TextEditingController(text: widget.medication?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.medication?.description ?? '');
    _priceController = TextEditingController(
        text: widget.medication?.price != null
            ? widget.medication!.price.toString()
            : '');
    _stockController = TextEditingController(
        text: widget.medication?.stock != null
            ? widget.medication!.stock.toString()
            : '');
    _imageUrlController =
        TextEditingController(text: widget.medication?.imageUrl ?? '');

    // Set initial type and category
    _selectedType = widget.medication?.type ?? widget.medicationType ?? 'human';

    // Load categories based on the type
    _loadCategories();

    // Add listener to the image URL controller to validate the URL
    _imageUrlController.addListener(_validateImageUrl);

    // If we already have an image URL (when editing), validate it
    if (_imageUrlController.text.isNotEmpty) {
      _validateImageUrl();
    }
  }

  // Validate the image URL when it changes
  void _validateImageUrl() {
    if (_imageUrlController.text.isEmpty) {
      setState(() {
        _isValidImageUrl = false;
        _isValidatingImage = false;
      });
      return;
    }

    if (!_imageUrlController.text.startsWith('http') &&
        !_imageUrlController.text.startsWith('https') &&
        !_imageUrlController.text.startsWith('assets/')) {
      setState(() {
        _isValidImageUrl = false;
        _isValidatingImage = false;
      });
      return;
    }

    setState(() {
      _isValidatingImage = true;
    });

    // Check if the URL points to a valid image
    if (_imageUrlController.text.startsWith('assets/')) {
      // For asset images, we can't validate - assume it's valid
      setState(() {
        _isValidImageUrl = true;
        _isValidatingImage = false;
      });
    } else {
      // For remote images, attempt to load the image
      final image = Image.network(_imageUrlController.text);
      final imageStream = image.image.resolve(const ImageConfiguration());

      imageStream.addListener(
        ImageStreamListener((_, __) {
          // Image loaded successfully
          setState(() {
            _isValidImageUrl = true;
            _isValidatingImage = false;
          });
        }, onError: (exception, stackTrace) {
          // Error loading image
          setState(() {
            _isValidImageUrl = false;
            _isValidatingImage = false;
          });
        }),
      );
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This would typically be an API call to get categories based on type
      if (_selectedType == 'human') {
        _categories = [
          'Painkillers',
          'Antibiotics',
          'Antihistamines',
          'Vitamin Supplements',
          'Antidiarrheals',
          'Antacids',
          'Skin Care',
          'Eye/Ear Drops',
          'Cough Syrups',
          'Other',
        ];
      } else {
        _categories = [
          'Dewormers',
          'Antibiotics',
          'Vaccines',
          'Vitamins',
          'Anti-inflammatory',
          'Wound Care',
          'Parasiticides',
          'Nutritional Supplements',
          'Other',
        ];
      }

      // Set initial category if editing
      if (widget.medication != null) {
        _selectedCategory = widget.medication!.category;
      } else {
        _selectedCategory = _categories.first;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicationData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'type': _selectedType,
        'category': _selectedCategory,
        'imageUrl': _imageUrlController.text,
      };

      final medicationProvider =
          Provider.of<MedicationProvider>(context, listen: false);
      Map<String, dynamic> result;

      if (widget.medication == null) {
        // Creating a new medication
        result = await medicationProvider.createMedication(medicationData);
      } else {
        // Updating existing medication
        result = await medicationProvider.updateMedication(
          widget.medication!.id,
          medicationData,
        );
      }

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pop(context); // Return to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing controller
    _imageUrlController.removeListener(_validateImageUrl);

    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication == null
            ? 'Add New Medication'
            : 'Edit Medication'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Medication Type Selection
                    if (widget.medication ==
                        null) // Only show when creating new medication
                      Row(
                        children: [
                          const Text('Medication Type:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'human',
                                  label: Text('Human'),
                                  icon: Icon(Icons.person),
                                ),
                                ButtonSegment(
                                  value: 'animal',
                                  label: Text('Animal'),
                                  icon: Icon(Icons.pets),
                                ),
                              ],
                              selected: {_selectedType},
                              onSelectionChanged: (Set<String> selection) {
                                setState(() {
                                  _selectedType = selection.first;
                                });
                                _loadCategories();
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price field
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (UGX)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stock field
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image preview
                    if (_imageUrlController.text.isNotEmpty && _isValidImageUrl)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Image Preview:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: _imageUrlController.text
                                      .startsWith('assets/')
                                  ? Image.asset(
                                      _imageUrlController.text,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 48,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),

                    // Image URL field with validation indicator
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              border: const OutlineInputBorder(),
                              hintText:
                                  'Enter URL or assets/images/filename.jpg',
                              suffixIcon: _isValidatingImage
                                  ? const CircularProgressIndicator()
                                  : _imageUrlController.text.isNotEmpty
                                      ? Icon(
                                          _isValidImageUrl
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: _isValidImageUrl
                                              ? Colors.green
                                              : Colors.red,
                                        )
                                      : null,
                            ),
                          ),
                        ),
                        if (_imageUrlController.text.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.photo_library),
                              tooltip: 'Browse assets',
                              onPressed: () {
                                // Show a modal with available asset images
                                _showAssetPicker(context);
                              },
                            ),
                          ),
                      ],
                    ),

                    if (_imageUrlController.text.isNotEmpty &&
                        !_isValidImageUrl &&
                        !_isValidatingImage)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please enter a valid image URL',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Save button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedication,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        widget.medication == null
                            ? 'Add Medication'
                            : 'Update Medication',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAssetPicker(BuildContext context) {
    // List of common asset images in the project
    final assetImages = [
      'assets/images/panadol.jpeg',
      'assets/images/antibiotics.jpeg',
      'assets/images/vitamin.jpeg',
      'assets/images/diarrhoea.jpeg',
      'assets/images/allergy.jpeg',
      'assets/images/DEWORMER.jpg',
      'assets/images/DOG.jpeg',
      'assets/images/CAT.jpeg',
      // Add more images as needed
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select an image from assets'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: assetImages.length,
            itemBuilder: (ctx, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _imageUrlController.text = assetImages[index];
                  });
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      assetImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, _) => const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
