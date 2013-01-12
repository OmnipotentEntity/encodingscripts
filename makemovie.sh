#!/bin/sh
#
EXE=./fceux
#
# Which file do you want to place your audio and video in.
VIDEO_RESULT="`pwd`/test0.avi"
#
SL="--slstart 0 --slend 239"
#
#
VIDEO="-ovc x264 -x264encopts crf=1.0:me=dia:turbo=2:frameref=4"
AUDIO="-oac mp3lame -lameopts mode=3:preset=60:aq=0"
VIDEO="$VIDEO -nocache"
VIDEO="/home/omnipotententity/coding/mplayer-src/mplayer/mencoder \
     - -o '$VIDEO_RESULT' \
     -mc 0 -aspect 4/3 \
     NESVSETTINGS \
     $VIDEO \
     $AUDIO "
#
rm -f s.log
$EXE $SL --xscale 1 --yscale 1 --special 0 \
     --pal 0 \
     --soundq 1 --sound 1 --soundrate 48000 --volume 150 --trianglevol 256 --square1vol 256 --square2vol 256 --noisevol 256 --pcmvol 256 --mute 1 \
     --nospritelim 1 --inputdisplay 0 \
     --videolog "$VIDEO" \
     $*

