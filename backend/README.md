# Winal Drug Shop - Backend API

This backend API serves the Winal Drug Shop application, providing authentication, data storage, and business logic for both the animal and human medication sections of the app.

## Technology Stack

- **Framework**: Flask (Python)
- **Database**: SQLite (development), PostgreSQL (production)
- **Authentication**: JWT (JSON Web Tokens)
- **API Documentation**: Swagger/OpenAPI
- **Deployment**: Render.com 

## Project Structure

```
backend/
├── app/
│   ├── __init__.py         # Flask application factory
│   ├── config.py           # Configuration settings
│   ├── models/             # Database models
│   │   ├── __init__.py
│   │   ├── user.py         # User model for authentication
│   │   ├── animal_meds.py  # Animal medications models
│   │   ├── human_meds.py   # Human medications models
│   │   └── cart.py         # Shopping cart model
│   ├── routes/             # API endpoints
│   │   ├── __init__.py
│   │   ├── auth.py         # Authentication routes
│   │   ├── animal_meds.py  # Animal medications routes
│   │   ├── human_meds.py   # Human medications routes
│   │   └── cart.py         # Shopping cart routes
│   ├── schemas/            # Serialization schemas
│   │   ├── __init__.py
│   │   └── schemas.py
│   └── utils/              # Utility functions
│       ├── __init__.py
│       ├── auth.py         # Authentication helpers
│       └── validators.py   # Input validation
├── migrations/             # Database migrations
├── tests/                  # Unit and integration tests
├── .env                    # Environment variables (not in version control)
├── .env.example            # Example environment variables
├── .gitignore              # Git ignore file
├── requirements.txt        # Python dependencies
└── run.py                  # Application entry point
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
  - **Request**: 
    ```json
    {
      "email": "user@example.com",
      "password": "SecurePass123",
      "first_name": "John",
      "last_name": "Doe",
      "phone_number": "1234567890",
      "date_of_birth": "1990-01-01"
    }
    ```
  - **Response (201)**: 
    ```json
    {
      "message": "User registered successfully",
      "user": {
        "id": 1,
        "email": "user@example.com",
        "first_name": "John",
        "last_name": "Doe"
      }
    }
    ```

- `POST /api/auth/login` - Login and receive JWT token
  - **Request**: 
    ```json
    {
      "email": "user@example.com",
      "password": "SecurePass123"
    }
    ```
  - **Response (200)**: 
    ```json
    {
      "message": "Login successful",
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": 1,
        "email": "user@example.com",
        "first_name": "John",
        "last_name": "Doe"
      }
    }
    ```

- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - Logout (invalidate token)
- `POST /api/auth/reset-password` - Request password reset
- `POST /api/auth/reset-password/<token>` - Reset password with token

### User Profile Management

- `GET /api/users/me` - Get current user profile
  - **Response (200)**:
    ```json
    {
      "id": 1,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone_number": "1234567890",
      "date_of_birth": "1990-01-01",
      "created_at": "2025-03-29T08:00:00Z"
    }
    ```

- `PUT /api/users/me` - Update current user profile
  - **Request**:
    ```json
    {
      "first_name": "Johnny",
      "last_name": "Doe",
      "phone_number": "9876543210"
    }
    ```
  - **Response (200)**:
    ```json
    {
      "message": "Profile updated successfully",
      "user": {
        "id": 1,
        "email": "user@example.com",
        "first_name": "Johnny",
        "last_name": "Doe",
        "phone_number": "9876543210",
        "date_of_birth": "1990-01-01"
      }
    }
    ```

### Animal Medications

- `GET /api/animal-meds` - List all animal medications
- `GET /api/animal-meds/<id>` - Get specific animal medication
- `POST /api/animal-meds` - Add new animal medication (admin only)
- `PUT /api/animal-meds/<id>` - Update animal medication (admin only)
- `DELETE /api/animal-meds/<id>` - Delete animal medication (admin only)

### Human Medications

- `GET /api/human-meds` - List all human medications
- `GET /api/human-meds/<id>` - Get specific human medication
- `POST /api/human-meds` - Add new human medication (admin only)
- `PUT /api/human-meds/<id>` - Update human medication (admin only)
- `DELETE /api/human-meds/<id>` - Delete human medication (admin only)

### Shopping Cart

- `GET /api/cart` - View shopping cart
- `POST /api/cart` - Add item to cart
- `PUT /api/cart/<item_id>` - Update cart item quantity
- `DELETE /api/cart/<item_id>` - Remove item from cart
- `POST /api/cart/checkout` - Process checkout

### Orders

- `GET /api/orders` - List user's orders
- `GET /api/orders/<id>` - Get specific order details
- `POST /api/orders/<id>/cancel` - Cancel an order (if eligible)

## Database Options

### 1. SQLite
- **Pros**: Simple setup, zero configuration, file-based
- **Cons**: Limited concurrent access, not suitable for high traffic
- **Best for**: Development and testing

### 2. PostgreSQL
- **Pros**: Robust, reliable, supports complex queries, widely supported
- **Cons**: Requires more setup, potential costs for managed services
- **Best for**: Production use
- **Free Options**: 
  - Render.com (free tier: 1GB storage)
  - Railway.app (limited free tier)
  - ElephantSQL (free tier: 20MB)
  - Supabase (free tier with PostgreSQL)

### 3. MongoDB
- **Pros**: Flexible schema, good for rapid development, JSON-like documents
- **Cons**: Not ideal for complex relationships between data
- **Best for**: Projects with evolving data models
- **Free Options**:
  - MongoDB Atlas (free tier: 512MB)

### 4. Firebase Realtime Database or Firestore
- **Pros**: Real-time updates, managed service, easy to integrate
- **Cons**: Query limitations, potentially expensive at scale
- **Best for**: Real-time applications
- **Free Options**:
  - Firebase Spark Plan (free tier with limitations)

## Authentication Flow

1. **Registration**:
   - User submits email, password, and profile details
   - Server validates input and checks for existing email
   - Password is hashed using bcrypt and user record created
   - Success response with user details (excluding password)
   - **Implementation**: `register()` function in `app/routes/auth.py`

2. **Login**:
   - User submits email and password
   - Server validates credentials using bcrypt password verification
   - JWT token is generated with Flask-JWT-Extended
   - Response includes access token, refresh token, and user details
   - Token stored in client (localStorage/SecureStorage)
   - **Implementation**: `login()` function in `app/routes/auth.py`

3. **Token Refresh**:
   - Frontend sends refresh token before access token expires
   - Server validates refresh token and generates new JWT
   - New access token is returned
   - **Implementation**: `refresh()` function in `app/routes/auth.py`

4. **Password Reset**:
   - User requests password reset with email
   - Server validates email and generates time-limited reset token
   - Reset link sent to user's email (mock implementation for development)
   - User sets new password using token
   - Password updated after validation
   - **Implementation**: `reset_password_request()` and `reset_password()` in `app/routes/auth.py`

5. **Profile Management (Upcoming)**:
   - User retrieves profile information using JWT authentication
   - User updates profile information with validation
   - **Required Implementation**: Add endpoints to `app/routes/users.py`

## Development Roadmap

### Database Population

```
python populate_db.py

