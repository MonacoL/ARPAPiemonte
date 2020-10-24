#! /bin/bash 

testStorage() {
#=====================================================================================
# Controllo che lo storage SAN sia attivo altrimenti lavoro su dir locale
#=====================================================================================
TESTDIR=/meteodata/grib/analysis
WINDIRSAN=/win
WN1DIR=/wn1

if [ ! -d $TESTDIR ]; then
  echo "`date +%H:%M:%S` |WAR| STORAGE SAN non attivo: lavoro su directory locale..."
  WINDIR=$WN1DIR
else
  WINDIR=$WINDIRSAN
  echo "`date +%H:%M:%S` |INF| STORAGE SAN attivo - radice di lavoro: ${WINDIR}"
fi
}

YYYY=$(date +%Y) #anno corrente
MM=$(date +%m) #mese corrente
DD=$(date +%d) #giorno corrente

data=$YYYY$MM$DD

controllaData(){ #controllo che i file dei modelli siano presenti alla data attuale
	fileModello=$1
	nomeModello=$2
	input="${work_path}/${fileModello}" #file che voglio leggere

	if [[ -s $input ]]; then
		line=$(head -3 $input | tail -1) #leggi la 3 riga e assegnala alla var line

		if [ "$line" == "$data" ]
		then
		echo "L'output di ${nomeModello} è di oggi."
		else
		echo "L'output di ${nomeModello} non è di oggi. Uso un file ${nomeModello} vuoto."
		cp $script_path/vuoto.txt $input
		fi	
	else
		echo "L'output di ${nomeModello} non è presente. Uso un file ${nomeModello} vuoto."
		cp $script_path/vuoto.txt $input
	fi
}

##############################################################
#INIZIA LA PROCEDURA

flagLocal=0 #se è 1, lavoro in locale e non prendo i dati da xmeteo4
anagrafiche_path="../Anagrafiche" #radice cartella anagrafiche
input_path="../data" #radice cartella da dove prendere i dati
work_path="../InputTemp" #radice cartella di lavoro
output_path="../Grafici" #radice cartella dove salvare i boxplot
script_path="../Scripts" #radice cartella scripts

if [[ flagLocal -eq 0 ]]; then #se non sono in locale, aggiorno le variabili con i path della macchina arpa che uso
	testStorage 
	input_path="${WINDIR}/ascii/psa"
	anagrafiche_path="/home/meteo/etc/mask"
	work_path="/home/meteo/proc/DPC/bin/InputTemp"
	output_path="/home/meteo/proc/DPC/bin/Grafici"
	script_path="/home/meteo/proc/DPC/bin/Scripts"
	odino_path="/var/lib/drupal7/files/default/field/image/meteorologia/previsione/Precipitazioni/Boxplot_ensemble/boxplotqpfmax/"
fi
echo " "
echo "Inizio importazione output modelli."
echo " "
cp ${input_path}/BOEUR0075_00_D0_IVIG.txt $work_path
controllaData "BOEUR0075_00_D0_IVIG.txt" "BOLAM"
cp ${input_path}/COSMO0020_00_D0_IVIG.txt $work_path
controllaData "COSMO0020_00_D0_IVIG.txt" "COSMO20"
cp ${input_path}/COSMO0045_00_D0_IVIG.txt $work_path
controllaData "COSMO0045_00_D0_IVIG.txt" "COSMO45"
cp ${input_path}/ECMWF0100_00_D0_IVIG.txt $work_path	
controllaData "ECMWF0100_00_D0_IVIG.txt" "ECMWF"
cp ${input_path}/ICOEU0063_00_D0_IVIG.txt $work_path
controllaData "ICOEU0063_00_D0_IVIG.txt" "ICON"
cp ${input_path}/MOLOC0023_03_D0_IVIG.txt $work_path
controllaData "MOLOC0023_03_D0_IVIG.txt" "MOLOC"
cp ${input_path}/WRFCM0019_00_D0_IVIG.txt $work_path
controllaData "WRFCM0019_00_D0_IVIG.txt" "WRF"
echo " "
echo "Fine importazione output modelli."


#Lancio lo scrip di R che fa i grafici e salva le immagini in questa dir
echo "LANCIO SCRIPT R"
TIPI="0 1" #0 massima 1 media
SCADENZE="1 5 9" #numero colonna a partire dalla prima che prendo: 12-24 oggi pomeriggio, 5 00-24 domani, 9 00-24 dopodomani
for tipo in $TIPI; do
	for scadenza in $SCADENZE; do
		#Rscript Boxplot_AreeVigilanza.R $work_path $output_path $anagrafiche_path $tipo $scadenza
		Rscript ${script_path}/Medie_AreeVigilanza.R $work_path $output_path $anagrafiche_path $tipo $scadenza
	done
done
echo "FINE SCRIPT R"

#Per la proteciv, lo script Medie_AreeVigilanza.R prende le aree richieste dalla prote civ
#e fa un pdf per ogni tipo e per ogni scadenza. Li unisco per avere un file unico
pdfunite ${output_path}/boxp_m*.pdf ${output_path}/boxp_a*.pdf ${output_path}/${DD}${MM}${YYYY}_boxp_protciv.pdf
rm ${output_path}/b*.pdf

if [[ flagLocal -eq 0 ]]; then #se non sono il locale
	echo " "
	#copio su odino le imagini che ho fatto con R
	echo "CANCELLO PDF IERI SU ODINO" 
	ssh sc05@odino.arpa.piemonte.it "rm ${odino_path}*.pdf"#se devo fornire uno storico, allora mi basta cancellare questa riga
	echo "COPIO PDF E BOXPLOT DI OGGI SU ODINO" 
	scp  ${output_path}/* sc05@odino.arpa.piemonte.it:$odino_path
	echo " "

	rm -r ${output_path}/* #libero cartella output
	rm -r ${work_path}/* #libero cartella di lavoro
fi

echo "FINE PROCEDURA"
