import 'package:flutter/material.dart';
import 'package:winal_front_end/utils/medication_service.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationService _medicationService = MedicationService();

  // State variables
  List<Map<String, dynamic>> _medications = [];
  Map<String, dynamic>? _selectedMedication;
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMorePages = true;
  int _currentPage = 1;

  // Filters
  String? _currentMedicationType;
  int? _currentCategoryId;
  String? _currentSearchQuery;

  // Getters
  List<Map<String, dynamic>> get medications => _medications;
  Map<String, dynamic>? get selectedMedication => _selectedMedication;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages => _hasMorePages;

  // Add a getter for the base URL
  String get baseUrl => _medicationService.baseUrl;

  // Filter getters
  String? get currentMedicationType => _currentMedicationType;
  int? get currentCategoryId => _currentCategoryId;
  String? get currentSearchQuery => _currentSearchQuery;

  // Load medications with optional filters
  Future<void> loadMedications({
    bool resetPage = true,
    String? searchQuery,
    String? medicationType,
    int? categoryId,
  }) async {
    if (resetPage) {
      _currentPage = 1;
      _hasMorePages = true;
      _medications = [];
    }

    if (!_hasMorePages) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _medicationService.getMedications(
        medicationType: medicationType ?? _currentMedicationType,
        categoryId: categoryId ?? _currentCategoryId,
        searchQuery: searchQuery ?? _currentSearchQuery,
        page: _currentPage,
        pageSize: 10,
      );

      final newMedications =
          List<Map<String, dynamic>>.from(result['medications'] ?? []);
      print('🆕 NEW MEDICATIONS: ${newMedications.length}');

      if (newMedications.isNotEmpty) {
        print('📋 FIRST MEDICATION: ${newMedications[0]}');
      }

      _medications.addAll(newMedications);
      _currentPage++;
      _hasMorePages = newMedications.length >= 10;
      _currentMedicationType = medicationType ?? _currentMedicationType;
      _currentCategoryId = categoryId;
      _currentSearchQuery = searchQuery;

      print(
          '📊 TOTALS: Items=${_medications.length}, Current Count=${newMedications.length}, Has More=$_hasMorePages');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading medications: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load medication details
  Future<void> loadMedicationDetails(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _medicationService.getMedicationById(id);
      _selectedMedication = result['medication'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories({String? medicationType}) async {
    try {
      _categories = [];
      notifyListeners();

      final result = await _medicationService.getCategories(
        medicationType: medicationType ?? _currentMedicationType,
      );

      _categories = List<Map<String, dynamic>>.from(result ?? []);
      notifyListeners();
    } catch (e) {
      print('❌ Error loading categories: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Admin: Create a new medication
  Future<Map<String, dynamic>> createMedication(
      Map<String, dynamic> medicationData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _medicationService.createMedication(medicationData);

      _isLoading = false;

      // If successful, refresh the medications list
      if (result['success']) {
        await loadMedications();
      } else {
        _errorMessage = result['message'];
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': 'Error creating medication: ${e.toString()}',
      };
    }
  }

  // Admin: Update an existing medication
  Future<Map<String, dynamic>> updateMedication(
      int medicationId, Map<String, dynamic> medicationData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _medicationService.updateMedication(
          medicationId, medicationData);

      _isLoading = false;

      // If successful, refresh the medications list and update selected medication if needed
      if (result['success']) {
        await loadMedications();

        // If the updated medication is currently selected, refresh it
        if (_selectedMedication != null &&
            _selectedMedication!['id'] == medicationId) {
          await loadMedicationDetails(medicationId);
        }
      } else {
        _errorMessage = result['message'];
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': 'Error updating medication: ${e.toString()}',
      };
    }
  }

  // Admin: Delete a medication
  Future<Map<String, dynamic>> deleteMedication(int medicationId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _medicationService.deleteMedication(medicationId);

      _isLoading = false;

      // If successful, refresh the medications list and clear selected medication if needed
      if (result['success']) {
        // If the deleted medication is currently selected, clear it
        if (_selectedMedication != null &&
            _selectedMedication!['id'] == medicationId) {
          clearSelectedMedication();
        }

        // Refresh the medications list
        await loadMedications();
      } else {
        _errorMessage = result['message'];
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': 'Error deleting medication: ${e.toString()}',
      };
    }
  }

  // Clear the selected medication
  void clearSelectedMedication() {
    _selectedMedication = null;
    notifyListeners();
  }

  // Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
