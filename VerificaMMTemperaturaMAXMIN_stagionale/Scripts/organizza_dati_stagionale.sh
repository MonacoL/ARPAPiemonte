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
    echo "Procedura per la creazione delle mappine di verifica di Multmodel vs. DMO" 
    echo "" 
    echo "Uso: verifica_Textr_stagionale_MM_vs_DMO_generale.sh [-d AAAAMMGG] [-D AAAAMMGG] [-a AREA]" 
    echo " -d AAAAMMGG : data di inizio del periodo (def. fine mese precedente meno 3 mesi)" 
    echo " -D AAAAMMGG : data di fine del periodo (def. fine mese precedente)" 
    echo " -a  AREA: PI (piemonte, default), SY (Synop), AB (Abruzzo), BA (Basilicata), o una delle altre regioni " 
    echo " " 
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
#yesterday=`days $today -1`  

data_in=`date +%Y%m%d` 
data_end=0 
regione="PI"                      # Area di default - PIEMONTE 
work_path="/home/meteo/multimodel/verifica/" 
anag_path="/home/meteo/etc/multimodel/stazioni/"
saveimg_path="/home/meteo/multimodel/verifica/"
script_path=""
  
#================================================================================
# 3 - OPZIONI controllo parametri in input
#================================================================================
while getopts d:D:r:w:o:a:s:h value; do
  case $value in  
    d) data_in=$OPTARG;; 
    D) data_end=$OPTARG;;    
    r) regione=$OPTARG;;
    a) anag_path=$OPTARG;;
    o) saveimg_path=$OPTARG;;
    w) work_path=$OPTARG;;
    s) script_path=$OPTARG;;
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

#================================================================================
# 4 - Testa se lo storage SUN attivo
#================================================================================
#testStorage $ANNO   

#================================================================================
# 5 - .gestione date
#================================================================================
 
flag=0 

#Date di inizio e fine specificate: calcolo il numero di giorni nel periodo    
if [ $data_end -ne 0 ] ; then 
  echo "presente dataend" 
  echo "dataend"
  echo $data_end

   
  deltagg=1 
  data_incr=$data_in
  until (( $data_incr == $data_end ))  
  do  
     data_incr=$(date +%Y%m%d -d "$data_incr UTC + 1 day")    
     #data_incr=`days $data_incr +1` 
     deltagg=$(($deltagg+1)) 
  done
  echo "deltagg=" $deltagg
fi 
 
# Date di inizio e fine non specificate:
# prendo come periodo i 3 mesi completi precedenti  
if [ $data_in -eq $today ]  ; then  
flag=1 
echo "non specificata data iniziale, si prende il primo giorno dei 3 mesi completi precedenti"  
 if (( $MESE > 3 ))  
 then 
  (( MESE_NEW = $MESE - 3 ))
  (( ANNO_NEW = $ANNO )) 
  (( MESE_END = $MESE ))  
  (( ANNO_END = $ANNO ))   
 fi 
 if (( $MESE == 3 ))  
 then 
  (( MESE_NEW = 12 ))
  (( ANNO_NEW = $ANNO - 1 )) 
  (( MESE_END = 3 ))  
  (( ANNO_END = $ANNO ))   
 fi 
 if (( $MESE == 2 ))  
 then 
  (( MESE_NEW = 11 ))
  (( ANNO_NEW = $ANNO - 1 )) 
  (( MESE_END = 3 ))  
  (( ANNO_END = $ANNO )) 
 fi  
 if (( $MESE == 1 ))  
 then 
  (( MESE_NEW = 10 ))
  (( ANNO_NEW = $ANNO - 1 )) 
  (( MESE_END = 1 ))  
  (( ANNO_END = $ANNO - 1 )) 
 fi  

 (( mese_req = $ANNO_NEW * 100 + $MESE_NEW )) 
 (( data_in=$mese_req*100+1 ))    

#  ((data_corr=`days $data_in -1`))   #vado indietro di un giorno per cercare i file osservati a +48  #CAMBIARE?? 
fi   

# calcolo data finale

if [ $data_end -eq 0 ] ; then 
 echo "non specificata data finale, vado fino alla fine del mese completo precedente" 
 data_end=$(date +%Y%m%d -d "$data_in + 3 month")
 data_end=$(date +%Y%m%d -d "$data_end - 1 day") 
fi  



#   deltagg=0 
#   data_corr=$data_in 
#   #(( mese_end=$data_corr/100 ))
#   while (( $data_corr <= $data_end )) 
#   do
#    data_corr=`days $data_corr +1` 
# #   (( mese_end=$data_end/100 ))
#    deltagg=$(($deltagg+1)) 
#   done 
# #  data_end=`days $data_end -1` 
    
echo " " 
echo "Periodo richiesto: da " "$data_in" "a" "$data_end" "numero giorni="$deltagg 
echo "Regione richiesta: " $regione    
echo " "

#=======================================================================================================================
# 6 - Elaborazione dati 
#======================================================================================================================= 

#COSTRUZIONE DATASET OSSERVATI ######################################################################################### 
echo "OSSERVATI" 
#TEMPERATURE MASSIME ################################################################### 
data_corr=$data_in 
#ISTRUZIONE CHE TAGLIA UNA STRINGA 
dd1=`echo ${data_corr}|cut -c 1-6` #così prendo AAAAMM dalla data, che mi servirà per il nome dei file
#ISTRUZIONE AWK CHE REDIRIGE UN FILE IN UN ALTRO TENENDO SOLO LE RIGHE CON LA TERZA COLONNA UGUALE A UN DATO VALORE NUMERICO (1800) 
awk '$3 == 1800' ${work_path}/${regione}${dd1}.DAT > ${work_path}/temp1.DAT  

#ISTRUZIONE CHE AUMENTA LA DATA DI UN MESE MEDIANTE IL COMANDO DATE 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
#RIPETO PER ALTRI DUE MESI 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 1800' ${work_path}/${regione}${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 1800' ${work_path}/${regione}${dd3}.DAT > ${work_path}/temp3.DAT 
#ISTRUZIONE CHE UNISCE I 3 FILES COSI PRODOTTI 
cat ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp.DAT  
 
#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}

mv ${work_path}/fileout700.txt ${work_path}/OSSMAX700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/OSSMAX150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/OSSMAX300.DAT  
rm ${work_path}/temp*.DAT
echo "TMAX: fatto" 

#TEMPERATURE MINIME ################################################################### 
data_corr=$data_in 
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 600' ${work_path}/${regione}${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 600' ${work_path}/${regione}${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 600' ${work_path}/${regione}${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp.DAT  
  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}

mv ${work_path}/fileout700.txt ${work_path}/OSSMIN700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/OSSMIN150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/OSSMIN300.DAT  
rm ${work_path}/temp*.DAT
echo "TMIN: fatto" 

echo " " 
# ############################################################################################################################################# 
# #COSTRUZIONE DATASET PREVISTI MM ############################################################################################################ 
echo "MMSUP"  

# #TEMPERATURE MASSIME ###################################################################  
data_corr=$data_in   
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18' ${work_path}/MMSUP_${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18'  ${work_path}/MMSUP_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 18'  ${work_path}/MMSUP_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp.DAT  

${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}

mv ${work_path}/fileout700.txt ${work_path}/MMSMAX700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/MMSMAX150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/MMSMAX300.DAT
rm ${work_path}/temp*.DAT
echo "TMAX: fatto"      

#   #TEMPERATURE MINIME  ################################################################### 
data_corr=$data_in 
#ESTRAZIONE ULTIMO GIORNO DI 4 MESI PRIMA (LE MINIME SONO PREVISTE NELLA CORSA DEL GIORNO PRIMA)  
data_corr=$(date +%Y%m%d -d "$data_corr - 1 month")  
dd0=`echo ${data_corr}|cut -c 1-6`   
awk '$3 == 30' ${work_path}/MMSUP_${dd0}.DAT > ${work_path}/temp.DAT   
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day") 
more ${work_path}/temp.DAT | grep $data_corr > ${work_path}/temp0.DAT 
rm ${work_path}/temp.DAT  
#FINE ESTRAZIONE ULTIMO GIORNO 4 MESI PRIMA 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 day")  
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/MMSUP_${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/MMSUP_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/MMSUP_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp0.DAT ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp4.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day")  
#ISTRUZIONE AWK CHE REDIRIGE UN FILE IN UN ALTRO TENENDO SOLO LE RIGHE CON LA SECONDA COLONNA DIVERSA DA UN DATO VALORE NUMERICO (data_corr)  
#lo faccio per togliere la previsione dell'ultimo giorno che si riferisce al mese seguente  
awk '$2 != '$data_corr*100 ${work_path}/temp4.DAT > ${work_path}/temp.DAT  
 
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}

mv ${work_path}/fileout700.txt ${work_path}/MMSMIN700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/MMSMIN150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/MMSMIN300.DAT
rm ${work_path}/temp*.DAT
echo "TMIN: fatto" 

echo " " 
#############################################################################################################################################  
#COSTRUZIONE DATASET PREVISTI ECMWF########################################################################################################## 
echo "ECMWF00"   
#TEMPERATURE MASSIME ###################################################################  
data_corr=$data_in  
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18' ${work_path}/ecn00_${dd1}.DAT > ${work_path}/temp1.DAT    
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month")  
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18' ${work_path}/ecn00_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 18' ${work_path}/ecn00_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp.DAT  

#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
mv ${work_path}/fileout700.txt ${work_path}/ECMMAX700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/ECMMAX150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/ECMMAX300.DAT    
rm ${work_path}/temp*.DAT   
echo "TMAX: fatto"

