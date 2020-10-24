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
nmodels=7
naree=70
dati_path="../dati" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
Grafici_path="../Grafici"
script_path="../Scripts"
work_path="../InputTemp"  #dove salvare i dati per lavorarci sopra
colors_path=".."
#logs_path="../logs/"
shp_file="../AreeVigilanzaSHP/Zone_Vigilanza_09_2017_corretto_4326.shp"

lista_modelli="b0700 c5m00 c2200 e0100 i0700 m0103 wrf00"
today="20200829"
ieri=$(date +%Y%m%d -d "$today - 1 day")
altroieri=$(date +%Y%m%d -d "$today - 2 day")

ANNOieri=`echo $ieri|cut -c1-4` 
ANNOaltroieri=`echo $altroieri|cut -c1-4`
MESEieri=`echo $ieri|cut -c5-6`
MESEaltroieri=`echo $altroieri|cut -c5-6` 
GIORNOieri=`echo $ieri|cut -c7-8`   
GIORNOaltroieri=`echo $altroieri|cut -c7-8`


flagLocal=0
if [ $flagLocal -eq 0 ]; then
  today=`date +%Y%m%d`
  ieri=$(date +%Y%m%d -d "$today - 1 day")
  altroieri=$(date +%Y%m%d -d "$today - 2 day")

  ANNOieri=`echo $ieri|cut -c1-4` 
  ANNOaltroieri=`echo $altroieri|cut -c1-4`
  MESEieri=`echo $ieri|cut -c5-6`
  MESEaltroieri=`echo $altroieri|cut -c5-6` 
  GIORNOieri=`echo $ieri|cut -c7-8`   
  GIORNOaltroieri=`echo $altroieri|cut -c7-8`
  root_path="/home/meteo/proc/VerificaQPFAreeVigilanza"
  xmeteo4_modelli_path="/pb1/verifica/forecast" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
  obs_path="/mnt/nas/progetti/dati_orari_DPC/${ANNOieri}/dati_tutte_stazioni"
  odino_path_grafici="/var/lib/drupal7/files/default/field/image/meteorologia/vigilanza/Grafici" #dove copiare i grafici su odino
  odino_path="/var/lib/drupal7/files/default/field/image/meteorologia/vigilanza" #dove copiare DalAl.txt su odino
  dati_path="$root_path/dati"
  script_path="$root_path/Scripts"
  Grafici_path="$root_path/Grafici"
  work_path="$root_path/InputTemp"  #dove salvare i dati per lavorarci sopra
  shp_file="$root_path/AreeVigilanzaSHP/Zone_Vigilanza_09_2017_corretto_4326.shp"
  #se non sono in locale, copio le anagrafiche da xmeteo4, così da averle sempre aggiornate
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo " "
  echo "PRELEVO I FILE DI INPUT DA XMETEO4"
  echo " "  
  for mod in $lista_modelli; do
    scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOaltroieri}${MESEaltroieri}/${mod}_06hh_${altroieri}00_IVIG_max.bal $dati_path/
    scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOaltroieri}${MESEaltroieri}/${mod}_06hh_${altroieri}00_IVIG_ave.bal $dati_path/  
    scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOieri}${MESEieri}/${mod}_06hh_${ieri}00_IVIG_max.bal $dati_path/
    scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOieri}${MESEieri}/${mod}_06hh_${ieri}00_IVIG_ave.bal $dati_path/
  done
  scp meteo@xmeteo4.ad.arpa.piemonte.it:${obs_path}/Export_${ieri}0000_rain.csv_orig $dati_path/
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo ""
  colors_path="$root_path"
fi

#================================================================================
#FUNZIONA SOLO SULLA STAZGIONE COMPLETA
#======================================
#command | tee -a $logs_path`date +%d%m%Y`_`date +%H_%M_%S`".txt" #log file

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "CONTROLLO I FILE DI INPUT"
echo " "

