#!/bin/bash -ex
#before running this script export CROSS_COMPILE env var with the desired compiler
cd /tmp
mkdir -p ${CROSS_COMPILE}

apt install libfl-dev -y

if [ ! -d 'pico-sdk' ]; then
git clone https://github.com/raspberrypi/pico-sdk.git
fi
if [ ! -d 'picotool' ]; then
git clone https://github.com/raspberrypi/picotool.git
fi

export PICO_SDK_PATH=$PWD/pico-sdk
export LIBUSB_DIR=/opt/lib/libusb-1.0.20/libusb/
export LIBUSBUDEV=/opt/lib/$CROSS_COMPILE/libusbudev.a

if [[ ${CROSS_COMPILE} == *mingw* ]]; then
export CFLAGS="-mno-ms-bitfields $CFLAGS"
fi

cd picotool
git apply /workdir/patches/picotool_cmakelists.patch # TODO apply only one time
if [[ ${CROSS_COMPILE} == *mingw* ]]; then
git apply /workdir/patches/windows_mingw.patch # maybe apply not only on win 🤷‍♂️
fi
rm -rf build
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILE-gcc -DCMAKE_CXX_COMPILER=$CROSS_COMPILE-g++ -DLIBUSB_LIBRARIES=$LIBUSBUDEV -DLIBUSB_INCLUDE_DIR=$LIBUSB_DIR ..
make
cp picotool ../../$CROSS_COMPILE #exe for win
cd ..
cd ..

cd pico-sdk/tools/elf2uf2/
git apply /workdir/patches/elf2uf2_cmakelists.patch
rm -rf build
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILE-gcc -DCMAKE_CXX_COMPILER=$CROSS_COMPILE-g++ ..
make
cp elf2uf2 ../../../../$CROSS_COMPILE #exe for win
cd ..
cd ..
cd ..
