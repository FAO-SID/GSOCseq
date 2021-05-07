#12/11/2020

# SPATIAL SOIL R  for VECTORS

###### SPIN UP ################

# MSc Ing Agr Luciano E Di Paolo
# Dr Ing Agr Guillermo E Peralta
###################################
# SOilR from Sierra, C.A., M. Mueller, S.E. Trumbore (2012). 
#Models of soil organic matter decomposition: the SoilR package, version 1.0 Geoscientific Model Development, 5(4), 
#1045--1060. URL http://www.geosci-model-dev.net/5/1045/2012/gmd-5-1045-2012.html.
#####################################

rm(list=ls()) 

library(SoilR)
library(raster)
library(rgdal)
library(soilassessment)


# Set working directory 

WD_FOLDER<-("D:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020")

# Vector must be an empty points vector. 

setwd(WD_FOLDER)
Vector<-readOGR("INPUTS/TARGET_POINTS/Target_Points_sub.shp")

# Stack_Set_1 is a stack that contains the spatial variables 

Stack_Set_1<- stack("INPUTS/STACK/Stack_Set_SPIN_UP_AOI.tif")

# Add pixels to the borders to avoid removing costal areas

for (i in 1:nlayers(Stack_Set_1)){
  Stack_Set_1[[i]]<-focal(Stack_Set_1[[i]], w = matrix(1,25,25), fun= mean,  na.rm = TRUE, NAonly=TRUE , pad=TRUE)
}

# Create A vector to save the results

C_INPUT_EQ<-Vector

# use this only for backup

# C_INPUT_EQ<-readOGR("OUTPUTS/1_SPIN_UP/SPIN_UP_BSAS_27-03-2020_332376.shp")

# extract variables to points

Vector_variables<-extract(Stack_Set_1,Vector,df=TRUE)

# Extract the layers from the Vector

SOC_im<-Vector_variables[[2]] # primera banda del stack

clay_im<-Vector_variables[[3]] # segunda banda del stack 

DR_im<-Vector_variables[[40]]

LU_im<-Vector_variables[[41]]

# Define Years for Cinputs calculations

years=seq(1/12,500,by=1/12)

# ROTH C MODEL FUNCTION . 

########## function set up starts###############
Roth_C<-function(Cinputs,years,DPMptf, RPMptf, BIOptf, HUMptf, FallIOM,Temp,Precip,Evp,Cov,Cov1,Cov2,soil.thick,SOC,clay,DR,bare1,LU)

{

# Paddy fields coefficent fPR = 0.4 if the target point is class = 13 , else fPR=1
# From Shirato and Yukozawa 2004

fPR=(LU == 13)*0.4 + (LU!=13)*1

#Temperature effects per month
fT=fT.RothC(Temp[,2]) 

#Moisture effects per month . 

fw1func<-function(P, E, S.Thick = 30, pClay = 32.0213, pE = 1, bare) 
{
   
    M = P - E * pE
    Acc.TSMD = NULL
    for (i in 2:length(M)) {
 	B = ifelse(bare[i] == FALSE, 1, 1.8)
	 Max.TSMD = -(20 + 1.3 * pClay - 0.01 * (pClay^2)) * (S.Thick/23) * (1/B)
        Acc.TSMD[1] = ifelse(M[1] > 0, 0, M[1])
        if (Acc.TSMD[i - 1] + M[i] < 0) {
            Acc.TSMD[i] = Acc.TSMD[i - 1] + M[i]
        }
        else (Acc.TSMD[i] = 0)
        if (Acc.TSMD[i] <= Max.TSMD) {
            Acc.TSMD[i] = Max.TSMD
        }
    }
    b = ifelse(Acc.TSMD > 0.444 * Max.TSMD, 1, (0.2 + 0.8 * ((Max.TSMD - 
        Acc.TSMD)/(Max.TSMD - 0.444 * Max.TSMD))))
	b<-clamp(b,lower=0.2)
    return(data.frame(b))	
}

fW_2<- fw1func(P=(Precip[,2]), E=(Evp[,2]), S.Thick = soil.thick, pClay = clay, pE = 1, bare=bare1)$b 

#Vegetation Cover effects 

fC<-Cov2[,2]

# Set the factors frame for Model calculations

xi.frame=data.frame(years,rep(fT*fW_2*fC*fPR,length.out=length(years)))

# RUN THE MODEL from soilassessment
#Roth C soilassesment
Model3_spin=carbonTurnover(tt=years,C0=c(DPMptf, RPMptf, BIOptf, HUMptf, FallIOM),In=Cinputs,Dr=DR,clay=clay,effcts=xi.frame, "euler") 
Ct3_spin=Model3_spin[,2:6]

# RUN THE MODEL FROM SOILR
#Model3_spin=RothCModel(t=years,C0=c(DPMptf, RPMptf, BIOptf, HUMptf, FallIOM),In=Cinputs,DR=DR,clay=clay,xi=xi.frame, pass=TRUE) 
#Ct3_spin=getC(Model3_spin)

# Get the final pools of the time series
poolSize3_spin=as.numeric(tail(Ct3_spin,1))

return(poolSize3_spin)
}
########## function set up ends###############

