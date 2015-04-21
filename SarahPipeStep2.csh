#! /bin/sh
#$ -S /bin/bash
#$ -t 1-41

export CLASSPATH=/home/ldavid/src/freclu/
BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2
OUTBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2/False_012711_dir
TMPFOL=/data/spacocha/tmp

SEEDFILEF=${OUTBASE}/SEEDST2F.txt
SEEDFILER=${OUTBASE}/SEEDST2R.txt
JBARFILE=${OUTBASE}/BARFILEST2.txt
LIBFILE=${OUTBASE}/LIBST2.txt
#this file has been check for unique seqs and manually curated
FALIGN=new_silva_short_unique.f
#this file has not been manually curated and it's for the old set up
#make a new file and manually curate it before running new system
RALIGN=new_silva_short.r

SEEDF=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILEF)
SEEDR=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILER)
BAR=$(sed -n -e "$SGE_TASK_ID p" $JBARFILE)
LIB=$(sed -n -e "$SGE_TASK_ID p" $LIBFILE)

#parse for quality
perl ${BIN}/parse_16S_Solexa_PEIV.pl ${SEEDF} ${SEEDR} ${LIB} > ${OUTBASE}/${LIB}_${BAR}.tab

#make the data into a fasta files
#forward
perl ${BIN}/tab2fasta.pl ${OUTBASE}/${LIB}_${BAR}.tab 1 3 > ${OUTBASE}/${LIB}_${BAR}_F.fa

#reverse
perl ${BIN}/tab2fasta.pl ${OUTBASE}/${LIB}_${BAR}.tab 1 5 > ${OUTBASE}/${LIB}_${BAR}_R.fa

#align the sequences to a seed
${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${TMPFOL}/${FALIGN},candidate=${OUTBASE}/${LIB}_${BAR}_F.fa)"

${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${TMPFOL}/${RALIGN},candidate=${OUTBASE}/${LIB}_${BAR}_R.fa)"
