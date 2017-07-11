# need to run in parallel, so following script, splits the file into tiles based on number of cores
automate this:
#numCores=lscpus

declare -i numCores=24
numCores=$((numCores - 2))

ls -sh --block-size=M /mydata/SRER_SfM/tLidar/Decimated_Cropped_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las

#output: 287



# As a starting point: if the scale (post spacing) of the lidar survey is 1.5 m, then try 1.5. Try varying it up or down by 0.5 m increments to see if it produces a more 
# desirable digital terrain model (DTM) interpolated from the classified ground returns in the output file. Use units that match the units of the lidar data.

# As for the curvature threshold, a good starting value to try might be 0.3 (if data are in meters; 1 if data are in feet), and then try varying this up or down by 0.1 m 
# increments (if data are in meters; 0.3 if data are in feet).

# Example: Run MCC at a scale parameter of 1.5 and a threshold parameter of 0.3 m:
#    mcc-lidar -s 1.5 -t 0.3 input_filename.las output_filename.las

# Scale before decimating = 0.01118436
#scale after decimating:
#First trying s = .04


cd /usr/local/bin/mcclidar-code/build/linux


# Running in parallel:
seq 1 23 | parallel ./mcc-lidar -s .04 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-{}.las /mydata/SRER_SfM/tLidar/classified/tile-{}.las

#Seems to be working!!
#output is not classified well, many tree points clearly classified as ground

#try large scale parameter do to gaps in scan lines
cd /usr/local/bin/mcclidar-code/build/linux
./mcc-lidar -s .5 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point5_-t_point3/tile-11.las

#try large scale parameter do to gaps in scan lines
#cd /usr/local/bin/mcclidar-code/build/linux
#./mcc-lidar -s .25 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point5_-t_point3/tile-11.las


#let's try iterating up through scale parameter and threshold parameters:
#make directory for each scale and parameter
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point2
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point2
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point2
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point2
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point2
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point14_-t_point2


mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point3
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point3
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point3
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point3
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point3
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point14_-t_point3

mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point4
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point4
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point4
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point4
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point4
mkdir /mydata/SRER_SfM/tLidar/classified/mcc-s_point14_-t_point4

#Check if all directories exist:
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point2
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point2
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point2
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point2
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point2
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point14_-t_point2


cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point3
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point3
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point3
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point3
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point3
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point14_-t_point3

cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point4
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point4
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point4
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point4
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point4
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point14_-t_point4

#parallelize as background processes:
cd /usr/local/bin/mcclidar-code/build/linux

./mcc-lidar -s .02 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point2/tile-11.las
./mcc-lidar -s .06 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point2/tile-11.las
./mcc-lidar -s .08 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point2/tile-11.las
./mcc-lidar -s .1 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point2/tile-11.las
./mcc-lidar -s .12 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point2/tile-11.las
#
./mcc-lidar -s .02 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point3/tile-11.las
./mcc-lidar -s .06 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point3/tile-11.las
./mcc-lidar -s .08 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point3/tile-11.las
./mcc-lidar -s .1 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point3/tile-11.las
./mcc-lidar -s .12 -t .3 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point3/tile-11.las
#
./mcc-lidar -s .02 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point02_-t_point4/tile-11.las
./mcc-lidar -s .06 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point06_-t_point4/tile-11.las
./mcc-lidar -s .08 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point08_-t_point4/tile-11.las
./mcc-lidar -s .1 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point10_-t_point4/tile-11.las
./mcc-lidar -s .12 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point12_-t_point4/tile-11.las

#After initial graphics showing too many ground points (errors of commission) and that lower threshold and higher scale decreases ground classification (thereby improving accuracy)


declare -a folders=("/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point5"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point4"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point4"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point4"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point4"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point6"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point6"
				)


for folder in "${folders[@]}"
do
	mkdir $folder
done


cd /usr/local/bin/mcclidar-code/build/linux
./mcc-lidar -s .06 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point5/tile-11.las &
./mcc-lidar -s .08 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point5/tile-11.las &
./mcc-lidar -s .1 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point5/tile-11.las  &
./mcc-lidar -s .12 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point5/tile-11.las &
./mcc-lidar -s .14 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point5/tile-11.las &
./mcc-lidar -s .16 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point5/tile-11.las &
./mcc-lidar -s .18 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point5/tile-11.las &
./mcc-lidar -s .20 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point5/tile-11.las &
./mcc-lidar -s .22 -t .5 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point5/tile-11.las &

./mcc-lidar -s .14 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point4/tile-11.las &
./mcc-lidar -s .16 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point4/tile-11.las &
./mcc-lidar -s .18 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point4/tile-11.las &
./mcc-lidar -s .20 -t .4 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point4/tile-11.las &

./mcc-lidar -s .06 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point6/tile-11.las &
./mcc-lidar -s .08 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point6/tile-11.las &
./mcc-lidar -s .1 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point6/tile-11.las &
./mcc-lidar -s .12 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point6/tile-11.las &
./mcc-lidar -s .14 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point6/tile-11.las &
./mcc-lidar -s .16 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point6/tile-11.las &
./mcc-lidar -s .18 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point6/tile-11.las &
./mcc-lidar -s .20 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point6/tile-11.las &
./mcc-lidar -s .22 -t .6 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point6/tile-11.las &


