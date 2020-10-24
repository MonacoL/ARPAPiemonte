#GENERAZIONE GRAFICI SCARTO ED ERRORE QUADRATICO MEDIO, SU ORIZZONTE TEMPORALE STAGIONALE, MMS ECM CI5 CI2

#pacchetti<-c("scales","reshape2","RColorBrewer")
#install.packages(pacchetti) #installa i pacchetti
#pacchetti1<-c("ggplot2")
#install.packages(pacchetti1) #installa i pacchetti1

library('scales')
library('reshape2')
library('RColorBrewer')
library('ggplot2')
lapply(c("scales","reshape2","RColorBrewer"), library, character.only = TRUE) 
lapply(c("ggplot2"), library, character.only = TRUE)

####################################################################################################

nmodels<-4 #da fissare a mano, probabilmente si può migliorare
args = commandArgs(trailingOnly=TRUE) 
regione<-args[1]
work_path<-args[2] #cartella contenente i dati da plottare
imgsave_path<-args[3] #cartella dove salvare i grafici
giorni_di_raggruppamento<-args[4] #se 1 serie temporale, se >1 raggruppo i dati

print("")
print("+++++++++++++++++++++++++++++++++++++++++")

print("i modelli sono")
print(nmodels)

print("+++++++++++++++++++++++++++++++++++++++++")
print("")

#DEFINISCO I COLORI DEI PLOT
scale_shape_discrete<- function(...)scale_shape_manual(name  ="Modello",
                                                       breaks=c("mod1", "mod2","mod3","mod4"),
                                                       labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"),
                                                       values=c(16,17,18,15))
scale_colour_discrete <- function(...) scale_colour_manual(name="Modello",
                                                           guide = guide_legend(override.aes=aes(fill=NA)),
                                                           breaks=c("mod1", "mod2","mod3","mod4"),
                                                           labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"),
                                                           values=c("darkblue","cyan","red","black"))


#carico il numero di stazioni da cui sono state fatte le osservazioni, alle 3 quote
filenumstaz<-paste(work_path,"/", "NUMSTAZ.DAT",sep="")
numstaz<-read.table(filenumstaz,header=F,na.strings=9999,sep=",") 

