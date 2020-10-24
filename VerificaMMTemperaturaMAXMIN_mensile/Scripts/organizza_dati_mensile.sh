#! /bin/bash 
# Procedura per la verifica delle previsioni di temperature estreme emesse con Multimodel 
# contro le previsioni dei modelli su base trimestrale variabile - versione solo sul Piemonte 
# 1.0       13/09/2012  Versione iniziale 
# 2.0       2018       
# 3.0       2020 Luca Monaco

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
# 
# SubRoutine and Function 
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

helpOnLine1(){
#================================================================================
# Funzione per la visualizzazione dell'help
#================================================================================ 
clear 
    echo ""   
    echo "Procedura per la creazione delle mappine di verifica di Multimodel vs. DMO" 
    echo "" 
    echo "Uso: FAI PARTIRE mappa_verifica_multimodel_mensile.sh, non questo file!"
    exit
}
 
 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
# 
# MAIN PROGRAM 
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
#================================================================================
# 1 - Carica file di configurazione
#================================================================================
#. $HOME/.bash_profile
#. $HOME/grads/proc/ModGradsModel 
#================================================================================
# 2 - scrive DEFAULTS
#================================================================================
today=`date +%Y%m%d` 

#setto alcune variabili di default, nel caso malaugurato che qualcuno runni questo file anzichè runnare mappa_verifica_multimodel_mensile.sh
data_in=`date +%Y%m%d` 
data_end=0 
regione="PI"                      # Area di default - PIEMONTE 
work_path="/home/meteo/multimodel/verifica/" 
anag_path="/home/meteo/etc/multimodel/stazioni/"
saveimg_path="/home/meteo/multimodel/verifica/"
script_path=""
annomese=""

#================================================================================
# 3 - OPZIONI controllo parametri in input
#================================================================================
while getopts d:D:M:r:w:o:a:s:h value; do
  case $value in  
    d) data_in=$OPTARG;; 
    D) data_end=$OPTARG;;    
    M) annomese=$OPTARG;;
    r) regione=$OPTARG;;
    a) anag_path=$OPTARG;;
    o) saveimg_path=$OPTARG;;
    s) script_path=$OPTARG;;
    w) work_path=$OPTARG;;
    h) helpOnLine1;; 
    ?) echo "Errore nell'immissione dei parametri" 
       exit ;; 
  esac 
done 


#echo "Processo: verifica MM_DMO  - lanciato il " `date +%d/%m/%Y` 
#echo "Avvio del processo alle " `date  +%H:%M` 
#echo "=================================================================" 
#echo "`date +%H:%M:%S`  DATA ELABORAZIONE   : $data_in " 
orai=`date +%H` 
minutii=`date +%M`  

#Spezza la data 
ANNO=`echo $data_in|cut -c1-4` 
MESE=`echo $data_in|cut -c5-6` 
GIORNO=`echo $data_in|cut -c7-8`   

   
echo " " 
echo "Periodo richiesto: da " "$data_in" "a" "$data_end" "numero giorni=30" 
echo "Regione richiesta: " $regione    
echo " "

#=======================================================================================================================
# 6 - Elaborazione dati 
#======================================================================================================================= 

MODELLI="MMSUP ecn00 nud00 lhr00"

for timestamp in $annomese; do #serializzo i dati dei diversi file in un file unico ordinati per data
  cat ${work_path}/${regione}${timestamp}.DAT >> ${work_path}/OSSERVATI.DAT
  cat ${work_path}/MMSUP_${timestamp}.DAT >> ${work_path}/MMS.DAT
  cat ${work_path}/ecn00_${timestamp}.DAT >> ${work_path}/ECN.DAT
  cat ${work_path}/nud00_${timestamp}.DAT >> ${work_path}/NUD.DAT
  cat ${work_path}/lhr00_${timestamp}.DAT >> ${work_path}/LNU.DAT
