# rp2040tools

This repo contains all the tools used by Arduino to upload compiled code to the boards that use the rp2040 processor.

## Tools

- [**picotool**](https://github.com/raspberrypi/picotool): a tool for interacting with a RP2040 device in BOOTSEL mode, or with a RP2040 binary
- [**elf2uf2**](https://github.com/raspberrypi/pico-sdk/tree/master/tools/elf2uf2): a tool to convert binary format
- **rp2040load** is a go tool which orchestrates the other two

## CI
The CI is responsible for building and uploading the tools
The [release workflow](https://github.com/arduino/rp2040tools/blob/master/.github/workflows/release.yml) is divided in:

- a job which uses a docker container (called crossbuild) with all the toolchains inside required to cross-compile the two tools from raspberry pi. The binaries produced are as static and self-contained as possible.
- a job that cross-compiles the go tool called rp2040load.
- one last job used to move in the correct folders the binaries and to `tar.bz2` them and upload them in the [github release page](https://github.com/arduino/rp2040tools/releases) and on s3 download server.
