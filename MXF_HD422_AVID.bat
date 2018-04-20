***************************************************************************
*  Video file to XDCAM HD422 1080/50i compliant with Avid Media Composer  *
* 					IMPORT : OK // Link To Media (AMA) :                  *
* 				Modify FFMPEG & FFMBC variable to your app link           *
* 	  How to use ? Pass your video file in parameters of this Batch %1    *
*			 Thanks to FFMPEG devs & FFMBC dev Baptiste Coudurier         *
***************************************************************************
@ECHO OFF 

set FFPROBE=
set FFMPEG=
set FFMBC=
set TEMP=

set "COMMANDLINE=%FFPROBE% -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 %1"
setlocal EnableDelayedExpansion
for /F "delims=" %%I in ('!COMMANDLINE!') do set "RESOLUTION=%%I"
echo %RESOLUTION%

set FILE=%1

if %RESOLUTION% == 3840x2160 (
	echo ok
	call :convertUHD
	) else (
	echo autre
	call :convertOTHER
	)

*************
* Fonctions *
*************

:convertUHD
echo convertUHD
%FFMPEG% -i %FILE% -pix_fmt yuv422p -vcodec mpeg2video -flags +ildct+ilme -top 1 -b:v 50000k -minrate 50000k -maxrate 50000k -bufsize 36408333 -r 25 -s 1920x1080 -aspect 16:9 -acodec pcm_s24le -ar 48000 -f mxf -y %FILE%_CONVERT_XDCAMHD422_TEMP.MXF
echo FFMEPGOK
%FFMBC% -i %FILE%_CONVERT_XDCAMHD422_TEMP.MXF  -threads 4 -tff -target xdcamhd422 -s hd1080 -pix_fmt yuv422p -f mxf -y -an %FILE%_AVID_XDCAMHD422.MXF -acodec pcm_s24le -ar 48000 -newaudio -acodec pcm_s24le -ar 48000 -newaudio -map_audio_channel 0:1:0:0:1:0 -map_audio_channel 0:1:0:0:2:0
echo FFMBC OK
del %FILE%_CONVERT_XDCAMHD422_TEMP.MXF
exit /B

:convertOTHER
echo convertOTHER
set name='echo "%FILE%"'
echo $name
%FFMBC% -i %FILE% -threads 4 -tff -target xdcamhd422 -s hd1080 -pix_fmt yuv422p -f mxf -an %FILE%_CONVERT_XDCAMHD422.MXF -acodec pcm_s24le -ar 48000 -newaudio -acodec pcm_s24le -ar 48000 -newaudio -map_audio_channel 0:1:0:0:1:0 -map_audio_channel 0:1:0:0:2:0
exit /B
