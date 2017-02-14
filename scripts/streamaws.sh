#!/bin/bash
# vim:expandtab:shiftwidth=4:tabstop=4:smarttab:autoindent:autoindent

HOST=35.161.85.32

QUIET=no
#QUIET=yes

RASPIVID_FLAGS=
FFMPEG_FLAGS=

if [ "$QUIET" == "yes" ]; then
	FFMPEG_FLAGS += "-loglevel panic "
fi

while [ true ]; do
	raspivid $RASPIVID_FLAGS -n -w 1280 -h 720 -fps 30 -vf -hf \
		-t 86400000 -b 1800000 -ih -o - | \
		ffmpeg $FFMPEG_FLAGS -re -i - -c:v copy -an -map 0:0 \
		-f flv rtmp://$HOST/live/live
	sleep 1
done