# Iterates over the area of interest

########for loop starts###############3
for (i in 1:dim(Vector_variables)[1]) {

# Extract the variables 

Vect<-as.data.frame(Vector_variables[i,])

Temp<-as.data.frame(t(Vect[4:15]))
Temp<-data.frame(Month=1:12, Temp=Temp[,1])

Precip<-as.data.frame(t(Vect[16:27]))
Precip<-data.frame(Month=1:12, Precip=Precip[,1])

Evp<-as.data.frame(t(Vect[28:39]))
Evp<-data.frame(Month=1:12, Evp=Evp[,1])
	
Cov<-as.data.frame(t(Vect[42:53]))
Cov1<-data.frame(Cov=Cov[,1])
Cov2<-data.frame(Month=1:12, Cov=Cov[,1])

#Avoid calculus over Na values 

if (any(is.na(Evp[,2])) | any(is.na(Temp[,2])) | any(is.na(SOC_im[i])) | any(is.na(clay_im[i])) | any(is.na(Precip[,2]))  |  any(is.na(Cov2[,2]))  |  any(is.na(Cov1[,1]))  | any(is.na(DR_im[i])) |  (SOC_im[i]<0) | (clay_im[i]<0) ) {C_INPUT_EQ[i,2]<-0}else{

# Set the variables from the images

soil.thick=30  #Soil thickness (organic layer topsoil), in cm
SOC<-SOC_im[i]      #Soil organic carbon in Mg/ha 
clay<-clay_im[i]        #Percent clay %

DR<-DR_im[i]              # DPM/RPM (decomplosable vs resistant plant material.)
bare1<-(Cov1>0.8)           # If the surface is bare or vegetated
LU<-LU_im[i]

#IOM using Falloon method
FallIOM=0.049*SOC^(1.139) 

# If you use a SOC uncertainty layer turn on this. First open the layer SOC_UNC 
#(it must have the same extent and resolution of the SOC layer)

#SOC_min<-(1-(SOC_UNC/100))*SOC
#SOC_max<-(1+(SOC_UNC/100))*SOC

# Define SOC min, max Clay min and max. 
SOC_min<-SOC*0.8
SOC_max<-SOC*1.2
clay_min<-clay*0.9
clay_max<-clay*1.1

b<-1

# C input equilibrium. (Ceq)

fb<-Roth_C(Cinputs=b,years=years,DPMptf=0, RPMptf=0, BIOptf=0, HUMptf=0, FallIOM=FallIOM,Temp=Temp,Precip=Precip,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC,clay=clay,DR=DR,bare1=bare1,LU=LU)
fb_t<-fb[1]+fb[2]+fb[3]+fb[4]+fb[5]

m<-(fb_t-FallIOM)/(b)

Ceq<-(SOC-FallIOM)/m

# UNCERTAINTIES C input equilibrium (MINIMUM)
FallIOM_min=0.049*SOC_min^(1.139) 

fb_min<-Roth_C(Cinputs=b,years=years,DPMptf=0, RPMptf=0, BIOptf=0, HUMptf=0, FallIOM=FallIOM,Temp=Temp*1.02,Precip=Precip*0.95,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC_min,clay=clay_min,DR=DR,bare1=bare1,LU=LU)
fb_t_MIN<-fb_min[1]+fb_min[2]+fb_min[3]+fb_min[4]+fb_min[5]

m<-(fb_t_MIN-FallIOM_min)/(b)

Ceq_MIN<-(SOC_min-FallIOM_min)/m

# UNCERTAINTIES C input equilibrium (MAXIMUM)
FallIOM_max=0.049*SOC_max^(1.139) 

fb_max<-Roth_C(Cinputs=b,years=years,DPMptf=0, RPMptf=0, BIOptf=0, HUMptf=0, FallIOM=FallIOM,Temp=Temp*0.98,Precip=Precip*1.05,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC_max,clay=clay_max,DR=DR,bare1=bare1,LU=LU)
fb_t_MAX<-fb_max[1]+fb_max[2]+fb_max[3]+fb_max[4]+fb_max[5]

m<-(fb_t_MAX-FallIOM_max)/(b)

Ceq_MAX<-(SOC_max-FallIOM_max)/m
 
# SOC POOLS AFTER 500 YEARS RUN WITH C INPUT EQUILIBRIUM

if (LU==2 | LU==12 | LU==13){
RPM_p_2<-((0.184*SOC + 0.1555)*(clay + 1.275)^(-0.1158))*0.9902+0.4788
BIO_p_2<-((0.014*SOC + 0.0075)*(clay + 8.8473)^(0.0567))*1.09038+0.04055
HUM_p_2<-((0.7148*SOC + 0.5069)*(clay + 0.3421)^(0.0184))*0.9878-0.3818
DPM_p_2<-SOC-FallIOM-RPM_p_2-HUM_p_2-BIO_p_2

feq_t<-RPM_p_2+BIO_p_2+HUM_p_2+DPM_p_2+FallIOM

#uncertainties  MIN

RPM_p_2_min<-((0.184*SOC_min + 0.1555)*(clay_min + 1.275)^(-0.1158))*0.9902+0.4788
BIO_p_2_min<-((0.014*SOC_min + 0.0075)*(clay_min + 8.8473)^(0.0567))*1.09038+0.04055
HUM_p_2_min<-((0.7148*SOC_min + 0.5069)*(clay_min + 0.3421)^(0.0184))*0.9878-0.3818
DPM_p_2_min<-SOC_min-FallIOM_min-RPM_p_2_min-HUM_p_2_min-BIO_p_2_min

feq_t_min<-RPM_p_2_min+BIO_p_2_min+HUM_p_2_min+DPM_p_2_min+FallIOM_min

#uncertainties  MAX

RPM_p_2_max<-((0.184*SOC_max + 0.1555)*(clay_max + 1.275)^(-0.1158))*0.9902+0.4788
BIO_p_2_max<-((0.014*SOC_max + 0.0075)*(clay_max + 8.8473)^(0.0567))*1.09038+0.04055
HUM_p_2_max<-((0.7148*SOC_max + 0.5069)*(clay_max + 0.3421)^(0.0184))*0.9878-0.3818
DPM_p_2_max<-SOC_max-FallIOM_max-RPM_p_2_max-HUM_p_2_max-BIO_p_2_max

feq_t_max<-RPM_p_2_max+BIO_p_2_max+HUM_p_2_max+DPM_p_2_max+FallIOM_max

C_INPUT_EQ[i,2]<-SOC
C_INPUT_EQ[i,3]<-Ceq
C_INPUT_EQ[i,4]<-feq_t
C_INPUT_EQ[i,5]<-DPM_p_2
C_INPUT_EQ[i,6]<-RPM_p_2
C_INPUT_EQ[i,7]<-BIO_p_2
C_INPUT_EQ[i,8]<-HUM_p_2
C_INPUT_EQ[i,9]<-FallIOM
C_INPUT_EQ[i,10]<-Ceq_MIN
C_INPUT_EQ[i,11]<-Ceq_MAX
C_INPUT_EQ[i,12]<-feq_t_min
C_INPUT_EQ[i,13]<-DPM_p_2_min
C_INPUT_EQ[i,14]<-RPM_p_2_min
C_INPUT_EQ[i,15]<-BIO_p_2_min
C_INPUT_EQ[i,16]<-HUM_p_2_min
C_INPUT_EQ[i,17]<-FallIOM_min
C_INPUT_EQ[i,18]<-feq_t_max
C_INPUT_EQ[i,19]<-DPM_p_2_max
C_INPUT_EQ[i,20]<-RPM_p_2_max
C_INPUT_EQ[i,21]<-BIO_p_2_max
C_INPUT_EQ[i,22]<-HUM_p_2_max
C_INPUT_EQ[i,23]<-FallIOM_max

}else if(LU==4){

RPM_p_4<-((0.184*SOC + 0.1555)*(clay + 1.275)^(-0.1158))*1.7631+0.4043
BIO_p_4<-((0.014*SOC + 0.0075)*(clay + 8.8473)^(0.0567))*0.9757+0.0209
HUM_p_4<-((0.7148*SOC + 0.5069)*(clay + 0.3421)^(0.0184))*0.8712-0.2904
DPM_p_4<-SOC-FallIOM-RPM_p_4-HUM_p_4-BIO_p_4

feq_t<-RPM_p_4+BIO_p_4+HUM_p_4+DPM_p_4+FallIOM

#uncertainties min

RPM_p_4_min<-((0.184*SOC_min + 0.1555)*(clay_min + 1.275)^(-0.1158))*1.7631+0.4043
BIO_p_4_min<-((0.014*SOC_min + 0.0075)*(clay_min + 8.8473)^(0.0567))*0.9757+0.0209
HUM_p_4_min<-((0.7148*SOC_min + 0.5069)*(clay_min + 0.3421)^(0.0184))*0.8712-0.2904
DPM_p_4_min<-SOC_min-FallIOM_min-RPM_p_4_min-HUM_p_4_min-BIO_p_4_min

feq_t_min<-RPM_p_4_min+BIO_p_4_min+HUM_p_4_min+DPM_p_4_min+FallIOM_min

#uncertainties max

RPM_p_4_max<-((0.184*SOC_max + 0.1555)*(clay_max + 1.275)^(-0.1158))*1.7631+0.4043
BIO_p_4_max<-((0.014*SOC_max + 0.0075)*(clay_max + 8.8473)^(0.0567))*0.9757+0.0209
HUM_p_4_max<-((0.7148*SOC_max + 0.5069)*(clay_max + 0.3421)^(0.0184))*0.8712-0.2904
DPM_p_4_max<-SOC_max-FallIOM_max-RPM_p_4_max-HUM_p_4_max-BIO_p_4_max

feq_t_max<-RPM_p_4_max+BIO_p_4_max+HUM_p_4_max+DPM_p_4_max+FallIOM_max

C_INPUT_EQ[i,2]<-SOC
C_INPUT_EQ[i,3]<-Ceq
C_INPUT_EQ[i,4]<-feq_t
C_INPUT_EQ[i,5]<-DPM_p_4
C_INPUT_EQ[i,6]<-RPM_p_4
C_INPUT_EQ[i,7]<-BIO_p_4
C_INPUT_EQ[i,8]<-HUM_p_4
C_INPUT_EQ[i,9]<-FallIOM
C_INPUT_EQ[i,10]<-Ceq_MIN
C_INPUT_EQ[i,11]<-Ceq_MAX
C_INPUT_EQ[i,12]<-feq_t_min
C_INPUT_EQ[i,13]<-DPM_p_4_min
C_INPUT_EQ[i,14]<-RPM_p_4_min
C_INPUT_EQ[i,15]<-BIO_p_4_min
C_INPUT_EQ[i,16]<-HUM_p_4_min
C_INPUT_EQ[i,17]<-FallIOM_min
C_INPUT_EQ[i,18]<-feq_t_max
C_INPUT_EQ[i,19]<-DPM_p_4_max
C_INPUT_EQ[i,20]<-RPM_p_4_max
C_INPUT_EQ[i,21]<-BIO_p_4_max
C_INPUT_EQ[i,22]<-HUM_p_4_max
C_INPUT_EQ[i,23]<-FallIOM_max

} else if (LU==3 | LU==5 | LU==6 | LU==8){

RPM_p_3<-((0.184*SOC + 0.1555)*(clay + 1.275)^(-0.1158))*1.3837+0.4692
BIO_p_3<-((0.014*SOC + 0.0075)*(clay + 8.8473)^(0.0567))*1.03401+0.02531
HUM_p_3<-((0.7148*SOC + 0.5069)*(clay + 0.3421)^(0.0184))*0.9316-0.5243
DPM_p_3<-SOC-FallIOM-RPM_p_3-HUM_p_3-BIO_p_3

feq_t<-RPM_p_3+BIO_p_3+HUM_p_3+DPM_p_3+FallIOM

#uncertainties min

RPM_p_3_min<-((0.184*SOC_min + 0.1555)*(clay_min + 1.275)^(-0.1158))*1.3837+0.4692
BIO_p_3_min<-((0.014*SOC_min + 0.0075)*(clay_min + 8.8473)^(0.0567))*1.03401+0.02531
HUM_p_3_min<-((0.7148*SOC_min + 0.5069)*(clay_min + 0.3421)^(0.0184))*0.9316-0.5243
DPM_p_3_min<-SOC_min-FallIOM_min-RPM_p_3_min-HUM_p_3_min-BIO_p_3_min

feq_t_min<-RPM_p_3_min+BIO_p_3_min+HUM_p_3_min+DPM_p_3_min+FallIOM_min

#uncertainties max

RPM_p_3_max<-((0.184*SOC_max + 0.1555)*(clay_max + 1.275)^(-0.1158))*1.3837+0.4692
BIO_p_3_max<-((0.014*SOC_max + 0.0075)*(clay_max + 8.8473)^(0.0567))*1.03401+0.02531
HUM_p_3_max<-((0.7148*SOC_max + 0.5069)*(clay_max + 0.3421)^(0.0184))*0.9316-0.5243
DPM_p_3_max<-SOC_max-FallIOM_max-RPM_p_3_max-HUM_p_3_max-BIO_p_3_max

feq_t_max<-RPM_p_3_max+BIO_p_3_max+HUM_p_3_max+DPM_p_3_max+FallIOM_max


C_INPUT_EQ[i,2]<-SOC
C_INPUT_EQ[i,3]<-Ceq
C_INPUT_EQ[i,4]<-feq_t
C_INPUT_EQ[i,5]<-DPM_p_3
C_INPUT_EQ[i,6]<-RPM_p_3
C_INPUT_EQ[i,7]<-BIO_p_3
C_INPUT_EQ[i,8]<-HUM_p_3
C_INPUT_EQ[i,9]<-FallIOM
C_INPUT_EQ[i,10]<-Ceq_MIN
C_INPUT_EQ[i,11]<-Ceq_MAX
C_INPUT_EQ[i,12]<-feq_t_min
C_INPUT_EQ[i,13]<-DPM_p_3_min
C_INPUT_EQ[i,14]<-RPM_p_3_min
C_INPUT_EQ[i,15]<-BIO_p_3_min
C_INPUT_EQ[i,16]<-HUM_p_3_min
C_INPUT_EQ[i,17]<-FallIOM_min
C_INPUT_EQ[i,18]<-feq_t_max
C_INPUT_EQ[i,19]<-DPM_p_3_max
C_INPUT_EQ[i,20]<-RPM_p_3_max
C_INPUT_EQ[i,21]<-BIO_p_3_max
C_INPUT_EQ[i,22]<-HUM_p_3_max
C_INPUT_EQ[i,23]<-FallIOM_max

}else {
C_INPUT_EQ[i,2]<-SOC
C_INPUT_EQ[i,3]<-Ceq
C_INPUT_EQ[i,4]<-0
C_INPUT_EQ[i,5]<-0
C_INPUT_EQ[i,6]<-0
C_INPUT_EQ[i,7]<-0
C_INPUT_EQ[i,8]<-0
C_INPUT_EQ[i,9]<-0
C_INPUT_EQ[i,10]<-0
C_INPUT_EQ[i,11]<-0
C_INPUT_EQ[i,12]<-0
C_INPUT_EQ[i,13]<-0
C_INPUT_EQ[i,14]<-0
C_INPUT_EQ[i,15]<-0
C_INPUT_EQ[i,16]<-0
C_INPUT_EQ[i,17]<-0
C_INPUT_EQ[i,18]<-0
C_INPUT_EQ[i,19]<-0
C_INPUT_EQ[i,20]<-0
C_INPUT_EQ[i,21]<-0
C_INPUT_EQ[i,22]<-0
C_INPUT_EQ[i,23]<-0

}

print(c(i,SOC,Ceq))

}
}
###############for loop ends##############


