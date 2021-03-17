#!/bin/bash
export CROSS_COMPILE=x86_64-ubuntu16.04-linux-gnu
./build_tools.sh
export CROSS_COMPILE=arm-linux-gnueabihf
./build_tools.sh
export CROSS_COMPILE=aarch64-linux-gnu
./build_tools.sh
export CROSS_COMPILE=i686-ubuntu16.04-linux-gnu
./build_tools.sh
export CROSS_COMPILE=i686-w64-mingw32
./build_tools.sh
# macos does not need eudev
# CROSS_COMPILER is used to override the compiler 
export CROSS_COMPILER=o64-clang 
export CROSS_COMPILE=x86_64-apple-darwin13
./build_tools.sh
tar -czvf /workdir/tools.tar.gz /tmp/x86_64-apple-darwin13/ /tmp/aarch64-linux-gnu/ /tmp/arm-linux-gnueabihf/ /tmp/i686-ubuntu16.04-linux-gnu/ /tmp/i686-w64-mingw32/ /tmp/x86_64-ubuntu16.04-linux-gnu/