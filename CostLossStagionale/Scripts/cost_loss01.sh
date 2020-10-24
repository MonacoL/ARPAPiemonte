#! /bin/bash

flagLocal=1
root_path="/home/monacoarpa/Desktop/ARPA/CostLossStagionale"
if [ $flagLocal -eq 0 ]; then
    root_path="/home/meteo/proc/CostLoss"
fi
dati_path="$root_path/dati"
script_path="$root_path/Scripts"
Grafici_path="$root_path/Grafici"
work_path="$root_path/InputTemp"
txt_file="$root_path/ToShowOnPage.txt"
odino_path=""


for entry in "$dati_path"/*
do
  nomefile=`echo ${entry##*/}|cut -c2-36``echo ${entry##*/}|cut -c42-55`
  cp $entry $work_path/$nomefile
done

Rscript $script_path/genera_grafici01.R $work_path $Grafici_path $txt_file