#Verifico se il numero di stazioni con osservazioni fatte sia > 0 per le ultime 2 fasce. Nella prima ho sicuramente stazioni.
#Se la verifica è positiva carico i file dei modelli
quote=c("700")
metri=c("700")
fileossmin700<-paste(work_path,"/","OSSMIN700.DAT",sep="") 
fileossmax700<-paste(work_path,"/","OSSMAX700.DAT",sep="")  
filemmsmin700<-paste(work_path,"/","MMSMIN700.DAT",sep="") 
filemmsmax700<-paste(work_path,"/","MMSMAX700.DAT",sep="")  
fileecmmin700<-paste(work_path,"/","ECMMIN700.DAT",sep="") 
fileecmmax700<-paste(work_path,"/","ECMMAX700.DAT",sep="")  
fileci7min700<-paste(work_path,"/","CI7MIN700.DAT",sep="") 
fileci7max700<-paste(work_path,"/","CI7MAX700.DAT",sep="")  
fileci2min700<-paste(work_path,"/","CI2MIN700.DAT",sep="") 
fileci2max700<-paste(work_path,"/","CI2MAX700.DAT",sep="")
ossmin700<-read.table(fileossmin700,header=F,na.strings="9999") 
ossmax700<-read.table(fileossmax700,header=F,na.strings="9999") 
mmsmin700<-read.table(filemmsmin700,header=F,na.strings="9999")
mmsmax700<-read.table(filemmsmax700,header=F,na.strings="9999")   
ecmmin700<-read.table(fileecmmin700,header=F,na.strings="9999") 
ecmmax700<-read.table(fileecmmax700,header=F,na.strings="9999")     
ci7min700<-read.table(fileci7min700,header=F,na.strings="9999") 
ci7max700<-read.table(fileci7max700,header=F,na.strings="9999") 
ci2min700<-read.table(fileci2min700,header=F,na.strings="9999") 
ci2max700<-read.table(fileci2max700,header=F,na.strings="9999")
print("   File 700m letti correttamente.")    
if (numstaz$V2>0){
    quote=append(quote,"150")
    metri=append(metri,"1500")
    fileossmin150<-paste(work_path,"/","OSSMIN150.DAT",sep="") 
    fileossmax150<-paste(work_path,"/","OSSMAX150.DAT",sep="")  
    filemmsmin150<-paste(work_path,"/","MMSMIN150.DAT",sep="") 
    filemmsmax150<-paste(work_path,"/","MMSMAX150.DAT",sep="") 
    fileecmmin150<-paste(work_path,"/","ECMMIN150.DAT",sep="") 
    fileecmmax150<-paste(work_path,"/","ECMMAX150.DAT",sep="") 
    fileci7min150<-paste(work_path,"/","CI7MIN150.DAT",sep="") 
    fileci7max150<-paste(work_path,"/","CI7MAX150.DAT",sep="") 
    fileci2min150<-paste(work_path,"/","CI2MIN150.DAT",sep="") 
    fileci2max150<-paste(work_path,"/","CI2MAX150.DAT",sep="")  
    ossmin150<-read.table(fileossmin150,header=F,na.strings="9999")
    ossmax150<-read.table(fileossmax150,header=F,na.strings="9999")
    mmsmin150<-read.table(filemmsmin150,header=F,na.strings="9999") 
    mmsmax150<-read.table(filemmsmax150,header=F,na.strings="9999") 
    ecmmin150<-read.table(fileecmmin150,header=F,na.strings="9999") 
    ecmmax150<-read.table(fileecmmax150,header=F,na.strings="9999")     
    ci7min150<-read.table(fileci7min150,header=F,na.strings="9999") 
    ci7max150<-read.table(fileci7max150,header=F,na.strings="9999")
    ci2min150<-read.table(fileci2min150,header=F,na.strings="9999") 
    ci2max150<-read.table(fileci2max150,header=F,na.strings="9999")
    print("   File 700m->1500m letti correttamente.")        
}
if (numstaz$V3 > 0){
    quote=append(quote,"300")
    metri=append(metri,"3000")
    fileossmin300<-paste(work_path,"/","OSSMIN300.DAT",sep="") 
    fileossmax300<-paste(work_path,"/","OSSMAX300.DAT",sep="")  
    filemmsmin300<-paste(work_path,"/","MMSMIN300.DAT",sep="") 
    filemmsmax300<-paste(work_path,"/","MMSMAX300.DAT",sep="")  
    fileecmmin300<-paste(work_path,"/","ECMMIN300.DAT",sep="") 
    fileecmmax300<-paste(work_path,"/","ECMMAX300.DAT",sep="")  
    fileci7min300<-paste(work_path,"/","CI7MIN300.DAT",sep="") 
    fileci7max300<-paste(work_path,"/","CI7MAX300.DAT",sep="")  
    fileci2min300<-paste(work_path,"/","CI2MIN300.DAT",sep="") 
    fileci2max300<-paste(work_path,"/","CI2MAX300.DAT",sep="")
    ossmin300<-read.table(fileossmin300,header=F,na.strings="9999")
    ossmax300<-read.table(fileossmax300,header=F,na.strings="9999")    
    mmsmin300<-read.table(filemmsmin300,header=F,na.strings="9999") 
    mmsmax300<-read.table(filemmsmax300,header=F,na.strings="9999")     
    ecmmin300<-read.table(fileecmmin300,header=F,na.strings="9999") 
    ecmmax300<-read.table(fileecmmax300,header=F,na.strings="9999") 
    ci7min300<-read.table(fileci7min300,header=F,na.strings="9999") 
    ci7max300<-read.table(fileci7max300,header=F,na.strings="9999")
    ci2min300<-read.table(fileci2min300,header=F,na.strings="9999") 
    ci2max300<-read.table(fileci2max300,header=F,na.strings="9999") 
    print("   File 1500->3000m letti correttamente.")        
}

