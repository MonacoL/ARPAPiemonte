today=`date +%Y%m%d`
MESEi=`echo $today|cut -c5-6`
nove_mesi=(GEN FEB MAR APR MAG GIU LUG AGO SET OTT NOV DIC)
echo $MESEi
echo ${nove_mesi[$((MESEi-3))]} > prova.txt
echo ${nove_mesi[$((MESEi-4))]} >> prova.txt