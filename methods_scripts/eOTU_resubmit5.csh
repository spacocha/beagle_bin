#! /bin/sh
#$ -S /bin/bash
# -cwd

#path to file where all of the data is
#load in the variables from the second command line input
. ./$1

source /etc/profile.d/modules.sh
module load qiime-default
module load R/2.12.1
module load mothur

#process number is the first command line variable
UNIQUE2=${UNIQUE}.${SGE_TASK_ID}.process


if [[ -s ${UNIQUE2}.f${FNUMBER}.unaligned.dst ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.unaligned.dst is empty; stopped program after FastTree" ;
exit;
fi ;

perl ${BIN}/${ERRORPROGRAM} -d ${UNIQUE2}.f${FNUMBER}.dst,${UNIQUE2}.f${FNUMBER}.unaligned.dst -m ${UNIQUE2}.f${FNUMBER}.mat -out ${UNIQUE2}.f${FNUMBER} -dist ${CUTOFF} ${VARSTRING} -old

if [[ -s ${UNIQUE2}.f${FNUMBER}.err ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err is empty; stopped program after ${ERRORPROGRAM}" ;
exit;
fi ;

rm ${UNIQUE2}.f${FNUMBER}.R_file.chi
rm ${UNIQUE2}.f${FNUMBER}.R_file.chisim
rm ${UNIQUE2}.f${FNUMBER}.R_file.err
rm ${UNIQUE2}.f${FNUMBER}.R_file.fis
rm ${UNIQUE2}.f${FNUMBER}.R_file.fisp
rm ${UNIQUE2}.f${FNUMBER}.R_file.in
rm ${UNIQUE2}.f${FNUMBER}.R_file.lic
if [[ $CLEAN ]] ; then
    rm ${UNIQUE2}.f${FNUMBER}.dst
    rm ${UNIQUE2}.f${FNUMBER}.align
    rm ${UNIQUE2}.f${FNUMBER}.align.report
    rm ${UNIQUE2}.f${FNUMBER}.unaligned.dst
    rm ${UNIQUE2}.f${FNUMBER}.mat
    rm ${UNIQUE2}.f${FNUMBER}.fa
fi ;