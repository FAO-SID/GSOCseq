#DATE: 12-11-2020

# MSc Ing.Agr. Luciano E. DI Paolo
# PHD Ing.Agr. Guillermo E. Peralta


# Install Packages

install.packages(c("raster","rgdal","SoilR","Formula","soilassessment","abind","ncdf4"))

#Load packages

library(raster)
library(rgdal)

# Set Gsoc Fao & Area of interest (AOI) directories

WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")

WD_GSOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")

# Open the shapefile of the region/country

setwd(WD_AOI)
AOI<-readOGR("Departamento_Pergamino.shp")

#Open FAO GSOC MAP , crop it and masked by the aoi. Then save it. 

setwd(WD_GSOC)
SOC_MAP<-raster("GSOCmapV1.2.0_subs.tif")
SOC_MAP_AOI<-crop(SOC_MAP,AOI)
SOC_MAP_AOI<-mask(SOC_MAP_AOI,AOI)

writeRaster(SOC_MAP_AOI,filename="SOC_MAP_AOI.tif",format="GTiff",overwrite=TRUE)

