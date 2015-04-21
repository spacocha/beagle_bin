#! /bin/sh
#$ -S /bin/bash
#$ -o /scratch/ldavid/huge/proc/10_08_27_1/tmp

BIN=/data/spacocha/bin
HOMEBASE=/scratch/ldavid/huge/proc/10_08_27_1/pipe
TMP=/scratch/ldavid/huge/proc/10_08_27_1/tmp

ls ${HOMEBASE}/*.final.total > ${HOMEBASE}/total_list.txt
perl ${BIN}/group_rdp_lib.pl ${HOMEBASE}/total_list.txt ${HOMEBASE}/complete_lib
