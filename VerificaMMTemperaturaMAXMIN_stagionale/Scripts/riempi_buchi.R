#luca monaco 12/05/2020
#Mi sono reso conto che non tutte le stazioni sono sempre presenti nei dati osservati. Inoltre, spesso i modelli non ci sono 
#tutti i giorni di un mese. Questa procedura "riempie" i file di dati osservati o i file di output dei modelli con righe
#vuote laddove mancassero giorni o stazioni, tenendo da conto solo i lead time 06 18 e 30 per garantire una maggiore velocità di
#esecuzione, dato che per la mappa di verifica mi interessano solo quelli. Alla fine, i file avranno lo stesso numero di righe 
#a parità di data.
print("")
print("PROCEDURA PER COMPLETARE I DATI CON LINEE VUOTE LADDOVE NECESSARIO")
args = commandArgs(trailingOnly=TRUE) 
tipo<-args[1]
Year<-args[2]
Month<-args[3]
file_path<-args[4]
anagrafiche_path<-args[5]
save_path<-args[6]

LeadTimeModelli=c("0018","0030")
LeadTimeOss=c("0600","1800")
if (tipo=="OSS"){
    LeadTime<-LeadTimeOss
}else{
    LeadTime<-LeadTimeModelli
}

#Year<-str_sub(file_path,-10,-7)
#Month<-str_sub(file_path,-6,-5)

if(Month %in% c("01","03","05","07","08","10","12")) { 
    Days=seq(1,31) 
}else if (Month %in% c("04","06","09","11")){
    Days=seq(1,30)
}else{
    year=as.numeric(Year)
    if((year %% 4) == 0) {
        if((year %% 100) == 0) {
            if((year %% 400) == 0) {
                Days=seq(1,29)
            } else {
                Days=seq(1,28)
            }
        } else {
            Days=seq(1,29)
        }
    } else {
        Days=seq(1,28)
    }    
}
split_path<-unlist(strsplit(file_path, "/"))
nomefile=tail(split_path,n=1)
print(paste("file:",nomefile))
print(paste("Anno:",Year))
print(paste("Mese:",Month))
print(paste("Numero di giorni:",tail(Days,n=1)))
print("")

#importo gli osservati
if (tipo!="MMSUP"){
    dati<-read.delim(file_path, header=FALSE, sep = "", col.names = c("CodiceStazione","PrevisionDay", "LeadTime", "Dummy1","Dummy2","Dummy3","Dummy4","Dummy5","TempMaxMin","Dummy6"),colClasses='character')    
    filled_dati<-data.frame(CodiceStazione=character(),PrevisionDay=character(),LeadTime=character(), Dummy1=character(),Dummy2=character(),Dummy3=character(),Dummy4=character(),Dummy5=character(),TempMaxMin=character(),Dummy6=character())
}else{
    dati<-read.delim(file_path, header=FALSE, sep = "", col.names = c("CodiceStazione","PrevisionDay", "LeadTime", "Dummy1","Dummy2","Dummy3","Dummy4","Dummy5","TempMaxMin"),colClasses='character')    
    filled_dati<-data.frame(CodiceStazione=character(),PrevisionDay=character(),LeadTime=character(), Dummy1=character(),Dummy2=character(),Dummy3=character(),Dummy4=character(),Dummy5=character(),TempMaxMin=character())
}
dati<-dati[dati$LeadTime %in% LeadTime, ]
dati_anagrafiche<-read.fwf(anagrafiche_path, widths=c(7), header=FALSE, sep = " ", col.names = c("CodiceStazione"),colClasses='character')
stazioni<-dati_anagrafiche$CodiceStazione
cont=0
for (d in Days)  {
    if (d<10){
        Day=paste("0",as.character(d),sep="")
    }else{
        Day=as.character(d)
    }    
    print(paste("Giorno:",Day))
    if (tipo=="OSS"){
        previsionday=paste(Year,Month,Day,sep="")
    }else{
        previsionday=paste(Year,Month,Day,"00",sep="")
    }
    for (s in stazioni){
        for (l in LeadTime){
            selection=dati[which(dati$CodiceStazione==s & dati$PrevisionDay==previsionday & dati$LeadTime==l), ]
            if (tipo!="MMSUP"){
                if(nrow(selection)==0){
                    to_add=data.frame(CodiceStazione=s,PrevisionDay=previsionday,LeadTime=l, Dummy1="9999",Dummy2="9999",Dummy3="9999",Dummy4="9999",Dummy5="9999",TempMaxMin="9999",Dummy6="9999")                
                    cont<-cont+1
                }else{
                    to_add=data.frame(CodiceStazione=s,PrevisionDay=previsionday,LeadTime=l, Dummy1=selection[1,"Dummy1"],Dummy2=selection[1,"Dummy2"],Dummy3=selection[1,"Dummy3"],Dummy4=selection[1,"Dummy4"],Dummy5=selection[1,"Dummy5"],TempMaxMin=selection[1,"TempMaxMin"],Dummy6=selection[1,"Dummy6"])                
                }
            }else{
                if(nrow(selection)==0){
                    to_add=data.frame(CodiceStazione=s,PrevisionDay=previsionday,LeadTime=l, Dummy1="9999",Dummy2="9999",Dummy3="9999",Dummy4="9999",Dummy5="9999",TempMaxMin="9999")                
                    cont<-cont+1
                }else{
                    to_add=data.frame(CodiceStazione=s,PrevisionDay=previsionday,LeadTime=l, Dummy1=selection[1,"Dummy1"],Dummy2=selection[1,"Dummy2"],Dummy3=selection[1,"Dummy3"],Dummy4=selection[1,"Dummy4"],Dummy5=selection[1,"Dummy5"],TempMaxMin=selection[1,"TempMaxMin"])                
                }
            }
            filled_dati<-rbind(filled_dati,to_add)                     
        }
    }
}
print("")
print(paste("Sono state aggiunte",cont,"righe."))
write.table(filled_dati, paste(save_path,"/temp.DAT",sep=""), append = FALSE, sep = " ", quote = FALSE, row.names = FALSE, col.names = FALSE)
print("")
if (cont>0){
    print("File aggiornato.")
}else{
    print("File già completo.")
}
print("")
print("Fine.")