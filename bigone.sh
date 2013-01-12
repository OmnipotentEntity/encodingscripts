#mencoder -nosound -mc 0 -ovc lavc -lavcopts vcodec=ffv1:format=444p -sub subtitles.txt -subfont-text-scale 4 -sub-bg-alpha 75 -utf8 -o video.avi ../logo/change.avi combine.avi

rm s.log
mkfifo s.log
/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet "video.avi" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --pass 1 --slow-firstpass --preset placebo --bitrate 164 --keyint 300 --fps 60.000 --threads 1 --output "video-test164.mp4" 256x224 
rm s.log
mkfifo s.log
/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet "video.avi" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --pass 2 --preset placebo --bitrate 164 --keyint 300 --fps 60.000 --threads 1 --output "video-test164.mp4" 256x224 

#mplayer mixed2.avi -ao pcm:file=encoded.wav -vc dummy -aid 1 -vo null
#oggenc -q0 encoded.wav
#mkvmerge --engage no_simpleblocks --aspect-ratio 1:4/3 -o final.mkv video-test145.mp4 encoded.ogg
