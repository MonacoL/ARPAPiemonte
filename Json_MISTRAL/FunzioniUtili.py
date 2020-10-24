#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 18 15:00:35 2020

@author: lucamonaco
"""
import pandas as pd
import datetime 
def ReadMMFile1(file, oggi):
    data=pd.read_csv(file, sep=" ", header=None) #importo tutto il file MM
    data.columns = ['Codice Stazione', 
                    'Data Emissione', 
                    'Leadtime', 
                    'QPF Esoraria', #[mm*10]
                    'Temp trioraria', #[°C*10]
                    'Dir. vento',#[°]
                    'Vel. vento',#[m/s]
                    'Umidità rel', #[%]
                    'Temp. estremante', #[°C*10]
                    ]
    data_oggi=data.loc[data["Data Emissione"]==int(oggi)]    #prendo solo il sottoinsieme con le date di oggi
    return data_oggi

def ReadMMFile2(file, oggi, beginLeadTime, endLeadTime):
    data=pd.read_csv(file, sep=" ", header=None) #importo tutto il file MM
    data.columns = ['Codice Stazione', 
                    'Data Emissione', 
                    'Leadtime', 
                    'QPF Esoraria', #[mm*10]
                    'Temp trioraria', #[°C*10]
                    'Dir. vento',#[°]
                    'Vel. vento',#[m/s]
                    'Umidità rel', #[%]
                    'Temp. estremante', #[°C*10]
                    ]
    data_oggi=data.loc[(data["Data Emissione"]==int(oggi)) & (data["Leadtime"]>=beginLeadTime) & (data["Leadtime"]<=endLeadTime)]    #prendo solo il sottoinsieme con le date di oggi
    return data_oggi    

def ReadAnagFile(file):
    data=pd.read_fwf(file, header=None)
    output=data.loc[:,0:4] #prendo solo le colonne che mi servono
    output.columns = ['Codice Stazione', 'Nome Stazione', 'Lat', 'Long','Quota']
    return output

def GetFullDayString(abslag,lagsign): #get delle stringhe YYYYMM e YYYYMMDD. Questa funzione è necessaria ad ottenere il timestamp di due giorni prim
    #rispetto a quello attuale, perchè i dati di multimodel arrivano sempre con 2 giorni di ritardo
    if abslag>0: #se il lag da applicare al giorno attuale è >0
        lag_days = datetime.timedelta(days=abslag)
        if lagsign<0:
            MMDate = datetime.date.today() - lag_days
        else:
            MMDate = datetime.date.today() + lag_days
        MMDay=MMDate.day
        MMMonth=MMDate.month
        MMYear=MMDate.year
        if MMDay<10:
            MMDay="0"+str(MMDay)
        else:
            MMDay=str(MMDay)

        if MMMonth<10:
            MMMonth="0"+str(MMMonth)
        else:
            MMMonth=str(MMMonth)
        MMYear = str(MMYear)

        return [MMYear+MMMonth, MMYear+MMMonth+MMDay]
    else: #se voglio semplicemente il timestamp del giorno attuale
        today=datetime.date.today()
        currentDay=today.day
        currentMonth=today.month
        currentYear=today.year 
        if currentDay<10:
            currentDay="0"+str(currentDay)
        else:
            currentDay=str(currentDay)

        if currentMonth<10:
            currentMonth="0"+str(currentMonth)
        else:
            currentMonth=str(currentMonth)
        currentYear = str(currentYear)        
        return [currentYear+currentMonth, currentYear+currentMonth+currentDay]

def GetPrevisionDayString(EmissionYearMonthDay,laghour):
    #funzione per ottenere la stringa contenente la data del giorno di previsione
    #le previsioni di multimodel emesse in un giorno vanno fino a 10 giorni nel futuro
    #quindi uso questa funzione la uso per ottenere le stringe delle date previsionali da oggi a dopodomani
    dt=datetime.datetime(int(EmissionYearMonthDay[0:4]),int(EmissionYearMonthDay[4:6]),int(EmissionYearMonthDay[6:8]),00,00,00)
    lag=datetime.timedelta(hours=int(laghour))
    dt=dt+lag 
    year=str(dt.year)
    if dt.month<10:
        month="0"+str(dt.month)
    else:
        month=str(dt.month)
    if dt.day<10:
        day="0"+str(dt.day)
    else:
        day=str(dt.day)    
    if dt.hour<10:
        hour="0"+str(dt.hour)
    else:
        hour=str(dt.hour)
    if dt.minute<10:
        minute="0"+str(dt.minute)
    else:
        minute=str(dt.minute)
    if dt.second<10:
        second="0"+str(dt.second)
    else:
        second=str(dt.second)                        
    return year+"-"+month+"-"+day+"T"+hour+":"+minute+":"+second+"Z"

