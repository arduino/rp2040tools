#!/bin/bash

if [ x$CROSS_COMPILER == x ]; then
CROSS_COMPILER=${CROSS_COMPILE}-gcc
else
export CC=$CROSS_COMPILER
fi
cd /opt/lib/libusb-1.0.20
export LIBUSB_DIR=`pwd`
./configure --prefix=${PREFIX} --disable-udev --enable-static --disable-shared --host=${CROSS_COMPILE}
make
make install

if [[ $CROSS_COMPILE == "i686-w64-mingw32" ]] ; then
  # libusb-compat is a mess to compile for win32
  # use a precompiled version from libusb-win32 project
  wget http://download.sourceforge.net/project/libusb-win32/libusb-win32-releases/1.2.6.0/libusb-win32-bin-1.2.6.0.zip
  unzip libusb-win32-bin-1.2.6.0.zip
  #mkdir -p $PREFIX/bin/
  #cp libusb-win32-bin-1.2.6.0/bin/x86/libusb0_x86.dll $PREFIX/bin/libusb0.dll
  cp libusb-win32-bin-1.2.6.0/include/lusb0_usb.h $PREFIX/include
  cp libusb-win32-bin-1.2.6.0/lib/gcc/libusb.a $PREFIX/lib
else

cd /opt/lib/libusb-compat-0.1.5
export LIBUSB0_DIR=`pwd`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" ./configure --prefix=${PREFIX} --enable-static --disable-shared --host=${CROSS_COMPILE}
make
make install

cd /opt/lib/libelf-0.8.13
export LIBELF_DIR=`pwd`
./configure --disable-shared --host=$CROSS_COMPILE --prefix=${PREFIX}
make
make install

cd /opt/lib/ncurses-5.9
export NCURSES_DIR=`pwd`
./configure --disable-shared --without-debug --without-ada --with-termlib --enable-termcap --host=$CROSS_COMPILE --prefix=${PREFIX}
make
make install.libs

cd /opt/lib/readline-6.3
export READLINE_DIR=`pwd`
autoconf
./configure --prefix=$PREFIX --disable-shared --host=$CROSS_COMPILE
make
make install-static

cd /opt/lib/eudev-3.2.10
./autogen.sh
./configure --enable-static --disable-gudev --disable-introspection  --disable-shared --disable-blkid --disable-kmod  --disable-manpages --prefix=$PREFIX --host=${CROSS_COMPILE}
make
make install

cd /opt/lib/hidapi
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
#set +e
#./bootstrap
./bootstrap
#set -e
./configure --prefix=$PREFIX --enable-static --disable-shared --host=$CROSS_COMPILE
make
make install


cd /opt/lib/libftdi1-1.4
mkdir build

CMAKE_EXTRA_FLAG="-DSHAREDLIBS=OFF -DBUILD_TESTS=OFF -DPYTHON_BINDINGS=OFF -DEXAMPLES=OFF -DFTDI_EEPROM=OFF"

if [[ $CROSS_COMPILE == "i686-w64-mingw32" ]] ; then
  CMAKE_EXTRA_FLAG="$CMAKE_EXTRA_FLAG -DCMAKE_TOOLCHAIN_FILE=./cmake/Toolchain-i686-w64-mingw32.cmake"
fi

cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" -DLIBUSB_INCLUDE_DIR="$PREFIX/include/libusb-1.0" -DLIBFTDI_LIBRARY_DIRS="$PREFIX/lib" -DLIBUSB_LIBRARIES="usb-1.0" ../
make
make install
