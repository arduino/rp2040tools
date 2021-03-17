#!/bin/bash

if [ x$CROSS_COMPILER == x ]; then
CROSS_COMPILER=${CROSS_COMPILE}-gcc
else
export CC=$CROSS_COMPILER
fi
# udev lib not required for macos
if [[ ${CROSS_COMPILE} != *apple* ]]; then
cd /opt/lib/eudev-3.2.10
export UDEV_DIR=`pwd`
./autogen.sh
./configure --enable-static --disable-shared --disable-blkid --disable-kmod  --disable-manpages --host=${CROSS_COMPILE}
make clean
make -j4
cd ..
export CFLAGS="-I$UDEV_DIR/src/libudev/"
export LDFLAGS="-L$UDEV_DIR/src/libudev/.libs/"
export LIBS="-ludev"
fi
cd /opt/lib/libusb-1.0.20
export LIBUSB_DIR=`pwd`
./configure --enable-static --disable-shared --host=${CROSS_COMPILE}
make clean
make
cd ..
# libusbudev.a merged not required for macos
if [[ ${CROSS_COMPILE} != *apple* ]]; then
mkdir -p ${CROSS_COMPILE}/libusb
mkdir -p ${CROSS_COMPILE}/libudev
cd ${CROSS_COMPILE}/libusb/
ar -x ../../libusb-1.0.20/libusb/.libs/libusb-1.0.a
cd ../libudev/
ar -x ../../eudev-3.2.10/src/libudev/.libs/libudev.a
cd ..
ar -qc libusbudev.a libudev/* libusb/*
fi
