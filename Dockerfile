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
# i686-ubuntu16.04-linux-gnu-gcc: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.33' not found ⬇️
RUN curl downloads.arduino.cc/tools/internal/i686-ubuntu16.04-linux-gnu.tar.gz | tar -xzC /opt
# Remove useless toolchains:
RUN rm -r /opt/arm-rpi-4.9.3-linux-gnueabihf/
RUN rm -r /opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/
RUN rm -r /opt/*ubuntu12.04*
#install proper arm toolchains
RUN wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz | tar -xJC /opt
RUN wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz | tar -xJC /opt

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

# debug/utilities
RUN alias ll="ls -lah"
RUN apt-get install -y tree cmake-curses-gui nano

# Handle libusb and libudev
COPY deps/ /opt/lib/
# compiler name is arm-linux-gnueabihf-gcc '-gcc' is added by ./configure
ENV CROSS_COMPILE=x86_64-ubuntu16.04-linux-gnu
RUN /opt/lib/build_libs.sh
ENV CROSS_COMPILE=arm-linux-gnueabihf
RUN /opt/lib/build_libs.sh
ENV CROSS_COMPILE=aarch64-linux-gnu
RUN /opt/lib/build_libs.sh
ENV CROSS_COMPILE=i686-ubuntu16.04-linux-gnu
RUN /opt/lib/build_libs.sh
#TODO missing darwin_amd64 and windows_386

ENTRYPOINT ["/bin/bash"]