#####################################################################
#####################################################################
#######  Fa dei boxplot con la QPF prevista dai vari modelli  #######
#####################################################################
#####################################################################
####               IMPORTA I FILE CON I DATI,                    ####
####            SELEZIONA SOLO LE RIGHE CON LA QPF               ####
####CREA UN DATAFRAME CON "Prec 24h" med o max in base all'input ####
####                     solo run OO                             ####
#####################################################################
#####################################################################

#pacchetti necessari
#install.packages("functional")
#install.packages("ggplot2")
#install.packages("stringr", dependencies=TRUE)

library(functional)
library(ggplot2)

numero_modelli=7
args = commandArgs(trailingOnly=TRUE) 
work_path<-args[1]
imgsave_path<- args[2]
anagrafiche_path<-args[3]
max_or_med<-args[4]
scadenza<-as.numeric(as.character(args[5]))

#importo le anagrafiche
file<-paste(anagrafiche_path,"/","aree_allertamento_IVIG.txt",sep="") 
Aree<-read.delim(file, header=FALSE, sep = "-", col.names = c("ModelOrder","NomeArea"))
NumeroAree=nrow(Aree[4:nrow(Aree),])

#importo i files txt
#1.Moloch
file<-paste(work_path,"/","MOLOC0023_03_D0_IVIG.txt",sep="") 
mol<-read.delim(file, 
                header=FALSE, sep = "",na.strings = -98,
                col.names = c("nome_var","ore_var","med_max","06","12","18","24",
                              "30","36","42","48","54","60","66","72"))
#2.Bolam
file<-paste(work_path,"/","BOEUR0075_00_D0_IVIG.txt",sep="") 
bol<-read.delim(file, 
                header=FALSE, sep = "",na.strings = -98,
                col.names = c("nome_var","ore_var","med_max","06","12","18","24",
                              "30","36","42","48","54","60","66","72"))

#3.Cosmo-2i
file<-paste(work_path,"/","COSMO0020_00_D0_IVIG.txt",sep="") 
cosmo20<-read.delim(file, 
                    header=FALSE, sep = "",na.strings = -98,
                    col.names = c("nome_var","ore_var","med_max","06","12","18","24",
      	                          "30","36","42","48","54","60","66","72"))

#4.Cosmo-i5
file<-paste(work_path,"/","COSMO0045_00_D0_IVIG.txt",sep="") 
cosmo45<-read.delim(file, 
                    header=FALSE, sep = "",na.strings = -98,
                    col.names = c("nome_var","ore_var","med_max","06","12","18","24",
                                  "30","36","42","48","54","60","66","72"))
#5.Centro europeo
file<-paste(work_path,"/","ECMWF0100_00_D0_IVIG.txt",sep="") 
ecm<-read.delim(file, 
                header=FALSE, sep = "",na.strings = -98,
                col.names = c("nome_var","ore_var","med_max","06","12","18","24",
                              "30","36","42","48","54","60","66","72"))
#6.Icon
file<-paste(work_path,"/","ICOEU0063_00_D0_IVIG.txt",sep="") 
icon<-read.delim(file, 
                 header=FALSE, sep = "",na.strings = -98,
                 col.names = c("nome_var","ore_var","med_max","06","12","18","24",
                               "30","36","42","48","54","60","66","72"))
#7.WRF
file<-paste(work_path,"/","WRFCM0019_00_D0_IVIG.txt",sep="") 
wrf<-read.delim(file, 
                 header=FALSE, sep = "",na.strings = -98,
                 col.names = c("nome_var","ore_var","med_max","06","12","18","24",
                               "30","36","42","48","54","60","66","72"))                               

#USO LA DATA DEL SISTEMA NON LA LEGGO DAL FILE	
#run 00UTC
giorno<-format(Sys.Date(), "%d-%m-%Y")  #data di oggi nel formato giorno-mese-anno da usare nel titolo

column=7+(scadenza-1) #prendo la colonna della scadenza richiesta

