# VMAF with FFmpeg

Refer VMAF score to reduce bitrate of RTMP live streaming.

* [VMAF](https://github.com/Netflix/vmaf)
* [Using VMAF with FFmpeg](https://github.com/Netflix/vmaf/blob/master/resource/doc/ffmpeg.md)
* [Model](https://github.com/Netflix/vmaf/blob/master/resource/doc/models.md)

## Requirement

* FFmpeg built with `--enable-libvmaf`
* grep
* Only tested on macOS

## Usage Example

I have published streaming with `700k` with resolution `800x450`.  
Now, I want to reduce the bitrate, but don't want users feel bad quality than before.

### Prepare Samples

1. Record stream video from OBS as `stream_75s_raw_1920x1080.mp4`. (Scripts will reference the naming pattern)
2. Convert `stream_75s_raw_1920x1080.mp4` to prefer bitrate `700k` as `stream_75s_700k_800x450_h264.flv`
3. Convert `stream_75s_raw_1920x1080.mp4` to bitrates `576k`, `448k`, `384k` for distored version.

see [create_sample_h264.sh](create_sample_h264.sh)

**Smaples**

```bash
# Current streaming quality
./create_sample_h264.sh stream_75s_raw_1920x1080.mp4 700k 800x450
=> stream_75s_700k_800x450_h264.flv
# Sample 1
./create_sample_h264.sh stream_75s_raw_1920x1080.mp4 576k 800x450
=> stream_75s_576k_800x450_h264.flv
# Sample 2
./create_sample_h264.sh stream_75s_raw_1920x1080.mp4 448k 800x450
=> stream_75s_448k_800x450_h264.flv
# Sample 3
./create_sample_h264.sh stream_75s_raw_1920x1080.mp4 384k 800x450
=> stream_75s_384k_800x450_h264.flv
```

**Sample for H265**

* [create_sample_h265.sh](create_sample_h265.sh)
    * Create H265 flv.
* [create_sample_hevc_nvenc.ps1.sh](create_sample_hevc_nvenc.ps1)
    * Create flv of hevc_nvenc codec with Nvidia grahpic card on Windows Poershell.
    * Install CUDA toolkit first.
    * FFmpeg for Windows

### Caculation

see [run_vmaf.sh](run_vmaf.sh)

**VMAF score**

Prepare `input1`, `input2` as reference and distored version to compare frame by frame.

Default model `model/vmaf_v0.6.1.json` is trained by `1920x1080` HDTV, the script will scale input1 and input2 to `1920x1080`.

```bash
./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_576k_800x450_h264.flv 1920x1080
./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_448k_800x450_h264.flv 1920x1080
./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_384k_800x450_h264.flv 1920x1080
```

**Phone Model**

```bash
# without phone model, can ignore last parameter 0
./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_384k_800x450_h264.flv 1920x1080 0
# with phone model, the score is close to 99. (phone model trained by lower resolution)
./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_384k_800x450_h264.flv 1920x1080 1
```

### Comparison

* Raw video `stream_75s_raw_1920x1080.mp4`

| reference                         | distored                          | scale     | vmaf score    |
| ---                               | ---                               | ---       | ---           |
| stream_75s_700k_800x450_h265.flv  | stream_75s_576k_800x450_h264.flv  | 1920x1080 | 91.979802     |
| ...                               | stream_75s_448k_800x450.flv       | 1920x1080 | **90.303380** |
| ...                               | stream_75s_384k_800x450.flv       | 1920x1080 | 88.956422     |

* Define target score : Pick optimized bitrate to VMAF score between `90 ± 1`.
* Pick `448k` as new bitrate to reduce bandwidth of network.