#rename de columns

colnames(C_INPUT_EQ@data)[2]="SOC_FAO"
colnames(C_INPUT_EQ@data)[3]="Cinput_EQ"
colnames(C_INPUT_EQ@data)[4]="SOC_pedotransfer"
colnames(C_INPUT_EQ@data)[5]="DPM_pedotransfer"
colnames(C_INPUT_EQ@data)[6]="RPM_pedotransfer"
colnames(C_INPUT_EQ@data)[7]="BIO_pedotransfer"
colnames(C_INPUT_EQ@data)[8]="HUM_pedotransfer"
colnames(C_INPUT_EQ@data)[9]="IOM_pedotransfer"
colnames(C_INPUT_EQ@data)[10]="CIneq_min"
colnames(C_INPUT_EQ@data)[11]="CIneq_max"
colnames(C_INPUT_EQ@data)[12]="SOC_min"
colnames(C_INPUT_EQ@data)[13]="DPM_min"
colnames(C_INPUT_EQ@data)[14]="RPM_min"
colnames(C_INPUT_EQ@data)[15]="BIO_min"
colnames(C_INPUT_EQ@data)[16]="HUM_min"
colnames(C_INPUT_EQ@data)[17]="IOM_min"
colnames(C_INPUT_EQ@data)[18]="SOC_max"
colnames(C_INPUT_EQ@data)[19]="DPM_max"
colnames(C_INPUT_EQ@data)[20]="RPM_max"
colnames(C_INPUT_EQ@data)[21]="BIO_max"
colnames(C_INPUT_EQ@data)[22]="HUM_max"
colnames(C_INPUT_EQ@data)[23]="IOM_max"

# SAVE the Points (shapefile)

setwd("D:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/OUTPUTS/1_SPIN_UP")
writeOGR(C_INPUT_EQ, ".", "SPIN_UP_County_AOI", driver="ESRI Shapefile",overwrite=TRUE) 

