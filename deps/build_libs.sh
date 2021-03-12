#!/bin/bash
cd /opt/lib/eudev-3.1.5
export UDEV_DIR=`pwd`
./autogen.sh
./configure --enable-static --disable-shared --disable-blkid --disable-kmod  --disable-manpages --host=${CROSS_COMPILE}
make clean
make -j4
cd ..
export CFLAGS="-I$UDEV_DIR/src/libudev/"
export LDFLAGS="-L$UDEV_DIR/src/libudev/.libs/"
export LIBS="-ludev"
cd libusb-1.0.20
export LIBUSB_DIR=`pwd`
./configure --enable-static --disable-shared --host=${CROSS_COMPILE}
make clean
make
cd ..
mkdir -p ${CROSS_COMPILE}/libusb
mkdir -p ${CROSS_COMPILE}/libudev
cd ${CROSS_COMPILE}/libusb/
ar -x ../../libusb-1.0.20/libusb/.libs/libusb-1.0.a
cd ../libudev/
ar -x ../../eudev-3.1.5/src/libudev/.libs/libudev.a
cd ..
ar -qc libusbudev.a libudev/* libusb/*