#sul bash, controllare presenza file in cartella, ottenerne la lista, togliere la b iniziale e il numeretto del cazzo in mezzo, e passare tutto su inputtemp

getAnnoStagione <- function(periodo) {
    periodo_splitted=unlist(strsplit(periodo, "_"))

    beginMonth<-substr(periodo_splitted[1],5,6)
    endYear<-substr(periodo_splitted[2],1,4)

    if (beginMonth=="12"){
        return(c(endYear,"DJF"))
    }else if(beginMonth=="03"){
        return(c(endYear,"MAM"))
    }else if(beginMonth=="06"){
        return(c(endYear,"JJA"))
    }else{
        return(c(endYear,"SON"))
    }
}


library(ggplot2)

args = commandArgs(trailingOnly=TRUE) 
work_path<-args[1]
output_path<-args[2]
txtfile<-args[3]

df_txtfile<-read.table(txtfile,header=F, col.names=c("Anno","Stagione", "AveMax", "ForecastTime", "Modelli","Soglia"), colClasses = "character")

modelli_descr=c("m0103","b0700","c2200","c5m00","e1000","i0700","wrf00","prvsa")
modelli_name=c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICON","WRF","PSA")

#root_path="/home/monacoarpa/Desktop/ARPA/CostLoss/"
#dati_path="dati/"
#output_path="Grafici/"

files=list.files(path = work_path, pattern = NULL, all.files = FALSE,
           full.names = FALSE, recursive = FALSE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)

df_files=as.data.frame(files)

m_files<-matrix("", nrow = nrow(df_files), ncol = 5)

for(i in seq(1,nrow(df_files))){
    file_name_vector=unlist(strsplit(as.character(df_files$files[i]), "_"))
    m_files[i,1]=paste(file_name_vector[5],"_",file_name_vector[6], sep="")   #periodo
    m_files[i,2]=file_name_vector[1]   #max o ave
    m_files[i,3]=paste(file_name_vector[2],"_",file_name_vector[3], sep="")   #modelli
    m_files[i,4]=file_name_vector[4]   #forecast time
    m_files[i,5]=file_name_vector[7]   #soglia
}

df_files<-as.data.frame(m_files)
colnames(df_files)<-c("Periodo","MaxAve","Modelli","ForecastTime","Soglia")

periodi=unique(df_files$Periodo)
nperiodi=NROW(periodi)

