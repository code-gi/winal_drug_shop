@echo off
echo Running Winal Drug Shop on connected Android device...

:: Check if device is connected
adb devices > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: ADB not found or not in PATH. Please install Android SDK platform tools.
    exit /b 1
)

:: Get list of connected devices
for /f "skip=1" %%a in ('adb devices') do (
    set device=%%a
    goto :found
)

:found
if not defined device (
    echo No Android devices connected. Please connect your device and enable USB debugging.
    exit /b 1
)

:: Extract just the device ID
for /f "tokens=1" %%a in ("%device%") do set deviceid=%%a

:: Run the app on the specific device
echo Running on device: %deviceid%
flutter run -d %deviceid%

pause