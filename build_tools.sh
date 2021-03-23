#!/bin/bash
#before running this script export CROSS_COMPILE and eventually CROSS_COMPILER env vars
cd /tmp
mkdir -p ${CROSS_COMPILE}

# apt install libfl-dev -y

if [ ! -d 'pico-sdk' ]; then
git clone https://github.com/raspberrypi/pico-sdk.git
fi
if [ ! -d 'picotool' ]; then
git clone https://github.com/raspberrypi/picotool.git
fi

export PICO_SDK_PATH=$PWD/pico-sdk
export LIBUSB_DIR=/opt/lib/libusb-1.0.20/libusb/
if [[ ${CROSS_COMPILE} != *apple* ]]; then
CROSS_COMPILER=${CROSS_COMPILE}-gcc
export LIBUSBUDEV=/opt/lib/$CROSS_COMPILE/libusbudev.a
else
export LIBUSBUDEV=$LIBUSB_DIR.libs/libusb-1.0.a
fi

if [[ ${CROSS_COMPILE} == *mingw* ]]; then
export CFLAGS="-mno-ms-bitfields $CFLAGS"
fi

cd picotool
git reset --hard
if [[ ${CROSS_COMPILE} != *apple* ]]; then
git apply /workdir/patches/picotool_cmakelists.patch # TODO apply only one time and if ! macos
fi
if [[ ${CROSS_COMPILE} == *mingw* ]]; then
git apply /workdir/patches/windows_mingw.patch # maybe apply not only on win 🤷‍♂️
fi
rm -rf build
mkdir build
cd build
if [[ ${CROSS_COMPILE} != *apple* ]]; then
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILE-gcc -DCMAKE_CXX_COMPILER=$CROSS_COMPILE-g++ -DLIBUSB_LIBRARIES=$LIBUSBUDEV -DLIBUSB_INCLUDE_DIR=$LIBUSB_DIR ..
else
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILER -DCMAKE_CXX_COMPILER=$CROSS_COMPILER++ -DCMAKE_CXX_FLAGS="-framework IOKit -framework Cocoa" -DLIBUSB_LIBRARIES=$LIBUSBUDEV -DLIBUSB_INCLUDE_DIR=$LIBUSB_DIR ..
fi
make
if [[ ${CROSS_COMPILE} == *mingw* ]]; then
cp picotool.exe ../../$CROSS_COMPILE
else
cp picotool ../../$CROSS_COMPILE
fi
cd ..
cd ..

cd pico-sdk/tools/elf2uf2/
git reset --hard
if [[ ${CROSS_COMPILE} != *apple* ]]; then
git apply /workdir/patches/elf2uf2_cmakelists.patch
fi
rm -rf build
mkdir build
cd build
if [[ ${CROSS_COMPILE} != *apple* ]]; then
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILE-gcc -DCMAKE_CXX_COMPILER=$CROSS_COMPILE-g++ ..
else
cmake -DCMAKE_C_COMPILER=$CROSS_COMPILER -DCMAKE_CXX_COMPILER=$CROSS_COMPILER++ -DCMAKE_CXX_FLAGS="-framework IOKit -framework Cocoa" ..
fi
make
if [[ ${CROSS_COMPILE} == *mingw* ]]; then
cp elf2uf2.exe ../../../../$CROSS_COMPILE #exe for win
else
cp elf2uf2 ../../../../$CROSS_COMPILE #exe for win
fi
cd ..
cd ..
cd ..
