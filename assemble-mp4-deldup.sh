#!/bin/bash

FPS=$1
XRES=$2
YRES=$3
LOGO=$4
SILENCE=$5
shift 5;

HALFFPS=$[$FPS/2]
DESTYRES=$[$XRES*3/4]
HDXRES=$[${XRES}*8]
HDYRES=$[${YRES}*8]

read -a SUBTITLEOPTS <<< "-sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig"

read -a RAWRGBOPTSOUT <<< "-nosound -vf format=rgb24 -ovc raw -of rawvideo -ofps ${FPS} -quiet"
read -a RAWRGBOPTSIN <<< "-demuxer rawvideo -rawvideo fps=${FPS}:w=${XRES}:h=${YRES}:format=rgb24 -nosound"

read -a RAWYUVOPTSOUT <<< "-nosound -vf format=iyuv -ovc raw -of rawvideo -ofps ${FPS} -quiet"
read -a RAWYUVOPTSOUTHALFFPS <<< "-nosound -vf format=iyuv -ovc raw -of rawvideo -ofps ${HALFFPS} -quiet"

read -a X264COMMON <<< "--demuxer raw --preset placebo --crf 18 --keyint 600 --threads 1 --sar ${YRES}:${DESTYRES} --input-res ${XRES}x${YRES}"

COMBINE="combine.avi"
LOGO="${HOME}/encoding/logo/${LOGO}.avi"
SILENCE="${HOME}/encoding/silence/${SILENCE}.wav"

X264="/usr/local/bin/x264"
X26410BIT="${HOME}/coding/x264-src/x264/x264-10bit"
DELDUP="${HOME}/coding/deldup"
TASBLEND="${HOME}/coding/tasblend-lookup"

MAXFRAMES=1000000

mencoder -aspect 4:3 -oac copy -mc 0 -ovc lavc -lavcopts vcodec=ffv1:format=bgr32 -o ${COMBINE} $@

#With dedup
echo making timecodes.

rm s.log s2.log s3.log 2>&1 > /dev/null;
mkfifo s.log s2.log s3.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} timecodes.txt ${FPS} ${XRES} ${YRES} 20 < s.log > /dev/null;

rm s.log s2.log s3.log 2>&1 > /dev/null;
mkfifo s.log s2.log s3.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} /dev/null ${FPS} ${XRES} ${YRES} 20 < s.log > s2.log & 
  mencoder ${RAWRGBOPTSIN[@]} ${RAWYUVOPTSOUT[@]} -o s3.log s2.log & 
  ${X264} s3.log ${X264COMMON[@]} --tcfile-in timecodes.txt --output video.mp4;

#10-bit 444
echo making timecodes.
rm s.log s2.log 2>&1 > /dev/null;
mkfifo s.log s2.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  ~/coding/deldup timecodes_10bit444.txt ${FPS} ${XRES} ${YRES} 20 < s.log > /dev/null;

rm s.log s2.log 2>&1 > /dev/null;
mkfifo s.log s2.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} /dev/null ${FPS} ${XRES} ${YRES} 20 < s.log > s2.log & 
  ${X26410BIT} s2.log ${X264COMMON[@]} --input-csp=rgb --output-csp=i444 --tcfile-in timecodes_10bit444.txt --colormatrix smpte170m --range pc --output video_10bit444.mp4;

#Without dedup
rm s.log 2>&1 > /dev/null; 
mkfifo s.log && 
  mencoder ${RAWYUVOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  ${X264} s.log ${X264COMMON[@]} --output video_512kb.mp4;

#youtube
rm s.log s2.log s3.log 2>&1 > /dev/null; 
mkfifo s.log s2.log s3.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${LOGO} ${COMBINE} & 
  sleep 1 && ${TASBLEND} ${XRES} ${YRES} 0 ${MAXFRAMES} < s.log > s2.log & 
  mencoder ${RAWRGBOPTSIN[@]} -vf scale=${HDXRES}:${HDYRES} -sws 4 ${SUBTITLEOPTS[@]} ${RAWYUVOPTSOUTHALFFPS[@]} -o s3.log s2.log & 
  ${X264} s3.log --demuxer raw --preset slow --crf 0 --keyint 150 --fps ${HALFFPS} --sar ${YRES}:${DESTYRES} --input-res ${HDXRES}x${HDYRES} --output video_youtube.mp4;

mplayer ${COMBINE} -ao pcm:file=dump.wav -novideo;
sox --combine concatenate ${SILENCE} dump.wav -o audio.wav;
~/coding/nero/linux/neroAacEnc -q .25 -if audio.wav -of audio.mp4
cp audio.mp4 audio_10bit444.mp4
#MP4Box -nhml 1 audio.mp4
#MP4Box -nhml 1 audio_10bit444.mp4
#~/coding/NHMLFixup.lua video_track1.nhml audio_track1.nhml timecodes.txt
#~/coding/NHMLFixup.lua video_10bit444_track1.nhml audio_10bit444_track1.nhml timecodes_10bit444.txt
MP4Box -add video.mp4 -add audio.mp4 -new final.mp4 
MP4Box -add video_10bit444.mp4 -add audio.mp4 -new final_10bit444.mp4 
MP4Box -add video_512kb.mp4 -add audio.mp4 -new final_512kb.mp4 
MP4Box -add video_youtube.mp4 -add audio.mp4 -new final_youtube.mp4 
