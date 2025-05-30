# Winal Drug Shop: Frontend-Backend Interaction & Information Flow Guide

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [Communication Patterns](#communication-patterns)
3. [Authentication Flow](#authentication-flow)
4. [Data Flow Patterns](#data-flow-patterns)
5. [API Communication Protocols](#api-communication-protocols)
6. [State Management](#state-management)
7. [Error Handling Strategies](#error-handling-strategies)
8. [Real-time Features](#real-time-features)
9. [Performance Optimization](#performance-optimization)
10. [Security Considerations](#security-considerations)

---

## System Architecture Overview

### Technology Stack Integration

The Winal Drug Shop application implements a clean separation between frontend and backend with the following architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                     FRONTEND (Flutter)                      │
├─────────────────────────────────────────────────────────────┤
│  • UI Components (Screens, Widgets)                        │
│  • State Management (Provider Pattern)                     │
│  • Service Layer (HTTP Client)                            │
│  • Local Storage (SharedPreferences)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS
                              │ JSON REST API
                              │
┌─────────────────────────────────────────────────────────────┐
│                     BACKEND (Flask)                        │
├─────────────────────────────────────────────────────────────┤
│  • API Endpoints (RESTful Routes)                         │
│  • Business Logic (Services)                              │
│  • Authentication (JWT)                                   │
│  • Database Layer (SQLAlchemy ORM)                        │
│  • Email Services (Gmail API)                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
┌─────────────────────────────────────────────────────────────┐
│                DATABASE (SQLite/PostgreSQL)                 │
├─────────────────────────────────────────────────────────────┤
│  • User Data                                              │
│  • Medication Inventory                                   │
│  • Orders & Transactions                                  │
│  • Cart Information                                       │
└─────────────────────────────────────────────────────────────┘
```

### Core Design Principles

1. **Service-Oriented Architecture**: Each major functionality is encapsulated in dedicated service classes
2. **Stateless Backend**: API endpoints are stateless, relying on JWT tokens for authentication
3. **Reactive Frontend**: Uses Provider pattern for state management with real-time UI updates
4. **RESTful Communication**: Standard HTTP methods and status codes for API communication
5. **Fallback Mechanisms**: Multiple server URLs with automatic failover capability

---

## Communication Patterns

### 1. Service Layer Architecture

#### Frontend Service Structure

**File:** `lib/utils/auth_service.dart`
```dart
// Base service pattern used across all services
class AuthService {
  // Base URLs for the Flask backend API with fallbacks
  final List<String> baseUrls = [
    'https://winal-backend.onrender.com', // Primary cloud-hosted URL
    'https://winaldrugshop-backend.onrender.com', // Alternative cloud URL
    'http://192.168.43.57:5000', // Legacy mobile hotspot (backup)
    'http://localhost:5000', // Local development
    'http://10.0.2.2:5000' // Android emulator to host loopback
  ];
  // Current working base URL
  String _currentBaseUrl = 'https://winal-backend.onrender.com'; // Default to primary
}
```

#### Service Discovery Pattern

**File:** `lib/utils/auth_service.dart` (lines 47-67)
```dart
// Try to find a working server
Future<String> _getWorkingBaseUrl() async {
  print('📱 AUTH SERVICE DEBUG: Finding a working server...');

  for (String url in baseUrls) {
    try {
      print('📱 AUTH SERVICE DEBUG: Trying server URL: $url');
      final response = await http.get(
        Uri.parse('$url/api/auth/token-debug'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3)); // Short timeout to quickly move to next server

      // Status 401 means server is up but we're not authenticated, which is expected
      if (response.statusCode == 401) {
        print('📱 AUTH SERVICE DEBUG: Server is available at: $url');
        _currentBaseUrl = url;
        return url;
      }
    } catch (e) {
      print('📱 AUTH SERVICE DEBUG: Server not available at $url: ${e.toString()}');
      // Continue to next URL
    }
  }

  // If all servers fail, use the default
  print('📱 AUTH SERVICE DEBUG: No servers available, using default: $_currentBaseUrl');
  return _currentBaseUrl;
}
```

### 2. HTTP Communication Patterns

#### Request-Response Flow
```
Frontend Service → HTTP Client → Backend Route → Business Logic → Database → Response
```

#### Standard Request Format
```dart
Future<Map<String, dynamic>> makeRequest({
  required String method,
  required String endpoint,
  Map<String, dynamic>? body,
  Map<String, String>? headers,
}) async {
  final baseHeaders = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  final response = await http.request(
    method,
    Uri.parse('$baseUrl$endpoint'),
    headers: {...baseHeaders, ...?headers},
    body: body != null ? json.encode(body) : null,
  );
  
  return _handleResponse(response);
}
```

#### Backend Response Pattern

**File:** `backend/app/routes/auth.py` (example from login endpoint)
```python
@auth_bp.route('/login', methods=['POST'])
def login():
    """Login and receive JWT token"""
    # ...existing validation logic...
    
    if not user or not user.verify_password(data['password']):
        return jsonify({"message": "Invalid credentials"}), 401
    
    access_token = create_access_token(
        identity=user.id,
        expires_delta=timedelta(days=1)
    )
    
    # Standard success response
    return jsonify({
        "message": "Login successful",
        "access_token": access_token,
        "user": {
            "id": user.id,
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name
        }
    }), 200

# Standard error response pattern used throughout
def handle_error(message, status_code):
    return jsonify({
        'success': False,
        'message': message
    }), status_code
```

---

## Authentication Flow

### 1. Registration Process

#### Frontend Flow

**File:** `lib/utils/auth_provider.dart` (lines 51-75)
```dart
// Register method in AuthProvider class
Future<bool> register({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String phoneNumber,
  required String dateOfBirth,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners(); // Update UI state

  final result = await _authService.register(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
  );

  _isLoading = false;

  if (!result['success']) {
    _errorMessage = result['message'];
  }

  notifyListeners(); // Update UI state
  return result['success'];
}
```

#### Backend Flow

**File:** `backend/app/routes/auth.py` (lines 23-90)
```python
@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user"""
    # Get request data
    data = request.get_json()
    if not data:
        return jsonify({'message': 'No data provided'}), 400

    # Convert date format if provided
    if 'date_of_birth' in data:
        try:
            # Convert from "M/D/YYYY" to "YYYY-MM-DD"
            dob = datetime.strptime(data['date_of_birth'], '%m/%d/%Y')
            data['date_of_birth'] = dob.strftime('%Y-%m-%d')
        except ValueError as e:
            return jsonify({
                'message': 'Invalid date format',
                'error': 'Date must be in format MM/DD/YYYY'
            }), 400

    # Get and validate data using UserSchema
    schema = UserSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        return jsonify({
            'message': 'Validation error',
            'errors': err.messages
        }), 400

    # Check if user already exists
    if User.query.filter_by(email=validated_data['email']).first():
        return jsonify({'message': 'Email already registered'}), 400

    # Create new user
    try:
        new_user = User(
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            phone_number=validated_data.get('phone_number'),
            date_of_birth=datetime.strptime(data['date_of_birth'], '%Y-%m-%d').date() if 'date_of_birth' in data else None
        )
        db.session.add(new_user)
        db.session.commit()
        
        # Generate tokens
        access_token = create_access_token(identity=new_user.id)
        refresh_token = create_refresh_token(identity=new_user.id)

        # Send welcome email (async)
        try:
            from app.utils.gmail_service import send_welcome_email
            send_welcome_email(new_user.email, new_user.first_name)
            print(f"Welcome email sent to {new_user.email}")
        except Exception as e:
            # Don't interrupt registration if email fails
            print(f"Error sending welcome email: {str(e)}")
            current_app.logger.error(f"Welcome email error: {str(e)}")

        return jsonify({
            'message': 'Registration successful',
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': new_user.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error creating user: {str(e)}'}), 500
```

### 2. Login Process

#### Complete Authentication Flow
```
1. User enters credentials
   ↓
2. Frontend validates form
   ↓
3. AuthService.login() called
   ↓
4. HTTP POST to /api/auth/login
   ↓
5. Backend validates credentials
   ↓
6. JWT token generated
   ↓
7. Token returned to frontend
   ↓
8. Token stored in SharedPreferences
   ↓
9. AuthProvider state updated
   ↓
10. UI navigates to main screen
```

#### Token Management
```dart
class AuthService {
  // Save token securely
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Auto-refresh expired tokens
  Future<Map<String, dynamic>> tryRefreshToken() async {
    final token = await getToken();
    if (token == null) return {'success': false};
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['access_token']);
      return {'success': true};
    }
    
    return {'success': false};
  }
}
```

### 3. Protected Route Access

#### Frontend Token Injection
```dart
Future<Map<String, dynamic>> makeAuthenticatedRequest(String endpoint) async {
  String? token = await _getToken();
  
  if (token == null) {
    // Redirect to login
    return {'success': false, 'message': 'Authentication required'};
  }
  
  final response = await http.get(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 401) {
    // Try to refresh token
    final refreshResult = await tryRefreshToken();
    if (refreshResult['success']) {
      // Retry original request
      return makeAuthenticatedRequest(endpoint);
    } else {
      // Redirect to login
      await logout();
      return {'success': false, 'message': 'Session expired'};
    }
  }
  
  return _handleResponse(response);
}
```

#### Backend Authentication Middleware
```python
@medication_bp.route('/', methods=['GET'])
@jwt_required()  # Middleware validates JWT
def get_medications():
    current_user_id = get_jwt_identity()
    
    # Access user context
    user = User.query.get(current_user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    # Business logic with user context
    medications = Medication.query.all()
    return jsonify({
        'medications': [med.to_dict() for med in medications]
    }), 200
```

---

## Data Flow Patterns

### 1. Medication Browsing Flow

#### Frontend Data Request
*File: `lib/utils/medication_service.dart` (lines 25-60)*
```dart
class MedicationService {
  Future<Map<String, dynamic>> getMedications({
    String? medicationType,
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': pageSize.toString(),
    };
    
    if (medicationType != null) queryParams['type'] = medicationType;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (searchQuery != null) queryParams['q'] = searchQuery;
    
    final uri = Uri.parse('$baseUrl/api/medications')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load medications');
    }
  }
}
```

#### Backend Data Processing
*File: `backend/app/routes/medications.py` (lines 15-50)*
```python
@medications_bp.route('/', methods=['GET'])
def get_medications():
    # Parse query parameters
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    medication_type = request.args.get('type')
    category_id = request.args.get('category_id', type=int)
    search_query = request.args.get('q')
    
    # Build database query
    query = Medication.query
    
    if medication_type:
        query = query.filter(Medication.type == medication_type)
    
    if category_id:
        query = query.filter(Medication.category_id == category_id)
    
    if search_query:
        query = query.filter(
            Medication.name.contains(search_query) |
            Medication.description.contains(search_query)
        )
    
    # Execute paginated query
    medications = query.paginate(
        page=page, 
        per_page=per_page, 
        error_out=False
    )
    
    return jsonify({
        'medications': [med.to_dict() for med in medications.items],
        'pagination': {
            'page': page,
            'pages': medications.pages,
            'per_page': per_page,
            'total': medications.total
        }
    }), 200
```

### 2. Shopping Cart Management

#### Frontend Cart State
*File: `lib/providers/cart_provider.dart` (lines 15-80)*
```dart
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  
  double get totalAmount => _items.fold(
    0.0, 
    (sum, item) => sum + (item.product.price * item.quantity)
  );
  
  Future<void> addToCart(Product product, int quantity) async {
    _isLoading = true;
    notifyListeners();
    
    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id
    );
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    // Sync with backend
    await _syncCartWithBackend();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _syncCartWithBackend() async {
    try {
      final cartData = _items.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
        'type': item.product.type,
      }).toList();
      
      await CartService().syncCart(cartData);
    } catch (e) {
      // Handle sync error - could implement offline mode
      print('Cart sync failed: $e');
    }
  }
}
```

### 3. Order Processing Flow

#### Complete Order Lifecycle
```
1. User adds items to cart (Local state + Backend sync)
   ↓
2. User initiates checkout
   ↓
3. Frontend validates cart contents
   ↓
4. Order data compiled and sent to backend
   ↓
5. Backend validates order and creates database record
   ↓
6. Payment processing (if applicable)
   ↓
7. Order confirmation email sent
   ↓
8. Frontend updates UI with order status
   ↓
9. Cart cleared on successful order
```

#### Frontend Order Creation
*File: `lib/utils/order_service.dart` (lines 29-70)*
```dart
Future<Map<String, dynamic>> createOrder({
  required List<CartItem> items,
  required int totalAmount,
  required String paymentMethod,
  required String deliveryAddress,
}) async {
  final token = await _getToken();
  
  final orderData = {
    'items': items.map((item) => {
      'product_id': item.product.id,
      'quantity': item.quantity,
      'price': item.product.price,
      'type': item.product.type,
      'name': item.product.name,
    }).toList(),
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'delivery_address': deliveryAddress,
  };
  
  // Try multiple server URLs for reliability
  for (String url in fallbackUrls) {
    try {
      final response = await http.post(
        Uri.parse('$url/api/orders/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      }
    } catch (e) {
      continue; // Try next server
    }
  }
  
  return {
    'success': false,
    'message': 'Unable to create order. Please try again.',
  };
}
```

---

## API Communication Protocols

### 1. HTTP Methods & Status Codes

#### RESTful Endpoint Design
```
GET    /api/medications     → List medications (200)
GET    /api/medications/:id → Get medication details (200)
POST   /api/medications     → Create medication (201) [Admin only]
PUT    /api/medications/:id → Update medication (200) [Admin only]
DELETE /api/medications/:id → Delete medication (204) [Admin only]

POST   /api/auth/register   → Register user (201)
POST   /api/auth/login      → Login user (200)
POST   /api/auth/refresh    → Refresh token (200)
POST   /api/auth/logout     → Logout user (200)

GET    /api/cart           → Get cart contents (200)
POST   /api/cart           → Add to cart (201)
PUT    /api/cart/:item_id  → Update cart item (200)
DELETE /api/cart/:item_id  → Remove from cart (204)

POST   /api/orders         → Create order (201)
GET    /api/orders         → List user orders (200)
GET    /api/orders/:id     → Get order details (200)
```

#### Error Response Standards
```python
# Validation Error (400)
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Invalid email format"],
    "password": ["Password too short"]
  }
}

# Authentication Error (401)
{
  "success": false,
  "message": "Invalid credentials"
}

# Authorization Error (403)
{
  "success": false,
  "message": "Admin access required"
}

# Not Found Error (404)
{
  "success": false,
  "message": "Resource not found"
}

# Server Error (500)
{
  "success": false,
  "message": "Internal server error",
  "error_id": "uuid-for-tracking"
}
```

### 2. Request/Response Patterns

#### Pagination Pattern
```dart
// Frontend request
final response = await http.get(
  Uri.parse('$baseUrl/api/medications?page=1&per_page=20')
);

// Backend response
{
  "medications": [...],
  "pagination": {
    "page": 1,
    "pages": 5,
    "per_page": 20,
    "total": 100,
    "has_next": true,
    "has_prev": false
  }
}
```

#### Search Pattern
```dart
// Frontend search request
final response = await http.get(
  Uri.parse('$baseUrl/api/medications?q=antibiotic&type=animal')
);

// Backend search logic
@medications_bp.route('/', methods=['GET'])
def search_medications():
    search_query = request.args.get('q', '').strip()
    medication_type = request.args.get('type')
    
    query = Medication.query
    
    if search_query:
        search_filter = or_(
            Medication.name.ilike(f'%{search_query}%'),
            Medication.description.ilike(f'%{search_query}%'),
            Medication.active_ingredient.ilike(f'%{search_query}%')
        )
        query = query.filter(search_filter)
    
    if medication_type:
        query = query.filter(Medication.type == medication_type)
    
    results = query.all()
    return jsonify({
        'medications': [med.to_dict() for med in results],
        'query': search_query,
        'count': len(results)
    })
```

---

## State Management

### 1. Provider Pattern Implementation

#### AuthProvider State Flow
```dart
class AuthProvider extends ChangeNotifier {
  // State variables
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  
  // State getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // State mutation with notification
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(email, password);
      
      if (result['success']) {
        _isAuthenticated = true;
        _userData = result['data'];
        await _saveUserData(result['data']);
      } else {
        _setError(result['message']);
      }
      
      return result['success'];
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Triggers UI rebuild
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners(); // Triggers UI rebuild
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners(); // Triggers UI rebuild
  }
}
```

#### UI State Binding
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              // Show loading indicator
              if (authProvider.isLoading)
                CircularProgressIndicator(),
              
              // Show error message
              if (authProvider.errorMessage != null)
                Text(
                  authProvider.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              
              // Login button
              ElevatedButton(
                onPressed: authProvider.isLoading 
                  ? null 
                  : () => _handleLogin(authProvider),
                child: authProvider.isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 2. Data Persistence Patterns

#### Local Storage Strategy
```dart
class StorageService {
  static const String USER_DATA_KEY = 'user_data';
  static const String AUTH_TOKEN_KEY = 'auth_token';
  static const String CART_ITEMS_KEY = 'cart_items';
  
  // Save user data locally
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_DATA_KEY, json.encode(userData));
  }
  
  // Retrieve user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(USER_DATA_KEY);
    
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
  
  // Cache cart items for offline functionality
  Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => item.toJson()).toList();
    await prefs.setString(CART_ITEMS_KEY, json.encode(itemsJson));
  }
}
```

---

## Error Handling Strategies

### 1. Network Error Handling

#### Frontend Error Recovery
```dart
class ApiService {
  Future<Map<String, dynamic>> makeRequest(String endpoint) async {
    try {
      // Try primary server
      final response = await _makeHttpRequest(_primaryUrl + endpoint);
      return _handleResponse(response);
    } on SocketException {
      // Network error - try backup servers
      return await _tryBackupServers(endpoint);
    } on TimeoutException {
      // Timeout - try with extended timeout
      return await _retryWithTimeout(endpoint);
    } on FormatException {
      // Invalid JSON response
      return {
        'success': false,
        'message': 'Invalid server response format',
      };
    } catch (e) {
      // Unexpected error
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
      };
    }
  }
  
  Future<Map<String, dynamic>> _tryBackupServers(String endpoint) async {
    for (String backupUrl in _backupUrls) {
      try {
        final response = await _makeHttpRequest(backupUrl + endpoint);
        if (response.statusCode < 500) {
          _primaryUrl = backupUrl; // Update primary for future requests
          return _handleResponse(response);
        }
      } catch (e) {
        continue; // Try next backup
      }
    }
    
    return {
      'success': false,
      'message': 'All servers unavailable. Please check your connection.',
    };
  }
}
```

#### Backend Error Logging
```python
import logging
import traceback
from functools import wraps

def handle_api_errors(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except ValidationError as e:
            current_app.logger.warning(f"Validation error in {f.__name__}: {e.messages}")
            return jsonify({
                'success': False,
                'message': 'Invalid input data',
                'errors': e.messages
            }), 400
        except SQLAlchemyError as e:
            db.session.rollback()
            current_app.logger.error(f"Database error in {f.__name__}: {str(e)}")
            return jsonify({
                'success': False,
                'message': 'Database operation failed'
            }), 500
        except Exception as e:
            current_app.logger.error(f"Unexpected error in {f.__name__}: {str(e)}")
            current_app.logger.error(traceback.format_exc())
            return jsonify({
                'success': False,
                'message': 'Internal server error'
            }), 500
    
    return decorated_function

# Usage
@medications_bp.route('/', methods=['POST'])
@jwt_required()
@handle_api_errors
def create_medication():
    # Function logic here
    pass
```

### 2. User Experience Error Handling

#### Graceful Degradation
```dart
class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;
  
  Future<void> loadMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _medicationService.getMedications();
      
      if (result['success']) {
        _medications = result['medications'];
        _isOfflineMode = false;
        await _cacheData(result['medications']); // Cache for offline
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      // Try to load from cache
      final cachedData = await _loadCachedData();
      if (cachedData.isNotEmpty) {
        _medications = cachedData;
        _isOfflineMode = true;
        _errorMessage = 'Showing cached data. Check your connection.';
      } else {
        _errorMessage = 'Unable to load medications: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Real-time Features

### 1. Notification System

#### Email Integration Flow
*File: `lib/services/email_service.dart` (lines 10-35)*
```dart
class EmailService {
  Future<bool> sendOrderConfirmation({
    required String userEmail,
    required String userName,
    required String orderId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/order-confirmation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'name': userName,
          'order_id': orderId,
          'items': items,
          'total_amount': totalAmount,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending order confirmation: $e');
      return false;
    }
  }
}
```

#### Backend Email Processing
*File: `backend/app/routes/notifications.py` (lines 15-50)*
```python
@notifications_bp.route('/order-confirmation', methods=['POST'])
def send_order_conf():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['email', 'name', 'order_id', 'items', 'total_amount']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing {field}'}), 400
        
        # Send email using Gmail API
        result = send_order_confirmation(
            email=data['email'],
            name=data['name'],
            order_id=data['order_id'],
            items=data['items'],
            total_amount=data['total_amount']
        )
        
        if result:
            return jsonify({'message': 'Order confirmation sent successfully'}), 200
        else:
            return jsonify({'error': 'Failed to send email'}), 500
            
    except Exception as e:
        current_app.logger.error(f"Order confirmation error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500
```

### 2. Live Data Updates

#### Admin Dashboard Real-time Data
*File: `lib/screens/admin/admin_dashboard_screen.dart` (conceptual implementation)*
```dart
class AdminDashboardProvider extends ChangeNotifier {
  Timer? _refreshTimer;
  Map<String, dynamic> _dashboardData = {};
  
  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      refreshDashboardData();
    });
  }
  
  Future<void> refreshDashboardData() async {
    try {
      final result = await _adminService.getDashboardData();
      if (result['success']) {
        _dashboardData = result['data'];
        notifyListeners(); // Update UI with new data
      }
    } catch (e) {
      // Handle error silently for background refresh
      print('Background refresh failed: $e');
    }
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

---

## Performance Optimization

### 1. Data Caching Strategies

#### Frontend Caching
*File: `lib/utils/cache_manager.dart` (conceptual implementation)*
```dart
class CacheManager {
  static const Duration CACHE_DURATION = Duration(hours: 1);
  static final Map<String, CacheEntry> _cache = {};
  
  static Future<T?> getOrFetch<T>(
    String key,
    Future<T> Function() fetchFunction,
  ) async {
    final cacheEntry = _cache[key];
    
    // Return cached data if still valid
    if (cacheEntry != null && !cacheEntry.isExpired) {
      return cacheEntry.data as T;
    }
    
    // Fetch new data
    try {
      final data = await fetchFunction();
      _cache[key] = CacheEntry(data, DateTime.now().add(CACHE_DURATION));
      return data;
    } catch (e) {
      // Return stale cache if available during error
      if (cacheEntry != null) {
        return cacheEntry.data as T;
      }
      throw e;
    }
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;
  
  CacheEntry(this.data, this.expiry);
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

#### Backend Caching
*File: `backend/app/utils/cache_decorator.py` (conceptual implementation)*
```python
from functools import wraps
from flask import current_app
import redis
import json

# Redis cache instance
cache = redis.Redis(host='localhost', port=6379, db=0)

def cached_route(timeout=300):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # Create cache key based on route and parameters
            cache_key = f"{request.endpoint}:{hash(frozenset(request.args.items()))}"
            
            # Try to get from cache
            cached_result = cache.get(cache_key)
            if cached_result:
                return json.loads(cached_result)
            
            # Execute function and cache result
            result = f(*args, **kwargs)
            cache.setex(cache_key, timeout, json.dumps(result))
            return result
        
        return decorated_function
    return decorator

# Usage
@medications_bp.route('/', methods=['GET'])
@cached_route(timeout=600)  # Cache for 10 minutes
def get_medications():
    # Expensive database operation
    medications = Medication.query.all()
    return jsonify([med.to_dict() for med in medications])
```

### 2. Lazy Loading Implementation

#### Frontend Pagination
*File: `lib/providers/infinite_scroll_provider.dart` (conceptual implementation)*
```dart
class InfiniteScrollProvider extends ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  
  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _medicationService.getMedications(
        page: _currentPage,
        pageSize: 20,
      );
      
      if (result['success']) {
        final newMedications = result['medications'] as List;
        _medications.addAll(newMedications.map((m) => Medication.fromJson(m)));
        _currentPage++;
        _hasMore = newMedications.length == 20; // Full page = more available
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Security Considerations

### 1. Token Security

#### Frontend Token Management
*File: `lib/utils/secure_token_manager.dart` (conceptual implementation)*
```dart
class SecureTokenManager {
  static const String TOKEN_KEY = 'auth_token';
  
  // Store token securely
  Future<void> storeToken(String token) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: TOKEN_KEY, value: token);
  }
  
  // Retrieve token securely
  Future<String?> getToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: TOKEN_KEY);
  }
  
  // Clear token on logout
  Future<void> clearToken() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: TOKEN_KEY);
  }
  
  // Validate token format before sending
  bool isValidTokenFormat(String token) {
    final parts = token.split('.');
    return parts.length == 3; // JWT has 3 parts
  }
}
```

#### Backend Token Validation
*File: `backend/app/utils/auth.py` (lines 45-80)*
```python
from functools import wraps
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt

def admin_required(f):
    @wraps(f)
    @jwt_required()
    def decorated_function(*args, **kwargs):
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user or not user.is_admin:
            return jsonify({'message': 'Admin access required'}), 403
        
        return f(*args, **kwargs)
    return decorated_function

def validate_token_freshness(f):
    @wraps(f)
    @jwt_required()
    def decorated_function(*args, **kwargs):
        jwt_data = get_jwt()
        
        # Check if token is too old for sensitive operations
        if sensitive_operation and jwt_data.get('fresh', False) == False:
            return jsonify({
                'message': 'Fresh token required for this operation'
            }), 401
        
        return f(*args, **kwargs)
    return decorated_function
```

### 2. Input Validation & Sanitization

#### Frontend Validation
*File: `lib/utils/validation_helper.dart` (conceptual implementation)*
```dart
class ValidationHelper {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'Password must contain uppercase, lowercase and number';
    }
    
    return null;
  }
  
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[^\w\s@.-]'), '') // Keep only safe characters
        .trim();
  }
}
```

#### Backend Validation
*File: `backend/app/schemas/schemas.py` (lines 10-70)*
```python
from marshmallow import Schema, fields, validate, ValidationError
import re

class UserRegistrationSchema(Schema):
    email = fields.Email(
        required=True,
        validate=validate.Length(max=120),
        error_messages={'invalid': 'Please provide a valid email address'}
    )
    
    password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=8, max=128),
            validate.Regexp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                error='Password must contain uppercase, lowercase and number'
            )
        ],
        load_only=True
    )
    
    first_name = fields.Str(
        required=True,
        validate=validate.Length(min=2, max=64),
        missing=None
    )
    
    phone_number = fields.Str(
        validate=validate.Regexp(
            r'^\+?[\d\s\-\(\)]{10,15}$',
            error='Please provide a valid phone number'
        ),
        missing=None
    )
    
    def validate_phone_sanitized(self, data, **kwargs):
        if 'phone_number' in data and data['phone_number']:
            # Remove non-digit characters except +
            phone = re.sub(r'[^\d+]', '', data['phone_number'])
            data['phone_number'] = phone
        return data

# Usage in route
@auth_bp.route('/register', methods=['POST'])
def register():
    schema = UserRegistrationSchema()
    try:
        validated_data = schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({
            'success': False,
            'message': 'Validation failed',
            'errors': err.messages
        }), 400
    
    # Proceed with validated data
```

---

## Conclusion

The Winal Drug Shop application demonstrates a well-architected frontend-backend interaction pattern that prioritizes:

1. **Reliability**: Multiple server fallbacks and robust error handling
2. **Security**: JWT authentication, input validation, and secure token storage
3. **Performance**: Caching strategies, lazy loading, and optimized API calls
4. **User Experience**: Offline capabilities, real-time updates, and graceful error recovery
5. **Maintainability**: Clean separation of concerns and consistent patterns

This architecture provides a solid foundation for scaling the application while maintaining high performance and security standards.

---

*Last Updated: May 24, 2025*
*Author: Winal Drug Shop Development Team*
