# Winal Drug Shop

A comprehensive Flutter application for a pharmacy that provides both human and animal medications, along with additional services.

![Flutter Version](https://img.shields.io/badge/Flutter-3.29.2-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)

## About

Winal Drug Shop is a mobile application that allows users to browse, search, and purchase medications for both humans and animals. The app also offers features like chat consultation with pharmacists, video calls, farm activity management, and notifications for medication reminders.

## Features

- **Authentication**: Login, Sign-up, and Password Recovery
- **Medication Catalog**: Browse medications for humans and animals
- **Communication**: Chat with pharmacists and make video calls for consultation
- **Farm Activities**: Track and manage farm-related activities
- **Notifications**: Get reminders and updates
- **Location Services**: Find nearby pharmacies using Google Maps

## Screenshots

<!-- Add screenshots here once available -->

## Tech Stack

- Flutter (SDK 3.29.2)
- Dart (3.0.0+)
- State Management: Provider/Bloc (specify which one you use)
- Google Maps for location features
- Image handling with image_picker
- Speech recognition capabilities

## Dependencies

- cupertino_icons: ^1.0.8
- font_awesome_flutter: ^10.8.0
- carousel_slider: ^5.0.0
- image_picker: ^1.1.2
- permission_handler: ^11.4.0
- speech_to_text: ^7.0.0
- google_maps_flutter: ^2.12.0
- geolocator: ^13.0.3

## Getting Started

### Prerequisites

- Flutter SDK (3.29.2 or compatible version)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android Emulator / iOS Simulator / Physical device
- Google Maps API Key (for location features)

### Development Environment Setup

Based on the Flutter Doctor output, you need to complete the following setup:

1. **Android SDK Setup**:
   
   If you encounter the error "Android sdkmanager not found", follow these steps:
   
   a. Download the command-line tools from [Android Studio downloads page](https://developer.android.com/studio#command-tools)
   
   b. Extract the downloaded zip file
   
   c. Create the following directory structure in your Android SDK location (typically found at `%LOCALAPPDATA%\Android\Sdk` or wherever you installed it):
   ```
   [Android SDK location]/cmdline-tools/latest/
   ```
   
   d. Move the contents of the extracted zip into this `latest` folder
   
   e. Add the following to your PATH environment variable:
   ```
   [Android SDK location]/cmdline-tools/latest/bin
   ```
   
   f. Restart your terminal/command prompt and try again:
   ```bash
   flutter doctor --android-licenses
   ```

2. **For Windows App Development** (optional):
   - Install Visual Studio with "Desktop development with C++" workload from [Visual Studio downloads](https://visualstudio.microsoft.com/downloads/)

3. **Android Studio** (recommended for Android development):
   - Install from [Android Studio website](https://developer.android.com/studio)

### Installation

1. Clone the repository
   ```bash
   https://github.com/code-gi/winal_drug_shop.git
   cd winal_drug_shop
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure API Keys
   - For Google Maps, create a file `lib/utils/api_keys.dart` with your API key:
     ```dart
     const String googleMapsApiKey = 'YOUR_API_KEY';
     ```

4. Run the application
   ```bash
   flutter run
   ```

## Running the Project

Once you have completed the setup above:

1. Connect your development device:
   - Physical Android device (ensure USB debugging is enabled)
   - Android emulator (can be launched from Android Studio)
   - iOS simulator (Mac only)
   - Chrome browser (for web development)

2. Navigate to the project directory:
   ```bash
   cd D:\projects\winal_drug_shop
   ```

3. Run the application:
   ```bash
   flutter run
   ```
   
   If multiple devices are connected, you'll be prompted to select one.

4. For specific platforms:
   ```bash
   flutter run -d chrome     # For web
   flutter run -d windows    # For Windows
   flutter run -d [device-id] # For a specific device
   ```

## Building for Production

### Android

```bash
flutter build apk --release
```
or for app bundle:
```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```
Then archive and upload using Xcode.

### Web

```bash
flutter build web --release
```

## Project Structure

```
lib/
  ├── main.dart             # Entry point
  ├── screens/              # UI screens
  │   ├── login_screen.dart
  │   ├── medications_screen.dart
  │   ├── animal_medications.dart
  │   ├── human_medications.dart
  │   └── ...
  ├── utils/               # Utilities and constants
  │   └── constants.dart
  └── ...
```

## Troubleshooting

If you encounter any issues with Flutter setup:

1. Ensure your Flutter version matches the project requirements:
   ```bash
   flutter --version
   ```
   Current project uses Flutter 3.29.2

2. If you see unauthorized device errors:
   - Check your physical device for an authorization dialog
   - For Android devices, ensure USB debugging is enabled

3. For complete environment diagnostics:
   ```bash
   flutter doctor -v
   ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

<!-- Specify your license here -->

## Acknowledgements

<!-- Add any acknowledgements here -->

## Contact

<!-- Add contact information here -->
