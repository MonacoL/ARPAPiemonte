import pandas as pd
import datetime 
import FunzioniUtili_Cumulate as FUNZIONI
import numpy as np
import sys,os
import pygrib

argomenti=sys.argv #Get input arguments
root_path=argomenti[1] #root path where the procedure is running
dati_path=argomenti[2] #obs file path
grib_path=argomenti[3] #model grib file path
script_path=argomenti[4] #path where all the scripts of this procedure reside
work_path=argomenti[5]  #temporary path to be used to manage data. In 28 10 2020 it is unused.
italyborders_file=argomenti[6] #italian borders json file 
output_json_path=argomenti[7] #path where to store output maps
models=["e1000","c5m00","c2200","bol00","mol00"]
scad_label=["D0","D1","D2"]

tipo=grib_path.split('/')[-1] #get whether the maps must be monthly or seasonal

print("Inizio computazione cumulata osservati") #Begin obs computations: compute cumulate rain over all the stations
time1 = datetime.datetime.now()
Cumulata=FUNZIONI.GetCumulata(dati_path)
time2 = datetime.datetime.now()
elapsedTime = time2 - time1
print("Tempo trascorso:",divmod(elapsedTime.total_seconds(), 60)) #Elapsed time
# Cumulata.to_csv(work_path+"/prova_JJA.csv", sep=' ', index=False, header=False)
# exit()
print("Fine computazione cumulata osservati") #Finish obs computations

# Cumulata=pd.read_csv(work_path+"/prova_JJA.csv", sep=" ")
# Cumulata.columns = ['IDStazione', 'Regione', 'Latitudine', 'Longitudine', 'TimeLead', 'Osservazione']

y=np.array(Cumulata.loc[:]["Latitudine"])
x=np.array(Cumulata.loc[:]["Longitudine"])
z=np.array(Cumulata.loc[:]["Osservazione"])

FUNZIONI.SaveGeoJSON(output_json_path,x,y,z,0,20,30,50,150,"osservati",italyborders_file) #Make obs contour, convert it GeoJSON

for model in models: #make models contour, convert them to GeoJSON
    if model=="c2200" or model=="mol00":
        scadenze=["24","48"]
    else:
        scadenze=["24","48","72"]
    for scadenza in scadenze:
        if tipo=="stagionale":
            grbs = pygrib.open(grib_path+"/"+model+"_"+scadenza+"_ST.grb")  
        else:
            grbs = pygrib.open(grib_path+"/"+model+"_"+scadenza+".grb")  
        z=grbs[1].values
        if model=="e1000":
            z=z*1000
        y, x = grbs[1].latlons()
        i=scadenze.index(scadenza)
        print(scad_label[i])
        FUNZIONI.SaveGeoJSON(output_json_path+"/"+scad_label[i],x,y,z,0,0,0,0,0,model,italyborders_file)