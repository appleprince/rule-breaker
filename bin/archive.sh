#!/bin/bash

set -euxo pipefail

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--input)
      INPUT="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--output)
      OUTPUT="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--segment)
      SEGMENT="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

mkdir -p build
ffmpeg -y -i "$INPUT" -c copy -segment_time $SEGMENT -f segment "build/%02d.mp4"
for f in build/*.mp4; do
  mv "$f" "$f.tmp"
  ffmpeg -y -f mp4 -i "$f.tmp" -c copy -bsf:a aac_adtstoasc -movflags frag_keyframe+empty_moov+faststart "$f"
  rm "$f.tmp"
done
(cd build && 7z a -y -p"$PASSWORD" -v50M "../$OUTPUT" *)
rm -rf build

