library(sf)
library(magrittr)

args = commandArgs(trailingOnly=TRUE) 
input_file<-args[1]
output_path<-args[2]
shp_file<-args[3]

print("++++ COSTRUZIONE FILE DATI OSSERVATI +++++")
print("")
print("")
print("INIZIO LETTURA DATI")
# fileobsieri<-paste("../dati/prova_202007300000.dat",sep="") #tolte le righe con la mezzanotte di ieri
# obsieri<-read.table(fileobsieri,header=F,na.strings=c("-9998.000000","-9999.000000"),sep=",")
# colnames(obsieri)<-c("CodiceStazione","Regione","Lat","Long","TimeStamp","Precipitazione","a","b","c","d")

#fileobsieri<-paste("../dati/prova_202008090000.dat",sep="") #tolte le righe con la mezzanotte di ieri
fileobsieri<-input_file
obsieri<-read.table(fileobsieri,header=F,na.strings=c("-9998.000000","-9999.000000"),sep=",")
colnames(obsieri)<-c("CodiceStazione","Regione","Lat","Long","TimeStamp","Precipitazione","a","b","c","d")
obsieri<-obsieri[,1:6]
nrighe=nrow(obsieri)

print("FINE LETTURA DATI")

print("INIZIO CALCOLO MEDIE E MASSIME OGNI SEI ORE PER OGNI STAZIONE")
obs_mediemax=matrix(, nrow = 0, ncol = 6)
colnames(obs_mediemax)<-c("CodiceStazione","Long","Lat","Scadenza","Max","Media")

bai=6
for (s in seq(1,nrighe,by=bai)){
    dati_stazione<-obsieri[s:(s+5),]
    for(i in seq(1,bai)){
        if(!is.na(dati_stazione[i,6]) && dati_stazione[i,6]>=300){
            dati_stazione[i,6]=NA
        }
    }
    massima<-max(dati_stazione[,6],na.rm=T)
    media<-mean(dati_stazione[,6],na.rm=T)
    if(is.infinite(massima) || is.nan(massima)){
        massima=NA
    }
    if(is.infinite(media) || is.nan(media)){
        media=NA
    }
    codice_staz=as.character(dati_stazione[1,"CodiceStazione"])
    obs_mediemax<-rbind(obs_mediemax,c(codice_staz,dati_stazione[1,"Long"],dati_stazione[1,"Lat"],substr(dati_stazione[6,"TimeStamp"],9,12),massima,media))    
}
print("FINE CALCOLO MEDIE E MASSIME OGNI SEI ORE PER OGNI STAZIONE")

print("INIZIO ASSOCIAZIONE STAZIONI CON AREE DI VIGILANZA")
obs_mediemax_matrix<-obs_mediemax
obs_mediemax[,"Long"]<-as.numeric(as.character(obs_mediemax[,"Long"]))
obs_mediemax[,"Lat"]<-as.numeric(as.character(obs_mediemax[,"Lat"]))

obs_mediemax<-as.data.frame(obs_mediemax,na.strings=NA)
obs_mediemax$Long<-as.numeric(as.character(obs_mediemax$Long))
obs_mediemax$Lat<-as.numeric(as.character(obs_mediemax$Lat))
obs_mediemax<-obs_mediemax[which(obs_mediemax$Long>0 & obs_mediemax$Lat>0),]

coordinate<-data.frame("x"=obs_mediemax$Long,"y"=obs_mediemax$Lat)

tt <- read_sf(shp_file)
# #tt <- st_transform(tt, 4326) #Not sure if this step is required with sf?

# create a points collection
pnts_sf <- do.call("st_sfc",c(lapply(1:nrow(coordinate), 
function(i) {st_point(as.numeric(coordinate[i, ]))}), list("crs" = 4326))) 

pnts_trans <- st_transform(pnts_sf, 2163) # apply transformation to pnts sf
tt1_trans <- st_transform(tt, 2163)      # apply transformation to polygons sf

# intersect and extract state name
coordinate$IDAreaVigilanza <- apply(st_intersects(tt1_trans, pnts_trans, sparse = FALSE), 2, 
               function(col) { 
                  tt1_trans[which(col), ]$OBJECTID
               })
coordinate$IDAreaVigilanza<-as.numeric(as.character(coordinate$IDAreaVigilanza))
coordinate<-cbind(coordinate,"CodiceStazione"=obs_mediemax$CodiceStazione)
obs_mediemax<-cbind(obs_mediemax,"IDAreaVigilanza"=coordinate$IDAreaVigilanza)
print("FINE ASSOCIAZIONE STAZIONI CON AREE DI VIGILANZA")

