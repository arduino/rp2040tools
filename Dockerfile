FROM ubuntu:latest

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
# TODO add --no-install-recommends
    apt-get install -y \
        build-essential \
        # Intall clang compiler used by macos
        clang \
        cmake \
        curl \
        dh-autoreconf \
        git \
        gperf \
        # various libs required to compile osxcross
        libxml2-dev \
        libssl-dev \
        libz-dev \
        # liblzma5 \
        # Install Windows cross-tools
        mingw-w64 \
        p7zip-full \
        pkg-config \
        tar \
        # xz-utils \
    && rm -rf /var/lib/apt/lists/*
# Install toolchains in /opt
RUN curl downloads.arduino.cc/tools/internal/toolchains.tar.gz | tar -xz "opt" && \
    curl downloads.arduino.cc/tools/internal/i686-ubuntu16.04-linux-gnu.tar.gz | tar -xzC /opt && \
    # Remove useless toolchains:
    rm -r /opt/arm-rpi-4.9.3-linux-gnueabihf/ && \
    rm -r /opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/ && \
    rm -r /opt/*ubuntu12.04* && \
    #install proper arm toolchains
    curl -L 'https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz' | tar -xJC /opt && \
    curl -L 'https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz' | tar -xJC /opt

# install macos10.15 sdk
COPY MacOSX10.15.sdk.tar.xz /opt/osxcross/tarballs/
# remove old unused macos10.09 sdk because we are using 10.15 one
RUN rm -rf /opt/osxcross/tarballs/MacOSX10.9.sdk.tar.bz2 && \
    cd /opt/osxcross; git pull; UNATTENDED=1 SDK_VERSION=10.15 ./build.sh
# Set toolchains paths
# arm-linux-gnueabihf-gcc -> linux_arm
ENV PATH=/opt/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/bin/:$PATH
# aarch64-linux-gnu-gcc -> linux_arm64
ENV PATH=/opt/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/bin/:$PATH
# x86_64-ubuntu16.04-linux-gnu-gcc -> linux_amd64
ENV PATH=/opt/x86_64-ubuntu16.04-linux-gnu-gcc/bin/:$PATH
# i686-ubuntu16.04-linux-gnu-gcc -> linux_386
ENV PATH=/opt/i686-ubuntu16.04-linux-gnu/bin/:$PATH
# o64-clang -> darwin_amd64
ENV PATH=/opt/osxcross/target/bin/:$PATH

RUN mkdir -p /workdir
WORKDIR /workdir

# Handle libusb and libudev compilation and merging
COPY deps/ /opt/lib/
# compiler name is arm-linux-gnueabihf-gcc '-gcc' is added by ./configure
RUN CROSS_COMPILE=x86_64-ubuntu16.04-linux-gnu /opt/lib/build_libs.sh && \
    CROSS_COMPILE=arm-linux-gnueabihf /opt/lib/build_libs.sh && \
    CROSS_COMPILE=aarch64-linux-gnu /opt/lib/build_libs.sh && \
    CROSS_COMPILE=i686-ubuntu16.04-linux-gnu /opt/lib/build_libs.sh && \
    CROSS_COMPILE=i686-w64-mingw32 /opt/lib/build_libs.sh && \
    # macos does not need eudev
    # CROSS_COMPILER is used to override the compiler 
    CROSS_COMPILER=o64-clang CROSS_COMPILE=x86_64-apple-darwin13 /opt/lib/build_libs.sh

ENTRYPOINT ["/bin/bash"]