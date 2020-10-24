#! /bin/bash
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
#================================================================================
# 1 - Carica file di configurazione
#================================================================================
#. $HOME/.bash_profile
#. $HOME/grads/proc/ModGradsModel 

#================================================================================
# 1 - Definizione delle cartelle di lavoro e dei flag di lavoro
#================================================================================
tipo=$1 #mensile o stagionale
from=$2 #data di inizio
to=$3 #data di fine

odino_path=""
odino_path_JSONFiles=""

root_path="/home/monacoarpa/Desktop/ARPA"

SetPathVariables(){
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

flagLocal=1
if [ $flagLocal -eq 0 ]; then
  root_path="/home/meteo/proc"
  SetPathVariables $root_path
  echo "Copio file osservati da nas."
  copia_file=1
  echo $from
  obs_path="/mnt/nas/progetti/dati_orari_DPC/${ANNOi}/dati_tutte_stazioni" 
  cp $obs_path/Export_${from}0000_rain.csv_orig $dati_path/
  sed '/'${from}'0000/d' $dati_path/Export_${from}0000_rain.csv_orig > $dati_path/Export_${from}0000_rain.csv_orig2
  mv $dati_path/Export_${from}0000_rain.csv_orig2 $dati_path/Export_${from}0000_rain.csv_orig
  from2=$from
  while [ $copia_file == 1 ]
  do
    from2=$(date +%Y%m%d -d "$from2 + 1 day")
    echo $from2
    ANNOcurrent=`echo $from2|cut -c1-4` 
    obs_path="/mnt/nas/progetti/dati_orari_DPC/${ANNOcurrent}/dati_tutte_stazioni" 
    cp $obs_path/Export_${from}0000_rain.csv_orig $dati_path/
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
    ssh meteo@xmeteo4.ad.arpa.piemonte.it '/home/meteo/proc/DPC/bin/mappe_cumulate_prova_2020.sh -m '$mod' -d '$from' -D '$to' -a ITALIA'
  done
  scp meteo@xmeteo4.ad.arpa.piemonte.it:"/home/meteo/proc/DPC/out/"*".grb" $grib_path/
fi

python3 $script_path/genera_contour_cumulate.py $root_path $dati_path $grib_path $script_path $work_path $italyborders_file $output_json_path

#Aggiorna i txt mensile o stagionale

firstDigitMESEi=`echo $MESEi|cut -c1-1`
secondDigitMESEi=`echo $MESEi|cut -c2-2`

if [[ $firstDigitMESEi == "0" ]]; then
    MESEi=$secondDigitMESEi
fi

if [ $tipo == "mensile" ];then
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
exit 1

if [ $flagLocal -eq 0 ]; then
  #Copia i json di output e i txt su odino
  scp ${output_json_path}/D0/* sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo/D0/ 
  scp ${output_json_path}/D1/* sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo/D1/ 
  scp ${output_json_path}/D2/* sc05@odino.arpa.piemonte.it:${odino_path_JSONFiles}/Output_$tipo/D2/ 
  rm -r ${dati_path}/* #libero la cartella grafici locale
  scp ${txt_path}/{"mensile","stagionale"}.txt sc05@odino.arpa.piemonte.it:${odino_path}
fi