#DATE: 12-11-2020

# MSc Ing Agr Luciano E Di Paolo
# Dr Ing Agr Guillermo E Peralta


#### Prepare the layers for the SPIN UP - WARM UP - FORWARD process of the Roth C Model. 

rm(list = ls())

library(raster)
library(rgdal)

WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")

WD_SOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")

WD_COV<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/COV")

# Open the shapefile of the region/country

setwd(WD_AOI)
AOI<-readOGR("Departamento_Pergamino.shp")

#Open SOC MAP FAO

setwd(WD_SOC)
SOC_MAP_AOI<-raster("SOC_MAP_AOI.tif")

# Open Vegetation Cover layer based only in proportion of NDVI pixels grater than 0.6 

setwd(WD_COV)

Cov1<-raster("NDVI_2015-2019_prop_gt03_M01.tif")
Cov1[is.na(Cov1[])] <- 0
Cov1_crop<-crop(Cov1,AOI)
Cov1_mask<-mask(Cov1_crop,AOI)
Cov1_res<-resample(Cov1_mask,SOC_MAP_AOI,method='bilinear') 

Cov2<-raster("NDVI_2015-2019_prop_gt03_M02.tif")
Cov2[is.na(Cov2[])] <- 0
Cov2_crop<-crop(Cov2,AOI)
Cov2_mask<-mask(Cov2_crop,AOI)
Cov2_res<-resample(Cov2_mask,SOC_MAP_AOI,method='bilinear') 

Cov3<-raster("NDVI_2015-2019_prop_gt03_M03.tif")
Cov3[is.na(Cov3[])] <- 0
Cov3_crop<-crop(Cov3,AOI)
Cov3_mask<-mask(Cov3_crop,AOI)
Cov3_res<-resample(Cov3_mask,SOC_MAP_AOI,method='bilinear') 

Cov4<-raster("NDVI_2015-2019_prop_gt03_M04.tif")
Cov4[is.na(Cov4[])] <- 0
Cov4_crop<-crop(Cov4,AOI)
Cov4_mask<-mask(Cov4_crop,AOI)
Cov4_res<-resample(Cov4_mask,SOC_MAP_AOI,method='bilinear') 

Cov5<-raster("NDVI_2015-2019_prop_gt03_M05.tif")
Cov5[is.na(Cov5[])] <- 0
Cov5_crop<-crop(Cov5,AOI)
Cov5_mask<-mask(Cov5_crop,AOI)
Cov5_res<-resample(Cov5_mask,SOC_MAP_AOI,method='bilinear') 

Cov6<-raster("NDVI_2015-2019_prop_gt03_M06.tif")
Cov6[is.na(Cov6[])] <- 0
Cov6_crop<-crop(Cov6,AOI)
Cov6_mask<-mask(Cov6_crop,AOI)
Cov6_res<-resample(Cov6_mask,SOC_MAP_AOI,method='bilinear') 

Cov7<-raster("NDVI_2015-2019_prop_gt03_M07.tif")
Cov7[is.na(Cov7[])] <- 0
Cov7_crop<-crop(Cov7,AOI)
Cov7_mask<-mask(Cov7_crop,AOI)
Cov7_res<-resample(Cov7_mask,SOC_MAP_AOI,method='bilinear') 

Cov8<-raster("NDVI_2015-2019_prop_gt03_M08.tif")
Cov8[is.na(Cov8[])] <- 0
Cov8_crop<-crop(Cov8,AOI)
Cov8_mask<-mask(Cov8_crop,AOI)
Cov8_res<-resample(Cov8_mask,SOC_MAP_AOI,method='bilinear') 

Cov9<-raster("NDVI_2015-2019_prop_gt03_M09.tif")
Cov9[is.na(Cov9[])] <- 0
Cov9_crop<-crop(Cov9,AOI)
Cov9_mask<-mask(Cov9_crop,AOI)
Cov9_res<-resample(Cov9_mask,SOC_MAP_AOI,method='bilinear') 

Cov10<-raster("NDVI_2015-2019_prop_gt03_M10.tif")
Cov10[is.na(Cov10[])] <- 0
Cov10_crop<-crop(Cov10,AOI)
Cov10_mask<-mask(Cov10_crop,AOI)
Cov10_res<-resample(Cov10_mask,SOC_MAP_AOI,method='bilinear') 

Cov11<-raster("NDVI_2015-2019_prop_gt03_M11.tif")
Cov11[is.na(Cov11[])] <- 0
Cov11_crop<-crop(Cov11,AOI)
Cov11_mask<-mask(Cov11_crop,AOI)
Cov11_res<-resample(Cov11_mask,SOC_MAP_AOI,method='bilinear') 

Cov12<-raster("NDVI_2015-2019_prop_gt03_M12.tif")
Cov12[is.na(Cov12[])] <- 0
Cov12_crop<-crop(Cov12,AOI)
Cov12_mask<-mask(Cov12_crop,AOI)
Cov12_res<-resample(Cov12_mask,SOC_MAP_AOI,method='bilinear') 

Stack_Cov<-stack(Cov1_res,Cov2_res,Cov3_res,Cov4_res,Cov5_res,Cov6_res,Cov7_res,Cov8_res,Cov9_res,Cov10_res,Cov11_res,Cov12_res)

# rescale values to 1 if it is bare soil and 0.6 if it is vegetated.

Cov<-((Stack_Cov)*(-0.4))+1

plot(Cov[[4]],Stack_Cov[[4]])

writeRaster(Cov,filename='Cov_stack_AOI.tif',format='GTiff',overwrite=TRUE)



