# Dependencies
The `deps/` folder contains the dependencies used to build and link statically `picotool` and `elf2uf2`: the libraries `libusb` and `libudev`.
The `deps/` folder contains also a bash script used by the docker container to successfully build them with different toolchains and with different targets.
This way they are already compiled and usable by the CI during the building/linking phase!

They come respectively from [here](https://github.com/arduino/OpenOCD-build-script/tree/static/libusb-1.0.20)
and from [here](https://github.com/gentoo/eudev)

## `build_libs.sh`
`build_libs.sh` is used by the [Dockerfile](../Dockerfile#L49-L55):
Basically during the docker build phase the libraries are compiled with every toolchain available in the Docker container. Other libraries can be added, the [`build_libs.sh`](build_libs.sh) script needs to be adapted, but the Dockerfile should be ok.

## libusbudev
libusbudev is the result of merging the two `.a` files with a command line tool called `ar`. This is done to ease the linking phase done by the [CI](.github/workflows/release.yml#L87) passing a single static library. See `LIBUSBUDEV` env variable [here](../../.github/workflows/release.yml#L67) and [here](../../.github/workflows/release.yml#L71).
For macos is not required to merge the two libraries because libudev is not a requirement, so macos uses `libusb.a` only: thus the distinction between the two platforms. Infact libusb for mac is the last one built in the [Dockerfile](../Dockerfile#L55).

`libusbudev.a` is created by the `build_libs.sh` the directory structure created is the following:

```
/opt/lib/
|-- aarch64-linux-gnu
|   |-- libudev
|   |-- libusb
|   `-- libusbudev.a
|-- arm-linux-gnueabihf
|   |-- libudev
|   |-- libusb
|   `-- libusbudev.a
|-- build_libs.sh
|-- eudev-3.2.10
|-- i686-ubuntu16.04-linux-gnu
|   |-- libudev
|   |-- libusb
|   `-- libusbudev.a
|-- i686-w64-mingw32
|   |-- libudev
|   |-- libusb
|   `-- libusbudev.a
|-- libusb-1.0.20
`-- x86_64-ubuntu16.04-linux-gnu
    |-- libudev
    |-- libusb
    `-- libusbudev.a
```

The original `libusb.a` is available in `/opt/lib/libusb-1.0.20/libusb/.libs/libusb-1.0.a`
and `libudev.a` is available in `/opt/lib/eudev-3.2.10/src/libudev/.libs/libudev.a`
