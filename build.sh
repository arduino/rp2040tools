#!/bin/bash -ex
#temporary fix for osx
export PATH=$PATH:/usr/local/Cellar/pkg-config/0.29.2/bin/

# rm -rf *

# wget https://github.com/libusb/libusb/releases/download/v1.0.24/libusb-1.0.24.7z
# 7z x libusb-1.0.24.7z -olibusb-1.0.24
# does not contains the .a lib but only the .h

git clone https://github.com/libusb/libusb.git
cd libusb
export LIBUSB_DIR=`pwd`
./configure --enable-static --disable-shared --host=${CROSS_COMPILE} # do not work
make clean
make
cd ..

git clone https://github.com/raspberrypi/pico-sdk.git
git clone https://github.com/raspberrypi/picotool.git

export PICO_SDK_PATH=$PWD/pico-sdk

#linux x86_64
cd picotool
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=x86_64-ubuntu12.04-linux-gnu-gcc .. # missing libUSB
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