rows=c()
start_row=0
if (column==7){ #se la scadenza è oggi, prendo la qpf in 12h
	#il vettore con il numero delle righe che voglio estrarre
	if (max_or_med=="1"){ #0 max 1 med
	  start_row=7
	} else {
	  start_row=8
	}
}else{ #se la scadenza è domani o dopodomani, prendo la qpf in 24h
	if (max_or_med=="1"){ #0 max 1 med
	  start_row=9
	} else {
	  start_row=10
	}
}

rows[1]=start_row #la riga del tipo e della scadenza richiesta è già stata trovata per la prima area di vigilanza
for (i in seq(2, 70)) { #fillo il vettore righe con tutte le righe necessarie da tutte le aree di vigilanza, che son 70, dalla seconda in poi
  rows[i]=rows[i-1]+19 
}	


#estraggo dal DF iniziale solo le righe con la precipitazione alla scadenza richiesta
molDATA<-mol[ rows, column]

bolDATA<-bol[ rows, column]

cosmo20DATA<-cosmo20[ rows, column]

cosmo45DATA<-cosmo45[ rows, column]

ecmDATA<-ecm[ rows, column]

iconDATA<-icon[ rows, column]

wrfDATA<-wrf[ rows, column]

#converto i factors prima in character poi in numerico

molDATA<-sapply( molDATA, Compose( as.character,as.numeric ) )

bolDATA<-sapply( bolDATA, Compose( as.character,as.numeric ) )

cosmo20DATA<-sapply( cosmo20DATA, Compose( as.character,as.numeric ) )

cosmo45DATA<-sapply( cosmo45DATA, Compose( as.character,as.numeric ) )

ecmDATA<-sapply( ecmDATA, Compose( as.character,as.numeric ) )

iconDATA<-sapply( iconDATA, Compose( as.character,as.numeric ) )

wrfDATA<-sapply( wrfDATA, Compose( as.character,as.numeric ) )

################################################################
# AGGIUNGO LE AREEE NEL DF
#aggiungo la lettera che identifica l'area come attributo nel mio df

molDATA<-cbind(Aree[4:nrow(Aree),],molDATA) #unisco la colonna con le aree al df

bolDATA<-cbind(Aree[4:nrow(Aree),],bolDATA)

cosmo20DATA<-cbind(Aree[4:nrow(Aree),],cosmo20DATA)

cosmo45DATA<-cbind(Aree[4:nrow(Aree),],cosmo45DATA)

ecmDATA<-cbind(Aree[4:nrow(Aree),],ecmDATA)

iconDATA<-cbind(Aree[4:nrow(Aree),],iconDATA)

wrfDATA<-cbind(Aree[4:nrow(Aree),],wrfDATA)

################################################################
# AGGIUNGO IL NOME DEL MODELLO NEL DF
# AGGIUNGO D0
#aggiungo altri due attributi, il nome del modello e l'indicazieno sul run 
#D0 run 00UTC

Moloc<-rep("MOLOCH",NumeroAree)      #ho 13 record, uno per ogni scadenza, per cui ripeto il nomemodello 13 volte
ICON<-rep("ICONEU",NumeroAree)       #ho cos� una colonna con l'attributo "nomemodello"
COSMO45<-rep("COSMO45",NumeroAree)
COSMO20<-rep("COSMO20",NumeroAree)
BOLAM<-rep("BOLAM",NumeroAree)
ECMWF<-rep("ECMWF",NumeroAree)
WRF<-rep("WRF",NumeroAree)

mD0<-rep("D0",NumeroAree)           #attributo run

molDATA<-cbind(Moloc,mD0,molDATA)  #unisco al mio df le due colonne con gli attributi

bolDATA<-cbind(BOLAM,mD0,bolDATA)

cosmo20DATA<-cbind(COSMO20,mD0,cosmo20DATA)

cosmo45DATA<-cbind(COSMO45,mD0,cosmo45DATA)

ecmDATA<-cbind(ECMWF,mD0,ecmDATA)

iconDATA<-cbind(ICON,mD0,iconDATA)

wrfDATA<-cbind(WRF,mD0,wrfDATA)

#nome colonne

dfList <- list(molDATA,
              bolDATA,
              cosmo20DATA, cosmo45DATA,ecmDATA,iconDATA, wrfDATA)            #elenco di df a cui cambio nome colonne

