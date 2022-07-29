# How to patch

To generate a patch use `git`: `git diff > mypatch.patch` and save it in the `patch/` directory.

**Important things to notice**:

- if you whant to generate a patch for [`picotool`](https://github.com/raspberrypi/picotool) remember to name the patch `picotool_*.patch`
- same thing applies to [`elf2uf2`](https://github.com/raspberrypi/pico-sdk/tree/master/tools/elf2uf2)
- same thing applies to [`pioasm`](https://github.com/raspberrypi/pico-sdk/tree/master/tools/pioasm)

The CI will apply automagically the patches (if they are present in the `patches/` directory) and it will search them using the name. see [here](../.github/workflows/release.yml#L81-L83) and [here](../.github/workflows/release.yml#L97-L99) and [here](../.github/workflows/release.yml#L113-L115)
