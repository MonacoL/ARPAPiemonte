#####################################################################
#####################################################################
#######  Fa dei boxplot con la QPF prevista dai vari modelli  #######
#####################################################################
#####################################################################
####               IMPORTA I FILE CON I DATI,                    ####
####            SELEZIONA SOLO LE RIGHE CON LA QPF               ####
####     CREA UN DF CON "Prec 12h" med o max in base all'input   ####
####                     solo run OO                             ####
#####################################################################
#####################################################################

#pacchetti necessari
#install.packages("functional")
#install.packages("tidyr")
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("stringr", dependencies=TRUE)

library(functional)
library(tidyr)
library(dplyr)
library(ggplot2)

print("pacchetti caricati")

#per prove in locale
#setwd("C:/Users/laurmass/Documents/R_script/BoxPlot")
#carico il workspace 
#load("./dati_import_D1_D0.RData")
#load("./QPF.RData")
#setwd("C:/Users/laurmass/Documents/R_script/BoxPlot")
#MOLOC0023_03_D0_PIEM.txt  ||| "./fileesempioMoloch.txt"

args = commandArgs(trailingOnly=TRUE) 
work_path<-args[1]
imgsave_path<- args[2]
anagrafiche_path<-args[3]
max_or_med<-args[4]
scadenza<-as.numeric(as.character(args[5])) #1 oggi pomeriggio, 2 domani mattina, 3 domani pomeriggio, 4 dopodomani mattina, 5 dopodomani pomeriggio

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
# file<-paste(work_path,"/","BOEUR0075_00_D0_IVIG.txt",sep="") 
# bol<-read.delim(file, 
#                 header=FALSE, sep = "",na.strings = -98,
#                 col.names = c("nome_var","ore_var","med_max","06","12","18","24",
#                               "30","36","42","48","54","60","66","72"))
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

#USO LA DATA DEL SISTEMA NON LA LEGGO DAL FILE	
#run 00UTC
giorno<-format(Sys.Date(), "%d-%m-%Y")  #data di oggi nel formato giorno-mese-anno da usare nel titolo

#il vettore con il numero delle righe che voglio estrarre
rows=c()
start_row=0
if (max_or_med=="1"){ #0 max 1 med
  start_row=7
} else {
  start_row=8
}

rows[1]=start_row
for (i in seq(2, 70)) {
  rows[i]=rows[i-1]+19 #prendo solo la precipitazione ogni 12 ore
}

column=7+((scadenza-1)*2) #prendo la colonna della scadenza richiesta

#estraggo dal DF iniziale solo le righe con la precipitazione alla scadenza richiesta
molDATA<-mol[ rows, column]

# bolDATA<-bol[ rows, column]

cosmo20DATA<-cosmo20[ rows, column]

cosmo45DATA<-cosmo45[ rows, column]

ecmDATA<-ecm[ rows, column]

iconDATA<-icon[ rows, column]

#converto i factors prima in character poi in numerico

molDATA<-sapply( molDATA, Compose( as.character,as.numeric ) )

# bolDATA<-sapply( bolDATA, Compose( as.character,as.numeric ) )

cosmo20DATA<-sapply( cosmo20DATA, Compose( as.character,as.numeric ) )

cosmo45DATA<-sapply( cosmo45DATA, Compose( as.character,as.numeric ) )

ecmDATA<-sapply( ecmDATA, Compose( as.character,as.numeric ) )

iconDATA<-sapply( iconDATA, Compose( as.character,as.numeric ) )

################################################################
# AGGIUNGO LE AREEE NEL DF
#aggiungo la lettera che identifica l'area come attributo nel mio df

molDATA<-cbind(Aree[4:nrow(Aree),],molDATA) #unisco la colonna con le aree al df

# bolDATA<-cbind(Aree[5:nrow(Aree),],bolDATA)

cosmo20DATA<-cbind(Aree[4:nrow(Aree),],cosmo20DATA)

cosmo45DATA<-cbind(Aree[4:nrow(Aree),],cosmo45DATA)

ecmDATA<-cbind(Aree[4:nrow(Aree),],ecmDATA)

iconDATA<-cbind(Aree[4:nrow(Aree),],iconDATA)

################################################################
# AGGIUNGO IL NOME DEL MODELLO NEL DF
# AGGIUNGO D0
#aggiungo altri due attributi, il nome del modello e l'indicazieno sul run 
#D0 run 00UTC

Moloc<-rep("MOLOCH",NumeroAree)      #ho 13 record, uno per ogni scadenza, per cui ripeto il nomemodello 13 volte
ICON<-rep("ICONEU",NumeroAree)       #ho così una colonna con l'attributo "nomemodello"
COSMO45<-rep("COSMO45",NumeroAree)
COSMO20<-rep("COSMO20",NumeroAree)
# BOLAM<-rep("BOLAM",NumeroAree)
ECMWF<-rep("ECMWF",NumeroAree)

