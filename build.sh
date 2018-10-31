#!/bin/sh

PLATFORM=$1
PLATFORM_BUCKCONFIG="armv7, arm64, x86, x86_64"
PLATFORM_BUCK_ASM="'android-armv7', 'android-arm64', 'android-x86', 'android-x86_64'"

if [ "$PLATFORM" = "32" ]; then
  PLATFORM_BUCKCONFIG="armv7, x86"
  PLATFORM_BUCK_ASM="'android-armv7', 'android-x86'"
elif [ "$PLATFORM" = "64" ]; then
  PLATFORM_BUCKCONFIG="arm64, x86_64"
  PLATFORM_BUCK_ASM="'android-arm64', 'android-x86_64'"
fi

sed -i "s#cpu_abis = armv7, arm64, x86, x86_64#cpu_abis = $PLATFORM_BUCKCONFIG#" .buckconfig
sed -i "s#for platform in ('android-armv7', 'android-arm64', 'android-x86', 'android-x86_64'):#for platform in ($PLATFORM_BUCK_ASM):#" jsc/BUCK

buck build :android-jsc
git checkout .buckconfig jsc/BUCK
