library(functional)
library(ggplot2)

args = commandArgs(trailingOnly=TRUE) 
nmodels<-as.integer(args[1])
naree<-as.integer(args[2])
ieri<-args[3]
altroieri<-args[4]
tipo<-args[5]
work_path<-args[6]
grafici_path<-args[7]
coloritxt_path<-args[8]

ncol=5
novalue=-98
nscadenze_altroieri=4
nscadenze_ieri=4
nmodels_plus_obs=nmodels
nosservati=1
ndati=nmodels*2+1
ngiorni_backwards=2 #quanti giorni previsionali vado indietro rispetto a oggi

aree=seq(1,70)
modelli_labels=c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU","WRF")
modelli_path=c("m0103","b0700","c2200","c5m00","e0100","i0700","wrf00")
modelli_values=c("01-m0103","02-b0700","03-c2200","04-c5m00","05-e0100","06-i0700","07-wrf00")
label_run_altroieri=paste("RUN ",altroieri,"_00",sep="")
label_run_ieri=paste("RUN ",ieri,"_00",sep="")
giorni=c(label_run_altroieri,label_run_ieri)
scadenze_altroieri=c("00-06","06-12","12-18","18-24")
scadenze_ieri=c("00-06","06-12","12-18","18-24")
col_scadenze_mod_ieri=c(1,2,3,4)
col_scadenze_mod_altroieri=c(5,6,7,8)
dati=matrix(, nrow =0, ncol = ncol)
colnames(dati)<-c("Precipitazione","Scadenza","Area","Modello","Giorno")

fileossaltroieri<-paste(work_path,"/","osservati_",tipo,".txt",sep="")
ossaltroieri<-read.table(fileossaltroieri,header=F,na.strings="-99") 

dati_modelli_ieri=c()
dati_modelli_altroieri=c()
for (m in seq(1,nmodels)){
    filemodieri<-paste(work_path,"/",modelli_path[m],"_06hh_",ieri,"00_IVIG_",tipo,".bal",sep="")
    modieri<-read.table(filemodieri,header=F,na.strings="-98")
    filemodaltroieri<-paste(work_path,"/",modelli_path[m],"_06hh_",altroieri,"00_IVIG_",tipo,".bal",sep="")
    modaltroieri<-read.table(filemodaltroieri,header=F,na.strings="-98")    

    for (s in seq(1,nscadenze_altroieri)){
        riga_previsioni=matrix(, nrow = naree, ncol = ncol)
        colnames(riga_previsioni)<-c("Precipitazione","Scadenza","Area","Modello","Giorno")  
        for (a in seq(1,naree)){
            riga_previsioni[a,"Precipitazione"]=modaltroieri[a,col_scadenze_mod_altroieri[s]]
            riga_previsioni[a,"Scadenza"]=scadenze_altroieri[s]
            riga_previsioni[a,"Area"]=aree[a]
            riga_previsioni[a,"Modello"]=modelli_values[m]
            riga_previsioni[a,"Giorno"]=label_run_altroieri
        }
        dati_modelli_altroieri<-rbind(dati_modelli_altroieri,riga_previsioni)
    }

    for (s in seq(1,nscadenze_ieri)){
        riga_previsioni=matrix(, nrow = naree, ncol = ncol)
        colnames(riga_previsioni)<-c("Precipitazione","Scadenza","Area","Modello","Giorno")  
        for (a in seq(1,naree)){
            riga_previsioni[a,"Precipitazione"]=modieri[a,col_scadenze_mod_ieri[s]]
            riga_previsioni[a,"Scadenza"]=scadenze_ieri[s]
            riga_previsioni[a,"Area"]=aree[a]
            riga_previsioni[a,"Modello"]=modelli_values[m]
            riga_previsioni[a,"Giorno"]=label_run_ieri
        }
        dati_modelli_ieri<-rbind(dati_modelli_ieri,riga_previsioni)
    }
}
dati_modelli_ieri<-as.data.frame(dati_modelli_ieri,na.strings = -98)
dati_modelli_altroieri<-as.data.frame(dati_modelli_altroieri,na.strings = -98)
dati<-rbind(dati,dati_modelli_altroieri,dati_modelli_ieri)
dati<-dati[order(dati$Giorno, as.numeric(as.character(dati$Area)), dati$Scadenza),] 