done #ricordo che questi file contengono le righe di massime e minime, come da output di riempibuchi.R
#prelevo SOLO le massime e salvo i file delle massime
awk '$3 == 1800' ${work_path}/OSSERVATI.DAT > ${work_path}/OSSERVATI_MAX.DAT 
awk '$3 == 18' ${work_path}/MMS.DAT > ${work_path}/MMS_MAX.DAT 
awk '$3 == 18' ${work_path}/ECN.DAT > ${work_path}/ECN_MAX.DAT 
awk '$3 == 18' ${work_path}/NUD.DAT > ${work_path}/NUD_MAX.DAT 
awk '$3 == 18' ${work_path}/LNU.DAT > ${work_path}/LNU_MAX.DAT 
#prelevo SOLO le minime e salvo i file delle minime
awk '$3 == 600' ${work_path}/OSSERVATI.DAT > ${work_path}/OSSERVATI_MIN.DAT 
awk '$3 == 30' ${work_path}/MMS.DAT > ${work_path}/MMS_MIN.DAT 
awk '$3 == 30' ${work_path}/ECN.DAT > ${work_path}/ECN_MIN.DAT 
awk '$3 == 30' ${work_path}/NUD.DAT > ${work_path}/NUD_MIN.DAT 
awk '$3 == 30' ${work_path}/LNU.DAT > ${work_path}/LNU_MIN.DAT

days=($(seq 0 1 30))
for day in "${days[@]}"; do #prelevo solo i dati dei giorni del periodo mensile in esame
  data_corr=$(date +%Y%m%d -d "$data_in + $day day")
  awk '$2 == '$data_corr ${work_path}/OSSERVATI_MAX.DAT >> ${work_path}/OSSMAX_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/MMS_MAX.DAT >> ${work_path}/MMSMAX_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/ECN_MAX.DAT >> ${work_path}/ECMMAX_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/NUD_MAX.DAT >> ${work_path}/CI7MAX_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/LNU_MAX.DAT >> ${work_path}/CI2MAX_MESE.DAT
done

data_in2=$(date +%Y%m%d -d "$data_in -1 day") #le minime partono dal giorno prima e finiscono un giorno prima
for day in "${days[@]}"; do
  data_corr=$(date +%Y%m%d -d "$data_in2 + $day day")
  awk '$2 == '$data_corr ${work_path}/OSSERVATI_MIN.DAT >> ${work_path}/OSSMIN_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/MMS_MIN.DAT >> ${work_path}/MMSMIN_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/ECN_MIN.DAT >> ${work_path}/ECMMIN_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/NUD_MIN.DAT >> ${work_path}/CI7MIN_MESE.DAT
  awk '$2 == '$data_corr*100 ${work_path}/LNU_MIN.DAT >> ${work_path}/CI2MIN_MESE.DAT
done

#separo per quote  
echo "SEPARO I DATI PER QUOTA 700M-1500M-3000M"
files="OSS MMS ECM CI7 CI2"
temperature="MAX MIN"
for file in $files; do
  for temp in $temperature; do    
    ${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/$file${temp}_MESE.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
    mv ${work_path}/fileout1500.txt ${work_path}/$file${temp}150.DAT 
    mv ${work_path}/fileout3000.txt ${work_path}/$file${temp}300.DAT
    mv ${work_path}/fileout700.txt ${work_path}/$file${temp}700.DAT 
    echo $file$temp " fatto"
  done
done
# ########################################################################################################################################################## 
#Lancio un codice che ordini le righe del file di Multimodel, inizialmente era solo per PI e AO, ma farlo su tutte le regioni non porta via troppo tempo
#così sono sicuro che tutte le regioni abbiano lo stesso ordine
files="MMS ECM CI7 CI2"
quote="700 150 300"
echo "SORT DEI FILE SECONDO DATA E STAZIONE"
for quota in $quote; do
  for temperatura in $temperature; do
    for file in $files; do
      sort -k2,2 -k1,1 ${work_path}/${file}${temperatura}${quota}.DAT | uniq > ${work_path}/SORTED.DAT #ogni tanto ci sono doppioni ma non ho capito perchè (luca)
      rm ${work_path}/${file}${temperatura}${quota}.DAT
      mv ${work_path}/SORTED.DAT ${work_path}/${file}${temperatura}${quota}.DAT
    done
  done
done 
echo "Fatto."
echo " "

numstaz="" #tiro fuori il numero di stazioni per quota e lo stampo su file... potrei ottimizzare e passare questi dati come parametri allo script di generazione plot
for quota in $quote; do 
  nro=$(wc -l < ${work_path}/OSSMAX${quota}.DAT )
  numstaz+=`expr $nro / 30`","     
done
echo ${numstaz: : -1} > ${work_path}/NUMSTAZ.DAT 

Rscript $script_path/genera_grafici_mensile.R $regione $work_path $saveimg_path 1 #creo finalmente i grafici
Rscript $script_path/genera_grafici_mensile.R $regione $work_path $saveimg_path 5 #creo finalmente i grafici