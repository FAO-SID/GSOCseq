DATE:  28/09/2020

#  MSc Ing Agr Luciano E. Di Paolo
#  Dr Ing Agr Guillermo E Peralta
#######################################################################################

library(raster)
library(rgdal)
library(ncdf4)
library(abind)

# CRU VARIABLES FROM : https://crudata.uea.ac.uk/cru/data/hrg/
#######################################################################################

#Set working directory
WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_28-09-2020/INPUTS/CRU_LAYERS")
setwd(WD)
# UNZIP THE CRU FILES!!!!
# TEMPERATURE

# Open nc temperature file 1981-1990 

nc_temp_81_90<-nc_open("cru_ts4.03.1981.1990.tmp.dat.nc")

lon <- ncvar_get(nc_temp_81_90, "lon")
lat <- ncvar_get(nc_temp_81_90, "lat", verbose = F)
t_81_90 <- ncvar_get(nc_temp_81_90, "time")

tmp_81_90<-ncvar_get(nc_temp_81_90, "tmp")

#close de nc temperature file

nc_close(nc_temp_81_90) 

# Open nc temperature file 1991-2000

nc_temp_91_00<-nc_open("cru_ts4.03.1991.2000.tmp.dat.nc")

lon <- ncvar_get(nc_temp_91_00, "lon")
lat <- ncvar_get(nc_temp_91_00, "lat", verbose = F)
t_91_00 <- ncvar_get(nc_temp_91_00, "time")

tmp_91_00<-ncvar_get(nc_temp_91_00, "tmp")

#close de nc temperature file

nc_close(nc_temp_91_00) 

# Merge 1981-1990 and 1991-2000 data 

tmp<-abind(tmp_81_90,tmp_91_00)

# Get one month temperature ( January)

tmp_Jan_1<-tmp[,,1]

dim(tmp_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)

# Average of 20 years (j)  and 12 months (i) 

######for loop starts#######
for (i in 1:12) { 

var_sum<-tmp_Jan_1*0
k<-i

for (j in 1:20) {
print(k)
var_sum<-(var_sum + tmp[,,k])

k<-k+12
}

#Save each month average. 

var_avg<-var_sum/20
name<-paste0('Temp_1981_2000_years_avg_',i,'.tif')

# Make a raster r from each average
ra<- raster(t(var_avg), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist[[i]]<-ra
}
#######for loop ends########

#save a stack of months averages

Temp_Stack<-stack(Rlist)
writeRaster(Temp_Stack,filename='Temp_Stack_81-00_CRU.tif',"GTiff")

#######################################################################################

#PRECIPITATION

rm(list = ls())

WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_28-09-2020/INPUTS/CRU_LAYERS")
setwd(WD)

# Open nc precipitation file 1981-1990

nc_pre_81_90<-nc_open("cru_ts4.03.1981.1990.pre.dat.nc")

lon <- ncvar_get(nc_pre_81_90, "lon")
lat <- ncvar_get(nc_pre_81_90, "lat", verbose = F)
t <- ncvar_get(nc_pre_81_90, "time")

pre_81_90<-ncvar_get(nc_pre_81_90, "pre")

#close de nc temperature file

nc_close(nc_pre_81_90) 

# Open nc precipitation file 1991-2000

nc_pre_91_00<-nc_open("cru_ts4.03.1991.2000.pre.dat.nc")

lon <- ncvar_get(nc_pre_91_00, "lon")
lat <- ncvar_get(nc_pre_91_00, "lat", verbose = F)
t <- ncvar_get(nc_pre_91_00, "time")

pre_91_00<-ncvar_get(nc_pre_91_00, "pre")

#close de nc temperature file

nc_close(nc_pre_91_00) 

# Merge 1981-1990 and 1991-2000 data 

pre_81_00<-abind(pre_81_90,pre_91_00)

# Get one month Precipitation ( January)

pre_Jan_1<-pre_81_00[,,1]

dim(pre_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)

# Average of 20 years (j)  and 12 months (i) 

######for loop starts#######
for (i in 1:12) { 

var_sum<-pre_Jan_1*0
k<-i

for (j in 1:20) {
print(k)
var_sum<-(var_sum + pre_81_00[,,k])
k<-k+12
}
#Save each month average. 

var_avg<-var_sum/20
name<-paste0('Prec_1981_2000_years_avg_',i,'.tif')

# Make a raster r from the each average
ra<- raster(t(var_avg), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist[[i]]<-ra
}

######for loop ends#######

#save a stack of months averages

Prec_Stack<-stack(Rlist)
writeRaster(Prec_Stack,filename='Prec_Stack_81-00_CRU.tif',"GTiff")

########################################################################

# POTENTIAL EVAPOTRANSPIRATION 

rm(list = ls())

WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_28-09-2020/INPUTS/CRU_LAYERS")
setwd(WD)

# Open nc temperature file 81 - 90

nc_pet_81_90<-nc_open("cru_ts4.03.1981.1990.pet.dat.nc")

lon <- ncvar_get(nc_pet_81_90, "lon")
lat <- ncvar_get(nc_pet_81_90, "lat", verbose = F)
t <- ncvar_get(nc_pet_81_90, "time")

pet_81_90<-ncvar_get(nc_pet_81_90, "pet")

#close de nc temperature file

nc_close(nc_pet_81_90) 

# Open nc temperature file 91 - 00

nc_pet_91_00<-nc_open("cru_ts4.03.1991.2000.pet.dat.nc")

lon <- ncvar_get(nc_pet_91_00, "lon")
lat <- ncvar_get(nc_pet_91_00, "lat", verbose = F)
t <- ncvar_get(nc_pet_91_00, "time")

pet_91_00<-ncvar_get(nc_pet_91_00, "pet")

#close de nc temperature file

nc_close(nc_pet_91_00) 

# Merge 1981-1990 and 1991-2000 data 

pet_81_00<-abind(pet_81_90,pet_91_00)

# Get one month PET ( January)

pet_Jan_1<-pet_81_90[,,1]

dim(pet_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)

# Average of 20 years (j)  and 12 months (i) 

######for loop starts#######
for (i in 1:12) { 

var_sum<-pet_Jan_1*0
k<-i

for (j in 1:20) {
print(k)
var_sum<-(var_sum + pet_81_00[,,k])

k<-k+12

}
#Save each month average. 

var_avg<-var_sum*30/20
name<-paste0('PET_1981_2000_years_avg_',i,'.tif')

# Make a raster r from the each average
ra<- raster(t(var_avg), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist[[i]]<-ra
}
######for loop ends#######

#save a stack of months averages

PET_Stack<-stack(Rlist)
writeRaster(PET_Stack,filename='PET_Stack_81-00_CRU.tif',"GTiff")



