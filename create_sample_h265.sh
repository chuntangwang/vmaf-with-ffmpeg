#!/usr/bin/env bash
#
# ./create_sample_h265.sh {input} {bitrate} {scale}
#
# example:
# high 700 * 0.6 = 420
# low  486 * 0.6 = 292
# ./create_sample_h265.sh stream_75s_raw_1920x1080.mp4 420K 800x450
#
# ========================================== #

input=$1
bitrate=$2
scale=$3

codec=libx265
fps=24
keyint=$((fps*5))
x265opts=keyint=$keyint:min-keyint=$fps:scenecut=0

# "ffmpeg -h encoder=libx265" or "x265 --fullhelp"
csp="format=yuv420p"
vformat="$csp"
vprofile="main"
vpreset="ultrafast"
vlevel=3.1
vtune="zerolatency"

output_prefix=$(echo "$input" | grep -oh ".*[a-z]_.*[0-9]s")
output="${output_prefix}_${bitrate}_${scale}_H265.flv"

ffmpeg -hide_banner \
-i "$input" \
-vf $vformat -c:v $codec -x265-params "$x265opts" \
-profile:v $vprofile -preset $vpreset -level:v $vlevel -tune $vtune \
-b:v "$bitrate" -minrate "$bitrate" -maxrate "$bitrate" -bufsize "$bitrate" \
-r $fps -s "$scale" -an \
"$output"
