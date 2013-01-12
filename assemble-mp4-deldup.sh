#!/bin/zsh

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

mencoder -aspect 4:3 -oac copy -mc 0 -ovc lavc -lavcopts vcodec=ffv1:format=bgr32 -o combine.avi $@
rm s.log s2.log s3.log; mkfifo s.log s2.log s3.log && mencoder -nosound -vf format=rgb24 -ovc raw -of rawvideo -ofps ${FPS} -o s.log -quiet -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig ~/encoding/logo/${LOGO}.avi combine.avi & ~/coding/deldup timecodes.txt ${FPS} ${XRES} ${YRES} 20 < s.log > /dev/null;
rm s.log s2.log s3.log; mkfifo s.log s2.log s3.log && mencoder -nosound -vf format=rgb24 -ovc raw -of rawvideo -ofps ${FPS} -o s.log -quiet -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig ~/encoding/logo/${LOGO}.avi combine.avi & ~/coding/deldup /dev/null ${FPS} ${XRES} ${YRES} 20 < s.log > s2.log & mencoder -demuxer rawvideo -rawvideo fps=${FPS}:w=${XRES}:h=${YRES}:format=rgb24 -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps ${FPS} -o s3.log -quiet s2.log & /usr/local/bin/x264 s3.log --demuxer raw --preset placebo --crf 18 --keyint 600 --threads 1 --sar ${YRES}:${DESTYRES} --tcfile-in timecodes.txt --output video.mp4 --input-res ${XRES}x${YRES};
rm s.log s2.log; mkfifo s.log s2.log && mencoder -nosound -vf format=rgb24 -ovc raw -of rawvideo -ofps ${FPS} -o s.log -quiet -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig ~/encoding/logo/${LOGO}.avi combine.avi & ~/coding/deldup timecodes_10bit444.txt ${FPS} ${XRES} ${YRES} 20 < s.log > /dev/null;
rm s.log s2.log; mkfifo s.log s2.log && mencoder -nosound -vf format=rgb24 -ovc raw -of rawvideo -ofps ${FPS} -o s.log -quiet -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig ~/encoding/logo/${LOGO}.avi combine.avi & ~/coding/deldup /dev/null ${FPS} ${XRES} ${YRES} 20 < s.log > s2.log & ~/coding/x264-src/x264/x264-10bit s2.log --demuxer raw --preset placebo --crf 18 --keyint 600 --threads 1 --sar ${YRES}:${DESTYRES} --input-csp=rgb --output-csp=i444 --tcfile-in timecodes_10bit444.txt --colormatrix smpte170m --range pc --output video_10bit444.mp4 --input-res ${XRES}x${YRES};
rm s.log; mkfifo s.log && mencoder -nosound -vf format=iyuv -ovc raw -of rawvideo -ofps ${FPS} -o s.log -quiet -sub subtitles.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig ~/encoding/logo/${LOGO}.avi combine.avi & /usr/local/bin/x264 s.log --demuxer raw --preset placebo --crf 18 --keyint 600 --fps ${FPS} --threads 1 --sar ${YRES}:${DESTYRES} --output video_512kb.mp4 --input-res ${XRES}x${YRES};
rm s.log s2.log s3.log; mkfifo s.log s2.log s3.log && mencoder -nosound -vf format=rgb24 -ovc raw -of rawvideo -ofps ${FPS} -o s.log -quiet ~/encoding/logo/${LOGO}.avi combine.avi & ~/coding/tasblend-lookup ${XRES} ${YRES} 0 1000000 < s.log > s2.log & mencoder -demuxer rawvideo -rawvideo fps=${HALFFPS}:w=${XRES}:h=${YRES}:format=rgb24 -nosound -vf scale=${HDXRES}:${HDYRES},format=iyuv -sws 4 -sub subtitlesHD.txt -subfont-text-scale 3.5 -sub-bg-alpha 75 -utf8 -nofontconfig -ovc raw -of rawvideo -ofps ${HALFFPS} -o s3.log -quiet s2.log & /usr/local/bin/x264 s3.log --demuxer raw --preset slow --crf 0 --keyint 150 --fps ${HALFFPS} --sar ${YRES}:${DESTYRES} --output video_youtube.mp4 --input-res ${HDXRES}x${HDYRES};
mplayer combine.avi -ao pcm:file=dump.wav -novideo;
sox --combine concatenate ../silence/${SILENCE}.wav dump.wav -o audio.wav;
~/coding/nero/linux/neroAacEnc -q .25 -if audio.wav -of audio.mp4
cp audio.mp4 audio_10bit444.mp4
MP4Box -nhml 1 audio.mp4
MP4Box -nhml 1 audio_10bit444.mp4
MP4Box -nhml 1 video.264
MP4Box -nhml 1 video_10bit444.264
~/coding/NHMLFixup.lua video_track1.nhml audio_track1.nhml timecodes.txt
~/coding/NHMLFixup.lua video_10bit444_track1.nhml audio_10bit444_track1.nhml timecodes_10bit444.txt
MP4Box -add video.mp4 -add audio.mp4 -new final.mp4 
MP4Box -add video_10bit444.mp4 -add audio.mp4 -new final_10bit444.mp4 
MP4Box -add video_512kb.mp4 -add audio.mp4 -new final_512kb.mp4 
MP4Box -add video_youtube.mp4 -add audio.mp4 -new final_youtube.mp4 
