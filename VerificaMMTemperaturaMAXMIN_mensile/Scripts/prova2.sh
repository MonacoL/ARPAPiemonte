today=`date +%Y%m%d`
dataf=$(date +%Y%m%d -d "$today - 2 day")
datai=$(date +%Y%m%d -d "$dataf - 30 day")

#Spezza la data 
ANNOi=`echo $datai|cut -c1-4` 
ANNOf=`echo $dataf|cut -c1-4`
MESEi=`echo $datai|cut -c5-6`
MESEf=`echo $dataf|cut -c5-6`

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
echo $dal #> $dalal_path/DalAl.txt
echo $al #>> $dalal_path/DalAl.txt