ControllaFileModelli(){ #controllo che i file dei modelli siano presenti alla data attuale
	data=$1
	nomeModello=$2
  tipo=$3

  nome_file=${nomeModello}_06hh_${data}00_IVIG_${tipo}.bal

  modello_file=$dati_path/$nome_file #file che voglio leggere  
  
  if [[ -s $modello_file ]]; then
    nrows=0
    nrows=$(wc -l < $modello_file)
    if [[ $nrows -ne $naree ]]; then
      echo "Il file del modello $nomeModello $tipo per la data $data non è nel formato giusto"
      echo "Ha un numero di righe diverso dal numero di aree, che sono $naree."
      cp $dati_path/vuoto_modello_IVIG.txt $work_path/$nome_file
      echo "Uso un file vuoto."
      echo ""
    else
      echo "Il file del modello $nomeModello $tipo per la data $data è presente"
      cp $modello_file $work_path
      echo "File copiato."
      echo ""
    fi
  else
      echo "Il file del modello $nomeModello $tipo non è presente per la data $data."
      cp $dati_path/vuoto_modello_IVIG.txt $work_path/$nome_file
      echo "Uso un file vuoto."  
      echo ""     
  fi
}

ControllaFileOsservati(){ #controllo che i file dei modelli siano presenti alla data attuale
	data=$1
  nome_file=Export_${data}0000_rain.csv_orig
  oss_file=$dati_path/$nome_file #file che voglio leggere

  if [[ -s $oss_file ]]; then
      oss_file_sed=$oss_file"_sed"
      sed '/'${data}'0000/d' $oss_file > $oss_file_sed
      echo "Calcolo le medie e le massime per ogni area di vigilanza."
      Rscript $script_path/genera_tabelle_osservati.R $oss_file_sed $work_path $shp_file
      echo "Dati generati e salvati nella cartella di lavoro."
  else
      echo "Il file degli osservati non è presente per la data $data."
      cp $dati_path/vuoto_osservati_IVIG.txt $work_path/$nome_file
      echo "Uso un file vuoto."      
      echo ""  
  fi
}

ControllaFileOsservati $ieri 

for mod in $lista_modelli; do
  ControllaFileModelli $ieri $mod "max"
  ControllaFileModelli $ieri $mod "ave"
  ControllaFileModelli $altroieri $mod "max"
  ControllaFileModelli $altroieri $mod "ave"
done

if [ $flagLocal -eq 0 ]; then  
  rm $dati_path/*.bal #svuoto la cartella dati, a parte il file vuoto.txt
  rm $dati_path/*.csv* #e cancello anche gli osservati
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "CREO I GRAFICI AVE"
echo " "
Rscript $script_path/grafici_verifica_qpf_aree_vigilanza.R $nmodels $naree $ieri $altroieri "ave" $work_path $Grafici_path $colors_path
echo " "
echo "CREO I GRAFICI MAX"
echo " "
Rscript $script_path/grafici_verifica_qpf_aree_vigilanza.R $nmodels $naree $ieri $altroieri "max" $work_path $Grafici_path $colors_path

rm $work_path/*

echo " "
echo "AGGIORNO LO STORICO"
echo " "

for (( COUNTER=1; COUNTER<=70; COUNTER+=1 )); do
    cp ${Grafici_path}/VerificaQPFMASSIMA_$COUNTER.png ${Grafici_path}/storico/VerificaQPFMASSIMA_${COUNTER}_$today.png
    cp ${Grafici_path}/VerificaQPFMEDIA_$COUNTER.png ${Grafici_path}/storico/VerificaQPFMEDIA_${COUNTER}_$today.png
done

trentagiornifa=$(date +%Y%m%d -d "$today - 31 day")

rm -v ${Grafici_path}/storico/VerificaQPF*_${trentagiornifa}.png

if [ $flagLocal -eq 0 ]; then  
  scp ${Grafici_path}/* sc05@odino.arpa.piemonte.it:${odino_path_grafici} #copio tutti i grafici su odino
  #rm -r ${Grafici_path}/* #libero la cartella grafici locale
  scp ${colors_path}/qpf_IVIG_colori.txt sc05@odino.arpa.piemonte.it:${odino_path} #copio dalal.txt su odino
fi

echo " "
echo "PROCEDURA COMPLETATA."
exit
