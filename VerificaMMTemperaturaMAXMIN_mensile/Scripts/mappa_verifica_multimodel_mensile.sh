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

#AREA
lista_aree="PI AO LO VE TR LI FR EM TO UM MA MO LA AB PU CA CB BA SI SA"
#lista_aree="MA"

multimodel_path="../dati" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
Grafici_path="../Grafici"
script_path="../Scripts"
work_path="../InputTemp"  #dove salvare i dati per lavorarci sopra
anag_path="../Anagrafiche"
dalal_path=".."
#logs_path="../logs/"


flagLocal=0
if [ $flagLocal -eq 0 ]; then
  root_path="/home/meteo/proc/odinoMM/odinoMM_mensile"
  multimodel_path="/output/meteo/multimodel" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
  odino_path_grafici="/var/lib/drupal7/files/default/field/image/meteorologia/Grafici" #dove copiare i grafici su odino
  odino_path="/var/lib/drupal7/files/default/field/image/meteorologia" #dove copiare DalAl.txt su odino
  script_path="$root_path/Scripts"
  Grafici_path="$root_path/Grafici"
  work_path="$root_path/InputTemp"  #dove salvare i dati per lavorarci sopra
  anag_path="$root_path/Anagrafiche"
  anag_xmeteo_path="$root_path/Anagrafiche_xmeteo"
  #se non sono in locale, copio le anagrafiche da xmeteo4, così da averle sempre aggiornate
  scp meteo@xmeteo4.ad.arpa.piemonte.it:/home/meteo/etc/multimodel/anagrafica/*.DAT $anag_xmeteo_path  
  for regione in $lista_aree; do
    if [ -s "$anag_xmeteo_path/${regione}_ANAG_OK.DAT" ];then
      cp $anag_xmeteo_path/${regione}_ANAG_OK.DAT $anag_path/${regione}_ANAG.DAT #quelle con OK sono più aggiornate, se ci sono uso quelle
    else
      cp $anag_xmeteo_path/${regione}_ANAG.DAT $anag_path/${regione}_ANAG.DAT
    fi
  done
  rm -r $anag_xmeteo_path/*
  #logs_path="$root_path/logs"
  dalal_path="$root_path"
fi

#================================================================================
#FUNZIONA SOLO SULLA STAZGIONE COMPLETA
#======================================
#command | tee -a $logs_path`date +%d%m%Y`_`date +%H_%M_%S`".txt" #log file

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "PRELEVO I FILE DI INPUT"
echo " "

today=`date +%Y%m%d`
dataf=$(date +%Y%m%d -d "$today - 2 day")
datai=$(date +%Y%m%d -d "$dataf - 30 day")

#Spezza la data 
ANNOi=`echo $datai|cut -c1-4` 
ANNOf=`echo $dataf|cut -c1-4`
MESEi=`echo $datai|cut -c5-6`
MESEf=`echo $dataf|cut -c5-6` 
GIORNOi=`echo $datai|cut -c7-8`   
GIORNOf=`echo $dataf|cut -c7-8`   

FrasiModello(){ #funzione per ottenere le frasi opportune da scrivere su video per ogni modello
#1 modello #2 "fatto"-"nonesistefile" #3 date
modello=$1
sentenceType=$2
data=$3

if [[ "$sentenceType" == "fatto" ]]; then
  if [[ "$modello" == "MMSUP" ]]; then
    echo "    MULTIMODEL: fatto $data"
    echo " "
  elif [[ "$modello" == "ecn00" ]]; then
    echo "    ECMWF: fatto $data" 
    echo " "
  elif [[ "$modello" == "nud00" ]]; then
    echo "    COSMO-i5: fatto $data"
    echo " "
  elif [[ "$modello" == "lnu00" ]]; then
    echo "    LAMINO: fatto $data"
    echo " "
  elif [[ "$modello" == "lhr00" ]]; then
    echo "    COSMINO: fatto $data"
    echo " "
  fi
elif [[ "$sentenceType" == "nonesistefile" ]]; then
  if [[ "$modello" == "MMSUP" ]]; then
    echo "    Il file MULTIMODEL per la data ${data} non esiste."
  elif [[ "$modello" == "ecn00" ]]; then
    echo "    Il file ECMWF per la data ${data} non esiste." 
  elif [[ "$modello" == "nud00" ]]; then
    echo "    Il file COSMO-I5 per la data ${data} non esiste."
  elif [[ "$modello" == "lnu00" ]]; then
    echo "    Il file LAMINO per la data ${data} non esiste."
  elif [[ "$modello" == "lhr00" ]]; then
    echo "    Il file COSMO-2I per la data ${data} non esiste."
  fi
fi

}

PrelevaFileModello(){ #prelevo i modelli in base ai parametri di ingresso
#1 copydir #2 savedir #3 modello #4 data  #5 regione
copydir=$1
savedir=$2
modello=$3
data=$4
regione=$5
anno=`echo $data|cut -c1-4`
mese=`echo $data|cut -c5-6`

flag=0
if [ "$modello" == "MMSUP" ] && [ -s "$copydir/${modello}_${data}_${regione}.DAT" ] ; then #controllo che i file siano non vuoti
  cp $copydir/${modello}_${data}_${regione}.DAT $savedir
  mv $savedir/${modello}_${data}_${regione}.DAT $savedir/${modello}_${data}.DAT #salvo i file coi nomi vecchi, perchè organizza_file.sh è impostato con quelli
  flag=1
elif [ "$modello" == "ecn00" ] && [ -s "${copydir}/ECMWF_EURNA_0250/ECMEA0250_00_${data}_${regione}.DAT" ]; then
  cp ${copydir}/ECMWF_EURNA_0250/ECMEA0250_00_${data}_${regione}.DAT $savedir
  mv ${savedir}/ECMEA0250_00_${data}_${regione}.DAT $savedir/${modello}_${data}.DAT
  flag=1
elif [ "$modello" == "nud00" ] && [ -s "${copydir}/COSMO_ITALY_0045/COSMO0045_00_${data}_${regione}.DAT" ]; then
  cp ${copydir}/COSMO_ITALY_0045/COSMO0045_00_${data}_${regione}.DAT $savedir
  mv ${savedir}/COSMO0045_00_${data}_${regione}.DAT $savedir/${modello}_${data}.DAT
  flag=1
elif [ "$modello" == "lnu00" ] && [ -s "${copydir}/LAMIN_ITALY_0025/LAMIN0025_00_${data}_${regione}.DAT" ]; then
  cp ${copydir}/LAMIN_ITALY_0025/LAMIN0025_00_${data}_${regione}.DAT $savedir
  mv ${savedir}/LAMIN0025_00_${data}_${regione}.DAT $savedir/${modello}_${data}.DAT
  flag=1
elif [ "$modello" == "lhr00" ] && [ -s "${copydir}/COSMO_ITALY_0020/COSMO0020_00_${data}_${regione}.DAT" ]; then
  cp ${copydir}/COSMO_ITALY_0020/COSMO0020_00_${data}_${regione}.DAT $savedir
  mv ${savedir}/COSMO0020_00_${data}_${regione}.DAT $savedir/${modello}_${data}.DAT
  flag=1
else
  FrasiModello $modello "nonesistefile" ${data}
fi
if [ $flag == 1 ];then
  sort -k2,2 -k1,1 $savedir/${modello}_${data}.DAT | uniq > $savedir/SORTED.DAT #ho le ansie e verifico che non ci siano doppioni
  mv $savedir/SORTED.DAT $savedir/${modello}_${data}.DAT
  #Ora avvio uno script che prende in ingresso il modello prelevato, riempie i buchi in termini di giorni rispetto al mese e in termini di stazioni rispetto alle anagrafiche
  #Lo script, inoltre, poi alla fine salva in output solo le righe corrispondenti ai massimi e alle minime, snellendo di molto i file
  Rscript $script_path/riempi_buchi.R $modello $anno $mese $savedir/${modello}_${data}.DAT ${anag_path}/${regione}_ANAG.DAT $savedir
  mv $savedir/temp.DAT $savedir/${modello}_${data}.DAT
fi
}

MODELLI="MMSUP ecn00 nud00 lhr00" #sono nomi vecchi, ma come scritto sopra la funzione PrelevaFileModello preleva i file coi nomi aggiornati
fileinpiu=$(date +%Y%m%d -d "$datai - 1 day") #se il mese parte dal primo, la minima è nell'ultimo giorno del mese prima, nel caso quindi copio il file del mese prima a quello di inizio
fileinpiu_annomese=`echo $fileinpiu|cut -c1-6`
fileinpiu_mese=`echo $fileinpiu|cut -c5-6`
#ora voglio costruire una lista che chiamo "annomese" che sarà quella su cui ciclerò per costruire i dati da plottare
if [ "$MESEi" == "$MESEf" ]; then #se mese inizio=mese fine
  if [ "$fileinpiu_mese" -ne "$MESEi" ]; then #se il file del giorno prima del giorno di inizio, NON è il file del medesimo mese del giorno di inizio
    annomese="${fileinpiu_annomese} ${ANNOi}${MESEi}" #allora devo copiare entrambi i mesi, visto che sono diversi
  else
    annomese="${ANNOi}${MESEi}" #altrimenti copio solo il mese di inizio
  fi
elif [ "$MESEi" == "01" -a "$MESEf" == "03" ]; then #quando sono intorno a febbraio, 30 giorni possono spaziare da fine gennaio ad inizio marzo
  annomese="${ANNOi}01 ${ANNOi}02 ${ANNOi}03" #nel caso devo copiare i file di gennaio febbraio marzo
else #se invece mese di inizio e mese di fine sono diversi
  if [ "$fileinpiu_mese" -ne "$MESEi" ]; then
    annomese="${fileinpiu_annomese} ${ANNOi}${MESEi} ${ANNOf}${MESEf}" #li copio entrambi, con il file del mese prima se serve
  else
    annomese="${ANNOi}${MESEi} ${ANNOf}${MESEf}" #o li copio entrambi e basta
  fi
fi
for regione in $lista_aree; do #ciclo sulle regioni definite nell'head del file
  echo "Regione: $regione"
  regione_dir=${multimodel_path}/$regione
  for timestamp in $annomese; do #ciclo su annomese che contiene i timestamp dei file da usare
    cp $regione_dir/$regione$timestamp.DAT ${work_path} #copio gli osservati
    sort -k2,2 -k1,1 ${work_path}/$regione$timestamp.DAT | uniq > ${work_path}/SORTED.DAT 
    mv ${work_path}/SORTED.DAT ${work_path}/$regione$timestamp.DAT
    anno=`echo $timestamp|cut -c1-4`
    mese=`echo $timestamp|cut -c5-6`
    #runno il riempibuchi sugli osservati
    Rscript $script_path/riempi_buchi.R "OSS" ${anno} ${mese} ${work_path}/$regione$timestamp.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
    mv ${work_path}/temp.DAT ${work_path}/$regione$timestamp.DAT
    echo "    OSSERVATI: fatto $timestamp"
    echo " " 
    for MODELLO in $MODELLI; do #ciclo sui modelli, prelevo i file e scrivo il messaggino appropriato
      PrelevaFileModello $regione_dir ${work_path} $MODELLO $timestamp $regione          
      FrasiModello $MODELLO "fatto" $timestamp
    done                 
  done
  echo "File $regione del multimodel copiati in locale."
  echo " "
  echo " "
  echo "ORGANIZZO I FILE DI INPUT"
  bash $script_path/organizza_dati_mensile.sh -d $datai -D $dataf -M "${annomese[@]}" -r $regione -w $work_path -o ${Grafici_path} -a $anag_path -s $script_path
  rm -r ${work_path}/* #libero la cartella di lavoro
done

#Una volta ciclato sulle regioni e aver plottato tutti i grafici, devo comporre un file txt nel quale scrivo il periodo preso in esame
#Questa è una procedura che viene runnata tutti i giorni, quindi il periodo di 30 giorni cambia ogni giorno
#Questo file va copiato poi in odino, perchè indica alla mappa mensile qual'è il periodo in esame
firstDigitMESEi=`echo $MESEi|cut -c1-1`
secondDigitMESEi=`echo $MESEi|cut -c2-2`
firstDigitMESEf=`echo $MESEf|cut -c1-1`
secondDigitMESEf=`echo $MESEf|cut -c2-2`

if [[ $firstDigitMESEi == "0" ]]; then
    MESEi=$secondDigitMESEi
fi
if [[ $firstDigitMESEf == "0" ]]; then
    MESEf=$secondDigitMESEf
fi

dodici_mesi=(GEN FEB MAR APR MAG GIU LUG AGO SET OTT NOV DIC)
dal=$GIORNOi" "${dodici_mesi[$((MESEi-1))]}" "$ANNOi #creo il timestamp DAL
al=$GIORNOf" "${dodici_mesi[$((MESEf-1))]}" "$ANNOf #crep il timestamp AL
echo $dal > $dalal_path/DalAl.txt
echo $al >> $dalal_path/DalAl.txt
if [ $flagLocal -eq 0 ]; then  
  scp ${Grafici_path}/* sc05@odino.arpa.piemonte.it:${odino_path_grafici} #copio tutti i grafici su odino
  rm -r ${Grafici_path}/* #libero la cartella grafici locale
  scp ${dalal_path}/DalAl.txt sc05@odino.arpa.piemonte.it:${odino_path} #copio dalal.txt su odino
fi

echo " "
echo "PROCEDURA COMPLETATA."
exit
