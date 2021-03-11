#DATE: 12-11-2020

# MSc Ing Agr Luciano E Di Paolo
# Dr Ing Agr Guillermo E Peralta

#ISRIC DATA
#https://data.isric.org/geonetwork/srv/spa/catalog.search#/metadata/20f6245e-40bc-4ade-aff3-a87d3e4fcc26


#### Prepare CLAY Layers from ISRIC

rm(list = ls())

library(raster)
library(rgdal)

WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")

WD_ISRIC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")

WD_CLAY<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")

# Open the shapefile of the region/country
setwd(WD_AOI)
AOI<-readOGR("Departamento_Pergamino.shp")

# Open Clay layers  (ISRIC)

setwd(WD_ISRIC)
Clay1<-raster("CLYPPT_M_sl1_250m_ll_subs.tif")
Clay2<-raster("CLYPPT_M_sl2_250m_ll_subs.tif")
Clay3<-raster("CLYPPT_M_sl3_250m_ll_subs.tif")
Clay4<-raster("CLYPPT_M_sl4_250m_ll_subs.tif")

Clay1_AOI<-crop(Clay1,AOI)
Clay2_AOI<-crop(Clay2,AOI)
Clay3_AOI<-crop(Clay3,AOI)
Clay4_AOI<-crop(Clay4,AOI)

# Weighted Average of four depths 

WeightedAverage<-function(r1,r2,r3,r4){return(r1*(1/30)+r2*(4/30)+r3*(10/30)+r4*(15/30))}

Clay_WA<-overlay(Clay1_AOI,Clay2_AOI,Clay3_AOI,Clay4_AOI,fun=WeightedAverage)

Clay_WA_AOI<-mask(Clay_WA,AOI)

setwd(WD_CLAY)

writeRaster(Clay_WA_AOI,filename="Clay_WA_AOI.tif",format='GTiff',overwrite=TRUE)

