DATE:  2/11/2020

#  MSc Ing Agr Luciano E. Di Paolo
#  Dr Ing Agr Guillermo E Peralta
#######################################################################################

library(raster)
library(rgdal)


# TERRA CLIME FROM GOOGLE EARTH ENGINE
#Abatzoglou, J.T., S.Z. Dobrowski, S.A. Parks, K.C. Hegewisch, 2018, Terraclimate, 
#a high-resolution global dataset of monthly climate and climatic water balance from 1958-2015, Scientific Data,
#######################################################################################

#Set working directory
WD<-("D:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/TERRA_CLIME")
setwd(WD)


# Open Terra Climate downloaded from Google Earth Engine

tmp<-stack("AverageTemperature_1981-2001_Pergamino.tif")

pre_81_00<-stack("Precipitation_1981-2001_Pergamino.tif")

pet_81_00<-stack("PET_1981-2001_Pergamino.tif")


# TEMPERATURE

# Get one month temperature ( January)

tmp_Jan_1<-tmp[[1]]

dim(tmp_Jan_1)

# Create empty list

Rlist<-list()

# Average of 20 years (j)  and 12 months (i) 

######for loop starts#######
for (i in 1:12) { 

var_sum<-tmp_Jan_1*0
k<-i

for (j in 1:20) {
print(k)
var_sum<-(var_sum + tmp[[k]])

k<-k+12
}

#Calculate each month average. 

var_avg<-var_sum/20

# Save the average of each month (i)

Rlist[[i]]<-var_avg
}
#######for loop ends########

#save a stack of months averages

Temp_Stack<-stack(Rlist)
Temp_Stack<-Temp_Stack*0.1 # rescale to °C
writeRaster(Temp_Stack,filename='Temp_Stack_81-00_TC.tif',"GTiff",overwrite=TRUE)

#######################################################################################

#PRECIPITATION

# Get one month Precipitation ( January)

pre_Jan_1<-pre_81_00[[1]]

dim(pre_Jan_1)

# Create empty list

Rlist<-list()

# Average of 20 years (j)  and 12 months (i) 

######for loop starts#######
for (i in 1:12) { 

var_sum<-pre_Jan_1*0
k<-i

for (j in 1:20) {
print(k)
var_sum<-(var_sum + pre_81_00[[k]])
k<-k+12
}
#Save each month average. 

var_avg<-var_sum/20

Rlist[[i]]<-var_avg
}

######for loop ends#######

#save a stack of months averages

Prec_Stack<-stack(Rlist)
writeRaster(Prec_Stack,filename='Prec_Stack_81-00_TC.tif',"GTiff",overwrite=TRUE)

########################################################################

# POTENTIAL EVAPOTRANSPIRATION 


# Get one month PET ( January)

pet_Jan_1<-pet_81_00[[1]]

dim(pet_Jan_1)

# Create empty list

Rlist<-list()

# Average of 20 years (j)  and 12 months (i) 

######for loop starts#######
for (i in 1:12) { 

var_sum<-pet_Jan_1*0
k<-i

for (j in 1:20) {
print(k)
var_sum<-(var_sum + pet_81_00[[k]])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum/20


Rlist[[i]]<-var_avg
}
######for loop ends#######

#save a stack of months averages

PET_Stack<-stack(Rlist)
PET_Stack<-PET_Stack*0.1
writeRaster(PET_Stack,filename='PET_Stack_81-00_TC.tif',"GTiff",overwrite=TRUE)



