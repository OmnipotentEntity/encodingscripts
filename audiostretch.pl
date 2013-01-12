#!/usr/bin/perl

$filein = $ARGV[0];
$fileout = $ARGV[1];
$intime = $ARGV[2];
$outtime = $ARGV[3];
print "INPUT IS $filein OUTPUT IS $fileout STRETCHING FROM $intime to $outtime.\n";
system("sox $filein $fileout speed ".$outtime/$intime);