#############################################################################
#DEFINISCO DELLE FUNZIONI UTILI PER I SUCCESSIVI CICLI
get_model_data <- function(modello,minmax,quota) { #GET MODELLO AD UNA CERTA QUOTA E PER UNA CERTA TEMPERATURA
    if (quota=="700"){
       if (minmax=="MAX"){
           if (modello=="MMS"){
               ritorno<-mmsmax700
           }else if(modello=="ECM"){
               ritorno<-ecmmax700
           }else if(modello=="CI7"){
               ritorno<-ci7max700
           }else if(modello=="CI2"){
               ritorno<-ci2max700
           }
       }else{
           if (modello=="MMS"){
               ritorno<-mmsmin700
           }else if(modello=="ECM"){
               ritorno<-ecmmin700
           }else if(modello=="CI7"){
               ritorno<-ci7min700
           }else if(modello=="CI2"){
               ritorno<-ci2min700
           }
       }
   }else if (quota=="150"){
       if (minmax=="MAX"){
           if (modello=="MMS"){
               ritorno<-mmsmax150
           }else if(modello=="ECM"){
               ritorno<-ecmmax150
           }else if(modello=="CI7"){
               ritorno<-ci7max150
           }else if(modello=="CI2"){
               ritorno<-ci2max150
           }
       }else{
           if (modello=="MMS"){
               ritorno<-mmsmin150
           }else if(modello=="ECM"){
               ritorno<-ecmmin150
           }else if(modello=="CI7"){
               ritorno<-ci7min150
           }else if(modello=="CI2"){
               ritorno<-ci2min150
           }
       }
   }else if (quota=="300"){
       if (minmax=="MAX"){
           if (modello=="MMS"){
               ritorno<-mmsmax300
           }else if(modello=="ECM"){
               ritorno<-ecmmax300
           }else if(modello=="CI7"){
               ritorno<-ci7max300
           }else if(modello=="CI2"){
               ritorno<-ci2max300
           }
       }else{
           if (modello=="MMS"){
               ritorno<-mmsmin300
           }else if(modello=="ECM"){
               ritorno<-ecmmin300
           }else if(modello=="CI7"){
               ritorno<-ci7min300
           }else if(modello=="CI2"){
               ritorno<-ci2min300
           }
       }
   }
   return(ritorno)
}

get_obs_data <- function(minmax,quota) { #GET OSSERVATI AD UNA CERTA QUOTA PER UNA CERTA TEMPERATURA
    if (quota=="700"){
       if (minmax=="MAX"){
            ritorno<-ossmax700
       }else{
            ritorno<-ossmin700
       }
   }else if (quota=="150"){
       if (minmax=="MAX"){
            ritorno<-ossmax150
       }else{
            ritorno<-ossmin150
       }
   }else if (quota=="300"){
       if (minmax=="MAX"){
            ritorno<-ossmax300
       }else{
            ritorno<-ossmin300
       }
   }
   return(ritorno)
}

get_num_staz <- function(filestaz,quota){ #GET NUMERO STAZIONI AD UNA CERTA QUOTA
    if (quota=="700"){
        ritorno=filestaz$V1
    }else if (quota=="150"){
        ritorno=filestaz$V2
    }else if (quota=="300"){
        ritorno=filestaz$V3
    }
    return(ritorno)
}

get_plot_title <- function(filestaz,temperatura, quota, from, to, raggr) { #GET TITOLO PER I PLOT
    ritorno=""
    if (temperatura=="MAX"){
        ritorno="TEMPERATURA MASSIMA,"
    }else{
        ritorno="TEMPERATURA MINIMA,"
    }    
    num_staz=get_num_staz(filestaz,quota)
    if (quota=="700"){
        ritorno=paste(ritorno,"0-700m,",num_staz,"STAZIONI,",from,"-",to)
    }else if (quota=="150"){
        ritorno=paste(ritorno,"700-1500m,",num_staz,"STAZIONI,",from,"-",to)
    }else if (quota=="300"){
        ritorno=paste(ritorno,"1500-3000m,",num_staz,"STAZIONI,",from,"-",to)
    }
    if (raggr==1){
        ritorno=paste(ritorno,"SERIE TEMPORALE")
    }else{
        ritorno=paste(ritorno,"FINESTRA DI",raggr,"GIORNI")
    }     
    return(ritorno)
}

get_plot_yAxisLabel <- function(temperatura) { #GET LABEL PER ASSE Y PLOT
    if (t=="MAX"){
        ritorno="TEMPERATURA MASSIMA [°C]"
    }else{
        ritorno="TEMPERATURA MINIMA [°C]"
    }
    return(ritorno)
}

get_save_path <- function(raggr) { #GET PATH COMPLETO PER SALVATAGGIO GRAFICI
#    if (raggr==1){
    ritorno=paste(imgsave_path,"/T",t,"/",regione,"/",regione,"_T",t,"_",q,".png",sep="")
#    }else{
#        ritorno=paste(imgsave_path,"/",regione,"_T",t,"_",q,"_",raggr,".png",sep="")
#    }     
    return(ritorno)
}

