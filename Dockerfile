FROM openjdk:8-jdk

ARG sdk_version=sdk-tools-linux-4333796.zip
ARG android_home=/opt/android/sdk

RUN apt-get update && \
    apt-get install --yes \
        xvfb clang unzip lib32z1 lib32stdc++6 build-essential > /dev/null

# Download and install Android SDK
RUN curl --silent --show-error --location --fail --retry 3 --output /tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    mkdir -p ${android_home} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV ANDROID_HOME ${android_home}
ENV ANDROID_SDK_HOME ${android_home}
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}
ENV ADB_INSTALL_TIMEOUT 120

# Fix install warning
RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --licenses > /dev/null && sdkmanager --update > /dev/null

# Update SDK manager and install system image, platform and build tools
RUN sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator" \
  "extras;android;m2repository" \
  "extras;google;m2repository" \
  "extras;google;google_play_services" > /dev/null 2>&1

RUN sdkmanager \
  "build-tools;25.0.3" \
  "build-tools;26.0.2" \
  "build-tools;27.0.3" > /dev/null 2>&1

RUN sdkmanager "platforms;android-27" > /dev/null 2>&1

#install ndk
RUN sdkmanager \
  "lldb;3.0" \
  "cmake;3.6.4111459" > /dev/null 2>&1

ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK /opt/android-ndk
ENV NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r17c
ENV PATH ${ANDROID_NDK_HOME}:$PATH

RUN mkdir /opt/android-ndk-tmp && \
  cd /opt/android-ndk-tmp && \
  wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
  unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
  mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
  cd ${ANDROID_NDK_HOME} && \
  rm -rf /opt/android-ndk-tmp

RUN apt-get install git ant python-dev ruby zip subversion -y > /dev/null

#install buck and checkout jsc
RUN wget "https://github.com/facebook/buck/releases/download/v2018.10.17.01/buck.2018.10.17.01_all.deb" > /dev/null 2>&1 && \
  dpkg -i buck.2018.10.17.01_all.deb > /dev/null 2>&1 && \
  buck --version && \
  svn export https://svn.webkit.org/repository/webkit/trunk/@174650 > /dev/null
