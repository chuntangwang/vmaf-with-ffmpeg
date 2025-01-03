#!/usr/bin/env bash
#
# ./run_vmaf.sh {input1} {input2} {scale} {phone_model}
#
# example:
# ./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_576k_800x450_h264.flv 1920x1080 0
# ./run_vmaf.sh stream_75s_700k_800x450_h264.flv stream_75s_576k_800x450_h264.flv 1920x1080 1
#
# about vmaf model
# https://github.com/Netflix/vmaf/blob/master/resource/doc/models.md#predict-quality-on-a-1080p-hdtv-screen-at-3h
#
# ========================================== #

input1=$1
input2=$2
scale=$3

log_prifix=$(echo "$input1" | grep -oh ".*[a-z].*_[0-9]*s")
log_input1=$(echo "$input1" | grep -ohE "([0-9]*(k|K)|raw)_[0-9].*x.*[0-9]")
log_input2=$(echo "$input2" | grep -ohE "([0-9]*(k|K)|raw)_[0-9].*x.*[0-9]")
phone_model_arg=""
phone_model_str=""

[ "$4" == 1 ] && phone_model_arg=":phone_model=1" && phone_model_str="_phone_model"

logfile="${log_prifix}_(${log_input1}_vs_${log_input2})_${scale}${phone_model_str}.xml"
echo "$logfile"

# vmaf 3.0.0
ffmpeg -hide_banner \
-r 24 -i "$input1" \
-r 24 -i "$input2" \
-lavfi "[0:v]scale=${scale}:flags=bicubic,setpts=PTS-STARTPTS[reference]; \
        [1:v]scale=${scale}:flags=bicubic,setpts=PTS-STARTPTS[distorted]; \
        [distorted][reference]libvmaf=log_fmt=xml:log_path=${logfile}:model=path=model/vmaf_v0.6.1.json:n_threads=6${phone_model_arg}" \
-f null -