mD0<-rep("D0",NumeroAree)           #attributo run

molDATA<-cbind(Moloc,mD0,molDATA)  #unisco al mio df le due colonne con gli attributi

# bolDATA<-cbind(BOLAM,mD0,bolDATA)

cosmo20DATA<-cbind(COSMO20,mD0,cosmo20DATA)

cosmo45DATA<-cbind(COSMO45,mD0,cosmo45DATA)

ecmDATA<-cbind(ECMWF,mD0,ecmDATA)

iconDATA<-cbind(ICON,mD0,iconDATA)

#nome colonne

dfList <- list(molDATA,
              #bolDATA,
              cosmo20DATA, cosmo45DATA,ecmDATA,iconDATA)            #elenco di df a cui cambio nome colonne
colonna_prec=""
if ( scadenza == 1 ) {
colonna_prec="X24"
} else if ( scadenza == 2 ) {
colonna_prec="X36"
} else if ( scadenza == 3 ) {
colonna_prec="X48"
} else if ( scadenza == 4 ) {
colonna_prec="X60"
} else {
colonna_prec="X72"
}

colnames<- c("Modello","Giorno","ModelOrder","Area", colonna_prec) #nuovi nomi per le colonne

cambio_nome<-lapply(dfList, setNames, colnames) #applico la funzione colnames al mio elenco

dfList <- list(molDATA = molDATA, 
               #bolDATA = bolDATA,
               cosmo20DATA = cosmo20DATA,
               cosmo45DATA = cosmo45DATA,
               ecmDATA = ecmDATA, 
               iconDATA = iconDATA)
list2env(lapply(dfList, setNames, colnames), .GlobalEnv) #restituisco tutto al GlobalEnv co i nomi cambiati

#################################################################
#Fino a qui ho estratto dai file i dati che mi servono, ora
#devo metterli in ordine come servono al df del boxplot
#################################################################

#TUTTE LE AREE TUTTE LE SCADENZE, 
#dataframe per il grafico boxdataMAX e boxdatMED

#unisco i df dei diversi modelli
DATA<-rbind(molDATA,
            #bolDATA,
            cosmo20DATA,cosmo45DATA,ecmDATA,iconDATA)

# # ordinato per scadenza
# tydiMED<-MED %>% 
#     gather(Scadenza,value, X06:X72) #creo un df tydi, una colonna per ogni variabile
# tydiMAX<-MAX %>%                    #colonna Scadenza: X6,X12 ecc
#     gather(Scadenza,value, X06:X72) #colonna value: valore numerico di qpf in mm

## ordinato per area
require(stringr)
DATA$ModelOrder=str_trim(DATA$ModelOrder)
DATA$Area=str_trim(DATA$Area)
DATA$Area=gsub("\\s+", " ", DATA$Area)
boxdata<-DATA[order(DATA$ModelOrder),] #prima tutta la area A, poi B ecc

# #############################################################
# # VIP TUTTE LE AREE 6 SCADENZE CENTRALI
# # dataframe per il grafico boxdataVIPMAX e boxdataVIPMED

# #estraggo solo alcune scadenze
# tydiVIPMAX<-dplyr::filter(boxdataMAX, Scadenza %in% c("X18", "X24","X30","X36","X42","X48"))
# tydiVIPMED<-dplyr::filter(boxdataMED, Scadenza %in% c("X18", "X24","X30","X36","X42","X48"))

# #estraggo solo le colonne che mi servono
#boxdataVIP<-boxdata[,ncol(boxdata)]

# #####################################################################
# ## dai DF con le 6 scadenze ordinati, boxdataVIPMAX e boxdataVIPMED,
# ## prendo solo il D0 per i primi due grafici, 
# ## poi prendo per i modelli che hanno anche il d1 entrambi i giorni


# #D0, df per il grafico di "Run 00UTC"

# mod6<-c("D0") #elenco del giorno che voglio

# d0_MAX <- boxdataVIPMAX %>%  #seleziono solo il D0 (ci sono sei modelli mod6)
#     filter(Giorno %in% mod6)

# d0_MED <- boxdataVIPMED %>% #seleziono solo il D0
#     filter(Giorno %in% mod6)

# #D0 D1 df per il grafico di "Run 12UTC e 00UTC"

# run2<- c( "COSMO20", "COSMO45","COSMO i2", "ICONEU", "ECMWF") #elenco modelli che voglio

# d1_MAX<-boxdataVIPMAX %>%	#devo filtrare solo i modelli con il doppio run (run2)
#     filter(Modello %in% run2)

# d1_MED<-boxdataVIPMED %>%
#     filter(Modello %in% run2)

# #SALVO IL WS
# #save.image("./dati_import.RData_prove_in_locale.RData")

