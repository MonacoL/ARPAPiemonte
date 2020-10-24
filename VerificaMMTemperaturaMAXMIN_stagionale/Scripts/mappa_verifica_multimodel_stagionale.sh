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
StoricoLocal_path="../StoricoGrafici"
work_path="../InputTemp"  #dove salvare i dati per lavorarci sopra
anag_path="../Anagrafiche"
show_file_path=".."
script_path="../Scripts"
#logs_path="../logs/"


flagLocal=0
if [ $flagLocal -eq 0 ]; then
  root_path="/home/meteo/proc/odinoMM/odinoMM_stagionale"
  script_path="$root_path/Scripts"
  multimodel_path="/output/meteo/multimodel" #percorso in xmeteo4 della cartella madre del multimodel in cui sono i dati divisi cartelle regionali
  odino_path_StoricoGrafici="/var/lib/drupal7/files/default/field/image/meteorologia/StoricoGrafici" #dove copiare i grafici su odino
  odino_path="/var/lib/drupal7/files/default/field/image/meteorologia"
  StoricoLocal_path="$root_path/StoricoGrafici"
  work_path="$root_path/InputTemp"  #dove salvare i dati per lavorarci sopra
  anag_path="$root_path/Anagrafiche"
  anag_xmeteo_path="$root_path/Anagrafiche_xmeteo"
  scp meteo@xmeteo4.ad.arpa.piemonte.it:/home/meteo/etc/multimodel/stazioni/*.DAT $anag_xmeteo_path  
  for regione in $lista_aree; do
    if [ -s "$anag_xmeteo_path/${regione}_ANAG_OK.DAT" ];then
      cp $anag_xmeteo_path/${regione}_ANAG_OK.DAT $anag_path/${regione}_ANAG.DAT
    else
      cp $anag_xmeteo_path/${regione}_ANAG.DAT $anag_path/${regione}_ANAG.DAT
    fi
  done
  rm -r $anag_xmeteo_path/*
  #logs_path="$root_path/logs"
  show_file_path="$root_path"
fi

salva_dati_dei_grafici=0
#================================================================================
# 2 - Definizione help dell'algoritmo
#================================================================================

helpOnLine1(){
    echo ""   
    echo "Uso: run.sh [AAAAMMGG] [aaaammmgg]" 
    echo "AAAAMMGG : data di inizio del periodo (def. fine mese precedente meno 3 mesi)" 
    echo "aaaammgg: data di fine del periodo (def. fine mese precedente)" 
    echo " "
    exit
}

helpOnLine2(){
    echo ""   
    echo "Procedura per la creazione dei grafici del multimodel per il servizio su Odino" 
    helpOnLine1
    exit
}

if [ $# -eq 0 ]
  then
  	echo ""
    echo "Nessun argomento fornito!"
    helpOnLine1
    exit 1
fi

if [ $# -eq 1 ]
  then
  	echo ""
    echo "Hai inserito solo un argomento!"
    helpOnLine1
    exit 1
fi


#================================================================================
#FUNZIONA SOLO SULLA STAZGIONE COMPLETA
#======================================
#command | tee -a $logs_path`date +%d%m%Y`_`date +%H_%M_%S`".txt" #log file

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "PRELEVO I FILE DI INPUT"
echo " "

datai=$1 
dataf=$2    

#Spezza la data 
ANNOi=`echo $datai|cut -c1-4` 
ANNOf=`echo $dataf|cut -c1-4`
MESEi=`echo $datai|cut -c5-6` 
GIORNOi=`echo $datai|cut -c7-8`   
GIORNOf=`echo $dataf|cut -c7-8`   

#STAGIONE
DJF="12 01 02"
MAM="03 04 05"
JJA="06 07 08"
SON="09 10 11"

DJF2="11 12 01 02"
MAM2="02 03 04 05"
JJA2="05 06 07 08"
SON2="08 09 10 11"

case $MESEi in
 12)
 stagione="$DJF"
 stagione2="$DJF2"
 stagione3="DJF"
	;; 
	03)
	stagione="$MAM" 
  stagione2="$MAM2"
  stagione3="MAM"
		;;
		06)
		stagione="$JJA"
    stagione2="$JJA2"
    stagione3="JJA"
			;;
			09)
			stagione="$SON"
      stagione2="$SON2"
      stagione3="SON"
esac


echo "Stagione: ${stagione}"
echo " "

FrasiModello(){ #1 modello #2 "fatto"-"nonesistefile" #3 date

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
    echo "    COSMO-i7: fatto $data"
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
    echo "    Il file COSMO-i7 per la data ${data} non esiste."
  elif [[ "$modello" == "lnu00" ]]; then
    echo "    Il file LAMINO per la data ${data} non esiste."
  elif [[ "$modello" == "lhr00" ]]; then
    echo "    Il file COSMINO per la data ${data} non esiste."
  fi
fi

}

PrelevaFileModello(){ #1 copydir #2 savedir #3 modello #4 data  #5 regione
copydir=$1
savedir=$2
modello=$3
data=$4
regione=$5
anno=`echo $data|cut -c1-4`
mese=`echo $data|cut -c5-6`

flag=0
# if [[ -s "$copydir/${modello}_${data}.DAT" ]]; then #vediamo se esistono i file coi vecchi nomi prima di tutto e che siano non vuoti
#   cp $copydir/${modello}_${data}.DAT $savedir
#   flag=1
# else #altrimenti cerchiamo i nuovi nominativi
if [ "$modello" == "MMSUP" ] && [ -s "$copydir/${modello}_${data}_${regione}.DAT" ] ; then
  cp $copydir/${modello}_${data}_${regione}.DAT $savedir
  mv $savedir/${modello}_${data}_${regione}.DAT $savedir/${modello}_${data}.DAT
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
# fi
if [ $flag == 1 ];then
  sort -k2,2 -k1,1 $savedir/${modello}_${data}.DAT | uniq > $savedir/SORTED.DAT 
  mv $savedir/SORTED.DAT $savedir/${modello}_${data}.DAT
  Rscript ${script_path}/riempi_buchi.R $modello $anno $mese $savedir/${modello}_${data}.DAT ${anag_path}/${regione}_ANAG.DAT $savedir
  mv $savedir/temp.DAT $savedir/${modello}_${data}.DAT
fi
}

MODELLI_OLD="MMSUP ecn00 nud00 lnu00" #cambiamento denominazione da 202001
MODELLI_NEW="MMSUP ecn00 nud00 lhr00"
MODELLI=""
if [ $ANNOf -eq 2020 ] && [ $ANNOi -eq 2019 ]; then
  MODELLI="misto"
elif [ $ANNOf -lt 2020 ] && [ $ANNOi -lt 2020 ]; then
  MODELLI=$MODELLI_OLD
else
  MODELLI=$MODELLI_NEW
fi
for regione in $lista_aree; do
  echo "Regione: $regione"
  regione_dir=${multimodel_path}/$regione 
  if [ "$MODELLI" == "misto" ]; then
    cp $regione_dir/$regione${ANNOi}12.DAT ${work_path}    
    cp $regione_dir/$regione${ANNOf}01.DAT ${work_path}
    cp $regione_dir/$regione${ANNOf}02.DAT ${work_path}

    sort -k2,2 -k1,1 ${work_path}/$regione${ANNOi}12.DAT | uniq > ${work_path}/SORTED.DAT 
    mv ${work_path}/SORTED.DAT ${work_path}/$regione${ANNOi}12.DAT
    sort -k2,2 -k1,1 ${work_path}/$regione${ANNOf}01.DAT | uniq > ${work_path}/SORTED.DAT 
    mv ${work_path}/SORTED.DAT ${work_path}/$regione${ANNOf}01.DAT 
    sort -k2,2 -k1,1 ${work_path}/$regione${ANNOf}02.DAT | uniq > ${work_path}/SORTED.DAT 
    mv ${work_path}/SORTED.DAT ${work_path}/$regione${ANNOf}02.DAT 

    Rscript ${script_path}/riempi_buchi.R "OSS" ${ANNOi} 12 ${work_path}/$regione${ANNOi}12.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
    mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOi}12.DAT   
    Rscript ${script_path}/riempi_buchi.R "OSS" ${ANNOf} 01 ${work_path}/$regione${ANNOf}01.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
    mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOf}01.DAT  
    Rscript ${script_path}/riempi_buchi.R "OSS" ${ANNOf} 02 ${work_path}/$regione${ANNOf}02.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
    mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOf}02.DAT  

    echo "    OSSERVATI: fatto ${ANNOi}12-${ANNOf}01-${ANNOf}02"
    echo " "
    for MODELLO in $MODELLI_OLD; do
      PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOi}11 $regione 
      PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOi}12 $regione
      FrasiModello $MODELLO "fatto" ${ANNOi}11"-"${ANNOi}12
    done
    for MODELLO in $MODELLI_NEW; do
      PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOf}01 $regione
      PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOf}02 $regione
      FrasiModello $MODELLO "fatto" ${ANNOf}01"-"${ANNOf}02
    done 
    mv ${work_path}/lhr00_${ANNOf}01.DAT ${work_path}/lnu00_${ANNOf}01.DAT
    mv ${work_path}/lhr00_${ANNOf}02.DAT ${work_path}/lnu00_${ANNOf}02.DAT
  else
    if [ "$stagione" == "$DJF" ]; 
      then        
        cp $regione_dir/$regione${ANNOi}12.DAT ${work_path}
        cp $regione_dir/$regione${ANNOf}01.DAT ${work_path}
        cp $regione_dir/$regione${ANNOf}02.DAT ${work_path}

        sort -k2,2 -k1,1 ${work_path}/$regione${ANNOi}12.DAT | uniq > ${work_path}/SORTED.DAT 
        mv ${work_path}/SORTED.DAT ${work_path}/$regione${ANNOi}12.DAT
        sort -k2,2 -k1,1 ${work_path}/$regione${ANNOf}01.DAT | uniq > ${work_path}/SORTED.DAT 
        mv ${work_path}/SORTED.DAT ${work_path}/$regione${ANNOf}01.DAT 
        sort -k2,2 -k1,1 ${work_path}/$regione${ANNOf}02.DAT | uniq > ${work_path}/SORTED.DAT 
        mv ${work_path}/SORTED.DAT ${work_path}/$regione${ANNOf}02.DAT 

        Rscript ${script_path}/riempi_buchi.R "OSS" ${ANNOi} 12 ${work_path}/$regione${ANNOi}12.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
        mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOi}12.DAT   
        Rscript ${script_path}/riempi_buchi.R "OSS" ${ANNOf} 01 ${work_path}/$regione${ANNOf}01.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
        mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOf}01.DAT  
        Rscript ${script_path}/riempi_buchi.R "OSS" ${ANNOf} 02 ${work_path}/$regione${ANNOf}02.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
        mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOf}02.DAT 

        echo "    OSSERVATI: fatto ${ANNOi}12-${ANNOf}01-${ANNOf}02"
        echo " "      
        for MODELLO in $MODELLI; do
          PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOi}11 $regione          
          PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOi}11 $regione
          PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOf}01 $regione
          PrelevaFileModello $regione_dir ${work_path} $MODELLO ${ANNOf}02 $regione
          FrasiModello $MODELLO "fatto" ${ANNOi}11"-"${ANNOi}12"-"${ANNOf}01"-"${ANNOf}02
        done
        if [ "${MODELLI[@]:18:3}" == "lhr" ]; then
          mv ${work_path}/lhr00_${ANNOi}11.DAT ${work_path}/lnu00_${ANNOi}11.DAT
          mv ${work_path}/lhr00_${ANNOi}12.DAT ${work_path}/lnu00_${ANNOi}12.DAT
          mv ${work_path}/lhr00_${ANNOf}01.DAT ${work_path}/lnu00_${ANNOf}01.DAT
          mv ${work_path}/lhr00_${ANNOf}02.DAT ${work_path}/lnu00_${ANNOf}02.DAT
        fi        
      else        
        for MESE in $stagione2; do
          cp $regione_dir/$regione$ANNOi$MESE.DAT ${work_path} #così copio un file osservato in più, ma non importa, poi verrà pulito
          
          sort -k2,2 -k1,1 ${work_path}/$regione$ANNOi$MESE.DAT | uniq > ${work_path}/SORTED.DAT 
          mv ${work_path}/SORTED.DAT ${work_path}/$regione$ANNOi$MESE.DAT

          Rscript ${script_path}/riempi_buchi.R "OSS" $ANNOi $MESE ${work_path}/$regione${ANNOi}$MESE.DAT ${anag_path}/${regione}_ANAG.DAT ${work_path}
          mv ${work_path}/temp.DAT ${work_path}/$regione${ANNOi}$MESE.DAT   

          echo "    OSSERVATI: fatto ${ANNOi}$MESE"
          echo " "   
          for MODELLO in $MODELLI; do
            PrelevaFileModello $regione_dir ${work_path} $MODELLO $ANNOi$MESE $regione
            FrasiModello $MODELLO "fatto" "$ANNOi$MESE"
          done   
          if [ "${MODELLI[@]:18:3}" == "lhr" ]; then
            mv ${work_path}/lhr00_$ANNOi$MESE.DAT ${work_path}/lnu00_$ANNOi$MESE.DAT
          fi                
        done
    fi    
  fi
  echo "File $regione del multimodel copiati in locale."
  echo " "
  echo " "
  echo "ORGANIZZO I FILE DI INPUT"
  bash ${script_path}/organizza_dati_stagionale.sh -d $datai -D $dataf -r $regione -w $work_path -o ${StoricoLocal_path}/${ANNOf}/${stagione3} -a $anag_path -s $script_path
  if [ $flagLocal -eq 0 ]; then
    rm -r ${work_path}/* #libero la cartella di lavoro
    plot_path="${StoricoLocal_path}/${ANNOf}/${stagione3}"
    scp ${plot_path}/TMAX/${regione}/${regione}_TMAX_{150,300,700}.png sc05@odino.arpa.piemonte.it:${odino_path_StoricoGrafici}/${ANNOf}/${stagione3}/TMAX/${regione}/
    scp ${plot_path}/TMIN/${regione}/${regione}_TMIN_{150,300,700}.png sc05@odino.arpa.piemonte.it:${odino_path_StoricoGrafici}/${ANNOf}/${stagione3}/TMIN/${regione}/
    rm -r ${plot_path}/TMAX/${regione}/* #libero lo storico locale
    rm -r ${plot_path}/TMIN/${regione}/*
  fi
done
echo "${ANNOf} ${stagione3} 1" >> $show_file_path/ToShowOnMap.txt
sort -u -o $show_file_path/ToShowOnMap.txt $show_file_path/ToShowOnMap.txt 
if [ $flagLocal -eq 0 ]; then
  scp $show_file_path/ToShowOnMap.txt sc05@odino.arpa.piemonte.it:${odino_path}
fi  

echo " "
echo "PROCEDURA COMPLETATA."
exit
