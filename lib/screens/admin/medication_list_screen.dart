import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/medication_provider.dart';
import '../../models/medication.dart';
import 'medication_form_screen.dart';

class AdminMedicationListScreen extends StatefulWidget {
  const AdminMedicationListScreen({super.key});

  @override
  State<AdminMedicationListScreen> createState() =>
      _AdminMedicationListScreenState();
}

class _AdminMedicationListScreenState extends State<AdminMedicationListScreen> {
  String _medicationType = 'human'; // Default to human medications
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<MedicationProvider>(context, listen: false)
          .loadMedications(
        medicationType: _medicationType,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medications: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${medication.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMedication(medication.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedication(int id) async {
    try {
      final result =
          await Provider.of<MedicationProvider>(context, listen: false)
              .deleteMedication(id);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        await _loadMedications(); // Reload the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);
    final medicationsData = medicationProvider.medications;

    // Convert medication maps to Medication objects
    final List<Medication> medications = medicationsData.map((medicationMap) {
      return Medication.fromJson(medicationMap);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Type selector and search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'human',
                            label: Text('Human Meds'),
                            icon: Icon(Icons.person),
                          ),
                          ButtonSegment(
                            value: 'animal',
                            label: Text('Animal Meds'),
                            icon: Icon(Icons.pets),
                          ),
                        ],
                        selected: {_medicationType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _medicationType = selection.first;
                          });
                          _loadMedications();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SearchBar(
                  hintText: 'Search medications...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _loadMedications,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Medication list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : medications.isEmpty
                    ? const Center(child: Text('No medications found'))
                    : ListView.builder(
                        itemCount: medications.length,
                        itemBuilder: (context, index) {
                          final medication = medications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: ListTile(
                              title: Text(medication.name),
                              subtitle: Text(
                                '${medication.category} - ${medication.price} UGX',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MedicationFormScreen(
                                            medication: medication,
                                          ),
                                        ),
                                      ).then((_) => _loadMedications());
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmation(medication),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationFormScreen(
                medicationType: _medicationType,
              ),
            ),
          ).then((_) => _loadMedications());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
