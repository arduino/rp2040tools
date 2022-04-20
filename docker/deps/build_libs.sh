#!/bin/bash -ex

export PREFIX=/opt/lib/${CROSS_COMPILE}

if [ x$CROSS_COMPILER == x ]; then
CROSS_COMPILER=${CROSS_COMPILE}-gcc
else
export CC=$CROSS_COMPILER
export CXX=$CROSS_COMPILER++
fi
cd /opt/lib/libusb-1.0.20
export LIBUSB_DIR=`pwd`
./configure --prefix=${PREFIX} --disable-udev --enable-static --disable-shared --host=${CROSS_COMPILE}
make
make install

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

if [[ $CROSS_COMPILE == "i686-w64-mingw32" ]] ; then
  # libusb-compat is a mess to compile for win32
  # use a precompiled version from libusb-win32 project
  curl http://download.sourceforge.net/project/libusb-win32/libusb-win32-releases/1.2.6.0/libusb-win32-bin-1.2.6.0.zip -o libusb-win32-bin-1.2.6.0.zip -L
  unzip libusb-win32-bin-1.2.6.0.zip
  #mkdir -p $PREFIX/bin/
  #cp libusb-win32-bin-1.2.6.0/bin/x86/libusb0_x86.dll $PREFIX/bin/libusb0.dll
  cp libusb-win32-bin-1.2.6.0/include/lusb0_usb.h $PREFIX/include
  cp libusb-win32-bin-1.2.6.0/lib/gcc/libusb.a $PREFIX/lib
else
  if [[ $CROSS_COMPILE == "x86_64-apple-darwin13" ]]; then
    export LIBUSB_1_0_CFLAGS=-I${PREFIX}/include/libusb-1.0
    export LIBUSB_1_0_LIBS="-L${PREFIX}/lib -lusb-1.0"
  fi
  cd /opt/lib/libusb-compat-0.1.5
  export LIBUSB0_DIR=`pwd`
  PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" ./configure --prefix=${PREFIX} --enable-static --disable-shared --host=${CROSS_COMPILE}
  make
  make install
fi

cd /opt/lib/libftdi1-1.4
rm -rf build && mkdir build && cd build

CMAKE_EXTRA_FLAG="-DSHAREDLIBS=OFF -DBUILD_TESTS=OFF -DPYTHON_BINDINGS=OFF -DEXAMPLES=OFF -DFTDI_EEPROM=OFF"

if [[ $CROSS_COMPILE == "i686-w64-mingw32" ]] ; then
  CMAKE_EXTRA_FLAG="$CMAKE_EXTRA_FLAG -DCMAKE_TOOLCHAIN_FILE=./cmake/Toolchain-i686-w64-mingw32.cmake"
fi

cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" $CMAKE_EXTRA_FLAG -DLIBUSB_INCLUDE_DIR="$PREFIX/include/libusb-1.0" -DLIBFTDI_LIBRARY_DIRS="$PREFIX/lib" -DLIBUSB_LIBRARIES="usb-1.0" ../
make
make install

cd /opt/lib/libelf-0.8.13
export LIBELF_DIR=`pwd`
./configure --disable-shared --host=$CROSS_COMPILE --prefix=${PREFIX}
make
make install

echo "*****************"
file ${PREFIX}/lib/*
echo "*****************"

export CPPFLAGS="-P"

cd /opt/lib/ncurses-5.9
export NCURSES_DIR=`pwd`

./configure $EXTRAFLAGS --disable-shared --without-debug --without-ada --with-termlib --enable-termcap --without-manpages --without-progs --without-tests --host=$CROSS_COMPILE --prefix=${PREFIX}
make
make install.libs

cd /opt/lib/readline-8.0
export READLINE_DIR=`pwd`
./configure --prefix=$PREFIX --disable-shared --host=$CROSS_COMPILE
make
make install-static

if [[ $CROSS_COMPILE != "i686-w64-mingw32" && $CROSS_COMPILE != "x86_64-apple-darwin13" ]] ; then
cd /opt/lib/eudev-3.2.10
./autogen.sh
./configure --enable-static --disable-gudev --disable-introspection --disable-shared --disable-blkid --disable-kmod --disable-manpages --prefix=$PREFIX --host=${CROSS_COMPILE}
make
make install
fi

cd /opt/lib/hidapi
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
./bootstrap
./configure --prefix=$PREFIX --enable-static --disable-shared --host=$CROSS_COMPILE
make
make install