#I got confused, actually higher scale (optimal at .2?) and SMALLER threshold is better
#make directories:
declare -a folders=("/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point2"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point2"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point2"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point2"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point2"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point1"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point05"
				"/mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point05"
				)


for folder in "${folders[@]}"
do
	mkdir $folder
done

#Should be no error messages:
for folder in "${folders[@]}"
do
	cd $folder
done

cd /usr/local/bin/mcclidar-code/build/linux

./mcc-lidar -s .14 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point16_-t_point2/tile-11.las &
./mcc-lidar -s .16 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point18_-t_point2/tile-11.las &
./mcc-lidar -s .18 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point20_-t_point2/tile-11.las &
./mcc-lidar -s .20 -t .2 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point22_-t_point2/tile-11.las &
#
./mcc-lidar -s .06 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point1/tile-11.las &
./mcc-lidar -s .08 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point1/tile-11.las &
./mcc-lidar -s .10 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point1/tile-11.las &
./mcc-lidar -s .12 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point1/tile-11.las &
./mcc-lidar -s .14 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point1/tile-11.las &
./mcc-lidar -s .16 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point1/tile-11.las &
./mcc-lidar -s .18 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point1/tile-11.las &
./mcc-lidar -s .20 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point1/tile-11.las &
./mcc-lidar -s .22 -t .1 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point1/tile-11.las &

./mcc-lidar -s .06 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point06_-t_point05/tile-11.las &
./mcc-lidar -s .08 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point08_-t_point05/tile-11.las &
./mcc-lidar -s .10 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point10_-t_point05/tile-11.las &
./mcc-lidar -s .12 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point12_-t_point05/tile-11.las &
./mcc-lidar -s .14 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point14_-t_point05/tile-11.las &
./mcc-lidar -s .16 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point16_-t_point05/tile-11.las &
./mcc-lidar -s .18 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point18_-t_point05/tile-11.las &
./mcc-lidar -s .20 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point20_-t_point05/tile-11.las &
./mcc-lidar -s .22 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-11.las /mydata/SRER_SfM/tLidar/classified/mccParamTesting/mcc-s_point22_-t_point05/tile-11.las &


#Best output is with lowest threshold and highest scale:
# Running in parallel:
cd /usr/local/bin/mcclidar-code/build/linux
seq 1 23 | parallel ./mcc-lidar -s .22 -t .05 /mydata/SRER_SfM/tLidar/tiles/tile-{}.las /mydata/SRER_SfM/tLidar/classified/mcc-s_point22_-t_point05/tile-{}.las

#move files into datastore:
cd /mydata/SRER_SfM/tLidar/classified/mcc-s_point22_-t_point05
icd /iplant/home/seanmhendryx/data/SRER_SfM/tLidar/classified/mcc-s_point22_-t_point05
iput -K -P -b -r -T --retries 3 -X checkpoint-file /mydata/SRER_SfM/tLidar/classified/mcc-s_point22_-t_point05


#trying on rectangular tiles:
mkdir /mydata/SRER_SfM/tLidar/rectangular_study_area/classified
mkdir /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/tiles
cd /usr/local/bin/mcclidar-code/build/linux
seq	1 20 | parallel ./mcc-lidar -s .22 -t .05 /mydata/SRER_SfM/tLidar/rectangular_study_area/tiles/tile-{}.las /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/tiles/tile-{}.las

#only three files classified, trying smaller scale param:
mkdir /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05
cd /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05
#
cd /usr/local/bin/mcclidar-code/build/linux
seq	1 20 | parallel ./mcc-lidar -s .20 -t .05 /mydata/SRER_SfM/tLidar/rectangular_study_area/tiles/tile-{}.las /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05/tile-{}.las

cd /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05
ls
icd /iplant/home/seanmhendryx/data/SRER_SfM/tLidar/rectangular_study_area/classified
iput -K -P -b -r -T mcc-s_point20_-t_point05
# all but tile-20.las ran, so let's try just that one with smaller scale param:
cd /usr/local/bin/mcclidar-code/build/linux
./mcc-lidar -s .18 -t .05 /mydata/SRER_SfM/tLidar/rectangular_study_area/tiles/tile-20.las /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05/tile-20_s_point_18.las

cd /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05
ls
icd /iplant/home/seanmhendryx/data/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05
iput -K -P -b -r -T tile-20.las


# tile-20.las still didn't run, so let's try -s .16:
cd /usr/local/bin/mcclidar-code/build/linux
./mcc-lidar -s .16 -t .05 /mydata/SRER_SfM/tLidar/rectangular_study_area/tiles/tile-20.las /mydata/SRER_SfM/tLidar/rectangular_study_area/classified/mcc-s_point20_-t_point05/tile-20_s_point_16.las






