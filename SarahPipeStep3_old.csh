#! /bin/sh
#$ -S /bin/bash
#$ -t 1-55
#$ -o /scratch/ldavid/huge/proc/10_08_27_1/tmp

export CLASSPATH=/home/ldavid/src/freclu/
SEEDFILE=/home/ldavid/alm/projects/huge/data/Chip5.barcodes.f
BARFILE=/home/ldavid/alm/projects/huge/data/Chip5.barcodes.r
#SEED=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILE)
SEED=$(sed -n -e "$SGE_TASK_ID p" $BARFILE)
BIN=/data/spacocha/bin
HOMEBASE=/scratch/ldavid/huge/proc/10_08_27_1/pipe
TMP=/scratch/ldavid/huge/proc/10_08_27_1/tmp

SOLFILEF=/home/ldavid/alm/shared_data/huge/data/100702_HuGE_amaterna_Alm_L3_1_sequence.txt
SOLFILER=/home/ldavid/alm/shared_data/huge/data/100702_HuGE_amaterna_Alm_L3_2_sequence.txt

perl ${BIN}/group_rdp_lib.pl ${HOMEBASE}/total_list.txt ${HOMEBASE}/complete_lib
