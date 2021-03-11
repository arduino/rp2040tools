#!/bin/bash -ex
#temporary fix for osx
export PATH=$PATH:/usr/local/Cellar/pkg-config/0.29.2/bin/


apt install libfl-dev
# rm -rf *
export CROSS_COMPILE=x86_64-ubuntu12.04-linux-gnu
cd deps/eudev-3.1.5
export UDEV_DIR=`pwd`
./autogen.sh
./configure --enable-static --disable-shared --disable-blkid --disable-kmod  --disable-manpages --host=${CROSS_COMPILE}
make clean
make -j4
cd ..

export CFLAGS="-I$UDEV_DIR/src/libudev/"
export LDFLAGS="-L$UDEV_DIR/src/libudev/.libs/"
export LIBS="-ludev"


# too recent they want c11 support
# wget https://github.com/libusb/libusb/releases/download/v1.0.24/libusb-1.0.24.7z # production version
# wget https://github.com/libusb/libusb/releases/download/v1.0.24/libusb-1.0.24.tar.bz2 # developement version
# 7z x libusb-1.0.24.7z -olibusb-1.0.24-p # the one with .h
# tar -xf libusb-1.0.24.tar.bz2

cd libusb-1.0.20
export LIBUSB_DIR=`pwd`
./configure --enable-static --disable-shared --host=${CROSS_COMPILE}
make clean
make
cd ..

# export LIBUSB1_CFLAGS="-I$LIBUSB_DIR/libusb/"
# export LIBUSB1_LIBS="-L$LIBUSB_DIR/libusb/.libs/ -lusb-1.0 -lpthread"

# export LIBUSB_1_0_CFLAGS="-I$LIBUSB_DIR/libusb/"
# export LIBUSB_1_0_LIBS="-L$LIBUSB_DIR/libusb/.libs/ -lusb-1.0 -lpthread"


git clone https://github.com/raspberrypi/pico-sdk.git
git clone https://github.com/raspberrypi/picotool.git

export PICO_SDK_PATH=$PWD/pico-sdk

#linux x86_64
cd picotool
mkdir build
cd build
#need to find a way to add the libudev.a
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILE-gcc -DCMAKE_CXX_COMPILER=$CROSS_COMPILE-g++ -DLIBUSB_LIBRARIES=$LIBUSB_DIR/libusb/.libs/libusb-1.0.a -DLIBUSB_INCLUDE_DIR=$LIBUSB_DIR/libusb/ ..
make
cd ..
cd ..

cd pico-sdk/tools/elf2uf2/
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=x86_64-ubuntu12.04-linux-gnu-gcc ..
make
cd ..
cd ..
cd ..

# OK, it works
# deps:
# ldd elf2uf2
#         linux-vdso.so.1 (0x00007fffe09e0000)
#         libstdc++.so.6 => /lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007fb5f4d1e000)
#         libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007fb5f4d03000)
#         libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb5f4b11000)
#         libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fb5f49c2000)
#        /lib64/ld-linux-x86-64.so.2 (0x00007fb5f4f13000)