colnames<- c("Modello","Giorno","ModelOrder","Area", "Precipitazione") #nuovi nomi per le colonne

cambio_nome<-lapply(dfList, setNames, colnames) #applico la funzione colnames al mio elenco

dfList <- list(molDATA = molDATA, 
               bolDATA = bolDATA,
               cosmo20DATA = cosmo20DATA,
               cosmo45DATA = cosmo45DATA,
               ecmDATA = ecmDATA, 
               iconDATA = iconDATA,
               wrfDATA=wrfDATA)
list2env(lapply(dfList, setNames, colnames), .GlobalEnv) #restituisco tutto al GlobalEnv co i nomi cambiati

#################################################################
#Fino a qui ho estratto dai file i dati che mi servono, ora
#devo metterli in ordine come servono al df del boxplot
#################################################################

#TUTTE LE AREE TUTTE LE SCADENZE, 

#unisco i df dei diversi modelli
DATA<-rbind(molDATA,
            bolDATA,
            cosmo20DATA,cosmo45DATA,ecmDATA,iconDATA,wrfDATA)

## ordinato per area
require(stringr)
DATA$ModelOrder=str_trim(DATA$ModelOrder)
DATA$Area=str_trim(DATA$Area)
DATA$Area=gsub("\\s+", " ", DATA$Area)
boxdata<-DATA[order(DATA$Area, DATA$Modello),] 

media=c() #qui calcolo la media delle previsioni di QPF per ogni area, in modo da poter aggiungere il segmento medio sui boxplot
for (i in seq(1, nrow(boxdata), by=numero_modelli)) {
	valori=c()
	l=1
	for (j in seq(1,numero_modelli)){
		if (!is.na(boxdata[i+j-1, "Precipitazione"])){
			valori[l]=boxdata[i+j-1, "Precipitazione"]
			l=l+1
		}
	}
	for (k in seq(i,i+numero_modelli-1)){
		media[k]=mean(valori)
	}
}

boxdata<-cbind(boxdata,media)

# ###################################################################
# ###################################################################
# #######                         GRAFICI                     #######
# ###################################################################
# ###################################################################

#parametri per la scala MAX
step<-10 #il passo scala è di 10 mm

smin<-min(DATA[,ncol(DATA)],na.rm=TRUE) #prendi il valore minimo dai dati
smax<-max(DATA[,ncol(DATA)],na.rm=TRUE) #prendi il valore max dai dati

if (smax<20){step<-5  #se il max � minore di 20 lo step � di 5 non di 10
}
if (smax<10){step<-2  ##se il max � minore di 10 metti lo step a 2 mm 
smax<-10} 	      #e imposta come max  di scala 10 mm


tipo=""
titolo=""
if (max_or_med=="1"){ #0 max 1 med
  tipo="ave"
  titolo="MEDIA"
} else {
  tipo="max"
  titolo="MASSIMA"
}

titoloScadenza=""
giorno2=""
if (scadenza==1){ #0 max 1 med
titoloScadenza=", scadenza oggi 12-24"
giorno2="D0"
#} else if ( scadenza == 2 ) {
#titoloScadenza=", scadenza domani 00-12"
#giorno="D1"
} else if ( scadenza == 5 ) {
titoloScadenza=", scadenza domani 00-24"
giorno2="D1"
#} else if ( scadenza == 4 ) {
#titoloScadenza=", scadenza dopodomani 00-12"
#giorno="D2"
} else {
titoloScadenza=", scadenza dopodomani 00-24"
giorno2="D2"
}

print(paste("Inizio a fare i grafici",giorno2,titoloScadenza))
png(paste(imgsave_path,"/boxp_",tipo,"_",giorno2,"_tutte.png", sep=""), width = 24, height = 14, units = 'in', res = 100)

