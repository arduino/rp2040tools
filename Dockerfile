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

# debug/utility
RUN alias ll="ls -lah"
RUN apt-get install -y tree

ENTRYPOINT ["/bin/bash"]