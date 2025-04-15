<<<<<<< HEAD
# Winal Drug Shop

A comprehensive Flutter application for a pharmacy that provides both human and animal medications, along with additional services.

![Flutter Version](https://img.shields.io/badge/Flutter-3.29.2-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)

## About

Winal Drug Shop is a mobile application that allows users to browse, search, and purchase medications for both humans and animals. The app also offers features like chat consultation with pharmacists, video calls, farm activity management, and notifications for medication reminders.

## Features

- **Authentication**: 
  - **Login**: Secure JWT-based authentication
  - **Sign-up**: Create new accounts with form validation
  - **Password Recovery**: Reset password via email
  - **Profile Management**: View and update user information (Coming Soon)
- **Medication Catalog**: 
  - Browse medications for humans and animals
  - View medication images, details, prices, and stock availability
  - Filter medications by category
  - Check medication's prescription requirements
- **Communication**: Chat with pharmacists and make video calls for consultation
- **Farm Activities**: Track and manage farm-related activities
- **Notifications**: Get reminders and updates
- **Location Services**: Find nearby pharmacies using Google Maps

## Screenshots

<!-- Add screenshots here once available -->

## Using the Application

### Browsing Medications

1. **Home Screen**: After logging in, you'll see the main dashboard with various options.
2. **Medication Types**: Choose between "Human Medications" or "Animal Medications" sections.
3. **Categories**: Browse medications by category (e.g., Antibiotics, Painkillers, etc.)
4. **Medication Details**: Tap on any medication to view:
   - Medication images
   - Full description and details
   - Price and availability
   - Dosage instructions
   - Side effects and contraindications
   - Storage instructions

### Managing Prescriptions

Some medications require prescriptions. For these:
1. Upload your prescription through the app
2. Wait for verification by our pharmacists
3. Once approved, you can purchase the medication

### Troubleshooting

If you see "No medications found" when browsing:
- Check your internet connection
- Ensure the backend server is running
- Try refreshing the page
- Contact support if the issue persists

## Tech Stack

- Flutter (SDK 3.29.2)
- Dart (3.0.0+)
- State Management: Provider/Bloc
- Google Maps for location features
- Image handling with image_picker
- Speech recognition capabilities

## Dependencies

- cupertino_icons: ^1.0.8
- font_awesome_flutter: ^10.8.0
- carousel_slider: ^5.0.0
- image_picker: ^1.1.2
- permission_handler: ^11

## Running the Project

Once you have completed the setup above:

1. **Start the Backend Server**:
   ```bash
   cd D:\projects\winal_drug_shop\backend
   
   # Activate virtual environment
   venv\Scripts\activate  # Windows
   # OR
   source venv/bin/activate  # macOS/Linux
   
   # First-time setup (only needed once)
   pip install -r requirements.txt
   flask db upgrade
   python populate_db.py
   
   # Run the server
   flask run --host=0.0.0.0
   ```
   The backend will be available at `http://your_ip_address:5000`

2. **Update API Base URL**:
   Open `lib/utils/medication_service.dart` and update the `baseUrl` to match your computer's IP address:
   ```dart
   final String baseUrl = 'http://your_ip_address:5000';
   ```

3. **Run the Flutter Application**:
   ```bash
   cd D:\projects\winal_drug_shop
   flutter run
   ```
   
   If multiple devices are connected, you'll be prompted to select one.

4. For specific platforms:
   ```bash
   flutter run -d chrome     # For web
   flutter run -d windows    # For Windows
   flutter run -d [device-id] # For a specific device
   ```
=======
# winal_drug_shop
>>>>>>> 45f462f58ee19778ce463c2136b5ca3b19cd6158