#L'IDEA DI QUESTA PROCEDURA E' QUELLA DI CICLARE SULLE QUOTE, SULLE TEMPERATURE E SUI MODELLI, SALVANDO UN GRAFICO AD OGNI CICLO
#DI TEMPERATURA
temperature=c("MAX","MIN")
temperature_names=c("   TEMPERATURA MASSIMA","   TEMPERATURA MINIMA")
osservati="OSS"
modelli=c("MMS","ECM","CI7","CI2")
models_name=c("MULTIMODEL","ECMWF","COSMO-I5","COSMO-2I")
from<-ossmax700[1,2] #Data inizio dei dati, la prendo dalla prima riga degli osservati ad una quota a caso, perchè non presentano la corsa nel campo data a differenza dei modelli
to<-tail(ossmax700,n=1)[,2] #uguale, ma prendo l'ultima riga
to2<-as.POSIXct(as.character(to), format="%Y%m%d") #converto from e to in un formato data più carino da plottare
to2<-format(to2,"%d %b %y")
from2<-as.POSIXct(as.character(from), format="%Y%m%d")
from2<-format(from2,"%d %b %y")

x_date<-c() #vettore delle date, da riempire in base al raggruppamento ove presente

# if (giorni_di_raggruppamento==1){ #no raggruppamento, serie temporale
#     trenta_giorni=seq(0,30,by=1) #è un'analisi mensile
#     for (d in trenta_giorni){ #riempi il vettore delle date con giorni susseguenti all'interno dell'orizzonte temporale
#         giorno=format(as.Date(as.character(from),format="%Y%m%d") + d,"%Y%m%d")
#         x_date<-append(x_date,giorno)
#     }    
#     for (q in quote){ #ciclo sulle quote
#         quota_index<-match(q,quote)
#         print(paste("ELABORAZIONE DATI ",metri[quota_index],"m", sep=""))
#         for (t in temperature){ #ciclo sulle temperature
#             osservati<-get_obs_data(t,q) #ricavo gli osservati a temperatura e quota fissata
#             temp_index<-match(t,temperature)            
#             print(temperature_names[temp_index]) 
#             ME<-matrix(nrow=31,ncol=length(modelli)) #definisco le matrici di scarto ed errore con tante righe quanti i giorni e tante colonne quanti i modelli
#             RMSE<-matrix(nrow=31,ncol=length(modelli)) #le matrici ora sono vuote evanno fillate                                  
#             for (m in modelli){  #ciclo sui modelli
#                 modello<-get_model_data(m,t,q) #ricavo il modello m, a temperatura e quota fissata
#                 model_index<-match(m,modelli)       
#                 print(paste("     MODELLO",models_name[model_index], "FATTO"))                         
#                 for (d in trenta_giorni)  { #riempio le matrici su tutto l'orizzonte temporale
#                     giorno=format(as.Date(as.character(from),format="%Y%m%d") + d,"%Y%m%d")                    
#                     oss_day<-osservati[which(osservati$V2==giorno), ]  #prendo gli osservati del giorno d                    
#                     modello_day<-modello[which(modello$V2==paste(giorno,"00",sep="")), ] #prendo il modello m al giorno d
#                     ME[d+1,model_index]<-mean((modello_day$V9-oss_day$V9)/10,na.rm=TRUE) #calcolo scarto
#                     RMSE[d+1,model_index]<-sqrt(mean(((modello_day$V9-oss_day$V9)/10)^2,na.rm=TRUE)) #calcolo errore
#                     #print(paste("       giorno: ",giorno, ME[d+1,model_index],RMSE[d+1,model_index]))                    
#                 }                    
#             }
#             #una volta ciclato su tutti i modelli, ho i dati da plottare per la quota q e la temperatura t
#             print(paste("ELABORAZIONE GRAFICI ",metri[quota_index],"m", sep=""))

#             risultati<-data.frame(x_date,ME,RMSE) #creo il data frame dei risultati
#             risultati<-melt(risultati,id.vars="x_date",variable.name = 'series')
#             ind<-c(rep(c("ME","RMSE"), each=nmodels*length(x_date),len=nrow(risultati))) #colonna per il facet
#             mod<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(x_date),len=nrow(risultati))) #colonna per individuare un modello dall'altro

