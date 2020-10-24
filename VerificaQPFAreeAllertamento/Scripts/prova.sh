# ieri=$(date +%Y%m%d -d "$today - 1 day")  
# xmeteo4_mkobs_path="/home/meteo/verifica"
# root_path="/home/meteo/proc/VerificaQPFAreeAllertamento"
# dati_path="$root_path/dati"

# ssh meteo@xmeteo4.ad.arpa.piemonte.it $xmeteo4_mkobs_path'/bin/stz2bal '$ieri' '$xmeteo4_mkobs_path'/non_cancellare_cartella'
# scp meteo@xmeteo4.ad.arpa.piemonte.it:${xmeteo4_mkobs_path}/non_cancellare_cartella/* $dati_path/
# ssh meteo@xmeteo4.ad.arpa.piemonte.it 'rm '$xmeteo4_mkobs_path'/non_cancellare_cartella/*'

numero=0
numero=$(wc -l < ../dati/b0700_06hh_2020071512_ave.bal)
echo $numero