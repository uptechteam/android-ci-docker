FROM openjdk:8-jdk
MAINTAINER Dima Kovalenko "dima.kovalenko@uptech.team"

# Install Deps
RUN apt-get update && apt-get install -y --force-yes expect git wget tar unzip lib32stdc++6 lib32z1

ENV ANDROID_TARGET_SDK="25" \
    ANDROID_BUILD_TOOLS="25.0.0" \
    ANDROID_SDK_TOOLS="24.4.1"

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS}-linux.tgz && tar xzf android-sdk.tgz && rm -f android-sdk.tgz && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN mkdir $ANDROID_HOME/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> $ANDROID_HOME/licenses/android-sdk-license

# Install sdk elements
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter android-${ANDROID_TARGET_SDK}
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter platform-tools
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter build-tools-${ANDROID_BUILD_TOOLS}
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter extra-google-play-services
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter extra-android-m2repository
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter extra-google-m2repository
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter extra-android-support
RUN echo y | $ANDROID_HOME/tools/android update sdk --all --no-ui --filter addon-google_apis_x86-google-21

RUN which adb
RUN which android

# Cleaning
RUN apt-get clean

# Install fastlane
RUN apt-get update
RUN apt-get install -y build-essential libssl-dev sudo
RUN wget http://ftp.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz && \ 
    tar -xzvf ruby-2.4.0.tar.gz && cd ruby-2.4.0/ && ./configure && make && sudo make install
RUN ruby -v
RUN gem install bundler --no-ri --no-rdoc
RUN gem install fastlane --no-ri --no-rdoc

# GO to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace