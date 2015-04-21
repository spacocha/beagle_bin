#! /bin/sh
#$ -S /bin/bash
#$ -t 1-250

BIN=/home/spacocha/bin
HOMEBASE=/scratch/spacocha/101222_dir/Mouse_dir2/OTU_test_021111
OUTBASE=/scratch/spacocha/101222_dir/Mouse_dir2/OTU_test_021111
TMPFOL=/data/spacocha/tmp

SEEDFILEF=${OUTBASE}/falist
FALIGN=new_silva_short_172.f.fa
RALIGN=new_silva_short.r

SEEDF=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILEF)

#slay the chimeras
${BIN}/mothur/Mothur.source/mothur "#chimera.slayer(fasta=${OUTBASE}/${SEEDF},template=${TMPFOL}/${FALIGN},minsnp=50,realign=F)"

