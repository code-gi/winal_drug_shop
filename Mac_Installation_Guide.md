# Mac Installation Guide for Android Development

This guide will help you set up your Mac for Android development in simple, easy-to-follow steps.

## What You'll Need

- A Mac computer with macOS
- Internet connection
- Administrator privileges on your Mac

## Step 1: Install Homebrew

Homebrew is a package manager for Mac that makes installing software easier.

1. Open Terminal (find it in Applications > Utilities > Terminal)
2. Paste this command and press Enter:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Follow the prompts on the screen
4. After installation, make sure Homebrew is working by typing:

```
brew --version
```

## Step 2: Install Java Development Kit (JDK)

Android requires Java to run. We'll install JDK 11, which works well with current Android development.

```
brew tap adoptopenjdk/openjdk
brew install --cask adoptopenjdk11
```

After installation, set up JAVA_HOME by adding this to your shell profile:

1. Open Terminal
2. Open your profile file using:
   ```
   nano ~/.zshrc
   ```
   (If you use bash, use `~/.bash_profile` instead)

3. Add this line:
   ```
   export JAVA_HOME=$(/usr/libexec/java_home -v 11)
   ```

4. Save the file (press Ctrl+O, then Enter, then Ctrl+X)
5. Load the updated profile:
   ```
   source ~/.zshrc
   ```
   (or `source ~/.bash_profile` for bash users)

6. Verify Java is installed correctly:
   ```
   java -version
   ```

## Step 3: Install Android Command Line Tools

1. Download the latest Command Line Tools from Android's website:
   - Go to https://developer.android.com/studio#command-tools
   - Scroll down to "Command line tools only"
   - Download the Mac version

2. Create a directory for the Android SDK:
   ```
   sudo mkdir -p /usr/local/share/android-sdk
   sudo chmod -R 777 /usr/local/share/android-sdk
   ```

3. Extract the downloaded zip file and move the contents to the SDK directory:
   ```
   unzip commandlinetools-mac-*.zip
   mkdir -p /usr/local/share/android-sdk/cmdline-tools/latest
   mv cmdline-tools/* /usr/local/share/android-sdk/cmdline-tools/latest/
   ```

## Step 4: Set Up Environment Variables

1. Open your profile file again:
   ```
   nano ~/.zshrc
   ```
   (or `~/.bash_profile` for bash)

2. Add these lines:
   ```
   export ANDROID_HOME=/usr/local/share/android-sdk
   export ANDROID_SDK_ROOT=/usr/local/share/android-sdk
   export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

3. Save and exit (Ctrl+O, Enter, Ctrl+X)
4. Load the updated profile:
   ```
   source ~/.zshrc
   ```
   (or `source ~/.bash_profile` for bash)

## Step 5: Install Android SDK Components

1. Accept all licenses:
   ```
   yes | sdkmanager --licenses
   ```

2. Install the basic SDK components:
   ```
   sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"
   ```

3. Verify installation:
   ```
   sdkmanager --list
   ```

## Step 6: Install an Emulator (Optional)

If you want to test your apps without a physical device:

1. Install the emulator package:
   ```
   sdkmanager "emulator"
   ```

2. Install a system image (this is like the Android OS for your virtual device):
   ```
   sdkmanager "system-images;android-30;google_apis;x86_64"
   ```

3. Create a virtual device:
   ```
   avdmanager create avd -n test_device -k "system-images;android-30;google_apis;x86_64" -d "pixel_5"
   ```

4. Start the emulator:
   ```
   emulator -avd test_device
   ```

## Troubleshooting

### If commands aren't found:
Make sure your PATH variables are set correctly by typing:
```
echo $PATH
```

### If you get permission errors:
Try running commands with `sudo`

### If the emulator is slow:
Install hardware acceleration:
```
sdkmanager "extras;intel;Hardware_Accelerated_Execution_Manager"
```

## Next Steps

- Install [Flutter](https://flutter.dev/docs/get-started/install/macos) if you're developing Flutter apps
- Install Android Studio for a full IDE experience: `brew install --cask android-studio`

## Help Resources

- [Official Android Documentation](https://developer.android.com/docs)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/android)
- [Flutter Documentation](https://flutter.dev/docs)
