#!/usr/bin/perl

$SampleRate = $ARGV[0];
$NrChannels = $ARGV[1];
$NrSeconds = $ARGV[2];
$FileOut = $ARGV[3];

print("ffmpeg -ar $SampleRate -acodec pcm_s16le -f s16le -ac $NrChannels -i <(dd if=/dev/zero bs=" . $SampleRate * $NrChannels * 2 . " count=$NrSeconds) $FileOut");
