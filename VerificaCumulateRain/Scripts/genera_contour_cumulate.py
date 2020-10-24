import pandas as pd
import datetime 
import FunzioniUtili_Cumulate as FUNZIONI
import numpy as np
import sys,os
import pygrib

argomenti=sys.argv
if len(argomenti)==1:
    print("Argomento 1: root path; blablabla");
    exit()
root_path=argomenti[1]
dati_path=argomenti[2] #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
grib_path=argomenti[3]
script_path=argomenti[4]
work_path=argomenti[5]  #dove salvare i dati per lavorarci sopra
italyborders_file=argomenti[6]
output_json_path=argomenti[7]
models=["e1000","c5m00","c2200","bol00","mol00"]
scad_label=["D0","D1","D2"]

# print("Inizio computazione cumulata osservati")
# time1 = datetime.datetime.now()
# Cumulata=FUNZIONI.GetCumulata(dati_path)
# time2 = datetime.datetime.now()
# elapsedTime = time2 - time1
# print("Tempo trascorso:",divmod(elapsedTime.total_seconds(), 60))
# Cumulata.to_csv(work_path+"/prova.csv", sep=' ', index=False, header=False)
# exit()
# print("Fine computazione cumulata osservati")

Cumulata=pd.read_csv(work_path+"/prova.csv", sep=" ")
Cumulata.columns = ['IDStazione', 'Regione', 'Latitudine', 'Longitudine', 'TimeLead', 'Osservazione']

y=np.array(Cumulata.loc[:]["Latitudine"])
x=np.array(Cumulata.loc[:]["Longitudine"])
z=np.array(Cumulata.loc[:]["Osservazione"])

FUNZIONI.SaveGeoJSON(output_json_path,x,y,z,0,20,30,50,50,"osservati",italyborders_file)

for model in models:
    if model=="c2200" or model=="mol00":
        scadenze=["24","48"]
    else:
        scadenze=["24","48","72"]
    for scadenza in scadenze:
        grbs = pygrib.open(grib_path+"/"+model+"_"+scadenza+".grb")  
        z=grbs[1].values
        if model=="e1000":
            z=z*1000
        y, x = grbs[1].latlons()
        i=scadenze.index(scadenza)
        print(scad_label[i])
        FUNZIONI.SaveGeoJSON(output_json_path+"/"+scad_label[i],x,y,z,0,0,0,0,0,model,italyborders_file)