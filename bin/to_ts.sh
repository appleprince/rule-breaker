ffmpeg -y -i "$1" -c copy -bsf:v h264_mp4toannexb "$2"
