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

read -a RAWRGBOPTSOUT <<< "-nosound -vf scale=${XRES}:${YRES},format=rgb24 -sws 4 -ovc raw -of rawvideo -ofps ${FPS} -quiet"
read -a RAWRGBOPTSIN <<< "-demuxer rawvideo -rawvideo fps=${FPS}:w=${XRES}:h=${YRES}:format=rgb24 -nosound"

read -a RAWYUVOPTSOUT <<< "-nosound -vf scale=${XRES}:${YRES},format=iyuv -sws 4 -ovc raw -of rawvideo -ofps ${FPS} -quiet"
read -a RAWYUVOPTSOUTHALFFPS <<< "-nosound -vf scale=${HDXRES}:${HDYRES},format=iyuv -sws 4 -ovc raw -of rawvideo -quiet"

read -a X264COMMON <<< "--demuxer raw --preset placebo --crf 18 --keyint 600 --threads 1 --sar ${YRES}:${DESTYRES} --input-res ${XRES}x${YRES}"

COMBINE="combine.avi"
LOGO="${HOME}/encoding/logo/${LOGO}.avi"
SILENCE="${HOME}/encoding/silence/${SILENCE}.wav"

X264="${HOME}/coding/x264/x264/x264"
X26410BIT="${HOME}/coding/x264/x264/x264-10bit"
DELDUP="${HOME}/coding/deldup"
TASBLEND="${HOME}/coding/tasblend"
AACENC="${HOME}/coding/nero/linux/neroAacEnc"
MP4BOX="/usr/local/bin/MP4Box"

MAXFRAMES=100000000

echo "Step 1"
mencoder -oac copy -mc 0 -ovc lavc -lavcopts vcodec=ffv1:format=bgr32 -o ${COMBINE} $@

#With dedup
echo "Step 2"
rm s.log s2.log s3.log 2>&1 > /dev/null;
mkfifo s.log s2.log s3.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} timecodes.txt ${FPS} ${XRES} ${YRES} 20 < s.log > /dev/null;

echo "Step 3"
rm s.log s2.log s3.log 2>&1 > /dev/null;
mkfifo s.log s2.log s3.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} /dev/null ${FPS} ${XRES} ${YRES} 20 < s.log > s2.log & 
  mencoder ${RAWRGBOPTSIN[@]} ${RAWYUVOPTSOUT[@]} -o s3.log s2.log & 
  ${X264} s3.log ${X264COMMON[@]} --tcfile-in timecodes.txt --output video.mp4;

#10-bit 444
echo "Step 4"
rm s.log s2.log 2>&1 > /dev/null;
mkfifo s.log s2.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} timecodes_10bit444.txt ${FPS} ${XRES} ${YRES} 20 < s.log > /dev/null;

echo "Step 5"
rm s.log s2.log 2>&1 > /dev/null;
mkfifo s.log s2.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  sleep 1 && ${DELDUP} /dev/null ${FPS} ${XRES} ${YRES} 20 < s.log > s2.log & 
  ${X26410BIT} s2.log ${X264COMMON[@]} --input-csp=rgb --output-csp=i444 --tcfile-in timecodes_10bit444.txt --colormatrix smpte170m --range pc --output video_10bit444.mp4;

#Without dedup
echo "Step 6"
rm s.log 2>&1 > /dev/null; 
mkfifo s.log && 
  mencoder ${RAWYUVOPTSOUT[@]} -o s.log ${SUBTITLEOPTS[@]} ${LOGO} ${COMBINE} & 
  ${X264} s.log ${X264COMMON[@]} --fps ${FPS} --output video_512kb.mp4;

#youtube
echo "Step 7"
rm s.log s2.log s3.log 2>&1 > /dev/null; 
mkfifo s.log s2.log s3.log && 
  mencoder ${RAWRGBOPTSOUT[@]} -o s.log ${LOGO} ${COMBINE} & 
  sleep 1 && ${TASBLEND} ${XRES} ${YRES} 0 ${MAXFRAMES} < s.log > s2.log & 
  mencoder ${RAWRGBOPTSIN[@]} ${SUBTITLEOPTS[@]} ${RAWYUVOPTSOUTHALFFPS[@]} -o s3.log s2.log & 
  ${X264} s3.log --demuxer raw --preset slow --crf 0 --keyint 150 --fps ${HALFFPS} --sar ${YRES}:${DESTYRES} --input-res ${HDXRES}x${HDYRES} --output video_youtube.mp4;

echo "Step 8"
mplayer ${COMBINE} -benchmark -vc null -vo null -ao pcm:file=dump.wav -novideo;
sox --combine concatenate ${SILENCE} dump.wav -e oki-adpcm audio.wav;
${AACENC} -q .25 -if audio.wav -of audio.mp4

echo "Step 9"
${MP4BOX} -add video.mp4 -add audio.mp4 -new final.mp4 
${MP4BOX} -add video_10bit444.mp4 -add audio.mp4 -new final_10bit444.mp4 
${MP4BOX} -add video_512kb.mp4 -add audio.mp4 -new final_512kb.mp4 
${MP4BOX} -add video_youtube.mp4 -add audio.mp4 -new final_youtube.mp4 
