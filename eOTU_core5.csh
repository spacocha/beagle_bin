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

#process number is the first command line variable
UNIQUE2=${UNIQUE}.${SGE_TASK_ID}.process


#make filtered fa, mat and trans files for each process
perl ${BIN}/list_through_filter_from_mat3.pl ${PCLUSTOUTPUT} ${SGE_TASK_ID} ${UNIQUE}.fa ${UNIQUE}.trans ${FNUMBER} ${UNIQUE2}.f${FNUMBER} ${COMBREPS}

if [[ -s ${UNIQUE2}.f${FNUMBER}.fa ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.fa is empty; stopped program after list_through_filter_from_mat.pl" ;
exit;
fi ;

#Align the sequences with mothur
mothur "#align.seqs(template=${FALIGN},candidate=${UNIQUE2}.f${FNUMBER}.fa)"

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

perl ${BIN}/${ERRORPROGRAM} -d ${UNIQUE2}.f${FNUMBER}.dst,${UNIQUE2}.f${FNUMBER}.unaligned.dst -m ${UNIQUE2}.f${FNUMBER}.mat -R ${UNIQUE2}.R_file -out ${UNIQUE2}.f${FNUMBER}.err -log ${UNIQUE2}.f${FNUMBER}.log -dist ${CUTOFF} ${VARSTRING}

if [[ -s ${UNIQUE2}.f${FNUMBER}.err ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err is empty; stopped program after ${ERRORPROGRAM}" ;
exit;
fi ;

#make a new fasta file from the errs with only the parents in a special uchime format incluing abundances
perl ${BIN}/err2list2.pl ${UNIQUE2}.f${FNUMBER}.err > ${UNIQUE2}.f${FNUMBER}.err.list
perl ${BIN}/list2mat.pl ${UNIQUE2}.f${FNUMBER}.mat ${UNIQUE2}.f${FNUMBER}.err.list eco > ${UNIQUE2}.f${FNUMBER}.err.list.mat
perl ${BIN}/fasta2filter_from_mat.pl  ${UNIQUE2}.f${FNUMBER}.err.list.mat ${UNIQUE2}.f${FNUMBER}.fa > ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa
perl ${BIN}/fasta2uchime_mat.pl ${UNIQUE2}.f${FNUMBER}.err.list.mat ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa > ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime
 
if [[ -s ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime is empty; stopped program after err2uchime.pl" ;
exit;
fi ;

#Run uchime to find chimeras Not sure if these abskew and minchunk apply to larger sizes
${BIN}/uchime4.0.87/bin/uchime4.0.87_i86linux32 --input ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime --uchimeout ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.res --minchunk 20 --abskew 10

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.res ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.res is empty; stopped program after uchime" ;
exit;
fi ;

#filter the fasta file to remove chimeras
perl ${BIN}/filter_fasta_uchime.pl ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.res ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa > ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.fa2

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.fa2 ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.uchime.fa2 is empty; stopped program after filter_fasta_uchime.pl" ;
exit;
fi ;

#get the lineage assignments
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.fa2 -o ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.rdp -f fixrank

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.rdp ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.res is empty; stopped program after rdp" ;
exit;
fi ;

perl ${BIN}/rdp_fixrank2SM2.pl ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.rdp 0.5 ${UNIQUE2}.f${FNUMBER}.err.list.mat > ${UNIQUE2}.f${FNUMBER}.err.list.mat.lin 

#remove the uneeded files
#only keep the ${UNIQUE2}.err.uchime.mat.lin and ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2

rm ${UNIQUE2}.R_file.chi
rm ${UNIQUE2}.R_file.chisim
rm ${UNIQUE2}.R_file.err
rm ${UNIQUE2}.R_file.fis
rm ${UNIQUE2}.R_file.fisp
rm ${UNIQUE2}.R_file.in
rm ${UNIQUE2}.R_file.lic
rm ${UNIQUE2}.f${FNUMBER}.align
rm ${UNIQUE2}.f${FNUMBER}.dst
rm ${UNIQUE2}.f${FNUMBER}.unalign.dst
rm ${UNIQUE2}.f${FNUMBER}.mat
${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime
${UNIQUE2}.f${FNUMBER}.err.list.mat
rm ${UNIQUE2}.f${FNUMBER}.err.list.mat.fa
${UNIQUE2}.f${FNUMBER}.err.list.mat.fa.uchime.res