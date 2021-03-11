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

# Have one month temperature layer( January)

tmp_Jan_1<-tmp[,,1]

dim(tmp_Jan_1)

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)

# SAVE 1 layer per month per year

Rlist2<-Rlist
############for loop starts###########
for (q in 1:(dim(tmp)[3])) {
print(q)
var<-(tmp[,,q])

#Save each month average. 

name<-paste0('Temp_1981-2000',q,'.tif')

# Make a raster r from each average
ra<- raster(t(var), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist2[[q]]<-ra
}
##############for loop ends###########

Temp_Stack_2<-stack(Rlist2)
writeRaster(Temp_Stack_2,filename='Temp_Stack_240_81-00_CRU.tif',"GTiff",overwrite=TRUE)

#############################################################################################################################

#PRECIPITATION

rm(list = ls())

WD<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")
setwd(WD)
# Open nc precipitation file 1981-1990

nc_pre_81_90<-nc_open("cru_ts4.03.1981.1990.pre.dat.nc")

lon <- ncvar_get(nc_pre_81_90, "lon")
lat <- ncvar_get(nc_pre_81_90, "lat", verbose = F)
t <- ncvar_get(nc_pre_81_90, "time")

pre_81_90<-ncvar_get(nc_pre_81_90, "pre")

#close de nc precipitation file

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

# Create empty list
r<-raster(ncol=3,nrow=3)
Rlist<-list(r,r,r,r,r,r,r,r,r,r,r,r)
Rlist2<-Rlist

# SAVE 1 layer per month per year
##############for loop starts############
for (q in 1:(dim(pre_81_00)[3])) {
print(q)
var<-(pre_81_00[,,q])

#Save each month average. 

#name<-paste0('Prec_2001-2018',q,'.tif')

# Make a raster r from each average
ra<- raster(t(var), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
ra<-flip(ra, direction='y')
#writeRaster(ra,filename=name, format="GTiff")
Rlist2[[q]]<-ra
}
#################for loop ends#############

Prec_Stack_2<-stack(Rlist2)
writeRaster(Prec_Stack_2,filename='Prec_Stack_240_81-00_CRU.tif',"GTiff",overwrite=TRUE)





