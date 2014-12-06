#!/bin/bash

echo "Building libffi ============================="

. $(dirname $0)/utils.sh

set -x

if [ ! -f $CACHEROOT/libffi-$FFI_VERSION.tar.gz ]; then
    try curl -L ftp://sourceware.org/pub/libffi/libffi-$FFI_VERSION.tar.gz > $CACHEROOT/libffi-$FFI_VERSION.tar.gz 
fi
if [ ! -d $TMPROOT/libffi-$FFI_VERSION ]; then
    try rm -rf $TMPROOT/libffi-$FFI_VERSION
    try tar xvf $CACHEROOT/libffi-$FFI_VERSION.tar.gz -C $TMPROOT
fi

# lib not found, compile it
pushd $TMPROOT/libffi-$FFI_VERSION

# libffi needs to use "-miphoneos-version-min=6.0" for xcode 6+ to compile it correctly
sed -i.bak s/-miphoneos-version-min=5.1.1/-miphoneos-version-min=6.0/g generate-darwin-source-and-headers.py

try xcodebuild -project libffi.xcodeproj -target "libffi-iOS" -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH clean
try xcodebuild -project libffi.xcodeproj -target "libffi-iOS" -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH


BC=$RENIOSBUILDCONFIGURATION-$SDKBASENAME
try cp build/$BC/libffi.a $BUILDROOT/lib/libffi.a
try mkdir -p $BUILDROOT/include/ffi
try cp build_$SDKBASENAME-${RENIOSARCH%s}/include/*.h  $BUILDROOT/include/ffi
popd
