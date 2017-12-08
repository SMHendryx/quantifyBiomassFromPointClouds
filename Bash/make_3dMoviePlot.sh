# assumes animation/ contains frames named frame*.png
cd /Users/seanmhendryx/Data/thesis/Processed_Data/SfM/animation 
convert -delay 5 -loop 0 frame*.png animated.gif
