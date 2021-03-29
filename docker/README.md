# Docker crossbuild

This docker container has been created to allow us to easily crosscompile the c++ tools starting from this repo. The idea comes from [multiarch/crossbuild](https://github.com/multiarch/crossbuild), but this container unfortunately is outdated, the apt sources are no longer available.

## Starting Image
The starting image is [ubuntu:latest](https://hub.docker.com/_/ubuntu) (The ubuntu:latest tag points to the "latest LTS", since that's the version recommended for general use.) at the time of writing latest points to Ubuntu 20.04 focal.

The starting image is only marginally important, since internally we use manually installed toolchains.

## The Toolchains
The toolchains are download from http://downloads.arduino.cc/tools/internal/toolchains.tar.gz .
Inside that archive there are:
- **gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu** toolchain to crosscompile for *linux_arm64* (downloaded from [here](https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz))
- **gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf** toolchain used to crosscompile for *linux_arm* (downloaded from [here](https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz))
- **i686-ubuntu16.04-linux-gnu** toolchain to crosscompile for *linux_386* (32bit)
- **x86_64-ubuntu16.04-linux-gnu-gcc** toolchain to crosscompile for *linux_amd64*
- [**osxcross**](https://github.com/tpoechtrager/osxcross) toolchain to crosscompile for *darwin_amd64*. Inside `osxcross/tarballs/` there is already `MacOSX10.15.sdk.tar.xz`: the SDK required by macos to crosscompile (we tried with SDK version 10.09 but it was too old)

Regarding the two ubuntu toolchains: in the beginning we tried to use the ones shipped with 12.04 but they caused some build errors because they were too old, so we upgraded to 16.04 ones. They are created using [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng).


Apparently, osxcross does not have tags or version so we checkout a specific commit in order to have a pinned environment.

The last toolchain required to crosscompile for windows is `mingw-w64` and it's installed through `apt` along with other useful packages.

Once the toolchains are installed in `/opt` we add the binaries to the `PATH` env variable, to easily call them in the CI.

## Copying and Building Libraries
As explained in the other [`README.md`](deps/README.md) there are some libraries that needs to be compiled. This is achieved by copying `deps/` directory inside `/opt/lib/` in the container and then by using [`build_libs.sh`](deps/build_libs.sh) script [here](Dockerfile#L47-L55)

## Multi-stage build
To reduce the overall dimesion of the docker image we used the  [multi-stage build](https://learnk8s.io/blog/smaller-docker-images). 

## How to build and use the container
Usefull commands you can use:
- `docker build -t ghcr.io/arduino/crossbuild:<version> docker/` to build the container
- `docker push ghcr.io/arduino/crossbuild:<version>` to push the image to [github remote registry](https://docs.github.com/en/packages/guides/container-guides-for-github-packages)
- `docker run -it --name crossbuild -v $PWD:/workdir ghcr.io/arduino/crossbuild:<version>` to get a shell inside the container and use the toolchains available inside (like the CI does).