Osservati=c()
for (a in seq(1,naree)){
    for (s in seq(1,nscadenze_altroieri)){
        dato_oss <- ossaltroieri[a,s]
        dato_oss <- rep(dato_oss,nmodels)
        Osservati<-append(Osservati,dato_oss)
    }        
} 
Osservati<-rep(Osservati,2)
dati<-cbind(dati,Osservati)
Sizes<-c(3,3,3,3,3,3,3)
Sizes<-rep(Sizes,nscadenze_altroieri*naree*2)
dati<-cbind(dati,Sizes)

# for (l in seq(1,ngiorni_backwards)){
#     for (k in seq(1,nmodels_plus_obs)){
#         previsioni_modello=matrix(, nrow = naree, ncol = ncol)
#         for (i in seq(1, naree)) { #fillo il vettore righe con tutte le righe necessarie da tutte le aree di vigilanza, che son 70, dalla seconda in poi
#             for (j in seq(1, nscadenze)){
#                 #if (giorni[l]=="D0"){
#                 previsione<-c(runif(1)*100,scadenze[j],aree[i],modelli[k],giorni[l])
#                 # }else{
#                 #     previsione<-c(runif(1)*100,scadenze[j],aree[i],modelliD1[k],giorni[l])
#                 # }
#                 dati<-rbind(dati,previsione)
#             }
#         }            
#     }
# }

# previsioni_modello=matrix(, nrow = naree, ncol = ncol)
# for (l in seq(1,ngiorni_backwards)){
#     for (i in seq(1, naree)) { #fillo il vettore righe con tutte le righe necessarie da tutte le aree di vigilanza, che son 70, dalla seconda in poi
#         for (j in seq(1, nscadenze)){
#             #previsione<-c(runif(1)*100,scadenze[j],aree[i],"15-OSSERVATI","OSSERVATI")
#             previsione<-c(runif(1)*100,scadenze[j],aree[i],"09-OSSERVATI",giorni[l])
#             dati<-rbind(dati,previsione)
#         }
#     } 
# }

#giorni<-append(giorni)
#modelliD1<-append(modelliD1,"15-OSSERVATI")
#modelli<-append(modelli,"09-OSSERVATI")
# dati<-as.data.frame(dati,na.strings = -98)
# dati<-dati[order(dati$Giorno, dati$Area, dati$Scadenza),] 
# Osservati=c()
# for (l in seq(1,ngiorni_backwards)){
#     for (i in seq(1, naree)) { #fillo il vettore righe con tutte le righe necessarie da tutte le aree di vigilanza, che son 70, dalla seconda in poi
#         for (j in seq(1, nscadenze)){
#             osservato=runif(1)*100
#             for (k in seq(1, nmodels)){
#                 Osservati<-append(Osservati,osservato)
#             }
#         }
#     }
# }
# Osservati<-as.data.frame(Osservati,na.strings = -98)
# dati<-cbind(dati,Osservati)