# Populate farm activities data
python populate_farm_activities.py
```

### Current Status
- ✅ User Authentication (Register, Login, Logout)
- ✅ Password Reset Endpoints
- ✅ Medication Browsing

### Next Steps
1. **Profile Management (In Progress)**
   - Implement user profile retrieval endpoint
   - Implement profile update functionality
   - Add profile picture upload capability
   - Create Flutter UI for profile screen

2. **Shopping Cart**
   - Implement cart persistence
   - Add item quantity management
   - Calculate pricing and discounts

3. **Checkout Process**
   - Implement order creation
   - Add payment method integration
   - Create order history tracking

4. **Admin Dashboard**
   - Medication inventory management
   - User management interface
   - Order processing dashboard

## Troubleshooting

### Common Authentication Issues

1. **"Invalid email or password" Error**
   - Ensure credentials are correct (case-sensitive)
   - Check if user exists in database
   - Verify password hashing implementation

2. **Token Expiration Issues**
   - Default access token expiration is 15 minutes
   - Implement proper token refresh on the frontend
   - Check JWT_ACCESS_TOKEN_EXPIRES in configuration

3. **CORS Issues with Authentication**
   - Ensure frontend domain is whitelisted in CORS configuration
   - Check that credentials are included in CORS requests
   - Verify proper headers are set in requests

## Database Structure

### Medications and Images

The application uses multiple related tables to store medication information:

- **categories**: Defines medication categories for both human and animal medications
- **medications**: Stores all medication details including name, description, price, etc.
- **medication_images**: Links images to specific medications

```
medications
├── id                     # Primary key
├── name                   # Medication name
├── description            # Short description
├── full_details           # Detailed information
├── price                  # Price in local currency
├── stock_quantity         # Available quantity
├── medication_type        # 'human' or 'animal'
├── category_id            # Foreign key to categories
├── requires_prescription  # Boolean flag
├── dosage_instructions    # How to take the medication
├── contraindications      # When not to use
├── side_effects           # Potential side effects
├── storage_instructions   # How to store
└── timestamps             # created_at, updated_at

medication_images
├── id                     # Primary key
├── medication_id          # Foreign key to medications
├── image_url              # Path to image file
├── is_primary             # Boolean flag for main image
└── created_at             # Timestamp
```

## Image Handling

The application serves medication images from the assets folder. The migration script automatically links these images to their corresponding medications in the database.

### Available Endpoints for Medication Images

- `GET /api/medications/{id}/images` - Get all images for a specific medication
  - **Response (200)**:
    ```json
    {
      "images": [
        {
          "id": 1,
          "medication_id": 1,
          "image_url": "assets/images/antibiotics.jpeg",
          "is_primary": true,
          "created_at": "2025-03-29T12:00:00Z"
        }
      ]
    }
    ```

### How to Use Medication Images in Frontend

1. The Flutter app should fetch medication data including the image URLs
2. Image paths should be resolved relative to the app's asset directory
3. For network images, prefix with the API base URL

Example Flutter code for displaying a medication image:
```dart
Image.asset(
  medication.imageUrl,
  fit: BoxFit.cover,
)
```

### Displaying Medications

When implementing the medication display screens, use the following API endpoints:

- `GET /api/medications?type=human` - Get all human medications with their images
- `GET /api/medications?type=animal` - Get all animal medications with their images

## Development Roadmap

### Database Population

```
python populate_db.py

# Populate farm activities data
python populate_farm_activities.py
```