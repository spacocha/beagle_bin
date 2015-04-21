#! /bin/sh
#$ -S /bin/bash
#$ -o /scratch/ldavid/huge/proc/10_08_27_1/tmp

BARFILE=/home/ldavid/alm/projects/huge/data/Chip5.barcodes.r
BIN=/data/spacocha/bin
HOMEBASE=/scratch/ldavid/huge/proc/10_08_27_1/pipe
TMP=/scratch/ldavid/huge/proc/10_08_27_1/tmp

SOLFILEF=/home/ldavid/alm/shared_data/huge/data/100702_HuGE_amaterna_Alm_L3_1_sequence.txt
SOLFILER=/home/ldavid/alm/shared_data/huge/data/100702_HuGE_amaterna_Alm_L3_2_sequence.txt

#divide the whole by barcodes
perl ${BIN}/divide_16S_Solexa4.pl ${SOLFILEF} ${BARFILE} ${HOMEBASE}/div1
perl ${BIN}/divide_16S_Solexa4.pl ${SOLFILER} ${BARFILE} ${HOMEBASE}/div2
