#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default
. $1

echo "${QIIMEFILE}\n";
#reduce sequences by only using 

~/bin/usearch6.0.307_i86linux32 -cluster_fast ${UNIQUE}.fa -id 0.9 -uc ${UNIQUE}.90.uc

perl ${BIN}/UC2list2.pl ${UNIQUE}.90.uc > ${PCLUSTOUTPUT}



