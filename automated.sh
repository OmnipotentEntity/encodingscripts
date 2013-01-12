#!/bin/zsh
mencoder -aspect 4:3 -oac copy -mc 0 -ovc lavc -lavcopts vcodec=ffv1:format=bgr32 -o combine.avi 
rm s.log; mkfifo s.log && mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig ~/encoding/logo/gba.avi combine.avi & x264 s.log --demuxer yuv --preset placebo --crf 18 --keyint 600 --fps 60.000 --threads 1 --output video.mp4 240x160;
mplayer combine.avi -ao pcm:file=dump.wav -vc dummy -aid 1 -vo null;
sox --combine concatenate ../silence/gbsilencestd.wav dump.wav -o audio.wav;
oggenc -q1 audio.wav;
mkvmerge --engage no_simpleblocks -o final.mkv video.mp4 audio.ogg;
