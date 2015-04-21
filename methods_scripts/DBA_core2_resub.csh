#! /bin/sh
#$ -S /bin/bash
# -cwd

#path to file where all of the data is
#load in the variables from the second command line input
. ./$1

#load in the modules necessary for this analysis
source /etc/profile.d/modules.sh
module add R/2.12.1
module load mothur

#make this work- it's what I want to put in the paper
perl ${BIN}/distribution_based_clustering.pl -d ${PREFIX}.${SGE_TASK_ID}.dist,${PREFIX}.${SGE_TASK_ID}.ng.dist -m ${PREFIX}.${SGE_TASK_ID}.mat -output ${PREFIX}.${SGE_TASK_ID}_DBA -dsttype pair -verbose -fasta ${PREFIX}.${SGE_TASK_ID}.fasta -old ${PREFIX}.${SGE_TASK_ID}_DBA.err

rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.lic
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chi
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chisim
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chisimp
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chip
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chiexp
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.in