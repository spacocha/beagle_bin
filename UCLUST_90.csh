#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default
. $1

echo "${QIIMEFILE}\n";
#prepare the file for uclust
perl ${BIN}/fasta2uchime_2.pl ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.fa > ${UNIQUE}.ab.fa

#progressively cluster, but 0.99 doesn't do anything,  so start with 0.98
uclust --input ${UNIQUE}.ab.fa --id 0.9 --uc ${UNIQUE}.90.uc --maxrejects 500 --maxaccepts 20

perl ${BIN}/UC2list2.pl ${UNIQUE}.90.uc > ${PCLUSTOUTPUT}



