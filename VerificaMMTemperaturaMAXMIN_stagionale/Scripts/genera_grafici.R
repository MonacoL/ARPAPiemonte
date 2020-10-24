#pacchetti<-c("scales","reshape2","RColorBrewer")
#install.packages(pacchetti) #installa i pacchetti
#pacchetti1<-c("ggplot2")
#install.packages(pacchetti1) #installa i pacchetti1

library('scales')
library('reshape2')
library('RColorBrewer')
library('ggplot2')
# script che crea un grafico con verifica tminima e tmassima di multimodel versus MMS, ECM e CI7 sul Piemonte 
# verifiche 
args = commandArgs(trailingOnly=TRUE) 
regione<-args[1]
work_path<-args[2]
imgsave_path<- args[3]


lapply(c("scales","reshape2","RColorBrewer"), library, character.only = TRUE) 
lapply(c("ggplot2"), library, character.only = TRUE)

print("")
print("+++++++++++++++++++++++++++++++++++++++++")

nmodels<-4 
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

#Verifico se il numero di stazioni con osservazioni fatte sia > 0 per ogni quota
if( numstaz$V1 > 0) { 
    print("ELABORAZIONE GRAFICI 700m")
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
    print("   File letti correttamente.")

    #LIVELLO SOTTO I 700 M ############################################################    
    ntot<-nrow(ossmin700) 
    nintervals<-(ntot/numstaz$V1)%/%10 
    rest<-(ntot/numstaz$V1)%%10

    if(rest > 5) { 
        nintervals<-nintervals + 1 
    }  
    # print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    # print("ntot")
    # print(ntot)
    # print("Nintervals")
    # print(nintervals)


    #ora costruisco le matrici dei risultati 
    MEmin700<-matrix(nrow=nintervals,ncol=nmodels) 
    RMSEmin700<-matrix(nrow=nintervals,ncol=nmodels) 
    MEmax700<-matrix(nrow=nintervals,ncol=nmodels) 
    RMSEmax700<-matrix(nrow=nintervals,ncol=nmodels) 

    for (i in 1:nintervals)  {    
        nstart<-(numstaz$V1*10*(i-1)+1) 
        nend<-numstaz$V1*10*i 
        if(i == nintervals) { 
            nend<-nrow(ossmin700)  
        }  
        
        #TMin sotto i 700 m   
        oss<-ossmin700[nstart:nend,] 
        mm<-mmsmin700[nstart:nend,]  
        ecm<-ecmmin700[nstart:nend,] 
        ci7<-ci7min700[nstart:nend,] 
        ci2<-ci2min700[nstart:nend,]  
        C<-sum((mm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin700[i,1]<-C 
        B<-sqrt(mean(((mm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin700[i,1]<-B 
        C<-sum((ecm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin700[i,2]<-C  
        B<-sqrt(mean(((ecm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin700[i,2]<-B 
        C<-sum((ci7$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin700[i,3]<-C  
        B<-sqrt(mean(((ci7$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin700[i,3]<-B 
        C<-sum((ci2$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin700[i,4]<-C  
        B<-sqrt(mean(((ci2$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin700[i,4]<-B 
        
        #TMax sotto i 700 m   
        oss<-ossmax700[nstart:nend,] 
        mm<-mmsmax700[nstart:nend,]  
        ecm<-ecmmax700[nstart:nend,] 
        ci7<-ci7max700[nstart:nend,] 
        ci2<-ci2max700[nstart:nend,]  
        C<-sum((mm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax700[i,1]<-C 
        B<-sqrt(mean(((mm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax700[i,1]<-B 
        C<-sum((ecm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax700[i,2]<-C  
        B<-sqrt(mean(((ecm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax700[i,2]<-B 
        C<-sum((ci7$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax700[i,3]<-C  
        B<-sqrt(mean(((ci7$V9-oss$V9)/10)^2,na.rm=T)) 
        RMSEmax700[i,3]<-B 
        C<-sum((ci2$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax700[i,4]<-C  
        B<-sqrt(mean(((ci2$V9-oss$V9)/10)^2,na.rm=T)) 
        RMSEmax700[i,4]<-B  
    }  
    print("   Dati da plottare modellati correttamente.")

    #Elementi asse x (date) 
    assex<-array(nintervals)  
    posx<-array(nintervals) 
    for (i in 1:nintervals)  {    
        numriga<-(numstaz$V1*10*(i-1)+1) 
        #if(i == nintervals) {                         #QUESTA PARTE CAMBIA L'ETICHETTA DELL'ULTIMA DECADE, prende l'ultimo giorno della decade
        #   numriga<-nrow(ossmin700)  
        # }  
        posx[i]<-i 
        assex[i]<- ossmin700[numriga,2]   
    } 

    date<-as.POSIXct(as.character(assex), format="%Y%m%d") #cambia formato alla data
    t<-format(date,"%d %b %y") #vettore tempi, prima colonna del mio df

    #############################################################################################
    risultati_min_unita700<-data.frame(t,MEmin700,RMSEmin700)
    risultati_max_unita700<-data.frame(t,MEmax700,RMSEmax700)

    risultati_min_unita700<-melt(risultati_min_unita700,id.vars="t",variable.name = 'series')
    risultati_max_unita700<-melt(risultati_max_unita700,id.vars="t",variable.name = 'series')

    ind_min700<-c(rep(c("ME","RMSE"), each=4*length(t),len=nrow(risultati_min_unita700)))
    mod_min700<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(t),len=nrow(risultati_min_unita700)))

    ind_max700<-c(rep(c("ME","RMSE"), each=4*length(t),len=nrow(risultati_max_unita700)))
    mod_max700<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(t),len=nrow(risultati_max_unita700)))

    #data.frame finito, con i gruppi necessari al ggplot
    df_grp_min700<-cbind(risultati_min_unita700,mod_min700,ind_min700)
    df_grp_max700<-cbind(risultati_max_unita700,mod_max700,ind_max700)

    #i tempi devono essere della classe Date
    df_grp_min700$t<-as.character(df_grp_min700$t)
    df_grp_min700$t<-as.Date(df_grp_min700$t,"%d %b %y")#"%Y-%m-%d")"%d %b %y"

    #i tempi devono essere della classe Date
    df_grp_max700$t<-as.character(df_grp_max700$t)
    df_grp_max700$t<-as.Date(df_grp_max700$t,"%d %b %y")#"%Y-%m-%d")"%d %b %y"

    datain<-df_grp_min700$t[1]

    #de<-length(df_grp_min700$t) #funziona se le decadi spezzano giusto il mese
    #print("de=")
    #print(de)
    #dataend<-df_grp_min700$t[de] 

    #print("data di fine calcolata a partire dal datain +3 mesi ultimo gg del mese")
    end2<-seq(datain,length=4,by="months")-1
    dataend<-end2[4]
    #print(dataend)

    datain_f<-format(datain,"%d %b %y")
    dataend_ff<-as.Date(dataend,format="%d %b %y")
    dataend_f<-format(dataend_ff,"%d %b %y")

    #print("####DATE####")
    #print(dataend_ff)
    #print(dataend_f)

    print("   Vettori da plottare creati correttamente.")

    #####################################################################
    #Grafico TMIN livello 700
    #####################################################################

    g700min=ggplot(df_grp_min700, aes(t,value))+ #variabili x=tempo y= valore indici
        geom_line(aes(colour=mod_min700,linetype=ind_min700),cex=1.2)+#colore indica il modello il trattoindica l'indice
        geom_point(aes(shape=mod_min700,color=mod_min700),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
        scale_x_date(breaks = df_grp_min700$t ,date_labels ="%d %b %y" )+#"%d %b %y")+ #etichette delle x  "%Y-%m-%d"
        geom_hline(yintercept=0)+
        ggtitle(paste(toupper("TMIN intervallo 0-700 metri, su"),toupper(numstaz$V1),toupper("stazioni,"),toupper("periodo"),toupper(datain_f),toupper(" - "),toupper(dataend_f)))+
        theme_light()+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_linetype_manual(name="Indice",values=c(1,4))+
        scale_colour_discrete(name="Modello",
                              guide = guide_legend(override.aes=aes(fill=NA)),
                              breaks=c("mod1", "mod2","mod3","mod4"),
                              labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
        scale_shape_discrete(name  ="Modello",
                             breaks=c("mod1", "mod2","mod3","mod4"),
                             labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))

    #colori scelti da me
    gg700min=g700min  + theme(axis.title.x = element_blank(),
                              axis.title.y = element_blank())
    png(paste(imgsave_path,"/TMIN/",regione,"/",regione,"_TMIN_700.png",sep=""),width=650,height=400) 
    print(gg700min)


    #####################################################################
    #Grafico TMAX livello 700
    #####################################################################


    g700max=ggplot(df_grp_max700, aes(t,value))+ #variabili x=tempo y= valore indici
        geom_line(aes(colour=mod_max700,linetype=ind_max700),cex=1.2)+#colore indica il modello il trattoindica l'indice
        geom_point(aes(shape=mod_max700,color=mod_max700),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
        scale_x_date(breaks = df_grp_max700$t ,date_labels ="%d %b %y" )+#"%d %b %y")+ #etichette delle x "%Y-%m-%d" 
        geom_hline(yintercept=0)+
        ggtitle(paste(toupper("TMAX intervallo 0-700 metri, su"),toupper(numstaz$V1),toupper("stazioni,"),toupper("periodo"),toupper(datain_f),toupper(" - "),toupper(dataend_f)))+
        theme_light()+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_linetype_manual(name="Indice",values=c(1,4))+
        scale_colour_discrete(name="Modello",
                              guide = guide_legend(override.aes=aes(fill=NA)),
                              breaks=c("mod1", "mod2","mod3","mod4"),
                              labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
        scale_shape_discrete(name  ="Modello",
                             breaks=c("mod1", "mod2","mod3","mod4"),
                             labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))

    #colori scelti da me
    gg700max=g700max  + theme(axis.title.x = element_blank(),
                              axis.title.y = element_blank())

    png(paste(imgsave_path,"/TMAX/",regione,"/",regione,"_TMAX_700.png",sep=""),width=650,height=400) 
    print(gg700max)

    print("   Grafici creati correttamente.")
} else {
    print("ELABORAZIONE GRAFICI 700m: nessun dato presente.")
}
print("")
print("")
if( numstaz$V2 > 0 ) {
    print("ELABORAZIONE GRAFICI 1500m")
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
    print("   File letti correttamente.")

    #LIVELLO SOTTO I 1500 M ############################################################    
    ntot<-nrow(ossmin150) 
    nintervals<-(ntot/numstaz$V2)%/%10 
    rest<-(ntot/numstaz$V2)%%10

    if(rest > 5) { 
        nintervals<-nintervals + 1 
    }  

    #ora costruisco le matrici dei risultati 
    MEmin150<-matrix(nrow=nintervals,ncol=nmodels) 
    RMSEmin150<-matrix(nrow=nintervals,ncol=nmodels) 
    MEmax150<-matrix(nrow=nintervals,ncol=nmodels) 
    RMSEmax150<-matrix(nrow=nintervals,ncol=nmodels) 

    for (i in 1:nintervals)  {    
        nstart<-(numstaz$V2*10*(i-1)+1) 
        nend<-numstaz$V2*10*i 
        if(i == nintervals) { 
            nend<-nrow(ossmin150)  
        }  
        
        #TMin sotto i 150 m   
        oss<-ossmin150[nstart:nend,] 
        mm<-mmsmin150[nstart:nend,]  
        ecm<-ecmmin150[nstart:nend,] 
        ci7<-ci7min150[nstart:nend,] 
        ci2<-ci2min150[nstart:nend,] 
        C<-sum((mm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin150[i,1]<-C 
        B<-sqrt(mean(((mm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin150[i,1]<-B 
        C<-sum((ecm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin150[i,2]<-C  
        B<-sqrt(mean(((ecm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin150[i,2]<-B 
        C<-sum((ci7$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin150[i,3]<-C  
        B<-sqrt(mean(((ci7$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin150[i,3]<-B 
        C<-sum((ci2$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin150[i,4]<-C  
        B<-sqrt(mean(((ci2$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin150[i,4]<-B 
        
        #TMax sotto i 150 m   
        oss<-ossmax150[nstart:nend,] 
        mm<-mmsmax150[nstart:nend,]  
        ecm<-ecmmax150[nstart:nend,] 
        ci7<-ci7max150[nstart:nend,] 
        ci2<-ci2max150[nstart:nend,] 
        C<-sum((mm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax150[i,1]<-C 
        B<-sqrt(mean(((mm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax150[i,1]<-B 
        C<-sum((ecm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax150[i,2]<-C  
        B<-sqrt(mean(((ecm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax150[i,2]<-B 
        C<-sum((ci7$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax150[i,3]<-C  
        B<-sqrt(mean(((ci7$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax150[i,3]<-B 
        C<-sum((ci2$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax150[i,4]<-C  
        B<-sqrt(mean(((ci2$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax150[i,4]<-B  
    }
    print("   Dati da plottare modellati correttamente.")  

    #############################################################
    #qui modifico io per avere il df ceh piace a me
    ######################
    #Elementi asse x (date) 
    assex<-array(nintervals)  
    posx<-array(nintervals) 
    for (i in 1:nintervals)  {    
        numriga<-(numstaz$V2*10*(i-1)+1) 
        #if(i == nintervals) {     #QUESTA PARTE CAMBIA L'ETICHETTA DELL'ULTIMA DECADE, prende l'ultimo giorno della decade
        #   numriga<-nrow(ossmin150)  
        #}  
        posx[i]<-i 
        assex[i]<- ossmin150[numriga,2]   
    } 


    date<-as.POSIXct(as.character(assex), format="%Y%m%d") #cambia formato alla data
    t<-format(date,"%d %b %y") #vettore tempi, prima colonna del mio df

    ###################################################################################
    risultati_min_unita150<-data.frame(t,MEmin150,RMSEmin150)
    risultati_max_unita150<-data.frame(t,MEmax150,RMSEmax150)

    risultati_min_unita150<-melt(risultati_min_unita150,id.vars="t",variable.name = 'series')
    risultati_max_unita150<-melt(risultati_max_unita150,id.vars="t",variable.name = 'series')

    ind_min150<-c(rep(c("ME","RMSE"), each=4*length(t),len=nrow(risultati_min_unita150)))
    mod_min150<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(t),len=nrow(risultati_min_unita150)))

    ind_max150<-c(rep(c("ME","RMSE"), each=4*length(t),len=nrow(risultati_max_unita150)))
    mod_max150<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(t),len=nrow(risultati_max_unita150)))

    #data.frame finito, con i gruppi necessari al ggplot
    df_grp_min150<-cbind(risultati_min_unita150,mod_min150,ind_min150)
    df_grp_max150<-cbind(risultati_max_unita150,mod_max150,ind_max150)

    #i tempi devono essere della classe Date
    df_grp_min150$t<-as.character(df_grp_min150$t)
    df_grp_min150$t<-as.Date(df_grp_min150$t,"%d %b %y")#"%Y-%m-%d")

    #i tempi devono essere della classe Date
    df_grp_max150$t<-as.character(df_grp_max150$t)
    df_grp_max150$t<-as.Date(df_grp_max150$t,"%d %b %y")#"%Y-%m-%d")
    print("   Vettori da plottare creati correttamente.")

    datain<-df_grp_min150$t[1]

    #de<-length(df_grp_min700$t) #funziona se le decadi spezzano giusto il mese
    #print("de=")
    #print(de)
    #dataend<-df_grp_min700$t[de] 

    #print("data di fine calcolata a partire dal datain +3 mesi ultimo gg del mese")
    end2<-seq(datain,length=4,by="months")-1
    dataend<-end2[4]
    #print(dataend)
    datain_f<-format(datain,"%d %b %y")
    dataend_ff<-as.Date(dataend,format="%d %b %y")
    dataend_f<-format(dataend_ff,"%d %b %y")    

    #####################################################################
    #Grafico  TMIN  livello 1500
    #####################################################################

    g150min=ggplot(df_grp_min150, aes(t,value))+ #variabili x=tempo y= valore indici
        geom_line(aes(colour=mod_min150,linetype=ind_min150),cex=1.2)+#colore indica il modello il trattoindica l'indice
        geom_point(aes(shape=mod_min150,color=mod_min150),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
        scale_x_date(breaks = df_grp_min150$t ,date_labels ="%d %b %y" )+#"%d %b %y")+ #etichette delle x"%Y-%m-%d"
        geom_hline(yintercept=0)+
        ggtitle(paste(toupper("TMIN intervallo 700-1500 metri, su"),toupper(numstaz$V2),toupper("stazioni,"),toupper("periodo"),toupper(datain_f),toupper(" - "),toupper(dataend_f)))+
        theme_light()+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_linetype_manual(name="Indice",values=c(1,4))+
        scale_colour_discrete(name="Modello",
                              guide = guide_legend(override.aes=aes(fill=NA)),
                              breaks=c("mod1", "mod2","mod3","mod4"),
                              labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
        scale_shape_discrete(name  ="Modello",
                             breaks=c("mod1", "mod2","mod3","mod4"),
                             labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))

    gg150min=g150min  + theme(axis.title.x = element_blank(),
                              axis.title.y = element_blank())

    png(paste(imgsave_path,"/TMIN/",regione,"/",regione,"_TMIN_150.png",sep=""),width=650,height=400) 
    print(gg150min)


    #####################################################################
    #Grafico TMAX livello 1500
    #####################################################################

    g150max=ggplot(df_grp_max150, aes(t,value))+ #variabili x=tempo y= valore indici
        geom_line(aes(colour=mod_max150,linetype=ind_max150),cex=1.2)+#colore indica il modello il trattoindica l'indice
        geom_point(aes(shape=mod_max150,color=mod_max150),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
        scale_x_date(breaks = df_grp_max150$t ,date_labels ="%d %b %y" )+#"%d %b %y")+ #etichette delle x
        geom_hline(yintercept=0)+
        ggtitle(paste(toupper("TMAX intervallo 700-1500 metri, su"),toupper(numstaz$V2),toupper("stazioni,"),toupper("periodo"),toupper(datain_f),toupper(" - "),toupper(dataend_f)))+
        theme_light()+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_linetype_manual(name="Indice",values=c(1,4))+
        scale_colour_discrete(name="Modello",
                              guide = guide_legend(override.aes=aes(fill=NA)),
                              breaks=c("mod1", "mod2","mod3","mod4"),
                              labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
        scale_shape_discrete(name  ="Modello",
                             breaks=c("mod1", "mod2","mod3","mod4"),
                             labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))

    gg150max=g150max + theme(axis.title.x = element_blank(),
                             axis.title.y = element_blank())

    png(paste(imgsave_path,"/TMAX/",regione,"/",regione,"_TMAX_150.png",sep=""),width=650,height=400) 
    print(gg150max)      
    print("   Grafici creati correttamente.")
} else {
    print("ELABORAZIONE GRAFICI 1500m: nessun dato presente.")
}
print("")
print("")

if( numstaz$V3 > 0 ) { 
    print("ELABORAZIONE GRAFICI 3000m")
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
    print("   File letti correttamente.")

    #LIVELLO SOTTO I 3000 M ############################################################    
    ntot<-nrow(ossmin300) 
    nintervals<-(ntot/numstaz$V3)%/%10 
    rest<-(ntot/numstaz$V3)%%10

    if(rest > 5) { 
        nintervals<-nintervals + 1 
    }  

    #ora costruisco le matrici dei risultati 
    MEmin300<-matrix(nrow=nintervals,ncol=nmodels) 
    RMSEmin300<-matrix(nrow=nintervals,ncol=nmodels) 
    MEmax300<-matrix(nrow=nintervals,ncol=nmodels) 
    RMSEmax300<-matrix(nrow=nintervals,ncol=nmodels) 

    for (i in 1:nintervals)  {    
        nstart<-(numstaz$V3*10*(i-1)+1) 
        nend<-numstaz$V3*10*i 
        if(i == nintervals) { 
            nend<-nrow(ossmin300)  
        }  
        
        #TMin sotto i 3000 m   
        oss<-ossmin300[nstart:nend,] 
        mm<-mmsmin300[nstart:nend,]  
        ecm<-ecmmin300[nstart:nend,] 
        ci7<-ci7min300[nstart:nend,] 
        ci2<-ci2min300[nstart:nend,]  
        C<-sum((mm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin300[i,1]<-C 
        B<-sqrt(mean(((mm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin300[i,1]<-B 
        C<-sum((ecm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin300[i,2]<-C  
        B<-sqrt(mean(((ecm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin300[i,2]<-B 
        C<-sum((ci7$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin300[i,3]<-C  
        B<-sqrt(mean(((ci7$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin300[i,3]<-B 
        C<-sum((ci2$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmin300[i,4]<-C  
        B<-sqrt(mean(((ci2$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmin300[i,4]<-B 
        
        #TMax sotto i 3000 m   
        oss<-ossmax300[nstart:nend,] 
        mm<-mmsmax300[nstart:nend,]  
        ecm<-ecmmax300[nstart:nend,] 
        ci7<-ci7max300[nstart:nend,] 
        ci2<-ci2max300[nstart:nend,] 
        C<-sum((mm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax300[i,1]<-C 
        B<-sqrt(mean(((mm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax300[i,1]<-B 
        C<-sum((ecm$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax300[i,2]<-C  
        B<-sqrt(mean(((ecm$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax300[i,2]<-B 
        C<-sum((ci7$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax300[i,3]<-C  
        B<-sqrt(mean(((ci7$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax300[i,3]<-B 
        C<-sum((ci2$V9-oss$V9)/10,na.rm=TRUE)/nrow(oss)         
        MEmax300[i,4]<-C  
        B<-sqrt(mean(((ci2$V9-oss$V9)/10)^2,na.rm=T))
        RMSEmax300[i,4]<-B  
    }   
    print("   Dati da plottare modellati correttamente.") 
    #############################################################
    #qui modifico io per avere il df ceh piace a me
    ######################
    #Elementi asse x (date) 
    assex<-array(nintervals)  
    posx<-array(nintervals) 
    for (i in 1:nintervals)  {    
        numriga<-(numstaz$V3*10*(i-1)+1) 
        #if(i == nintervals) {   #QUESTA PARTE CAMBIA L'ETICHETTA DELL'ULTIMA DECADE, prende l'ultimo giorno della decade
        #   numriga<-nrow(ossmin300)  
        #}  
        posx[i]<-i 
        assex[i]<- ossmin300[numriga,2]   
    } 

    date<-as.POSIXct(as.character(assex), format="%Y%m%d") #cambia formato alla data
    t<-format(date,"%d %b %y") #vettore tempi, prima colonna del mio df

    risultati_min_unita300<-data.frame(t,MEmin300,RMSEmin300)
    risultati_max_unita300<-data.frame(t,MEmax300,RMSEmax300)

    risultati_min_unita300<-melt(risultati_min_unita300,id.vars="t",variable.name = 'series')
    risultati_max_unita300<-melt(risultati_max_unita300,id.vars="t",variable.name = 'series')

    ind_min300<-c(rep(c("ME","RMSE"), each=4*length(t),len=nrow(risultati_min_unita300)))
    mod_min300<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(t),len=nrow(risultati_min_unita300)))

    ind_max300<-c(rep(c("ME","RMSE"), each=4*length(t),len=nrow(risultati_max_unita300)))
    mod_max300<-c(rep(c("mod1","mod2","mod3","mod4"),each=length(t),len=nrow(risultati_max_unita300)))

    #data.frame finito, con i gruppi necessari al ggplot
    df_grp_min300<-cbind(risultati_min_unita300,mod_min300,ind_min300)
    df_grp_max300<-cbind(risultati_max_unita300,mod_max300,ind_max300)

    #i tempi devono essere della classe Date
    df_grp_min300$t<-as.character(df_grp_min300$t)
    df_grp_min300$t<-as.Date(df_grp_min300$t,"%d %b %y")#"%Y-%m-%d")

    #i tempi devono essere della classe Date
    df_grp_max300$t<-as.character(df_grp_max300$t)
    df_grp_max300$t<-as.Date(df_grp_max300$t,"%d %b %y")#"%Y-%m-%d")
    print("   Vettori da plottare creati correttamente.")

    datain<-df_grp_min300$t[1]

    #de<-length(df_grp_min700$t) #funziona se le decadi spezzano giusto il mese
    #print("de=")
    #print(de)
    #dataend<-df_grp_min700$t[de] 

    #print("data di fine calcolata a partire dal datain +3 mesi ultimo gg del mese")
    end2<-seq(datain,length=4,by="months")-1
    dataend<-end2[4]
    #print(dataend)
    datain_f<-format(datain,"%d %b %y")
    dataend_ff<-as.Date(dataend,format="%d %b %y")
    dataend_f<-format(dataend_ff,"%d %b %y")

    #####################################################################
    #Grafico TMIN livello 3000
    #####################################################################

    g300min=ggplot(df_grp_min300, aes(t,value))+ #variabili x=tempo y= valore indici
        geom_line(aes(colour=mod_min300,linetype=ind_min300),cex=1.2)+#colore indica il modello il trattoindica l'indice
        geom_point(aes(shape=mod_min300,color=mod_min300),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
        scale_x_date(breaks = df_grp_min300$t ,date_labels ="%d %b %y" )+#"%d %b %y")+ #etichette delle x
        geom_hline(yintercept=0)+
        ggtitle(paste(toupper("TMIN intervallo 1500-3000 metri, su"),toupper(numstaz$V3),toupper("stazioni,"),toupper("periodo"),toupper(datain_f),toupper(" - "),toupper(dataend_f)))+
        theme_light()+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_linetype_manual(name="Indice",values=c(1,4))+
        scale_colour_discrete(name="Modello",
                              guide = guide_legend(override.aes=aes(fill=NA)),
                              breaks=c("mod1", "mod2","mod3","mod4"),
                              labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
        scale_shape_discrete(name  ="Modello",
                             breaks=c("mod1", "mod2","mod3","mod4"),
                             labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))

    gg300min=g300min  + theme(axis.title.x = element_blank(),
                              axis.title.y = element_blank())

    png(paste(imgsave_path,"/TMIN/",regione,"/",regione,"_TMIN_300.png",sep=""),width=650,height=400) 
    print(gg300min)


    #####################################################################
    #Grafico  TMAX livello 3000
    #####################################################################

    g300max=ggplot(df_grp_max300, aes(t,value))+ #variabili x=tempo y= valore indici
        geom_line(aes(colour=mod_max300,linetype=ind_max300),cex=1.2)+#colore indica il modello il trattoindica l'indice
        geom_point(aes(shape=mod_max300,color=mod_max300),cex=4)+ #ogni modello ha un marcatore con la forma diversa e colore uguale alla linea
        scale_x_date(breaks = df_grp_max300$t ,date_labels ="%d %b %y" )+#"%d %b %y")+ #etichette delle x
        geom_hline(yintercept=0)+
        ggtitle(paste(toupper("TMAX intervallo 1500-3000 metri, su"),toupper(numstaz$V3),toupper("stazioni,"),toupper("periodo"),toupper(datain_f),toupper(" - "),toupper(dataend_f)))+
        theme_light()+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_linetype_manual(name="Indice",values=c(1,4))+
        scale_colour_discrete(name="Modello",
                              guide = guide_legend(override.aes=aes(fill=NA)),
                              breaks=c("mod1", "mod2","mod3","mod4"),
                              labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00")) +
        scale_shape_discrete(name  ="Modello",
                             breaks=c("mod1", "mod2","mod3","mod4"),
                             labels=c("MMS_00", "ECMWF_00","COSMO-I5_00","COSMO-2I_00"))

    gg300max=g300max + theme(axis.title.x = element_blank(),
                             axis.title.y = element_blank())

    png(paste(imgsave_path,"/TMAX/",regione,"/",regione,"_TMAX_300.png",sep=""),width=650,height=400) 
    print(gg300max)
    print("   Grafici creati correttamente.")
} else {
    print("ELABORAZIONE GRAFICI 3000m: nessun dato presente.")
}

q() 
