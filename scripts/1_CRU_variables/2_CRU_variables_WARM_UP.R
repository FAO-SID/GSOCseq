DATE: 12/11/2020

#  MSc Ing Agr Luciano E. Di Paolo
#  Dr Ing Agr Guillermo E Peralta
#######################################################################################

library(raster)
library(rgdal)
library(ncdf4)
library(abind)

# CRU VARIABLES FROM : https://crudata.uea.ac.uk/cru/data/hrg/
#######################################################################################

WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")
setwd(WD)

# TEMPERATURE

# Open nc temperature file 2001-2010

nc_temp_01_10<-nc_open("cru_ts4.03.2001.2010.tmp.dat.nc")

lon <- ncvar_get(nc_temp_01_10, "lon")
lat <- ncvar_get(nc_temp_01_10, "lat", verbose = F)
t_01_10 <- ncvar_get(nc_temp_01_10, "time")

tmp_01_10<-ncvar_get(nc_temp_01_10, "tmp")

#close de nc temperature file

nc_close(nc_temp_01_10) 

# Open nc temperature file 2010-2018

nc_temp_11_18<-nc_open("cru_ts4.03.2011.2018.tmp.dat.nc")

lon <- ncvar_get(nc_temp_11_18, "lon")
lat <- ncvar_get(nc_temp_11_18, "lat", verbose = F)
t_11_18 <- ncvar_get(nc_temp_11_18, "time")

tmp_11_18<-ncvar_get(nc_temp_11_18, "tmp")

#close de nc temperature file

nc_close(nc_temp_11_18) 

# Merge 2001-2010 and 2011-2018 data 

tmp<-abind(tmp_01_10,tmp_11_18)

# Get one month temperature ( January)

tmp_Jan_1<-tmp[,,1]

dim(tmp_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)

