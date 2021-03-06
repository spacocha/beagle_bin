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
perl ${BIN}/subsample_fasta.pl ${LIST} ${SGE_TASK_ID} ${FASTA} > ${PREFIX}.${SGE_TASK_ID}.fasta
perl ${BIN}/subsample_mat.pl ${MATFILE} ${PREFIX}.${SGE_TASK_ID}.fasta > ${PREFIX}.${SGE_TASK_ID}.mat
mothur "#dist.seqs(fasta=${PREFIX}.${SGE_TASK_ID}.fasta, cutoff=0.15)"
mothur "#degap.seqs(fasta=${PREFIX}.${SGE_TASK_ID}.fasta)"
perl ~/bin/truncate_fasta.pl ${PREFIX}.${SGE_TASK_ID}.ng.fasta 252 > ${PREFIX}.${SGE_TASK_ID}.ng.252.fasta
mothur "#dist.seqs(fasta=${PREFIX}.${SGE_TASK_ID}.ng.252.fasta, cutoff=0.15)"
if [[ -s ${PREFIX}.${SGE_TASK_ID}.dist ]] ; then
    if [[ -s ${PREFIX}.${SGE_TASK_ID}.ng.252.dist ]] ; then
	perl ${BIN}/distribution_based_clustering.pl -d ${PREFIX}.${SGE_TASK_ID}.dist,${PREFIX}.${SGE_TASK_ID}.ng.252.dist -m ${PREFIX}.${SGE_TASK_ID}.mat -output ${PREFIX}.${SGE_TASK_ID}_DBA -dsttype pair -fasta ${PREFIX}.${SGE_TASK_ID}.fasta ${VARSTRING}
    else
        perl ${BIN}/distribution_based_clustering.pl -d ${PREFIX}.${SGE_TASK_ID}.dist -m ${PREFIX}.${SGE_TASK_ID}.mat -output ${PREFIX}.${SGE_TASK_ID}_DBA -dsttype pair -fasta ${PREFIX}.${SGE_TASK_ID}.fasta ${VARSTRING}
    fi;
else
    perl ${BIN}/distribution_based_clustering.pl -m ${PREFIX}.${SGE_TASK_ID}.mat -output ${PREFIX}.${SGE_TASK_ID}_DBA -dsttype pair -fasta ${PREFIX}.${SGE_TASK_ID}.fasta ${VARSTRING}
fi;

rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.lic
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chi
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chisim
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chisimp
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chip
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.chiexp
rm ${PREFIX}.${SGE_TASK_ID}_DBA.Rfile.in