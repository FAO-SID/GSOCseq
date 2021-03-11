#DATE 11-2-2021
# ADD NPP_MIN AND NPP_MAX TO THE STACK TO CALCULATE UNCERTAINTIES

# MSc Ing Agr Luciano E Di Paolo
# Dr Ing Agr Guillermo E Peralta


#### Prepare the layers for the WARM UP Roth C Model. 

rm(list = ls())

library(raster)
library(rgdal)

# Set the number of years of the warm up
nWUP<-18

WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")

WD_SOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")

WD_CLAY<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")

WD_CLIM<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CRU_LAYERS")

WD_LU<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/LAND_USE")

WD_COV<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/COV")

WD_STACK<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/STACK")

WD_NPP<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/NPP")


# Open the shapefile of the region/country
setwd(WD_AOI)
AOI<-readOGR("Departamento_Pergamino.shp") # change the AOI

#Open SOC MAP 

setwd(WD_SOC)
SOC_MAP_AOI<-raster("SOC_MAP_AOI.tif") # change the SOC_MAP

# Open Clay layers  (ISRIC)

setwd(WD_CLAY)

Clay_WA_AOI<-raster("Clay_WA_AOI.tif")

Clay_WA_AOI_res<-resample(Clay_WA_AOI,SOC_MAP_AOI,method='bilinear') 

# OPen Land Use layer (ESA)

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
LU_AOI<-stack("ESA_Land_Cover_12clases_FAO_Stack_AOI.tif")

# Open Vegetation Cover layer 

setwd(WD_COV)

Cov_AOI<-stack('Cov_stack_AOI.tif')

# Open Land Use Stack , One Land use layer for each year (in this example we use the same LU for the 18 year period

#LU_Stack <-stack(replicate(nWUP, LU_AOI))
#LU_Stack <-stack(ESA[2001:2015],2015,2015,2015)
LU_Stack<-LU_AOI

# Convert LU layer  to DR layer (ESA land use , 14 classes)

#DPM/RPM (decomplosable vs resistant plant material)
#(1) Most agricultural crops and improved grassland or tree crops 1.44 
#(2) Unimproved grassland and schrub 0.67
#(3) Deciduous and tropical woodland 0.25    

#DR<-(LU_AOI==2 | LU_AOI==12 | LU_AOI==13)*1.44+ (LU_AOI==4)*0.25 + (LU_AOI==3 | LU_AOI==5 | LU_AOI==6 | LU_AOI==8)*0.67

DR_Stack<-LU_Stack

for (i in 1:nlayers(LU_Stack)){
DR_Stack[[i]]<-(LU_Stack[[i]]==2 | LU_Stack[[i]]==12 | LU_Stack[[i]]==13)*1.44+ (LU_Stack[[i]]==4)*0.25 + (LU_Stack[[i]]==3 | LU_Stack[[i]]==5 | LU_Stack[[i]]==6 | LU_Stack[[i]]==8)*0.67
}

# STACK all layers

Stack_Set_AOI<-stack(SOC_MAP_AOI,Clay_WA_AOI_res,Cov_AOI,LU_Stack,DR_Stack)

setwd(WD_STACK)
writeRaster(Stack_Set_AOI,filename=("Stack_Set_WARM_UP_AOI.tif"),format="GTiff",overwrite=TRUE)

