#! /bin/bash

#get input parameters
tipo=$1 #mensile o stagionale
from=$2 #data di inizio
to=$3 #data di fine

#set odino paths
odino_path="/var/lib/drupal7/files/default/field/image/meteorologia/verifica/precipitazione"
odino_path_JSONFiles="/var/lib/drupal7/files/default/field/image/meteorologia/verifica/precipitazione/GeoJSON_files"

root_path="/home/monacoarpa/Desktop/ARPA" #set local root path

SetPathVariables(){ #function for setting all the paths used in this procedure
  root_path=$1
  dati_path="$root_path/VerificaCumulateRain/dati_oss" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
  grib_path="$root_path/VerificaCumulateRain/dati_grib/"$tipo
  script_path="$root_path/VerificaCumulateRain/Scripts"
  work_path="$root_path/VerificaCumulateRain/InputTemp"  #dove salvare i dati per lavorarci sopra
  italyborders_file="$root_path/VerificaCumulateRain/GeoJSON_files/Input/Italy_Borders.json"
  output_json_path="$root_path/VerificaCumulateRain/GeoJSON_files/Output_"$tipo
  txt_path="$root_path/VerificaCumulateRain"
}

SetPathVariables $root_path

ANNOi=`echo $from|cut -c1-4` 
MESEi=`echo $from|cut -c5-6`
GIORNOi=`echo $from|cut -c7-8`

flagLocal=0 #if 1 the procedore is computed in local pc, otherwise in xmeteo8. I used this for debugging in local.
if [ $flagLocal -eq 0 ]; then
  root_path="/home/meteo/proc"
  SetPathVariables $root_path
  rm $dati_path/* #Delete old obs and model grib files from last computation
  rm $grib_path/*
  echo "Copio file osservati da nas."
  copia_file=1
  echo $from
  obs_path="/mnt/nas/progetti/dati_orari_DPC/${ANNOi}/dati_tutte_stazioni" 
  cp $obs_path/Export_${from}0000_rain.csv_orig $dati_path/
  # The first timelead 0000 is referred to 23-00 of the previous day, so it must be deleted
  sed '/'${from}'0000/d' $dati_path/Export_${from}0000_rain.csv_orig > $dati_path/Export_${from}0000_rain.csv_orig2
  mv $dati_path/Export_${from}0000_rain.csv_orig2 $dati_path/Export_${from}0000_rain.csv_orig
  from2=$from
  while [ $copia_file == 1 ]
  do
    from2=$(date +%Y%m%d -d "$from2 + 1 day")
    echo $from2
    ANNOcurrent=`echo $from2|cut -c1-4` 
    obs_path="/mnt/nas/progetti/dati_orari_DPC/${ANNOcurrent}/dati_tutte_stazioni" 
    cp $obs_path/Export_${from2}0000_rain.csv_orig $dati_path/
    sed '/'${from}'0000/d' $dati_path/Export_${from2}0000_rain.csv_orig > $dati_path/Export_${from2}0000_rain.csv_orig2
    mv $dati_path/Export_${from2}0000_rain.csv_orig2 $dati_path/Export_${from2}0000_rain.csv_orig
    if [ $from2 == $to ]; then
      copia_file=0
    fi
  done
  echo ""
  echo "Genero e copio file grib modelli da xmeteo4"
  lista_modelli="ecm ci5 ci2 bol mol"
  cont=0
  for mod in $lista_modelli; do  
    echo $mod
    #generate grib cumulated file for every model with a xmeteo4 procedure developed by Paolo Bertolotto
    ssh meteo@xmeteo4.ad.arpa.piemonte.it '/home/meteo/proc/DPC/bin/mappe_cumulate_prova_2020.sh -m '$mod' -d '$from' -D '$to' -a ITAL'
  done
  #copy gribs
  scp meteo@xmeteo4.ad.arpa.piemonte.it:"/home/meteo/proc/DPC/out/"*".grb" $grib_path/
fi

#Now all files are stored, it's time to compute the maps
python3 $script_path/genera_contour_cumulate.py $root_path $dati_path $grib_path $script_path $work_path $italyborders_file $output_json_path

#Update monthly and seasonal txt file, they are used in the leaflet representation
if [ $tipo == "mensile" ];then
  firstDigitMESEi=`echo $MESEi|cut -c1-1`
  secondDigitMESEi=`echo $MESEi|cut -c2-2`

  if [[ $firstDigitMESEi == "0" ]]; then
      MESEi=$secondDigitMESEi
  fi

  dodici_mesi=(GENNAIO FEBBRAIO MARZO APRILE MAGGIO GIUGNO LUGLIO AGOSTO SETTEMBRE OTTOBRE NOVEMBRE DICEMBRE)
  MESE_label=${dodici_mesi[$((MESEi-1))]}
  echo "Anno: "$ANNOi" - Mese: "$MESE_label > $txt_path/mensile.txt
else
  if [ $MESEi == "12" ];then
    stagione="DJF"
  elif [ $MESEi == "03" ];then
    stagione="MAM"
  elif [ $MESEi == "06" ];then
    stagione="JJA"
  else
    stagione="SON"
  fi
  echo "Anno: "$ANNOi" - Stagione: "$stagione > $txt_path/stagionale.txt
fi

#Copy output maps to odino
if [ $flagLocal -eq 0 ]; then
  scp ${output_json_path}/osservati.geojson sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo
  scp ${output_json_path}/D0/* sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo/D0
  scp ${output_json_path}/D1/* sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo/D1
  scp ${output_json_path}/D2/* sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo/D2
  #rm -r ${dati_path}/* #empty obs files path
  scp ${txt_path}/{"mensile","stagionale"}.txt sc05@odino.arpa.piemonte.it:${odino_path}
fi