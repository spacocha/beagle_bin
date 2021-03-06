#! /bin/sh
#$ -S /bin/bash
# -cwd

#path to file where all of the data is
#load in the variables from the second command line input
. ./$1

source /etc/profile.d/modules.sh
module load qiime-default
module load R/2.12.1
module load mothur

date +"%m-%d-%y"
date +"%T"

#process number is the first command line variable
UNIQUE2=${UNIQUE}.${SGE_TASK_ID}.process

#combines unique files
perl ${BIN}/fasta2unique_table5.pl ${QIIMEFILE} ${UNIQUE}

#makes a fake OTU list with all entries on the first line
perl ${BIN}/fasta2list_single.pl ${UNIQUE}.fa > ${PCLUSTOUTPUT}

#make filtered fa, mat and trans files for each process
perl ${BIN}/list_through_filter_from_mat3.pl ${PCLUSTOUTPUT} ${SGE_TASK_ID} ${UNIQUE}.fa ${UNIQUE}.trans ${FNUMBER} ${UNIQUE2}.f${FNUMBER} ${COMBREPS}

if [[ -s ${UNIQUE2}.f${FNUMBER}.fa ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.fa is empty; stopped program after list_through_filter_from_mat.pl" ;
exit;
fi ;

#Align the sequences with mothur
mothur "#align.seqs(template=${FALIGN},candidate=${UNIQUE2}.f${FNUMBER}.fa)" > ${UNIQUE2}.f${FNUMBER}.mothurout

if [[ -s ${UNIQUE2}.f${FNUMBER}.align ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.align is empty; stopped program after mothur:align.seqs" ;
exit;
fi ;

#make the distance matrix from the aligned sequences
FastTree -nt -makematrix ${UNIQUE2}.f${FNUMBER}.align > ${UNIQUE2}.f${FNUMBER}.dst

if [[ -s ${UNIQUE2}.f${FNUMBER}.dst ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.dst is empty; stopped program after FastTree" ;
exit;
fi ;

FastTree -nt -makematrix ${UNIQUE2}.f${FNUMBER}.fa > ${UNIQUE2}.f${FNUMBER}.unaligned.dst

if [[ -s ${UNIQUE2}.f${FNUMBER}.unaligned.dst ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.unaligned.dst is empty; stopped program after FastTree" ;
exit;
fi ;

perl ${BIN}/${ERRORPROGRAM} -d ${UNIQUE2}.f${FNUMBER}.dst,${UNIQUE2}.f${FNUMBER}.unaligned.dst -m ${UNIQUE2}.f${FNUMBER}.mat -out ${UNIQUE2}.f${FNUMBER} -dist ${CUTOFF} ${VARSTRING}

if [[ -s ${UNIQUE2}.f${FNUMBER}.err ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err is empty; stopped program after ${ERRORPROGRAM}" ;
exit;
fi ;

perl ${BIN}/err2list3.pl ${UNIQUE2}.f${FNUMBER}.err > ${UNIQUE2}.f${FNUMBER}.err.list
perl ${BIN}/list2mat.pl ${UNIQUE2}.f${FNUMBER}.mat ${UNIQUE2}.f${FNUMBER}.err.list eco > ${UNIQUE2}.f${FNUMBER}.err.list.mat
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE2}.f${FNUMBER}.err.list.mat ${UNIQUE}.fa > ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa


#get the lineage assignments
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa -o ${UNIQUE2}.f${FNUMBER}.err.list.mat.rdp -f fixrank

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.uchime.rdp ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.uchime.rdp is empty; stopped program after rdp" ;
exit;
fi ;

perl ${BIN}/rdp_fixrank2SM2.pl ${UNIQUE2}.f${FNUMBER}.err.list.mat.rdp 0.5 ${UNIQUE2}.f${FNUMBER}.err.list.mat > ${UNIQUE2}.f${FNUMBER}.err.list.mat.lin

#remove the uneeded files
#only keep the ${UNIQUE2}.err.uchime.mat.lin and ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2

date +"%m-%d-%y"
date +"%T"

rm ${UNIQUE2}.R_file.chi
rm ${UNIQUE2}.R_file.chisim
rm ${UNIQUE2}.R_file.err
rm ${UNIQUE2}.R_file.fis
rm ${UNIQUE2}.R_file.fisp
rm ${UNIQUE2}.R_file.in
rm ${UNIQUE2}.R_file.lic