print("INIZIO CORREZIONE STAZIONI AREE NON ASSOCIATE")
non_associati<-coordinate[which(is.na(coordinate$IDAreaVigilanza)),]
non_associati_new <- non_associati[FALSE,]

for(i in seq(1,nrow(non_associati),by=4)){
    non_associati_new=rbind(non_associati_new,non_associati[i,])
}
print(non_associati_new)

nrows_tot<-dim(obs_mediemax_matrix)[1]
nrows_non_ass<-dim(non_associati_new)[1]

R=6371 #raggio medio terra
for (n in seq(1,nrows_non_ass)){
    min=100000000
    stazione_min=""
    for(i in seq(1,nrows_tot)){
        if(!(obs_mediemax_matrix[i,"CodiceStazione"] %in% non_associati_new[,"CodiceStazione"])){
            longdiff=(as.numeric(obs_mediemax_matrix[i,"Long"])-non_associati_new[n,"x"])*3.14/180
            lat1=as.numeric(obs_mediemax_matrix[i,"Lat"])*3.14/180
            lat2=non_associati_new[n,"y"]*3.14/180
            latdiff=(lat1-lat2)
            a=sin(latdiff/2)^2 + cos(lat1)*cos(lat2)*(sin(longdiff/2)^2)
            c=2*asin(sqrt(a))
            distanza<-R*c
            if(distanza<min){
                min=distanza
                stazione_min=obs_mediemax_matrix[i,"CodiceStazione"]
            }
        }
    }
    if(stazione_min!=""){
        area_da_associare=obs_mediemax[which(obs_mediemax$CodiceStazione==stazione_min & obs_mediemax$Scadenza=="0000"),"IDAreaVigilanza"]
        obs_mediemax[which(obs_mediemax$CodiceStazione==non_associati_new[n,"CodiceStazione"]),"IDAreaVigilanza"]=area_da_associare
        non_associati_new[n,"IDAreaVigilanza"]=area_da_associare
    }
}
print(non_associati_new)

print("FINE CORREZIONE STAZIONI AREE NON ASSOCIATE")
print("")
print("INIZIO SCRITTURA FILE MAX E MED IN OUTPUT")
aree_vigilanza<-unique(obs_mediemax$IDAreaVigilanza)
aree_vigilanza<-sort(as.numeric(as.character(aree_vigilanza)))

scadenze<-c("0600","1200","1800","0000")

#### STAMPARE MAX E MED FILE OSSERVATI 4 COLONNE 70 RIGHE
obsMAX_qpf_perScadenza_perArea=matrix(, nrow = 0, ncol = 4, dimnames = NULL)
obsMED_qpf_perScadenza_perArea=matrix(, nrow = 0, ncol = 4, dimnames = NULL)

for(area in aree_vigilanza){
    massime=c()
    medie=c()
    for(s in scadenze){
        qpf_area_scadenza<-obs_mediemax[which(obs_mediemax$IDAreaVigilanza==area & obs_mediemax$Scadenza==s),]
        media<-mean(as.numeric(as.character(qpf_area_scadenza$Media)), na.rm=T)
        massima<-max(as.numeric(as.character(qpf_area_scadenza$Max)), na.rm=T)      
        if(is.infinite(massima) || is.nan(massima)){
            massima=-99
        }else{
            massima<-round(massima)
        }
        if(is.infinite(media) || is.nan(media)){
            media=-99
        }else{
            media<-round(media)
        }
        massime=append(massime,massima)
        medie=append(medie,media)
                
    }
    obsMAX_qpf_perScadenza_perArea<-rbind(obsMAX_qpf_perScadenza_perArea,as.numeric(massime))
    obsMED_qpf_perScadenza_perArea<-rbind(obsMED_qpf_perScadenza_perArea,as.numeric(medie))
}

write.table(obsMAX_qpf_perScadenza_perArea, paste(output_path,"/osservati_max.txt",sep=""), append = FALSE, sep = " ", dec = ".", row.names = FALSE, col.names = FALSE)
write.table(obsMED_qpf_perScadenza_perArea, paste(output_path,"/osservati_ave.txt",sep=""), append = FALSE, sep = " ", dec = ".", row.names = FALSE, col.names = FALSE)

print("FINE SCRITTURA FILE")
q()
