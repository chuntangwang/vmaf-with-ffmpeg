#!/usr/bin/env bash
#
# ./create_sample_h264.sh {input} {bitrate} {scale}
#
# example:
# ./create_sample_h264.sh stream_75s_raw_1920x1080.mp4 700k 800x450
#
# ========================================== #

input=$1
bitrate=$2
scale=$3

codec=libx264
fps=24
keyint=$((fps*5))
x264opts=keyint=$keyint:min-keyint=$fps:scenecut=0

# "ffmpeg -h encoder=libx264" or "x264 --fullhelp"
csp="format=yuv420p"
vformat="$csp,setsar=sar=1/1,setdar=dar=16/9"
vprofile="baseline"
vpreset="ultrafast"
vlevel=3.1
vtune="zerolatency"

output_prefix=$(echo "$input" | grep -oh ".*[a-z]_.*[0-9]s")
output="${output_prefix}_${bitrate}_${scale}_h264.flv"

ffmpeg -hide_banner \
-i "$input" \
-vf $vformat -c:v $codec -x264opts "$x264opts" \
-profile:v $vprofile -preset $vpreset -level:v $vlevel -tune $vtune \
-b:v "$bitrate" -minrate "$bitrate" -maxrate "$bitrate" -bufsize "$bitrate" \
-r $fps -s "$scale" -an \
"$output"
