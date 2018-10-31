#!/bin/sh

ROOTDIR=$(dirname "$0")
cd $ROOTDIR
BUCK_AAR_PATH="$ROOTDIR/build/android-jsc.aar"

rm -rf "$ROOTDIR/build/jni"

unzip $BUCK_AAR_PATH "jni/*" -d "$ROOTDIR/build"

# Remove c++_shared binaries from AAR. This is due to gradle inability to
# handle native libraries with conflicting names coming from multiple
# dependecies. See https://code.google.com/p/android/issues/detail?id=158630
# Referenced from install.sh
find "$ROOTDIR/build" -name "libc++_shared.so" -delete

./gradlew createAAR
