FROM ubuntu:latest

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y curl tar cmake build-essential git wget p7zip-full pkg-config clang dh-autoreconf gperf &&\
    # Install Windows cross-tools
    apt-get install -y mingw-w64 &&\
    apt-get clean
# Install toolchains in /opt
RUN curl downloads.arduino.cc/tools/internal/toolchains.tar.gz | tar -xz "opt"

# Set toolchains paths
# arm-linux-gnueabihf-gcc -> linux_arm
ENV PATH=/opt/arm-rpi-4.9.3-linux-gnueabihf/bin/:$PATH
# aarch64-linux-gnu-gcc -> linux_arm64
ENV PATH=/opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/:$PATH
# i686-ubuntu12.04-linux-gnu-gcc -> linux_386
ENV PATH=/opt/i686-ubuntu12.04-linux-gnu/bin/:$PATH
# x86_64-ubuntu12.04-linux-gnu-gcc -> linux_amd64
ENV PATH=/opt/x86_64-ubuntu12.04-linux-gnu/bin/:$PATH
# x86_64-ubuntu16.04-linux-gnu-gcc -> linux_amd64 with newer gcc
ENV PATH=/opt/x86_64-ubuntu16.04-linux-gnu-gcc/bin/:$PATH
# o64-clang -> darwin_amd64
ENV PATH=/opt/osxcross/target/bin/:$PATH

RUN mkdir -p /workdir
WORKDIR /workdir

# debug/utilities
RUN alias ll="ls -lah"
RUN apt-get install -y tree cmake-curses-gui nano

# Handle libusb and libudev
COPY deps/ /opt/lib/
ENV CROSS_COMPILE=x86_64-ubuntu16.04-linux-gnu
RUN /opt/lib/build_libs.sh
ENV CROSS_COMPILE=arm-rpi-4.9.3-linux-gnueabihf # FIX checking host system type... Invalid configuration `arm-rpi-4.9.3-linux-gnueabihf': machine `arm-rpi-4.9.3' not recognized \ configure: error: /bin/bash ./config.sub arm-rpi-4.9.3-linux-gnueabihf failed
RUN /opt/lib/build_libs.sh
ENV CROSS_COMPILE=gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu # FIX checking host system type... Invalid configuration `gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu': machine `gcc-linaro-7.2.1-2017.11-x86_64_aarch64' not recognized \ configure: error: /bin/bash ./config.sub gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu failed
RUN /opt/lib/build_libs.sh
#TODO missing darwin_amd64, linux_386 and windows_386

ENTRYPOINT ["/bin/bash"]