#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 18 14:40:08 2020

@author: lucamonaco
"""

#PROCEDURA PER CREAZIONE JSON PER MISTRAL
import os
import jsonlines
import FunzioniUtili
import datetime
import pandas as pd
import numpy as np
from collections import OrderedDict

flagLocal=0 #1 if local, 0 if xmeteo

#definisco variabili da usare quando sono in local
Regioni=["PI","EM"]
Prefisso_NomeFile="MMSUP"
path_MM="dati/" #radice da dove prendo i dati MM
path_InputTemp="InputTemp/" #radice della cartella di lavoro
path_Anagrafiche="Anagrafiche/" #radice cartella anagrafiche
path_JSONOutput="JSON_Output/" #radice cartella di output per il json
leadtime_minime=[6,30,54,78,102,126,150,174,198,222]
leadtime_massime=[18,42,66,90,114,138,162,186,210,234]
currentYearMonth="202003" #timestamps per le prove in locale
currentYearMonthDay="20200320"
MMYearMonth="202003"
MMYearMonthDay="20200318"

if flagLocal==0: #se non sono in local, allora setto le variabili come da macchina online
    Regioni=["PI","AO","LO","VE","TR","LI","FR","EM","TO","UM","MA","MO","LA","AB","PU","CA","CB","BA","SI","SA"]
    path_MM="/output/meteo/multimodel/"
    path_InputTemp="/home/meteo/proc/MISTRAL/InputTemp/"
    path_Anagrafiche="/home/meteo/proc/MISTRAL/Anagrafiche/"
    path_JSONOutput="/home/meteo/proc/MISTRAL/JSON_Output/"
    path_JSONOutput_xmeteo="/output/meteo/multimodel/json/"
    [currentYearMonth, currentYearMonthDay]=FunzioniUtili.GetFullDayString(0,0) #today
    [MMYearMonth, MMYearMonthDay]=FunzioniUtili.GetFullDayString(2,-1) #two days ago
    print("Popolo la cartella anagrafiche.") #copiando da xmeteo4, dove sono sempre aggiornate
    os.system("scp meteo@xmeteo4.ad.arpa.piemonte.it:/home/meteo/etc/multimodel/stazioni/*.DAT "+path_Anagrafiche)
    print(" ")
    print(" ")

jsonfile_path=path_JSONOutput+"JSON_ARPAPiemonte.jsonl"  #path cartella locale per output json

print("inizio:",datetime.datetime.now()) #voglio vedere quanto dura la procedura

with jsonlines.open(jsonfile_path, mode='w') as writer:   
    for regione in Regioni: #ciclo sulle regioni
        Dati=pd.DataFrame() #definisco un dataframe pandas vuoto
        MM_source_file=path_MM+regione+"/"+Prefisso_NomeFile+"_"+MMYearMonth+"_"+regione+".DAT" #definisco i path di source e destinazione dei file di multimodel
        MM_destination_file=path_InputTemp+Prefisso_NomeFile+"_"+MMYearMonth+"_"+regione+".DAT"
        if os.path.isfile(MM_source_file): #se c'è il file di multimodel nella cartella di source
            print("File MM regione",regione,"esiste.") #allora vado avanti
            path_anag=path_Anagrafiche+regione+"_ANAG_OK.DAT" #le anagrafiche con OK sono quelle più aggiornate
            presenza_anag=os.path.isfile(path_anag) 
            if not presenza_anag: #ma se non c'è quella con l'ok, verifico che ci sia almeno quella senza ok
                path_anag=path_Anagrafiche+regione+"_ANAG.DAT"
                presenza_anag=os.path.isfile(path_anag)
            if presenza_anag: #se uno dei due file di anagrafica esiste, vado avanti
                print("File Anagrafica regione",regione,"esiste.")
                os.system("cp "+MM_source_file+" "+MM_destination_file) #e copio il file di multimodel in locale
                print("   File MM regione",regione,"copiato in locale in cartella temporanea.")           
                Dati=FunzioniUtili.ReadMMFile2(MM_destination_file, MMYearMonthDay+"00", 51, 120) #51 leadtime oggi 00-03, 120 leadtime dopodomani 21-24
                nrow=Dati.shape[0]
                if nrow>0: #se ci sono dati per il giorno considerato
                    Anagrafica=FunzioniUtili.ReadAnagFile(path_anag) #leggo l'anagrafica        
                    json_row={} #
                    for riga in range(0,nrow): #ciclo sui dati previsionali nell'intervallo di leadtime considerati
                        Previsione=Dati.values[riga] #riga di multimodel
                        codice_stazione=Previsione[0] 
                        if not pd.isnull(codice_stazione): #riga introdotta per ovviare al problema dei codici stazione corrotti nei file multimodel
                            # if old_codice_stazione!=codice_stazione:
                            #     if json_row!={}:
                            #         writer.write(json_row)
                            #         json_row={}
                            stazione=Anagrafica.loc[Anagrafica["Codice Stazione"]==codice_stazione] #prendo la riga di anagrafica corrispondente al codice stazione della riga previsionale
                            lat=int(float('{0:.3f}'.format(stazione.values[0][2]))*(10**5))
                            longi=int(float('{0:.3f}'.format(stazione.values[0][3]))*(10**5))
                            quota=int(stazione.values[0][4])
                            #data=str(Previsione[1])
                            data_completa = FunzioniUtili.GetPrevisionDayString(MMYearMonthDay,Previsione[2])
                            #data_completa=data[0:4]+"-"+data[4:6]+"-"+data[6:8]+"T00:00:00Z" #run delle 00
                            json_row=OrderedDict()
                            json_row["network"]="multim-forecast"
                            json_row["lon"]=longi
                            json_row["date"]=data_completa #data del giorno di previsione
                            json_row["lat"]=lat
                            json_row["data"]=[]

                            info_stazione={"vars": 
                                                {
                                                "B01019": {"v": stazione.values[0][1]}, #nome stazione
                                                "B07030": {"v": quota}, #altezza stazione
                                                #"B07031": {"v": quota} #altezza barometrica stazione
                                                }
                                        }                
                            json_row["data"].append(info_stazione)     
                
                            Variabili={}                            
                            #dati triorari                  
                            Variabili["B12101"]={"v": 0} #temperatura trioraria
                            if int(Previsione[4])==9999:
                                Variabili["B12101"]["v"]=None
                            else:
                                Variabili["B12101"]["v"]=float("{:0.2f}".format(Previsione[4]/10 + 273.15)) #temp in K*10-2     
                                
                            Variabili["B13003"]={"v": 0} #umidità relativa
                            if int(Previsione[7])==9999:
                                Variabili["B13003"]["v"]=None
                            else:
                                Variabili["B13003"]["v"]=int(Previsione[7])
        
                            previsioni={
                                    "timerange": [254, int(Previsione[2])*60*60,0], # 254=custom timerange, int(Previsione[2])*60*60 = quanto tempo in secondi c'è tra data della previsione e data di emissione, 0 previsioni di grandezze istantanee
                                    "vars": Variabili,
                                    "level": [105, 2000, None, None] #previsioni a 2m da terra
                                    }                
                            json_row["data"].append(previsioni) 
                            #dati massima/minima, dati ogni 12 ore                            
                            if (Previsione[2] in leadtime_massime) or (Previsione[2] in leadtime_minime): 
                                Variabili={}
                                Variabili["B12101"]={"v": 0}
                                if int(Previsione[8])==9999:
                                    Variabili["B12101"]["v"]=None
                                else:
                                    Variabili["B12101"]["v"]=float("{:0.2f}".format(Previsione[8]/10 + 273.15)) #temp in K*10-2
                                if Previsione[2] in leadtime_massime:
                                    codice_temp=2
                                else:
                                    codice_temp=3
                                previsioni={
                                        "timerange": [codice_temp, int(Previsione[2])*60*60,12*60*60],
                                        "vars": Variabili,
                                        "level": [105, 2000, None, None]
                                        }                
                                json_row["data"].append(previsioni)                                                                                                                            
                            #old_codice_stazione=codice_stazione                    
                            writer.write(json_row) #scrivo l'ultima riga
                else:
                    print("Previsione della data "+MMYearMonthDay+" non presente per la regione",regione,". Skip alla prossima regione.")    
                if flagLocal==0:
                    print("   Dati inseriti nel jsonline.")
                    os.system("rm "+path_InputTemp+"*")#se non sono in locale, libero, la cartella di lavoro
                    print("   Liberata cartella temporanea file MM.") 
                print("")            
            else:
                print ("File Anagrafica regione",regione,"non esiste. Skip alla prossima regione.")
        else:
            print("File MM regione",regione,"non esiste. Skip alla prossima regione.")
print("")
if flagLocal==0: #se non sono in locale copio il json sulla macchina arpa adibita a questo scopo
    JSON_destination_file=path_JSONOutput_xmeteo+"JSON_ARPAPiemonte.jsonl"
    os.system("cp "+jsonfile_path+" "+JSON_destination_file)
    print("   Copiato il jsonline nella cartella di output.")
    os.system("rm "+path_JSONOutput+"*")
    print("   Liberata cartella temporanea json.")
    os.system("rm "+path_Anagrafiche+"*")
    print("   Liberata cartella anagrafiche.")    
    print("")
print("fine:",datetime.datetime.now())    