#             #data.frame finito, con i gruppi necessari al ggplot
#             risultati_bind<-cbind(risultati,mod,ind) #unisco le colonne mod e ind alla matrice dei risultati

#             #i tempi devono essere della classe Date
#             risultati_bind$x_date<-as.Date(as.character(risultati_bind$x_date),"%Y%m%d")

#             print("   Vettori da plottare creati correttamente.")

#             risultati_plot=ggplot(risultati_bind, aes(x_date,value))+ #variabili x=tempo y= valore indici
#                             geom_line(aes(colour=mod,linetype=ind),cex=1.2, show.legend = F)+#colore indica il modello il tratto indica l'indice
#                             geom_point(aes(shape=mod,color=mod),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
#                             scale_x_date(breaks = risultati_bind$x_date, date_labels ="%d %b %y" )+ #etichette delle x
#                             facet_grid(ind~., scales = "free_y")+ #creo subplot con la stessa x ma y diverse date dalla colonna ind
#                             geom_hline(yintercept=0)+
#                             ggtitle(get_plot_title(numstaz,t, q, from2, to2, giorni_di_raggruppamento))+
#                             theme_light()+
#                             ylab(get_plot_yAxisLabel(t))+
#                             theme(plot.title = element_text(hjust = 0.7,size=15.3, face="bold"),
#                                   axis.title.x = element_blank(), 
#                                   axis.title.y = element_text(size=14),
#                                   axis.text.x  = element_text(size = 10, angle = 45, colour = "black",vjust = 1, hjust = 1),
#                                   axis.text.y = element_text(size=10, face="bold"),
#                                   legend.position="top",
#                                   legend.title=element_blank(),
#                                   legend.text=element_text(size=14),
#                                   strip.text = element_text(colour = 'black',size=14, face="bold"))+
#                             scale_linetype_manual(name="Indice",values=c(1,4))+
#                             scale_colour_discrete(name="Modello",
#                                                 guide = guide_legend(override.aes=aes(fill=NA)),
#                                                 breaks=c("mod1", "mod2","mod3","mod4"),
#                                                 labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
#                             scale_shape_discrete(name  ="Modello",
#                                                 breaks=c("mod1", "mod2","mod3","mod4"),
#                                                 labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))+                                              

#             png(get_save_path(giorni_di_raggruppamento),width=800,height=400) 
#             print(risultati_plot)
#         }     
#     }
# }else{ #qui invece raggruppo i dati. Evito i commenti rindondanti
giorni_raggr_int=as.integer(giorni_di_raggruppamento)
ntot<-nrow(ossmax700) #tiro fuori gli intervalli di tempo da un file a caso
num_stazioni=get_num_staz(numstaz,"700") #prendo il numero stazioni da un file a caso per trovare in quanti intervalli di tempo dividere l'orizzonte temporale
nintervals<-(ntot/num_stazioni)%/%giorni_raggr_int
rest<-(ntot/num_stazioni)%%giorni_raggr_int
if(rest > 5) { 
    nintervals<-nintervals + 1 
}   
for (i in 1:nintervals)  { #fillo il vettore delle date col primo giorno di ogni intervallo
    nstart<-(num_stazioni*giorni_raggr_int*(i-1)+1) 
    giorno<-format(as.Date(as.character(ossmax700[nstart,2]),format="%Y%m%d"),"%Y%m%d")
    x_date<-append(x_date,giorno)
}

