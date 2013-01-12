#!/usr/bin/perl
$filename = $ARGV[0];
$bitrate = $ARGV[1];
print "FILE NAME IS $filename, BITRATE IS $bitrate.\n\n";
system('rm s.log');
system('mkfifo s.log');
system("/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet \"$filename\" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --preset placebo --pass 1 --slow-firstpass --bitrate $bitrate --keyint 300 --fps 60.000 --threads 1 --output \"video-final-$bitrate.mp4\" 256x224");
system('rm s.log');
system('mkfifo s.log');
system("/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet \"$filename\" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --preset placebo --pass 3 --bitrate $bitrate --keyint 300 --fps 60.000 --threads 1 --output \"video-final-$bitrate.mp4\" 256x224");
system('rm s.log');
system('mkfifo s.log');
system("/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet \"$filename\" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --preset placebo --pass 3 --bitrate $bitrate --keyint 300 --fps 60.000 --threads 1 --output \"video-final-$bitrate.mp4\" 256x224");
