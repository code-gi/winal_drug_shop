> Here is a high level overview for what you need to do to get most of an Android environment setup and maintained.

Here the SDK is under `/usr/local/share/android-sdk` because I may switch to a different Catalina user in the future, but it works fine under `/Users/<your_user>/Library/Android/sdk` as well.

## Prerequisites:

See for brew, python3 and NodeJS on nvm see gist https://gist.github.com/agrcrobles/3d945b165871c355b6f169c317958e3e

## Java 14 

> Open JDK 14 works fine with gradle 6.x

To install the JDKs 8 ( LTS ) from AdoptOpenJDK:

    # brew tap adoptopenjdk/openjdk

    brew cask install adoptopenjdk/openjdk/adoptopenjdk8


> Do not follow this step if installed adoptopenjdk8

    brew cask install java8

Export JAVA_HOME on your bash profile or zshrc

    export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home

### SDK Manager
> Or try Command line tools | Android

Use Command line tools or SDK Manager

Quick reminder: Have as many build tools as you want, have one platform tool with backwards compatibility :=)

Download and Install Command line tools for mac ( not the android studio unless I need it )

https://developer.android.com/studio#cmdline-tools

https://developer.android.com/studio/command-line

https://developer.android.com/studio/command-line/sdkmanager

Use Homebrew to install Android dev tools:
Note that Java8 is tricky since licence changed: https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac

    brew install gradle
    brew cask install android-sdk
    
Optional

    brew install ant
    brew install maven
    brew cask install android-ndk


https://developer.android.com/studio#cmdline-tools

Install all of the Android SDK components (you will be prompted to agree to license info and then this will take a while to run):

If you need to have openjdk first in your PATH run:
  echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc

For compilers to find openjdk you may need to set:
  export CPPFLAGS="-I/usr/local/opt/openjdk/include"


### Build tools 28

```
touch ~/.android/repositories.cfg
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-28"
sdkmanager --no_https --install 'build-tools;28'
sdkmanager --no_https --install emulator
sdkmanager --list
```

### Build tools 29
```
touch ~/.android/repositories.cfg
yes | sdkmanager --licenses
sdkmanager --update
sdkmanager --no_https --install emulator
sdkmanager --no_https --install platform-tools
sdkmanager --no_https --install 'system-images;android-29;google_apis_playstore;x86_64'
sdkmanager --no_https --install 'extras;intel;Hardware_Accelerated_Execution_Manager'
sdkmanager --no_https --install 'build-tools;29.0.2'
sdkmanager --no_https --install 'platforms;android-29'
sdkmanager --list
```

### Edit for build tools 23

    touch ~/.android/repositories.cfg
    sdkmanager "platform-tools" "platforms;android-23"
    sdkmanager "build-tools;23.0.1"
    
Install HAXM for blazing fast emulators.  Check out the "Configuring VM Acceleration on Mac" section here: http://developer.android.com/tools/devices/emulator.html
    
    brew cask install intel-haxm // this might not work on high sierra.
    
*Edit:* You can download the dmg and install manually from Intel's site

Install emulators? Nga copied from https://gist.github.com/gasolin/9300f5f9276b2df884c80da3e2c54ffc

    sdkmanager --no_https --install emulator
    sdkmanager --no_https --install platform-tools
    sdkmanager --no_https --install 'system-images;android-29;google_apis_playstore;x86_64'
    sdkmanager --no_https --install 'extras;intel;Hardware_Accelerated_Execution_Manager'
    sdkmanager --update
    sdkmanager --list
   
### Ammend for android-29
Create and run virtual devices? Nga copied from https://gist.github.com/gasolin/9300f5f9276b2df884c80da3e2c54ffc

    avdmanager list (find device skin id, lets use pixel 17)
    avdmanager create avd -f -n test -d 17 -k 'system-images;android-29;google_apis_playstore;x86_64'
    avdmanager list avd (or emulator -list-avds)
    
    /usr/local/share/android-sdk/emulator/emulator -avd test

## Update your environment variables:

### android-28 / android-30

sdk can be installed on /Library/Android/sdk or /usr/local/ to be sure check it by

    which sdkmanager
    
### Export ANDROID_HOME

    export ANDROID_HOME=$HOME/Library/Android/sdk

or

    export ANDROID_HOME="/usr/local/share/android-sdk"


Both locations are valid ones from what I am aware of :)

### android-23
    export ANT_HOME=/usr/local/opt/ant
    export MAVEN_HOME=/usr/local/opt/maven
    export GRADLE_HOME=/usr/local/opt/gradle
    export ANDROID_HOME=/usr/local/share/android-sdk
    export ANDROID_SDK_ROOT=/usr/local/share/android-sdk
    export ANDROID_NDK_HOME=/usr/local/share/android-ndk
    export INTEL_HAXM_HOME=/usr/local/Caskroom/intel-haxm
    
    
### ... update paths

Update your paths (bonus points to a better solution to the hardcoded build tools version):

#### android-28 / android-30

To Copy paste, It's a good idea double check your paths anyways.

    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/tools
    export PATH=$PATH:$ANDROID_HOME/tools/bin
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    

#### android-23

    export PATH=$ANT_HOME/bin:$PATH
    export PATH=$MAVEN_HOME/bin:$PATH
    export PATH=$GRADLE_HOME/bin:$PATH
    export PATH=$ANDROID_HOME/tools:$PATH
    export PATH=$ANDROID_HOME/platform-tools:$PATH
    
### Optional: Build tool version specific export

### For build-tools/23.0.1

    export PATH=$ANDROID_HOME/build-tools/23.0.1:$PATH

### For build-tools/28.0.3
    
    export PATH=$ANDROID_HOME/build-tools/28.0.3:$PATH
    
    
Suggested: You will have to add the ANDROID_HOME to the profile configuration settings either on .zshrc, .bashrc or .bash_profile 

If `emulator` doesn't run, i am here to remind you to provide access into System Preferences - Security & Privacy

### Important: Ide is Optional

Optional, install android studio or intellij ide, point your sdk, java_home, build and platform tools to the already installed ones.


### Android NDK

TODO

### adb cheatsheet

https://gist.github.com/HugoMatilla/f92682b06068b06a6f2a

### Creating an android AVD

https://stackoverflow.com/a/44172716/6716408

### More helpfull Resources

https://glacion.com/2019/04/06/AVD.html


Happy code