# ###################################################################
# ###################################################################
# #######                         GRAFICI                     #######
# ###################################################################
# ###################################################################
# #                    GRAFICI 6 SCADENZE CENTRALI                  #
# ###################################################################
# ###################################################################

# ###################################################################
# ###################################################################
# ##################       D0    6 MODELLI     ######################
# ###################################################################
# ###################################################################
print("Inizio a fare i grafici D0")

#parametri per la scala MAX
step<-10 #il passo scala è di 10 mm

smin<-min(DATA[,ncol(DATA)],na.rm=TRUE) #prendi il valore minimo dai dati
smax<-max(DATA[,ncol(DATA)],na.rm=TRUE) #prendi il valore max dai dati

if (smax<20){step<-5  #se il max è minore di 20 lo step è di 5 non di 10
}
if (smax<10){step<-2  ##se il max è minore di 10 metti lo step a 2 mm 
smax<-10} 	      #e imposta come max  di scala 10 mm

#ETICHETTE GRAFICO
#########################################################################################
# etichette<-c()
# for (i in seq(1:70)) {
#   prova=Aree[3+i,2]
#   etichette[i]<-(prova="Area")
#   #etichette[i]<-paste(Aree[3+i,2],"=",paste("Area", Aree[3+i,2], sep=""), sep="")
# }
# print(etichette)
# warnings()
#########################################################################################

tipo=""
titolo=""
if (max_or_med=="1"){ #0 max 1 med
  tipo="med"
  titolo="MEDIA"
} else {
  tipo="max"
  titolo="MASSIMA"
}

titoloScadenza=""
if (scadenza==1){ #0 max 1 med
titoloScadenza=", scadenza oggi 12-24"
} else if ( scadenza == 2 ) {
titoloScadenza=", scadenza domani 00-12"
} else if ( scadenza == 3 ) {
titoloScadenza=", scadenza domani 12-24"
} else if ( scadenza == 4 ) {
titoloScadenza=", scadenza dopodomani 00-12"
} else {
titoloScadenza=", scadenza dopodomani 12-24"
}

png(paste(imgsave_path,"qpf_",tipo,"_",scadenza,".png", sep=""), width = 24, height = 14, units = 'in', res = 100)

boxMAX<- ggplot(boxdata, aes(x = "", y = boxdata[,ncol(boxdata)])) + #in aes() variabile che voglio sul grafico 
    geom_boxplot(outlier.size= -1)+ #voglio un boxplot, senza che si vedano gli outlayer come pallini neri
    geom_jitter(shape=16,size=3.5 ,aes(color = boxdata$Modello), #gruppo che voglio distinguere con il colore
                position=position_jitter(0.2,0))+ #disallinieo i punti sulla x aggiungendo rumore, sulla y = 0 li tengo fissi
    #facet_wrap(~ paste(d0_MAX$Scadenza,d0_MAX$Area), ncol=14, #più box sulla pagina,per area e scadenza
               #labeller = as_labeller(etichette))+ #i titoli sono le "etichette"
    facet_wrap(~ boxdata$Area, ncol=14)+ #i titoli sono le "etichette"
    #theme_light()+ #se voglio lo sfondo bianco
    theme(strip.text.x = element_text(size = 8,         #parametri grafici del testo
                                      color = "black",  
                                      face = "plain"),
          plot.title = element_text(hjust = 0.5),       #per centrae il titolo
          panel.grid.major = element_line(size=0.8),    #spessore griglia principale
          panel.grid.minor = element_line(size=0.8))+   #spessore griglia secondaria
    scale_y_continuous(breaks = round(seq(smin, 
                                          smax, by = step),0),#scala asse y la personalizzo 
                       limits = c(smin,smax),
                       sec.axis = sec_axis(~. * 1, #asse y aggiuntivo sulla dx
                                           breaks = round(seq(smin, 
                                                              smax, by = step),0)))+ 
    labs(title=paste(toupper(paste("QPF",titolo)),tolower(" run "),toupper("00 UTC"),tolower(" del "),toupper(giorno),tolower(titoloScadenza), sep=""), #giorno è la data estrapolata dal file
         x=" ", #non voglio l'etichetta sulla x
         y="Precipitazione  (mm)",
         color = "Modello")+ #titoli
    #scale_color_manual(values=c("#009E73","#CC79A7","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))#colori personalizzati #0072B2
    scale_color_manual(values=c("#009E73","#D55E00","#56B4E9","green" ,"purple"),labels = c("MOLOCH","COSMO-2I","COSMO-I5","ECMWF","ICONEU"))+#colori personalizzati #0072B2
    theme(legend.title=element_text(size=14),legend.text=element_text(size=14))
print(boxMAX) #serve per disegnare il grafico sul file
dev.off() #chiude il file aperto prima

print("finiti i grafici del D0")

q()