# media=c()
# for (l in seq(1,ngiorni_backwards)){
#     for (i in seq(1, naree)) { #fillo il vettore righe con tutte le righe necessarie da tutte le aree di vigilanza, che son 70, dalla seconda in poi
#         for (j in seq(1, nscadenze)){
#             dati_media <- dati[which(dati$Giorno==giorni[l] & dati$Area==aree[i] & dati$Scadenza==scadenze[j] & dati$Modello!="09-OSSERVATI"), ]            
#             #dati_media <- dati[which(dati$Giorno==giorni[l] & dati$Area==aree[i] & dati$Scadenza==scadenze[j]), ]            
#             ave<-mean(as.numeric(as.character(dati_media$Precipitazione)))
#             ave_rep<-rep(ave,nmodels)
#             media<-append(media,ave_rep) 
#             media<-append(media,-98)
#         }    
#     }                
# }
# # no_media=rep(-98,naree*nscadenze*ngiorni_backwards)
# # media<-append(media,no_media)
# media<-as.data.frame(media,na.strings = -98)
# dati<-cbind(dati,media)
print("")
print("CREAZIONE GRAFICI")
if (tipo=="max"){
    tipoplot<-"MASSIMA"
}else{
    tipoplot<-"MEDIA"
}
for (a in aree){
    dati_area<-dati[which(dati$Area==a),]
    step<-10
    smin1<-min(as.numeric(as.character(dati_area$Precipitazione)),na.rm=TRUE)
    smax1<-max(as.numeric(as.character(dati_area$Precipitazione)),na.rm=TRUE)
    smin2<-min(as.numeric(as.character(dati_area$Osservati)),na.rm=TRUE)
    smax2<-max(as.numeric(as.character(dati_area$Osservati)),na.rm=TRUE)
    smin<-min(smin1,smin2)
    smax<-max(smax1,smax2)
    if (smax<20){step<-5
    }
    if (smax<10){step<-2
    smax<-10}
    png(paste(grafici_path,"/VerificaQPF",tipoplot,"_",a,".png", sep=""),width = 550, height = 650, units = "px", res = 100)
    bp<- ggplot(dati_area, aes(x = dati_area$Modello, y = as.numeric(as.character(dati_area$Precipitazione)))) + #variabile che voglio sul grafico aes
        geom_point(aes(color = dati_area$Modello, shape = dati_area$Modello), size=dati_area$Sizes)+    
        geom_line(aes(x = dati_area$Modello, y = dati_area$Osservati, group = dati_area$Giorno,linetype = paste("OSSERVATI\n",ieri,sep="")), size=1, colour="black")+
        facet_grid(dati_area$Giorno ~ dati_area$Scadenza)+
        guides(colour = guide_legend(nrow = 2,override.aes = list(size = 3)))+
        theme(strip.text = element_text(size = 11, 
                                        color = "black", 
                                        face = "plain"),
            plot.title = element_text(hjust = 0.5, size=12), #per centrae il titolo
            panel.grid.major = element_line(size=0.2, linetype = "dashed", color = "black"),    #spessore griglia principale
            panel.grid.major.x = element_blank(),
            panel.grid.minor = element_blank(),
            legend.position="top",
            legend.title=element_blank(),
            legend.text=element_text(size=9),          
            axis.text.x=element_blank(), 
            axis.ticks.x=element_blank(), #parametri grafici testo
            axis.text.y = element_text(size=8))+
        scale_y_continuous(breaks = round(seq(smin, 
                                            smax, by = step),0),#scala asse y 
                        limits = c(smin,smax))+ #asse y sulla dx
        labs(title=paste("VERIFICA QPF",tipoplot,ieri),
            x=" ",
            y="Precipitazione (mm)\n")+ #titoli
        scale_shape_manual(name = "Modelli",labels=modelli_labels, values = c(16,16,16,16,16,16,16,17))+
        scale_color_manual(name = "Modelli",labels=modelli_labels, values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple","blue","red"))#colori personalizzati
    print(bp)   
    dev.off() 
} 
if (tipo=="max"){
    print("")
    print("AGGIORNO IL FILE COLORI DELLA MAPPA")
    massimi=c(ieri,paste(ieri,"_00",sep=""), paste(altroieri,"_00",sep=""))
    for (a in seq(1,naree)){
        massimo=max(ossaltroieri[a,],na.rm=T)
        if(is.infinite(massimo)){
            massimi<-append(massimi,0)
        }else{
            massimi<-append(massimi,massimo)
        }
    }
    fileConn<-file(paste(coloritxt_path,"/qpf_IVIG_colori.txt",sep=""))
    writeLines(massimi, fileConn)
    close(fileConn)
}
print("")
print("FINE PROCEDURA R PER I GRAFICI")
