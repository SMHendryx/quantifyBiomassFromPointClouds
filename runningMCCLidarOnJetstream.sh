# need to run in parallel, so following script runs the tiles on multiple cores:

# Example: Run MCC at a scale parameter of 1.5 and a threshold parameter of 0.3 m:
#    mcc-lidar -s 1.5 -t 0.3 input_filename.las output_filename.las

# Scale before decimating = 0.01118436
#scale after decimating:
#First trying s = .04


cd /usr/local/bin/mcclidar-code/build/linux


# Running in parallel:
seq 1 20 | parallel ./mcc-lidar -s .22 -t .05 /home/hendryx/mydata/SRER_SfM/tLidar/watershedBeforeClipToRectangular/watershedBeforeClipToRectangular/tiles/tile-{}.las /home/hendryx/mydata/SRER_SfM/tLidar/watershedBeforeClipToRectangular/watershedBeforeClipToRectangular/groundClassified/tiles/tile-{}.las


cd /home/hendryx/mydata/SRER_SfM/tLidar/watershedBeforeClipToRectangular/watershedBeforeClipToRectangular/groundClassified
icd /iplant/home/seanmhendryx/data/SRER_SfM/tLidar/watershedBeforeClipToRectangular/groundClassified
iput -K -P -b -r -T tiles





