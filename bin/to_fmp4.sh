ffmpeg -y -i "$1" -c copy -bsf:a aac_adtstoasc -movflags frag_keyframe+empty_moov+faststart "$2"
