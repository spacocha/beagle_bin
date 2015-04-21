#! /bin/sh
#$ -S /bin/bash
#$ -t 1-250

#make all the variable here so they are easy to change
BIN=/home/spacocha/bin
HOMEBASE=/scratch/spacocha/100514_B
OUTBASE=/scratch/spacocha/100514_B/OTU_test_021111
#this file lists all the .dat files for man chisq
SEEDFILE=falist
SEED=$(sed -n -e "$SGE_TASK_ID p" ${OUTBASE}/$SEEDFILE)
REF=new_silva_short_172.f.fa
TMPFOL=/data/spacocha/tmp
#run chimera slayer
${BIN}/mothur/Mothur.source/mothur "#chimera.slayer(fasta=${OUTBASE}/${SEED},template=${TMPFOL}/${REF},minsnp=100,realign=T)"

