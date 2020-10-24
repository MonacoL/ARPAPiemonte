Grafici_path="../Grafici"
today="20200829"
ieri=$(date +%Y%m%d -d "$today - 1 day")

rm -v ${Grafici_path}/storico/VerificaQPF*_${ieri}.png