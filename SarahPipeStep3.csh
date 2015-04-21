#! /bin/sh
#$ -S /bin/bash

#not exactly sure what it means, but this is necessary to run FreClu on the cluster
export CLASSPATH=/home/ldavid/src/freclu/
BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2
OUTBASE=/scratch/spacocha/101222_dir/Chicken_dir
TMPFOL=/data/spacocha/tmp

#Do this before running
#cat ${OUTBASE}/*F.align > ${OUTBASE}/all_aligned.F.fa
#cat ${OUTBASE}/*.tab > ${OUTBASE}/all_tab

#make all the variable here so they are easy to change
ALIGN=all_aligned.F.fa
SEED=all_tab
THRESH=75
LOG=log.txt
STAT=stat.txt
#keep only the aligned sequences of specific length and trim the sequences to the right length
perl ${BIN}/add_aligned_seq.pl ${OUTBASE}/${ALIGN} ${OUTBASE}/${SEED} ${THRESH} ${OUTBASE}/${LOG} ${OUTBASE}/${STAT}> ${OUTBASE}/${SEED}.med.tab

#Make unique IDs
perl ${BIN}/qual_checker3.pl ${OUTBASE}/${SEED}.med.tab 3 4 7 ${OUTBASE}/${SEED}.med.ID.qc

#Divide Unique ID's for ChimeraSlayer
perl ${BIN}/split_fasta.pl ${OUTBASE}/${SEED}.med.ID.qc.fa 250

