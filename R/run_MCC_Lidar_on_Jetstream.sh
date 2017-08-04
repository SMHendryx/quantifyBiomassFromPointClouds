cd /usr/local/bin/mcclidar-code/build/linux
seq	1 20 | parallel ./mcc-lidar -s .20 -t .05 /home/hendryx/mydata/SRER_SfM/20160519Flights/mildDepthFiltering/rectangular_study_area/tiles/tile-{}.las /home/hendryx/mydata/SRER_SfM/20160519Flights/mildDepthFiltering/rectangular_study_area/classified/mcc-s_point20_-t_point05/tiles/tile-{}.las