box<- ggplot(boxdata, aes(x = Modello, y = Precipitazione)) + #in aes() variabile che voglio sul grafico 
    geom_line(aes(x = Modello, y = media, group = 1), color="black", size=1)+
    geom_point()+
    geom_jitter(shape=16,size=3.5 ,aes(color = Modello), #gruppo che voglio distinguere con il colore
                position=position_jitter(0,0))+ #disallinieo i punti sulla x aggiungendo rumore, sulla y = 0 li tengo fissi
    #facet_wrap(~ paste(d0_MAX$Scadenza,d0_MAX$Area), ncol=14, #pi� box sulla pagina,per area e scadenza
               #labeller = as_labeller(etichette))+ #i titoli sono le "etichette"
    facet_wrap(~ Area, ncol=14)+ #i titoli sono le "etichette"
    #theme_light()+ #se voglio lo sfondo bianco
    theme(strip.text.x = element_text(size = 8,         #parametri grafici del testo
                                      color = "black",  
                                      face = "plain"),
          plot.title = element_text(hjust = 0.5),       #per centrae il titolo
          panel.grid.major = element_line(size=0.3, linetype = "dashed", color = "black"),    #spessore griglia principale
          panel.grid.major.x = element_line(size=0),
          panel.grid.minor = element_line(size=0),
          legend.title=element_text(size=14),
          legend.text=element_text(size=14), 
          axis.text.x=element_blank(), 
          axis.ticks.x=element_blank())+   #spessore griglia secondaria
    scale_y_continuous(breaks = round(seq(smin, 
                                          smax, by = step),0),#scala asse y la personalizzo 
                       limits = c(smin,smax),
                       sec.axis = sec_axis(~. * 1, #asse y aggiuntivo sulla dx
                                           breaks = round(seq(smin, 
                                                              smax, by = step),0)))+ 
    labs(title=paste(toupper(paste("QPF",titolo)),tolower(" run "),toupper("00 UTC"),tolower(" del "),toupper(giorno),tolower(titoloScadenza), sep=""), #giorno � la data estrapolata dal file
         x="", #non voglio l'etichetta sulla x
         y="Precipitazione  (mm)",
         color = "Modello")+ #titoli
    scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple","blue"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU","WRF"))#colori personalizzati #0072B2
    #scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
    #scale_color_manual(values=c("#009E73","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
print(box) #serve per disegnare il grafico sul file
dev.off() #chiude il file aperto prima

#prendo il sottoinsieme delle aree di vigilanza richiesto dalla proteciv e salvo sia png che pdf
boxdataprovciv <- boxdata[which(as.integer(substr(boxdata$Area, 1, 2))>=25 & as.integer(substr(boxdata$Area, 1, 2))<=59), ]
step<-10 #il passo scala � di 10 mm

smin<-min(boxdataprovciv$Precipitazione,na.rm=TRUE) #prendi il valore minimo dai dati
smax<-max(boxdataprovciv$Precipitazione,na.rm=TRUE) #prendi il valore max dai dati

if (smax<20){step<-5  #se il max � minore di 20 lo step � di 5 non di 10
}
if (smax<10){step<-2  ##se il max � minore di 10 metti lo step a 2 mm 
smax<-10} 	      #e imposta come max  di scala 10 mm