# Average of 20 years (j)  and 12 months (i) 
##########for loop starts###############
for (i in 1:12) { 
var_sum<-tmp_Jan_1*0
k<-i

for (j in 1:(dim(tmp)[3]/12)) {
print(k)
var_sum<-(var_sum + tmp[,,k])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum/(dim(tmp)[3]/12)
name<-paste0('Temp_2001_2018_years_avg_',i,'.tif')

# Make a raster r from each average
ra<- raster(t(var_avg), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist[[i]]<-ra
}
##########for loop ends#############
#save a stack of months averages

Temp_Stack<-stack(Rlist)
writeRaster(Temp_Stack,filename='Temp_Stack_01-18_CRU.tif',"GTiff",overwrite=TRUE)

#Calculate anual average for MIAMI MODEL
Temp_Mean<-(Rlist[[1]]+Rlist[[2]]+Rlist[[3]]+Rlist[[4]]+Rlist[[5]]+Rlist[[6]]+Rlist[[7]]+Rlist[[8]]+Rlist[[9]]+Rlist[[10]]+Rlist[[11]]+Rlist[[12]])/12
writeRaster(Temp_Mean,filename='Temp_mean_01-18_CRU.tif',"GTiff",overwrite=TRUE)

# SAVE 1 layer per month per year

Rlist2<-Rlist

# Create a raster image for each month
###########for loop starts################
for (q in 1:(dim(tmp)[3])) {

var<-(tmp[,,q])

#Save each month average. 

name<-paste0('Temp_2001-2018',q,'.tif')

# Make a raster r from each average
ra<- raster(t(var), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist2[[q]]<-ra
}
############for loop ends#################

Temp_Stack_2<-stack(Rlist2)
writeRaster(Temp_Stack_2,filename='Temp_Stack_216_01-18_CRU.tif',"GTiff",overwrite=TRUE)

#############################################################################################################################

#PRECIPITATION

rm(list = ls())

WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")
setwd(WD)
# Open nc precipitation file 2001-2010

nc_pre_01_10<-nc_open("cru_ts4.03.2001.2010.pre.dat.nc")

lon <- ncvar_get(nc_pre_01_10, "lon")
lat <- ncvar_get(nc_pre_01_10, "lat", verbose = F)
t <- ncvar_get(nc_pre_01_10, "time")

pre_01_10<-ncvar_get(nc_pre_01_10, "pre")

#close de nc temperature file

nc_close(nc_pre_01_10) 

# Open nc precipitation file 2011-2018

nc_pre_11_18<-nc_open("cru_ts4.03.2011.2018.pre.dat.nc")

lon <- ncvar_get(nc_pre_11_18, "lon")
lat <- ncvar_get(nc_pre_11_18, "lat", verbose = F)
t <- ncvar_get(nc_pre_11_18, "time")

pre_11_18<-ncvar_get(nc_pre_11_18, "pre")

#close de nc temperature file

nc_close(nc_pre_11_18) 

# Merge 2001-2010 and 2011-2018 data 

pre_01_18<-abind(pre_01_10,pre_11_18)

# Have one month Precipitation ( January)

pre_Jan_1<-pre_01_18[,,1]

dim(pre_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)


# Average of 20 years (j)  and 12 months (i) 

#########for loop starts############
for (i in 1:12) { 

var_sum<-pre_Jan_1*0
k<-i

for (j in 1:(dim(pre_01_18)[3]/12)) {
print(k)
var_sum<-(var_sum + pre_01_18[,,k])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum/(dim(pre_01_18)[3]/12)

name<-paste0('Prec_2001_2018_years_avg_',i,'.tif')

# Make a raster r from the each average
ra<- raster(t(var_avg), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff",overwrite=TRUE)
Rlist[[i]]<-ra
}
##########for loop ends##########

#save a stack of months averages

Prec_Stack<-stack(Rlist)
writeRaster(Prec_Stack,filename='Prec_Stack_01-18_CRU.tif',"GTiff",overwrite=TRUE)

# SAVE 1 layer per month per year

Rlist2<-Rlist


# Make a raster r from each month

##########for loop starts#########
for (q in 1:(dim(pre_01_18)[3])) {

var<-(pre_01_18[,,q])

#Save each month average. 

name<-paste0('Prec_2001-2018',q,'.tif')

ra<- raster(t(var), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist2[[q]]<-ra
}
###########for loop ends##########

Prec_Stack_2<-stack(Rlist2)
writeRaster(Prec_Stack_2,filename='Prec_Stack_216_01-18_CRU.tif',"GTiff",overwrite=TRUE)

########################################################################

# POTENTIAL EVAPOTRANSPIRATION 

rm(list = ls())
WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")
setwd(WD)
# Open nc temperature file 01 - 10

nc_pet_01_10<-nc_open("cru_ts4.03.2001.2010.pet.dat.nc")

lon <- ncvar_get(nc_pet_01_10, "lon")
lat <- ncvar_get(nc_pet_01_10, "lat", verbose = F)
t <- ncvar_get(nc_pet_01_10, "time")

pet_01_10<-ncvar_get(nc_pet_01_10, "pet")

#close de nc temperature file

nc_close(nc_pet_01_10) 

# Open nc temperature file 11 - 18

nc_pet_11_18<-nc_open("cru_ts4.03.2011.2018.pet.dat.nc")

lon <- ncvar_get(nc_pet_11_18, "lon")
lat <- ncvar_get(nc_pet_11_18, "lat", verbose = F)
t <- ncvar_get(nc_pet_11_18, "time")

pet_11_18<-ncvar_get(nc_pet_11_18, "pet")

#close de nc temperature file

nc_close(nc_pet_11_18) 

# Merge 2001-2010 and 2011-2018 data 

pet_01_18<-abind(pet_01_10,pet_11_18)

# Have one month ETP ( January)

pet_Jan_1<-pet_01_18[,,1]

dim(pet_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)
Rlist2<-Rlist

# Average of 18 years (j)  and 12 months (i) 
############for loop starts##############
for (i in 1:12) { 

var_sum<-pet_Jan_1*0
k<-i

for (j in 1:(dim(pet_01_18)[3]/12)) {
print(k)
var_sum<-(var_sum + pet_01_18[,,k])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum*30/(dim(pet_01_18)[3]/12)
name<-paste0('PET_2001_2018_years_avg_',i,'.tif')

# Make a raster r from the each average
ra<- raster(t(var_avg), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff",overwrite=TRUE)
Rlist[[i]]<-ra
}
#########for loop ends############

#save a stack of months averages

PET_Stack<-stack(Rlist)
writeRaster(PET_Stack,filename='PET_Stack_01-18_CRU.tif',"GTiff",overwrite=TRUE)

# SAVE 1 layer per month 
########for loop starts##########
for (q in 1:(dim(pet_01_18)[3])) {

var<-(pet_01_18[,,q])*30

#Save each month average. 

name<-paste0('PET_2001-2018',q,'.tif')

# Make a raster r from each average
ra<- raster(t(var), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist2[[q]]<-ra
}
#########for loop ends###########

PET_Stack_2<-stack(Rlist2)
writeRaster(PET_Stack_2,filename='PET_Stack_216_01-18_CRU.tif',"GTiff",overwrite=TRUE)





