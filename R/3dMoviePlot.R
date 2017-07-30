# Example of making a 3d movie

library(rgl)

rgl.open()
rgl.points(rnorm(1000), rnorm(1000), rnorm(1000), color = heat.colors(1000))
rgl.bg(color = "black")

play3d(spin3d(axis = c(0, 1, 0)))

#movie3d(spin3d(axis = c(0, 0, 1)), duration = 3)     