png(paste(imgsave_path,"/boxp_",tipo,"_",giorno2,"_protciv.png", sep=""), width = 20, height = 7, units = 'in', res = 100)
boxPROTCIV<- ggplot(boxdataprovciv, aes(x = Modello, y = Precipitazione)) + #in aes() variabile che voglio sul grafico 
    geom_line(aes(x = Modello, y = media, group = 1), color="black", size=1)+
    geom_point()+
    geom_jitter(shape=16,size=3.5 ,aes(color = Modello), #gruppo che voglio distinguere con il colore
                position=position_jitter(0,0))+ #disallinieo i punti sulla x aggiungendo rumore, sulla y = 0 li tengo fissi
    #facet_wrap(~ paste(d0_MAX$Scadenza,d0_MAX$Area), ncol=14, #pi� box sulla pagina,per area e scadenza
               #labeller = as_labeller(etichette))+ #i titoli sono le "etichette"
    facet_wrap(~ Area, ncol=11)+ #i titoli sono le "etichette"
    #theme_light()+ #se voglio lo sfondo bianco
    theme(strip.text.x = element_text(size = 9,         #parametri grafici del testo
                                      color = "black",  
                                      face = "plain"),
          plot.title = element_text(hjust = 0.5),       #per centrae il titolo
          panel.grid.major = element_line(size=0.3, linetype = "dashed", color = "black"),    #spessore griglia principale
          panel.grid.major.x = element_line(size=0),
          panel.grid.minor = element_line(size=0),
          legend.title=element_text(size=14),
          legend.text=element_text(size=14), 
          axis.text.x=element_blank(), 
          axis.ticks.x=element_blank())+   #spessore griglia secondaria
    scale_y_continuous(breaks = round(seq(smin, 
                                          smax, by = step),0),#scala asse y la personalizzo 
                       limits = c(smin,smax),
                       sec.axis = sec_axis(~. * 1, #asse y aggiuntivo sulla dx
                                           breaks = round(seq(smin, 
                                                              smax, by = step),0)))+ 
    labs(title=paste(toupper(paste("QPF",titolo)),tolower(" run "),toupper("00 UTC"),tolower(" del "),toupper(giorno),tolower(titoloScadenza), sep=""), #giorno � la data estrapolata dal file
         x="", #non voglio l'etichetta sulla x
         y="Precipitazione  (mm)",
         color = "Modello")+ #titoli
    scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple","blue"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU","WRF"))#colori personalizzati #0072B2
    #scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
    #scale_color_manual(values=c("#009E73","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
print(boxPROTCIV) #serve per disegnare il grafico sul file
dev.off() #chiude il file aperto prima


pdf(paste(imgsave_path,"/boxp_",tipo,"_protciv_",giorno2,".pdf", sep=""), width = 8.26772, height = 11.6929)
boxPROTCIV<- ggplot(boxdataprovciv, aes(x = Modello, y = Precipitazione)) + #in aes() variabile che voglio sul grafico 
    geom_line(aes(x = Modello, y = media, group = 1), color="black", size=1)+
    geom_point()+
    geom_jitter(shape=16,size=3.5 ,aes(color = Modello), #gruppo che voglio distinguere con il colore
                position=position_jitter(0,0))+ #disallinieo i punti sulla x aggiungendo rumore, sulla y = 0 li tengo fissi
    #facet_wrap(~ paste(d0_MAX$Scadenza,d0_MAX$Area), ncol=14, #pi� box sulla pagina,per area e scadenza
               #labeller = as_labeller(etichette))+ #i titoli sono le "etichette"
    facet_wrap(~ Area)+ #i titoli sono le "etichette"
    #theme_light()+ #se voglio lo sfondo bianco
    guides(colour = guide_legend(nrow = 1))+
    theme(strip.text.x = element_text(size = 8.5,         #parametri grafici del testo
                                      color = "black",  
                                      face = "plain",angle = 0, hjust = 0),
          plot.title = element_text(hjust = 0.5),       #per centrae il titolo
          panel.grid.major = element_line(size=0.3, linetype = "dashed", color = "black"),    #spessore griglia principale
          panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          legend.title=element_text(size=10),
          legend.text=element_text(size=10),
          legend.position="top", 
          axis.text.x=element_blank(), 
          axis.ticks.x=element_blank())+   #spessore griglia secondaria
    scale_y_continuous(breaks = round(seq(smin, 
                                          smax, by = step),0),#scala asse y la personalizzo 
                       limits = c(smin,smax),
                       sec.axis = sec_axis(~. * 1, #asse y aggiuntivo sulla dx
                                           breaks = round(seq(smin, 
                                                              smax, by = step),0)))+ 
    labs(title=paste(toupper(paste("QPF",titolo)),tolower(" run "),toupper("00 UTC"),tolower(" del "),toupper(giorno),tolower(titoloScadenza), sep=""), #giorno � la data estrapolata dal file
         x="", #non voglio l'etichetta sulla x
         y="Precipitazione  (mm)",
         color = "Modello")+ #titoli
    scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple","blue"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU","WRF"))#colori personalizzati #0072B2
    #scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
    #scale_color_manual(values=c("#009E73","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
print(boxPROTCIV) #serve per disegnare il grafico sul file
dev.off()
print("Fine")
q()
