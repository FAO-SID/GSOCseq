#DATE: 12-11-2020

# MSc Ing Agr Luciano E Di Paolo
# Dr Ing Agr Guillermo E Peralta

#### Prepare the layers for the SPIN UP process of the Roth C Model. 

rm(list = ls())

library(raster)
library(rgdal)

WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")

WD_SOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")

WD_CLAY<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")

WD_CLIM<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")

WD_LU<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/LAND_USE")

WD_COV<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/COV")

WD_STACK<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/STACK")

# Open the shapefile of the region/country
setwd(WD_AOI)
AOI<-readOGR("Departamento_Pergamino.shp")

#Open SOC MAP FAO
setwd(WD_SOC)
SOC_MAP_AOI<-raster("SOC_MAP_AOI.tif")

# Open Clay layer

setwd(WD_CLAY)

Clay_WA_AOI<-raster("Clay_WA_AOI.tif")

Clay_WA_AOI_res<-resample(Clay_WA_AOI,SOC_MAP_AOI,method='bilinear') 

#Open Precipitation layer 

setwd(WD_CLIM)

PREC<-stack("Prec_Stack_81-00_CRU.tif")

PREC_AOI<-crop(PREC,AOI)
PREC_AOI<-resample(PREC_AOI,SOC_MAP_AOI)
PREC_AOI<-mask(PREC_AOI,AOI)
PREC_AOI<-stack(PREC_AOI)

#Open Temperatures layer (CRU https://crudata.uea.ac.uk/cru/data/hrg/)

TEMP<-stack("Temp_Stack_81-00_CRU.tif")

TEMP_AOI<-crop(TEMP,AOI)
TEMP_AOI<-resample(TEMP_AOI,SOC_MAP_AOI)
TEMP_AOI<-mask(TEMP_AOI,AOI)
TEMP_AOI<-stack(TEMP_AOI)

#Open Potential Evapotranspiration layer (CRU https://crudata.uea.ac.uk/cru/data/hrg/)

PET<-stack("PET_Stack_81-00_CRU.tif")

PET_AOI<-crop(PET,AOI)
PET_AOI<-resample(PET_AOI,SOC_MAP_AOI)
PET_AOI<-mask(PET_AOI,AOI)
PET_AOI<-stack(PET_AOI)

# OPen Land Use layer reclassify to FAO classes 

# 0	No Data
# 1 Artificial
# 2 Croplands
# 3 Grassland
# 4 Tree Covered
# 5 Shrubs Covered
# 6 Herbaceous vegetation flooded
# 7 Mangroves
# 8 Sparse Vegetation
# 9 Baresoil
# 10 Snow and Glaciers
# 11 Waterbodies
# 12 TreeCrops
# 13 Paddy fields

setwd(WD_LU)
LU_AOI<-raster("ESA_Land_Cover_12clases_FAO_AOI.tif")

# Open Vegetation Cover layer 

setwd(WD_COV)
Cov_AOI<-stack('Cov_stack_AOI.tif')

# Use Land use layer to convert it to DR layer 

#DPM/RPM (decomplosable vs resistant plant material)
#(1) Most agricultural crops and improved grassland and tree crops 1.44 
#(2) Unimproved grassland and schrub 0.67
#(3) Deciduous and tropical woodland 0.25    

DR<-(LU_AOI==2 | LU_AOI==12| LU_AOI==13)*1.44+ (LU_AOI==4)*0.25 + (LU_AOI==3 | LU_AOI==5 | LU_AOI==6 | LU_AOI==8)*0.67

plot(LU_AOI[[1]],DR[[1]] , pch=3, cex=3, ylab="DPM/RPM", xlab="Land Use classes")

# STACK all layers

Stack_Set_AOI<-stack(SOC_MAP_AOI,Clay_WA_AOI_res,TEMP_AOI,PREC_AOI,PET_AOI,DR,LU_AOI,Cov_AOI)

setwd(WD_STACK)
writeRaster(Stack_Set_AOI,filename=("Stack_Set_SPIN_UP_AOI.tif"),format="GTiff",overwrite=TRUE)


