mencoder -aspect 4:3 -oac copy -mc 0 -ovc lavc -lavcopts vcodec=ffv1:vstrict=-2 -o combine.avi test0.avi test0_part2.avi test0_part3.avi;
mencoder -aspect 4:3 -nosound -mc 0 -ovc lavc -lavcopts vcodec=ffv1:vstrict=-2 -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -ofps 60.000 -o video.avi logo/gbbw.avi combine.avi;
mplayer combine.avi -ao pcm:file=dump.wav -vc dummy -aid 1 -vo null; 
./makefinalgbvideo.pl video.avi 65;
sox --combine concatenate silence/gbsilencestd.wav dump.wav -o audio.wav;
oggenc -q-1 audio.wav;
mkvmerge --engage no_simpleblocks -o final.mkv video-final-65.mkv audio.ogg;