for (q in quote){      
    num_stazioni=get_num_staz(numstaz,q)                     
    quota_index<-match(q,quote)
    print(paste("ELABORAZIONE DATI ",metri[quota_index],"m", sep=""))
    for (t in temperature){
        osservati<-get_obs_data(t,q)
        temp_index<-match(t,temperature)            
        print(temperature_names[temp_index]) 
        ME<-matrix(nrow=nintervals,ncol=length(modelli)) #questo giro il numero di righe corrisponde al numero di intervalli
        RMSE<-matrix(nrow=nintervals,ncol=length(modelli))                                   
        for (m in modelli){
            modello<-get_model_data(m,t,q)
            model_index<-match(m,modelli)       
            print(paste("     MODELLO",models_name[model_index], "FATTO"))                         
            for (i in 1:nintervals)  {#invece che ciclare sui giorni, ciclo sugli intervalli
                nstart<-(num_stazioni*giorni_raggr_int*(i-1)+1) #trovo gli indici di riga di start ed end dell'intervallo i
                nend<-nstart+num_stazioni*(giorni_raggr_int)
                if(i == nintervals) { #se l'intervallo è l'ultimo, l'end index sarà l'ultima riga
                    nend<-nrow(get_model_data(m,t,q))
                }          
                modello_interval<-modello[nstart:nend,] #prendo modello ed osservati nell'intervallo i considerato
                oss_interval<-osservati[nstart:nend,]
                ME[i,model_index]<-mean((modello_interval$V9-oss_interval$V9)/10,na.rm=TRUE)
                RMSE[i,model_index]<-sqrt(mean(((modello_interval$V9-oss_interval$V9)/10)^2,na.rm=TRUE))
            }                    
        }
        print(paste("ELABORAZIONE GRAFICI ",metri[quota_index],"m", sep=""))

        risultati<-data.frame(x_date,ME,RMSE)
        risultati<-melt(risultati,id.vars="x_date",variable.name = 'series')
        ind<-c(rep(c("ME","RMSE"), each=nmodels*length(x_date),len=nrow(risultati)))
        mod<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(x_date),len=nrow(risultati)))

        #data.frame finito, con i gruppi necessari al ggplot
        risultati_bind<-cbind(risultati,mod,ind)

        #i tempi devono essere della classe Date
        risultati_bind$x_date<-as.Date(as.character(risultati_bind$x_date),"%Y%m%d")#"%Y-%m-%d")
        #risultati_bind$x_date<-format(risultati_bind$x_date,"%d %b %y")

        print("   Vettori da plottare creati correttamente.")

        new_xaxis=c() #ho bisogno di customizzare l'asse delle x, perchè come scritto sopra ogni punto corrisponde al primo giorno di ogni intervallo
        for (j in 1:length(x_date)){ 
            dal=x_date[j] #primo giorno intervallo
            al=format(as.Date(as.character(dal),format="%Y%m%d") + giorni_raggr_int,"%Y%m%d")
            dal=as.POSIXct(as.character(dal), format="%Y%m%d")
            al=as.POSIXct(as.character(al), format="%Y%m%d")
            dal=format(dal,"%d %b %y")
            al=format(al,"%d %b %y")
            newtick=paste("DAL",dal,"\nAL",al) #mentre io voglio che sulle labels escano gli intervalli completi
            new_xaxis=append(new_xaxis,newtick)
        }
        new_xaxis<-c(rep(new_xaxis,nmodels*2))
        risultati_bind<-cbind(risultati_bind,new_xaxis)
        risultati_plot=ggplot(risultati_bind, aes(x_date,value))+ #variabili x=tempo y= valore indici
                        geom_line(aes(colour=mod,linetype=ind),cex=1.2, show.legend = F)+#colore indica il modello il trattoindica l'indice
                        geom_point(aes(shape=mod,color=mod),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
                        scale_x_date(breaks = risultati_bind$x_date, labels=risultati_bind$new_xaxis)+ #etichette delle x customizzate con new_xaxis
                        facet_grid(ind~., scales = "free_y")+
                        geom_hline(yintercept=0)+
                        ggtitle(get_plot_title(numstaz,t, q, from2, to2, giorni_di_raggruppamento))+
                        theme_light()+
                        ylab(get_plot_yAxisLabel(t))+
                        theme(plot.title = element_text(hjust = 0.7,size=15.3, face="bold"),
                                axis.title.x = element_blank(), 
                                axis.title.y = element_text(size=14),
                                axis.text.x  = element_text(size = 10, angle = 45, colour = "black",vjust = 1, hjust = 1),
                                axis.text.y = element_text(size=10, face="bold"),
                                legend.position="top",
                                legend.title=element_blank(),
                                legend.text=element_text(size=14),
                                strip.text = element_text(colour = 'black',size=14, face="bold"))+
                        scale_linetype_manual(name="Indice",values=c(1,4))+
                        scale_colour_discrete(name="Modello",
                                            guide = guide_legend(override.aes=aes(fill=NA)),
                                            breaks=c("mod1", "mod2","mod3","mod4"),
                                            labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
                        scale_shape_discrete(name  ="Modello",
                                            breaks=c("mod1", "mod2","mod3","mod4"),
                                            labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))+                                              

        png(get_save_path(giorni_di_raggruppamento),width=800,height=400) 
        print(risultati_plot)
        #}     
    }    
}

q()