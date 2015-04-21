#! /bin/sh
#$ -S /bin/bash
#$ -t 1-10
# -cwd

#path to file where all of the data is
. ./ML_variables


UNIQUE2=${UNIQUE}.${SGE_TASK_ID}.$1.process

#remove the uneeded files
#only keep the ${UNIQUE2}.err.uchime.mat.lin and ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2

rm ${UNIQUE2}.R_file.chi
rm ${UNIQUE2}.R_file.chisim
rm ${UNIQUE2}.R_file.err
rm ${UNIQUE2}.R_file.fis
rm ${UNIQUE2}.R_file.fisp
rm ${UNIQUE2}.R_file.in
rm ${UNIQUE2}.R_file.lic
rm ${UNIQUE2}.f${FNUMBER}.err
rm ${UNIQUE2}.f${FNUMBER}.err.uchime.fa
rm ${UNIQUE2}.f${FNUMBER}.dst
rm ${UNIQUE2}.f${FNUMBER}.align
rm ${UNIQUE2}.f${FNUMBER}.align.report
rm ${UNIQUE2}.f${FNUMBER}.unaligned.dst
rm ${UNIQUE2}.f${FNUMBER}.mat
rm ${UNIQUE2}.f${FNUMBER}.log
rm ${UNIQUE2}.f${FNUMBER}.fa
rm ${UNIQUE2}.f${FNUMBER}.err.uchime.res