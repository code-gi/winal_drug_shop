@echo off
echo Setting up Winal Drug Shop development environment...

:: Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Flutter not found! Please install Flutter first from https://flutter.dev/docs/get-started/install
    exit /b 1
)

:: Install dependencies
echo Installing Flutter dependencies...
flutter pub get

:: Guide to fix Android SDK issues
echo.
echo ===================================
echo ANDROID SDK SETUP GUIDE
echo ===================================
echo If you encounter "Android sdkmanager not found" error:
echo.
echo 1. Download Android command-line tools from:
echo    https://developer.android.com/studio#command-tools
echo.
echo 2. Extract the zip file
echo.
echo 3. Create this folder structure in your Android SDK location:
echo    [Android SDK location]/cmdline-tools/latest/
echo.
echo 4. Move the extracted contents into the 'latest' folder
echo.
echo 5. Add this to your PATH environment variable:
echo    [Android SDK location]/cmdline-tools/latest/bin
echo.
echo 6. Restart your terminal and run:
echo    flutter doctor --android-licenses
echo.
echo ===================================

:: Ask user if they want to configure the Android SDK path
set /p CONFIGURE_SDK="Do you want to configure the Android SDK path now? (y/n): "
if /i "%CONFIGURE_SDK%"=="y" (
    set /p SDK_PATH="Enter your Android SDK path (e.g., C:\Users\YourName\AppData\Local\Android\Sdk): "
    
    :: Create the necessary directories if they don't exist
    if not exist "%SDK_PATH%\cmdline-tools" (
        mkdir "%SDK_PATH%\cmdline-tools"
    )
    if not exist "%SDK_PATH%\cmdline-tools\latest" (
        mkdir "%SDK_PATH%\cmdline-tools\latest"
    )
    
    echo.
    echo Created directory structure at %SDK_PATH%\cmdline-tools\latest
    echo.
    echo Now download and extract the command-line tools to this location.
    echo After extraction, ensure the 'bin' folder is directly inside the 'latest' folder.
    echo.
    echo Then add %SDK_PATH%\cmdline-tools\latest\bin to your PATH variable.
)

echo.
echo Setup guide completed! Once Android SDK is properly configured:
echo 1. Run 'flutter doctor' to verify your setup
echo 2. Run 'flutter run' to launch the Winal Drug Shop app
echo.

pause