#  #TEMPERATURE MINIME  ###################################################################   
data_corr=$data_in 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 month")  
dd0=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/ecn00_${dd0}.DAT > ${work_path}/temp.DAT   
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day") 
more ${work_path}/temp.DAT | grep $data_corr > ${work_path}/temp0.DAT 
rm ${work_path}/temp.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 day")    
dd1=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/ecn00_${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/ecn00_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month")  
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/ecn00_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp0.DAT ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp4.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day") 
awk '$2 != '$data_corr*100 ${work_path}/temp4.DAT > ${work_path}/temp.DAT  
  
#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
mv ${work_path}/fileout700.txt ${work_path}/ECMMIN700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/ECMMIN150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/ECMMIN300.DAT    
rm ${work_path}/temp*.DAT   
echo "TMIN: fatto" 

echo " " 

# #############################################################################################################################################  
# #COSTRUZIONE DATASET PREVISTI COSMO-I7 ######################################################################################################  
echo "COSMO-I7"   
#TEMPERATURE MASSIME ###################################################################  
data_corr=$data_in  
dd1=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 18' ${work_path}/nud00_${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18' ${work_path}/nud00_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 18' ${work_path}/nud00_${dd3}.DAT > ${work_path}/temp3.DAT

cat ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp.DAT  

#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
mv ${work_path}/fileout700.txt ${work_path}/CI7MAX700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/CI7MAX150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/CI7MAX300.DAT    
rm ${work_path}/temp*.DAT   
echo "TMAX: fatto"    
  
#  #TEMPERATURE MINIME  ###################################################################  
data_corr=$data_in 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 month")  
dd0=`echo ${data_corr}|cut -c 1-6`  

awk '$3 == 30' ${work_path}/nud00_${dd0}.DAT > ${work_path}/temp.DAT   
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day") 
more ${work_path}/temp.DAT | grep $data_corr > ${work_path}/temp0.DAT 
rm ${work_path}/temp.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 day")  
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/nud00_${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/nud00_${dd2}.DAT > ${work_path}/temp2.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/nud00_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp0.DAT ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp4.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day")  
awk '$2 != '$data_corr*100 ${work_path}/temp4.DAT > ${work_path}/temp.DAT  

#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
mv ${work_path}/fileout700.txt ${work_path}/CI7MIN700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/CI7MIN150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/CI7MIN300.DAT    
rm ${work_path}/temp*.DAT   
echo "TMIN: fatto"    
 
echo " " 
#############################################################################################################################################  
# #COSTRUZIONE DATASET PREVISTI COSMO-I2 ######################################################################################################  
echo "COSMO-I2"   
#TEMPERATURE MASSIME ###################################################################  
data_corr=$data_in  
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18' ${work_path}/lnu00_${dd1}.DAT > ${work_path}/temp1.DAT   
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 18' ${work_path}/lnu00_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month")  
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 18' ${work_path}/lnu00_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp.DAT 
#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
mv ${work_path}/fileout700.txt ${work_path}/CI2MAX700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/CI2MAX150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/CI2MAX300.DAT    
rm ${work_path}/temp*.DAT   
echo "TMAX: fatto"   
  
#  #TEMPERATURE MINIME  ################################################################### 
data_corr=$data_in 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 month")  
dd0=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/lnu00_${dd0}.DAT > ${work_path}/temp.DAT   
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day") 
more ${work_path}/temp.DAT | grep $data_corr > ${work_path}/temp0.DAT 
rm ${work_path}/temp.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 day")  
dd1=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/lnu00_${dd1}.DAT > ${work_path}/temp1.DAT  
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd2=`echo ${data_corr}|cut -c 1-6` 
awk '$3 == 30' ${work_path}/lnu00_${dd2}.DAT > ${work_path}/temp2.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
dd3=`echo ${data_corr}|cut -c 1-6`  
awk '$3 == 30' ${work_path}/lnu00_${dd3}.DAT > ${work_path}/temp3.DAT 
cat ${work_path}/temp0.DAT ${work_path}/temp1.DAT ${work_path}/temp2.DAT   ${work_path}/temp3.DAT  > ${work_path}/temp4.DAT 
data_corr=$(date +%Y%m%d -d "$data_corr + 1 month") 
data_corr=$(date +%Y%m%d -d "$data_corr - 1 day") 
awk '$2 != '$data_corr*100 ${work_path}/temp4.DAT > ${work_path}/temp.DAT  

#separo per quote  
${script_path}/separa_files_per_quote_Luca_20200615 ${work_path}/temp.DAT $anag_path/${regione}_ANAG.DAT ${work_path}
mv ${work_path}/fileout700.txt ${work_path}/CI2MIN700.DAT 
mv ${work_path}/fileout1500.txt ${work_path}/CI2MIN150.DAT 
mv ${work_path}/fileout3000.txt ${work_path}/CI2MIN300.DAT    
rm ${work_path}/temp*.DAT   
echo "TMIN: fatto" 
echo " "

# ########################################################################################################################################################## 
#Lancio un codice che ordini le righe del file di Multimodel, inizialmente era solo per PI e AO, ma farlo su tutte le regioni non porta via troppo tempo
#così sono sicuro che tutte le regioni abbiano lo stesso ordine
quote="700 150 300"
temperature="MIN MAX"
modelli="MMS ECM CI7 CI2"
echo "SORT DEI FILE SECONDO DATA E STAZIONE"
for quota in $quote; do
  for temperatura in $temperature; do
    for modello in $modelli; do
      sort -k2,2 -k1,1 ${work_path}/${modello}${temperatura}${quota}.DAT | uniq > ${work_path}/SORTED.DAT #ogni tanto ci sono doppioni ma non ho capito perchè (luca)
      rm ${work_path}/${modello}${temperatura}${quota}.DAT
      mv ${work_path}/SORTED.DAT ${work_path}/${modello}${temperatura}${quota}.DAT
    done
  done
done 
echo "Fatto."
echo " "

numstaz="" #tiro fuori il numero di stazioni per quota e lo stampo su file
for quota in $quote; do 
  nro=$(wc -l < ${work_path}/OSSMAX${quota}.DAT )
  numstaz+=`expr $nro / $deltagg`","     
done
echo ${numstaz: : -1} > ${work_path}/NUMSTAZ.DAT 

Rscript ${script_path}/genera_grafici_stagionale.R $regione $work_path $saveimg_path 10
