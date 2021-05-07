DATE: 12/02/2021

#  MSc Ing Agr Luciano E. Di Paolo
#  Dr Ing Agr Guillermo E Peralta



# TERRA CLIME FROM GOOGLE EARTH ENGINE
#Abatzoglou, J.T., S.Z. Dobrowski, S.A. Parks, K.C. Hegewisch, 2018, Terraclimate, 
#a high-resolution global dataset of monthly climate and climatic water balance from 1958-2015, Scientific Data,
#######################################################################################

#######################################################################################

library(raster)
library(rgdal)

#######################################################################################

WD<-("D:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/TERRA_CLIME")
setwd(WD)

# OPEN LAYERS


# Open Terra Climate downloaded from Google Earth Engine

tmp<-stack("AverageTemperature_2001-2021_Pergamino.tif")

pre_01_18<-stack("Precipitation_2001-2021_Pergamino.tif")

pet_01_18<-stack("PET_2001-2021_Pergamino.tif")

# TEMPERATURE


# Get one month temperature ( January)

tmp_Jan_1<-tmp[[1]]

dim(tmp_Jan_1)

# Create empty list
Rlist<-list()

# Average of 20 years (j)  and 12 months (i) 
##########for loop starts###############
for (i in 1:12) { 
var_sum<-tmp_Jan_1*0
k<-i

for (j in 1:(dim(tmp)[3]/12)) {
print(k)
var_sum<-(var_sum + tmp[[k]])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum/(dim(tmp)[3]/12)

#writeRaster(ra,filename=name, format="GTiff")
Rlist[[i]]<-var_avg
}
##########for loop ends#############
#save a stack of months averages

Temp_Stack<-stack(Rlist)
Temp_Stack<-Temp_Stack*0.1 # rescale to °C
writeRaster(Temp_Stack,filename='Temp_Stack_01-19_TC.tif',"GTiff",overwrite=TRUE)



#############################################################################################################################

#PRECIPITATION


# Have one month Precipitation ( January)

pre_Jan_1<-pre_01_18[[1]]

dim(pre_Jan_1)

# Create empty list
Rlist<-list()


# Average of 20 years (j)  and 12 months (i) 

#########for loop starts############
for (i in 1:12) { 

var_sum<-pre_Jan_1*0
k<-i

for (j in 1:(dim(pre_01_18)[3]/12)) {
print(k)
var_sum<-(var_sum + pre_01_18[[k]])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum/(dim(pre_01_18)[3]/12)

#writeRaster(ra,filename=name, format="GTiff",overwrite=TRUE)
Rlist[[i]]<-var_avg
}
##########for loop ends##########

#save a stack of months averages

Prec_Stack<-stack(Rlist)
writeRaster(Prec_Stack,filename='Prec_Stack_01-19_TC.tif',"GTiff",overwrite=TRUE)


########################################################################

# POTENTIAL EVAPOTRANSPIRATION 

# Have one month ETP ( January)

pet_Jan_1<-pet_01_18[[1]]

dim(pet_Jan_1)

# Create empty list
Rlist<-list()

# Average of 18 years (j)  and 12 months (i) 
############for loop starts##############
for (i in 1:12) { 

var_sum<-pet_Jan_1*0
k<-i

for (j in 1:(dim(pet_01_18)[3]/12)) {
print(k)
var_sum<-(var_sum + pet_01_18[[k]])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum/(dim(pet_01_18)[3]/12)

#writeRaster(ra,filename=name, format="GTiff",overwrite=TRUE)
Rlist[[i]]<-var_avg
}
#########for loop ends############

#save a stack of months averages

PET_Stack<-stack(Rlist)
PET_Stack<-PET_Stack*0.1
writeRaster(PET_Stack,filename='PET_Stack_01-19_TC.tif',"GTiff",overwrite=TRUE)





