#DATE: 12-11-2020

# MSc Ing.Agr. Luciano E. DI Paolo
# PHD Ing.Agr. Guillermo E. Peralta


# MIAMI MODEL

library(raster)
library(rgdal)

WD_NPP<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/NPP")

WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")

WD_GSOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")

WD_CRU_LAYERS<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")

setwd(WD_CRU_LAYERS)

# Open Anual Precipitation (mm) and Mean Anual Temperature (grades C) stacks

Temp<-stack("Temp_Stack_240_81-00_CRU.tif")
Prec<-stack("Prec_Stack_240_81-00_CRU.tif")

setwd(WD_AOI)
AOI<-readOGR("Departamento_Pergamino.shp")

#Temp<-crop(Temp,AOI)
#Prec<-crop(Prec,AOI)

# Temperature Annual Mean 

k<-1
TempList<-list()
#######loop for starts#########
for (i in 1:20){

Temp1<-mean(Temp[[k:(k+11)]])
TempList[i]<-Temp1

k<-k+12
}
#######loop for ends##########
TempStack<-stack(TempList)

#Annual Precipitation

k<-1
PrecList<-list()
########loop for starts#######
for (i in 1:20){

Prec1<-sum(Prec[[k:(k+11)]])
PrecList[i]<-Prec1

k<-k+12
}
########loop for ends#######
PrecStack<-stack(PrecList)

# Calculate eq 1 from MIAMI MODEL (g DM/m2/day)

NPP_Prec<-3000*(1-exp(-0.000664*PrecStack))

# Calculate eq 2 from MIAMI MODEL (g DM/m2/day)

NPP_temp<-3000/(1+exp(1.315-0.119*TempStack))

# Calculate eq 3 from MIAMI MODEL (g DM/m2/day)

NPP_MIAMI_List<-list()

########loop for starts#######
for (i in 1:20){
NPP_MIAMI_List[i]<-min(NPP_Prec[[i]],NPP_temp[[i]])
}
########loop for ends#######

NPP_MIAMI<-stack(NPP_MIAMI_List)

#NPP_MIAMI gDM/m2/year To tn DM/ha/year

NPP_MIAMI_tnDM_Ha_Year<-NPP_MIAMI*(1/100)

#NPP_MIAMI tn DM/ha/year To tn C/ha/year

NPP_MIAMI_tnC_Ha_Year<-NPP_MIAMI_tnDM_Ha_Year*0.5

# Save WORLD NPP MIAMI MODEL tnC/ha/year

setwd(WD_NPP)

writeRaster(NPP_MIAMI_tnC_Ha_Year,filename="NPP_MIAMI_tnC_Ha_Year_STACK_81-00.tif",format="GTiff",overwrite=TRUE)

#NPP_MIAMI_tnC_Ha_Year<-stack("NPP_MIAMI_tnC_Ha_Year_STACK_81-00.tif")

# NPP MEAN

NPP_MIAMI_MEAN_81_00<-mean(NPP_MIAMI_tnC_Ha_Year)

# Open the shapefile of the region/country

setwd(WD_AOI)

AOI<-readOGR("Departamento_Pergamino.shp")

#Open FAO GSOC MAP 

setwd(WD_GSOC)

SOC_MAP_AOI<-raster("SOC_MAP_AOI.tif")

# Crop & mask

setwd(WD_NPP)

NPP_MIAMI_MEAN_81_00_AOI<-crop(NPP_MIAMI_MEAN_81_00,AOI)
NPP_MIAMI_MEAN_81_00_AOI<-resample(NPP_MIAMI_MEAN_81_00_AOI,SOC_MAP_AOI)
NPP_MIAMI_MEAN_81_00_AOI<-mask(NPP_MIAMI_MEAN_81_00_AOI,AOI)

writeRaster(NPP_MIAMI_MEAN_81_00_AOI,filename="NPP_MIAMI_MEAN_81-00_AOI.tif",format="GTiff",overwrite=TRUE)
writeRaster(NPP_MIAMI_MEAN_81_00,filename="NPP_MIAMI_MEAN_81-00.tif",format="GTiff",overwrite=TRUE)


#UNCERTAINTIES MINIMUM TEMP , PREC

Temp_min<-Temp*1.02
Prec_min<-Prec*0.95

# Temperature Annual Mean 

k<-1
TempList<-list()
########loop for starts#######
for (i in 1:20){

Temp1<-mean(Temp_min[[k:(k+11)]])
TempList[i]<-Temp1

k<-k+12
}
########loop for ends#######

TempStack<-stack(TempList)

#Annual Precipitation

k<-1
PrecList<-list()

########loop for starts#######
for (i in 1:20){

Prec1<-sum(Prec_min[[k:(k+11)]])
PrecList[i]<-Prec1

k<-k+12
}
########loop for ends#######

PrecStack<-stack(PrecList)

# Calculate eq 1 from MIAMI MODEL (g DM/m2/day)

NPP_Prec<-3000*(1-exp(-0.000664*PrecStack))

# Calculate eq 2 from MIAMI MODEL (g DM/m2/day)

NPP_temp<-3000/(1+exp(1.315-0.119*TempStack))

