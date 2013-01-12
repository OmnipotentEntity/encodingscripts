#!/usr/bin/perl
$filename = $ARGV[0];
$starttime = $ARGV[1];
$startrate = $ARGV[2];
$endrate = $ARGV[3];
for (($startrate/5)..($endrate/5)) {
  $_*=5;
  system('rm s.log');
  system('mkfifo s.log');
  system("/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -ss $starttime -endpos 00:00:30 -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet \"$filename\" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --pass 1 --slow-firstpass --preset placebo --bitrate $_ --keyint 300 --fps 60.000 --threads 1 --output \"video-test$_.mp4\" 256x224");
  system('sleep 60');
  system('rm s.log');
  system('mkfifo s.log');
  system("/home/omnipotententity/coding/mplayer-src/mplayer/mencoder -ss $starttime -endpos 00:00:30 -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps 60.000 -o s.log -quiet \"$filename\" & /home/omnipotententity/coding/x264-src/x264/x264 s.log --pass 2 --preset placebo --bitrate $_ --keyint 300 --fps 60.000 --threads 1 --output \"video-test$_.mp4\" 256x224");
  system('sleep 60');
}
