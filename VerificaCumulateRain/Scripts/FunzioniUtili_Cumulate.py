import pandas as pd
import numpy as np
import scipy.ndimage 
import os
from geopandas import GeoDataFrame
from shapely.geometry import Polygon, MultiPolygon
from shapely.ops import unary_union, polygonize
from scipy.interpolate import griddata
import matplotlib.pyplot as plt


def ReadInputFile(input_file):
    data=pd.read_csv(input_file, sep=",", header=None, na_values=[-9998.000000,-9999.000000]) #importo tutto il file MM
    data_useful=data.iloc[:,0:6]
    data_useful.columns = ['IDStazione', 'Regione', 'Latitudine', 'Longitudine', 'TimeLead', 'Osservazione']
    return data_useful

def GetCumulataGiornaliera(input_file):
    data_input_file=ReadInputFile(input_file)
    cumulata_giornaliera_italia=data_input_file.drop(data_input_file.index)
    nrow=data_input_file.shape[0]
    idstazione=data_input_file.iloc[0,0] #prendo la prima stazione
    cumulata_giornaliera_stazione=np.nan
    for i in range(0,nrow):
        riga=data_input_file.loc[i]
        if riga["IDStazione"]==idstazione:
            if not(np.isnan(riga["Osservazione"])):
                if riga["Osservazione"]<300 and riga["Osservazione"]>=0: #effettuo controllo a valle dati dpc, han problemi
                    if not(np.isnan(cumulata_giornaliera_stazione)):
                        cumulata_giornaliera_stazione+=riga["Osservazione"]
                    else:
                        cumulata_giornaliera_stazione=riga["Osservazione"]
        else:
            riga_vecchiastaz=data_input_file.loc[i-1]
            if not(np.isnan(cumulata_giornaliera_stazione)):
                cumulata_giornaliera_italia.loc[len(cumulata_giornaliera_italia)] = [riga_vecchiastaz[0],riga_vecchiastaz[1],riga_vecchiastaz[2],riga_vecchiastaz[3],str(riga_vecchiastaz[4])[0:7],cumulata_giornaliera_stazione]
            idstazione=riga["IDStazione"]     
            if np.isnan(riga["Osservazione"]):
                cumulata_giornaliera_stazione=np.nan
            else:
                cumulata_giornaliera_stazione=riga["Osservazione"]   
    return cumulata_giornaliera_italia

def GetCumulata(path_file):
    Cumulata = pd.DataFrame(columns=['IDStazione', 'Regione', 'Latitudine', 'Longitudine', 'TimeLead', 'Osservazione']) #qui il timelead è superfluo, ma lo lascio per non complicare troppo il codice       
    files=os.listdir(path_file)
    files.sort()
    for file_giornaliero in files:
        print("File esaminato:",file_giornaliero)
        CumulataGiornaliera=GetCumulataGiornaliera(path_file+"/"+file_giornaliero)
        if Cumulata.empty:
            Cumulata=CumulataGiornaliera
        else:
            nrow=CumulataGiornaliera.shape[0]
            for i in range(0,nrow):
                riga=CumulataGiornaliera.loc[i]
                IDStazioneCumGiorn=riga["IDStazione"]
                if Cumulata.loc[Cumulata["IDStazione"]==IDStazioneCumGiorn].empty:
                    Cumulata.loc[len(Cumulata)]=riga
                else:
                    Cumulata.loc[Cumulata["IDStazione"]==IDStazioneCumGiorn,"Osservazione"]+=riga["Osservazione"]    
    return Cumulata

def Polygons_To_GeoDataFrame(collec_poly):
    """Transform a `matplotlib.contour.QuadContourSet` to a GeoDataFrame"""
    polygons, colors = [], []
    for i, polygon in enumerate(collec_poly.collections):
        mpoly = []
        for path in polygon.get_paths():
            try:
                path.should_simplify = False
                poly = path.to_polygons()
                # Each polygon should contain an exterior ring + maybe hole(s):
                exterior, holes = [], []
                if len(poly) > 0 and len(poly[0]) > 3:
                    # The first of the list is the exterior ring :
                    exterior = poly[0]
                    # Other(s) are hole(s):
                    if len(poly) > 1:
                        holes = [h for h in poly[1:] if len(h) > 3]
                mpoly.append(Polygon(exterior, holes).buffer(0))
            except:
                print('Warning: Geometry error when making polygon #{}'
                      .format(i))
        if len(mpoly) > 1:
            mpoly = MultiPolygon(mpoly)
            polygons.append(mpoly)
            colori=polygon.get_facecolor().tolist()[0]
            for i in [0,1,2,3]:
                colori[i]=colori[i]*255
            colors.append(colori)
        elif len(mpoly) == 1:
            polygons.append(mpoly[0])
            colori=polygon.get_facecolor().tolist()[0]
            for i in [0,1,2,3]:
                colori[i]=colori[i]*255
            colors.append(colori)
    return GeoDataFrame(
        geometry=polygons,
        data={'colori':colors},
        crs=('epsg:4326'))

def SaveGeoJSON(output_json_path,x,y,z,longi,longf,lati,latf,n,tipo,italyborders_file):
    if tipo=="osservati":
        xi = np.linspace(longi,longf,n)
        yi = np.linspace(lati, latf,n)
        xi, yi = np.meshgrid(xi,yi)
        zi = griddata((x,y), z, (xi, yi), method="linear", fill_value=0) 
        xi = scipy.ndimage.zoom(xi, 3)
        yi = scipy.ndimage.zoom(yi, 3)
        zi = scipy.ndimage.zoom(zi, 3)
    else:
        xi=x
        yi=y
        zi=z
    livelli=[1,5,10,25,50,75,100,150,200,300,400,500,600]
    colori=["#d2d2d2","#969696","#a5f0ff","#4181ff","#1b3fff","#73f5a5","#1dc400","#ffff00","#ffc40e","#ff8205","#ff0000","#ff00a2","#ab00ab"]
    collec_poly = plt.contourf(xi, yi, zi,levels=livelli, colors=colori)#cmap='RdGy'
    print("Contour",tipo,"fatto")

    gdf = Polygons_To_GeoDataFrame(collec_poly)
    boundary = GeoDataFrame.from_file(italyborders_file)
    # Assuming you have a boundary as linestring, transform it to a Polygon:
    mask_geom = unary_union([i for i in polygonize(boundary.geometry)])
    #mask_geom = mask_geom[~mask_geom.is_valid]
    #mask_geom.buffer(0)
    # Then compute the intersection:
    gdf.geometry = gdf.geometry.intersection(mask_geom)

    mappa=gdf.to_json()

    f = open(output_json_path+"/"+tipo+".geojson", "w+")
    f.write(mappa)
    f.close()
    print("Contour",tipo,"convertito in json e salvato")