for(i in seq(1,nperiodi)){ #ciclo sui periodi
    for(max_or_ave in c("max","ave")){  #ciclo su max e ave
        #trovo quanti modelli ci sono
        modelli<-df_files$Modelli[which(df_files$Periodo==periodi[i] & df_files$MaxAve==max_or_ave)]
        modelli<-unique(modelli)
        nmodels<-NROW(modelli)
        for(m in seq(1,nmodels)){
            forecast_time<-df_files$ForecastTime[which(df_files$Periodo==periodi[i] & df_files$MaxAve==max_or_ave & df_files$Modelli==modelli[m])]
            forecast_time<-unique(forecast_time)
            n_forecasttimes<-NROW(forecast_time)
            for(f in seq(1,n_forecasttimes)){
                thresholds<-df_files$Soglia[which(df_files$Periodo==periodi[i] & df_files$MaxAve==max_or_ave & df_files$Modelli==modelli[m] & df_files$ForecastTime==forecast_time[f])]
                n_threshold<-NROW(thresholds)               
                for(t in seq(1,n_threshold)){
                    first_model=unlist(strsplit(as.character(modelli[m]), "_"))[1]
                    second_model=unlist(strsplit(as.character(modelli[m]), "_"))[2]

                    begin_period=unlist(strsplit(as.character(periodi[i]), "_"))[1]
                    end_period=unlist(strsplit(as.character(periodi[i]), "_"))[2]

                    fmodel_id=match(first_model,modelli_descr)
                    first_model=modelli_name[fmodel_id]
                    smodel_id=match(second_model,modelli_descr)
                    second_model=modelli_name[smodel_id]

                    threshold_title=""
                    if (thresholds[t]=="000"){
                        threshold_title="0.2"    
                        threshold_filename="02"
                    }else if (substr(thresholds[t],1,2)=="00"){
                        threshold_title=substr(thresholds[t],3,3)
                        threshold_filename=threshold_title
                    }else if (substr(thresholds[t],1,1)=="0"){
                        threshold_title=substr(thresholds[t],2,3)
                        threshold_filename=threshold_title
                    }

                    titolo=paste("VALUE ",first_model," VS. ",second_model," ",toupper(max_or_ave),"\n",sep="")
                    titolo=paste(titolo,"threshold=",threshold_title,"mm/24h; ",sep="")
                    titolo=paste(titolo,"forecast time=+",substr(forecast_time[f],1,2),"/+",substr(forecast_time[f],3,4),"; ", sep="")
                    titolo=paste(titolo,"periodo=",begin_period,"-",end_period,sep="")

                    file_name=paste(max_or_ave,"_",modelli[m],"_",forecast_time[f],"_",periodi[i],"_",thresholds[t],"_VALUE.tab",sep="")
                    file_path=paste(work_path,"/",file_name,sep="")
                    df_fmodel<-read.table(file_path,header=F, col.names=c("costloss","model1", "model2", "lowerbar","higherbar"))

                    #df_fmodel<-df_fmodel[which(as.double(df_fmodel$model1)>=0), ]
                    #df_smodel<-data.frame("costloss"=df_fmodel$costloss)

                    for (j in seq(1,nrow(df_fmodel))){
                        if(df_fmodel[j,"lowerbar"]<0){
                            df_fmodel[j,"lowerbar"]=0
                        }
                    }

                    AnnoStagione<-getAnnoStagione(as.character(periodi[i]))

                    output_file<-paste(output_path,"/",AnnoStagione[1],"/",AnnoStagione[2],"/",max_or_ave,"/",sep="")
                    output_file<-paste(output_file,max_or_ave,"_",modelli[m],"_",forecast_time[f],"_",threshold_filename,".png",sep="")
                    png(output_file,width = 1100, height = 400)
                    valore_plot<- ggplot(df_fmodel, aes(x = costloss))+theme_bw()+
                                #geom_point(aes(y=model1), colour="red")+
                                geom_pointrange(aes(y = model1,ymin=lowerbar, ymax=higherbar, linetype=first_model), colour="red")+
                                geom_point(aes(y = model2,color=second_model), size = 4, shape=1)+
                                scale_y_continuous(breaks=c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1), limits=c(0,1),expand = c(0, 0))+
                                scale_x_continuous(breaks=c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1), limits=c(0,1),expand = c(0, 0))+
                                labs(title=titolo,x="C/L", y="VALORE", group="legenda")+
                                theme(legend.position = c(0.9, 0.85), 
                                legend.title=element_blank(),
                                legend.text=element_text(size=20),
                                legend.box.background = element_rect(colour = "black"),
                                legend.spacing.y = unit(0, "mm"),
                                panel.grid.major = element_blank(), 
                                panel.grid.minor = element_blank(),
                                axis.text.x = element_text(size=18,margin=unit(c(0.3,0,0.3,0),"cm")),
                                axis.text.y = element_text(size=18,margin=unit(c(0,0.3,0,0.3),"cm")),
                                plot.margin=unit(c(0.5,0.5,0.5,0.5),"cm"),
                                axis.title=element_text(size=18),
                                plot.title = element_text(hjust = 0.5, size=20, face="bold"))+
                                scale_color_manual(name = "Legenda", values = c("blue","red"), labels=c(second_model,first_model))
                    print(valore_plot)
                    dev.off()
                    df_txtfile<-rbind(df_txtfile,c(AnnoStagione[1],AnnoStagione[2],max_or_ave,as.character(forecast_time[f]),as.character(modelli[m]),threshold_filename))
                }
            }
        }
    }
}
df_txtfile<-unique(df_txtfile)
write.table(df_txtfile, txtfile, append = FALSE, sep = " ", row.names = FALSE, col.names = FALSE, quote = FALSE)