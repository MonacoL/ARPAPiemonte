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
nmodels=8
naree=13
dati_path="../dati" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
Grafici_path="../Grafici"
script_path="../Scripts"
work_path="../InputTemp"  #dove salvare i dati per lavorarci sopra
colors_path=".."
#logs_path="../logs/"

lista_modelli="b0700 c5m00 c2200 e0100 i0700 m0103 psa_NA wrf00"
today="20200718"
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
  #today="20201003"
  ieri=$(date +%Y%m%d -d "$today - 1 day")
  altroieri=$(date +%Y%m%d -d "$today - 2 day")

  ANNOieri=`echo $ieri|cut -c1-4` 
  ANNOaltroieri=`echo $altroieri|cut -c1-4`
  MESEieri=`echo $ieri|cut -c5-6`
  MESEaltroieri=`echo $altroieri|cut -c5-6` 
  GIORNOieri=`echo $ieri|cut -c7-8`   
  GIORNOaltroieri=`echo $altroieri|cut -c7-8`
  root_path="/home/meteo/proc/VerificaQPFAreeAllertamento"
  xmeteo4_modelli_path="/pb1/verifica/forecast" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
  xmeteo4_mkobs_path="/home/meteo/verifica"
  odino_path_grafici="/var/lib/drupal7/files/default/field/image/meteorologia/allertamento/Grafici" #dove copiare i grafici su odino
  odino_path="/var/lib/drupal7/files/default/field/image/meteorologia/allertamento" #dove copiare DalAl.txt su odino
  dati_path="$root_path/dati"
  script_path="$root_path/Scripts"
  Grafici_path="$root_path/Grafici"
  work_path="$root_path/InputTemp"  #dove salvare i dati per lavorarci sopra
  #se non sono in locale, copio le anagrafiche da xmeteo4, così da averle sempre aggiornate
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo " "
  echo "PRELEVO I FILE DI INPUT DA XMETEO4"
  echo " "  
  for mod in $lista_modelli; do
    if [ $mod == "psa_NA" ]; then
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOaltroieri}${MESEaltroieri}/prvsa_06hh_${altroieri}12_max.bal $dati_path/
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOaltroieri}${MESEaltroieri}/prvsa_06hh_${altroieri}12_ave.bal $dati_path/  
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOieri}${MESEieri}/prvsa_06hh_${ieri}12_max.bal $dati_path/
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOieri}${MESEieri}/prvsa_06hh_${ieri}12_ave.bal $dati_path/
    else
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOaltroieri}${MESEaltroieri}/${mod}_06hh_${altroieri}00_max.bal $dati_path/
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOaltroieri}${MESEaltroieri}/${mod}_06hh_${altroieri}00_ave.bal $dati_path/  
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOieri}${MESEieri}/${mod}_06hh_${ieri}00_max.bal $dati_path/
      scp meteo@xmeteo4.ad.arpa.piemonte.it:$xmeteo4_modelli_path/$mod/${ANNOieri}${MESEieri}/${mod}_06hh_${ieri}00_ave.bal $dati_path/
    fi  
  done
  ssh meteo@xmeteo4.ad.arpa.piemonte.it '/home/meteo/verifica/bin/datiope.sh' #per aggiornare gli osservati altrimenti fallisce la procedura
  ssh meteo@xmeteo4.ad.arpa.piemonte.it $xmeteo4_mkobs_path'/bin/stz2bal '$altroieri' '$xmeteo4_mkobs_path'/non_cancellare_cartella'
  scp meteo@xmeteo4.ad.arpa.piemonte.it:${xmeteo4_mkobs_path}/non_cancellare_cartella/* $dati_path/
  ssh meteo@xmeteo4.ad.arpa.piemonte.it 'rm '$xmeteo4_mkobs_path'/non_cancellare_cartella/*'
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

  nome_file=${nomeModello}_06hh_${data}00_${tipo}.bal
  path_vuoto=$dati_path/vuoto_modello.txt
  if [[ $nomeModello == "psa_NA" ]];then
    nome_file=prvsa_06hh_${data}12_${tipo}.bal
    path_vuoto=$dati_path/vuoto_psa.txt
  fi

  modello_file=$dati_path/$nome_file #file che voglio leggere  
  
  if [[ -s $modello_file ]]; then
    nrows=0
    nrows=$(wc -l < $modello_file)
    if [[ $nrows -ne $naree ]]; then
      echo "Il file del modello $nomeModello $tipo per la data $data non è nel formato giusto"
      echo "Ha un numero di righe diverso dal numero di aree, che sono $naree."
      cp $dati_path/vuoto_modello.txt $work_path/$nome_file
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
      cp $dati_path/vuoto_modello.txt $work_path/$nome_file
      echo "Uso un file vuoto."  
      echo ""     
  fi
}

ControllaFileOsservati(){ #controllo che i file dei modelli siano presenti alla data attuale
	data=$1
  tipo=$2
  nome_file=osser_06hh_${data}12_${tipo}.bal
  oss_file=$dati_path/$nome_file #file che voglio leggere
	awk 'NF' $dati_path/$nome_file > $dati_path/temp.bal #elimino le righe vuote in più, laddove presenti
  tail -n +2 $dati_path/temp.bal > $dati_path/oss_pulito.bal #elimino la prima riga, è un'intestazione

  if [[ -s $dati_path/oss_pulito.bal ]]; then
    nrows=0
    nrows=$(wc -l < $dati_path/oss_pulito.bal)
    if [[ $nrows -ne $naree ]]; then
      echo "Il file degli osservati $tipo per la data $data non è nel formato giusto"
      echo "Ha un numero di righe diverso dal numero di aree, che sono $naree."
      cp $dati_path/vuoto_osservati.txt $work_path/$nome_file
      echo "Uso un file vuoto."
      echo ""
    else
      echo "Il file degli osservati $tipo per la data $data è presente"
      cp $dati_path/oss_pulito.bal $work_path/$nome_file
      echo "File copiato."
      echo ""
    fi
  else
      echo "Il file degli osservati $tipo non è presente per la data $data."
      cp $dati_path/vuoto_osservati.txt $work_path/$nome_file
      echo "Uso un file vuoto."      
      echo "" 
  fi

  rm $dati_path/temp.bal
  rm $dati_path/oss_pulito.bal
}

ControllaFileOsservati $altroieri "max"
ControllaFileOsservati $altroieri "ave"

for mod in $lista_modelli; do
  ControllaFileModelli $ieri $mod "max"
  ControllaFileModelli $ieri $mod "ave"
  ControllaFileModelli $altroieri $mod "max"
  ControllaFileModelli $altroieri $mod "ave"
done

if [ $flagLocal -eq 0 ]; then  
  rm $dati_path/*.bal #svuoto la cartella dati, a parte il file vuoto.txt
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "CREO I GRAFICI AVE"
echo " "
Rscript $script_path/grafici_verifica_qpf_aree_allertamento.R $nmodels $naree $ieri $altroieri "ave" $work_path $Grafici_path $colors_path
echo " "
echo "CREO I GRAFICI MAX"
echo " "
Rscript $script_path/grafici_verifica_qpf_aree_allertamento.R $nmodels $naree $ieri $altroieri "max" $work_path $Grafici_path $colors_path

rm $work_path/*

echo " "
echo "AGGIORNO LO STORICO"
echo " "

zone="A B C D E F G H I L M T V"
for zona in $zone; do
    cp ${Grafici_path}/VerificaQPFMASSIMA_$zona.png ${Grafici_path}/storico/VerificaQPFMASSIMA_${zona}_$today.png
    cp ${Grafici_path}/VerificaQPFMEDIA_$zona.png ${Grafici_path}/storico/VerificaQPFMEDIA_${zona}_$today.png
done

trentagiornifa=$(date +%Y%m%d -d "$today - 31 day")

rm -v ${Grafici_path}/storico/VerificaQPF*_${trentagiornifa}.png


if [ $flagLocal -eq 0 ]; then  
  scp ${Grafici_path}/* sc05@odino.arpa.piemonte.it:${odino_path_grafici} #copio tutti i grafici su odino
  #rm -r ${Grafici_path}/* #libero la cartella grafici locale
  scp ${colors_path}/qpf_aree_colori.txt sc05@odino.arpa.piemonte.it:${odino_path} #copio dalal.txt su odino
fi

echo " "
echo "PROCEDURA COMPLETATA."
exit
