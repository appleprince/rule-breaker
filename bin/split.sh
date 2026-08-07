ffmpeg -y -i "$1" -c copy -segment_time 120 -f segment "$2"

