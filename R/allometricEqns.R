# Implemented by Sean M. Hendryx
# Equations from: 
#McClaran, M. P., C. R. McMurtry, and S. R. Archer. "A tool for estimating impacts of woody encroachment in arid grasslands: Allometric equations for biomass, carbon and nitrogen content in Prosopis velutina." Journal of arid environments 88 (2013): 39-42.
#Huang, Cho-ying, et al. "Postfire stand structure in a semiarid savanna: Cross‐scale challenges estimating biomass." Ecological Applications 17.7 (2007): 1899-1910.

#allometric models:
#Cercidium microphyllum (paloverde canopy area allometry-biomass not published?)
#natural log
#log(Y) = (a + b(log(X)))*CF
#Mesquite (Prosopis velutina) biomass - canopy area relationship:
mesqAllom <- function(X){
  #Function takes in Canopy Area (CA) in square meters or vector of CAs and returns Total biomass (kg) of mesquite
  #Equation from McClaran et al. 2013
  a = -.59
  b = 1.60
  CF = 1.06
  biomass <- exp(a + b*(log(X))*CF)
  return(biomass)

}

#hackberry (Celtis pallida)
hackAllom <- function(X){
  #Function takes in Canopy Area (CA) in square meters or vector of CAs and returns Total biomass (kg)
  #From HUANG et al. 2007
  #to return mass in kg, multiply by .001
  biomass <- .001*exp(1.02*(6.78 + 1.41 * log(X)))
  return(biomass)
}

#Burrowweed
#As scripted, this function returns funny values
burrAllom <- function(X){
  #Convert X to square cm, as that is what the allometric eqn is written to take in paper:
  X = X * 1000
  biomass<-.001*exp(-4.81 + 1.25 *log(X))
  return(biomass)
}


# Prickly pear (Opuntia engelmannii)
#r 1⁄4 ([center height/2] þ [longest diameter/2])/2, where center height and longest diameter are measured in METERS IN THIS IMPLEMENTATION
prickAllom <- function(r){  
  #Convert input METERS to centimeters:
  r <- r * 100
  biomass <-((4.189 * r^3)^0.965)/(10^5)
  return(biomass)
}  