# Calculate eq 3 from MIAMI MODEL (g DM/m2/day)

NPP_MIAMI_List<-list()

########loop for starts#######
for (i in 1:20){
NPP_MIAMI_List[i]<-min(NPP_Prec[[i]],NPP_temp[[i]])
}
########loop for ends#######

NPP_MIAMI<-stack(NPP_MIAMI_List)

#NPP_MIAMI gDM/m2/year To tn DM/ha/year

NPP_MIAMI_tnDM_Ha_Year<-NPP_MIAMI*(1/100)

#NPP_MIAMI tn DM/ha/year To tn C/ha/year

NPP_MIAMI_tnC_Ha_Year<-NPP_MIAMI_tnDM_Ha_Year*0.5

# Save WORLD NPP MIAMI MODEL tnC/ha/year

setwd(WD_NPP)

writeRaster(NPP_MIAMI_tnC_Ha_Year,filename="NPP_MIAMI_tnC_Ha_Year_STACK_81-00_MIN.tif",format="GTiff",overwrite=TRUE)

# NPP MEAN

NPP_MIAMI_MEAN_81_00<-mean(NPP_MIAMI_tnC_Ha_Year)

# Crop & and mask

setwd(WD_NPP)

NPP_MIAMI_MEAN_81_00_AOI<-crop(NPP_MIAMI_MEAN_81_00,AOI)
NPP_MIAMI_MEAN_81_00_AOI<-resample(NPP_MIAMI_MEAN_81_00_AOI,SOC_MAP_AOI)
NPP_MIAMI_MEAN_81_00_AOI<-mask(NPP_MIAMI_MEAN_81_00_AOI,AOI)

writeRaster(NPP_MIAMI_MEAN_81_00_AOI,filename="NPP_MIAMI_MEAN_81-00_AOI_MIN.tif",format="GTiff",overwrite=TRUE)
writeRaster(NPP_MIAMI_MEAN_81_00,filename="NPP_MIAMI_MEAN_81-00_MIN.tif",format="GTiff",overwrite=TRUE)


#UNCERTAINTIES MAXIMUM TEMP , PREC

# Open Anual Precipitation (mm) and Mean Anual Temperature (grades C) stacks

Temp_max<-Temp*0.98
Prec_max<-Prec*1.05

# Temperature Annual Mean 

k<-1
TempList<-list()

########loop for starts#######
for (i in 1:20){

Temp1<-mean(Temp_max[[k:(k+11)]])
TempList[i]<-Temp1

k<-k+12
}
########loop for ends#######

TempStack<-stack(TempList)

#Annual Precipitation

k<-1
PrecList<-list()

########loop for starts#######
for (i in 1:20){

Prec1<-sum(Prec_max[[k:(k+11)]])
PrecList[i]<-Prec1

k<-k+12
}
########loop for ends#######

PrecStack<-stack(PrecList)

# Calculate eq 1 from MIAMI MODEL (g DM/m2/day)

NPP_Prec<-3000*(1-exp(-0.000664*PrecStack))

# Calculate eq 2 from MIAMI MODEL (g DM/m2/day)

NPP_temp<-3000/(1+exp(1.315-0.119*TempStack))

# Calculate eq 3 from MIAMI MODEL (g DM/m2/day)

NPP_MIAMI_List<-list()

########loop for starts#######
for (i in 1:20){
NPP_MIAMI_List[i]<-min(NPP_Prec[[i]],NPP_temp[[i]])
}
########loop for ends#######


NPP_MIAMI<-stack(NPP_MIAMI_List)

#NPP_MIAMI gDM/m2/year To tn DM/ha/year

NPP_MIAMI_tnDM_Ha_Year<-NPP_MIAMI*(1/100)

#NPP_MIAMI tn DM/ha/year To tn C/ha/year

NPP_MIAMI_tnC_Ha_Year<-NPP_MIAMI_tnDM_Ha_Year*0.5

# Save NPP MIAMI MODEL tnC/ha/year

setwd(WD_NPP)

writeRaster(NPP_MIAMI_tnC_Ha_Year,filename="NPP_MIAMI_tnC_Ha_Year_STACK_81-00_MAX.tif",format="GTiff",overwrite=TRUE)

# NPP MEAN

NPP_MIAMI_MEAN_81_00<-mean(NPP_MIAMI_tnC_Ha_Year)

# Crop & and mask

setwd(WD_NPP)

NPP_MIAMI_MEAN_81_00_AOI<-crop(NPP_MIAMI_MEAN_81_00,AOI)
NPP_MIAMI_MEAN_81_00_AOI<-resample(NPP_MIAMI_MEAN_81_00_AOI,SOC_MAP_AOI)
NPP_MIAMI_MEAN_81_00_AOI<-mask(NPP_MIAMI_MEAN_81_00_AOI,AOI)

writeRaster(NPP_MIAMI_MEAN_81_00_AOI,filename="NPP_MIAMI_MEAN_81-00_AOI_MAX.tif",format="GTiff",overwrite=TRUE)
writeRaster(NPP_MIAMI_MEAN_81_00,filename="NPP_MIAMI_MEAN_81-00_MAX.tif",format="GTiff",overwrite=TRUE)





