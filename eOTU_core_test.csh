#! /bin/sh
#$ -S /bin/bash
# -cwd

#path to file where all of the data is
. ./ML_variables

source /etc/profile.d/modules.sh
module load qiime-default
module load R/2.12.1
SGE_TASK_ID=1

UNIQUE2=${UNIQUE}.${SGE_TASK_ID}.99.process

#make filtered fa, mat and trans files for each process
perl ${BIN}/list_through_filter_from_mat.pl ${UNIQUE}.final_list 99 $1 ${UNIQUE}.fa ${UNIQUE}.trans ${FNUMBER} ${UNIQUE2}.f${FNUMBER}

if [[ -s ${UNIQUE2}.f${FNUMBER}.fa ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.fa is empty; stopped program after list_through_filter_from_mat.pl" ;
exit;
fi ;

#Align the sequences with mothur
${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${FALIGN},candidate=${UNIQUE2}.f${FNUMBER}.fa)"

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

#make the error checker
perl ${BIN}/find_seq_errors23_2.pl -d ${UNIQUE2}.f${FNUMBER}.dst,${UNIQUE2}.f${FNUMBER}.unaligned.dst -m ${UNIQUE2}.f${FNUMBER}.mat -R ${UNIQUE2}.R_file -out ${UNIQUE2}.f${FNUMBER}.err -log ${UNIQUE2}.f${FNUMBER}.log -abund 0 -correl 0.8 -KLdiv 0.2 -smfrac 0.00001

if [[ -s ${UNIQUE2}.f${FNUMBER}.err ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err is empty; stopped program after find_seq_errors22_2.pl" ;
exit;
fi ;

#make a new fasta file from the errs with only the parents in a special uchime format incluing abundances
perl ${BIN}/err2uchime.pl ${UNIQUE2}.f${FNUMBER}.err ${UNIQUE2}.f${FNUMBER}.fa ${UNIQUE2}.f${FNUMBER}.mat > ${UNIQUE2}.f${FNUMBER}.err.uchime.fa

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.uchime.fa ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.uchime.fa is empty; stopped program after err2uchime.pl" ;
exit;
fi ;

#Run uchime to find chimeras
${BIN}/uchime4.0.87/bin/uchime4.0.87_i86linux32 --input ${UNIQUE2}.f${FNUMBER}.err.uchime.fa --uchimeout ${UNIQUE2}.f${FNUMBER}.err.uchime.res --minchunk 20 --abskew 10

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.uchime.res ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.uchime.res is empty; stopped program after uchime" ;
exit;
fi ;

#filter the fasta file to remove chimeras
perl ${BIN}/filter_fasta_uchime.pl ${UNIQUE2}.f${FNUMBER}.err.uchime.res ${UNIQUE2}.f${FNUMBER}.err.uchime.fa > ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2 ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.uchime.fa2 is empty; stopped program after filter_fasta_uchime.pl" ;
exit;
fi ;

#get the lineage assignments
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2 -o ${UNIQUE2}.f${FNUMBER}.err.uchime.rdp -f fixrank

if [[ -s ${UNIQUE2}.f${FNUMBER}.err.uchime.rdp ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE2}.f${FNUMBER}.err.uchime.rdp is empty; stopped program after rdp" ;
exit;
fi ;

perl ${BIN}/rdp_fixrank2SM2.pl ${UNIQUE2}.f${FNUMBER}.err.uchime.rdp 0.5 ${UNIQUE2}.f${FNUMBER}.mat > ${UNIQUE2}.err.uchime.mat.lin

#remove the uneeded files
#only keep the ${UNIQUE2}.err.uchime.mat.lin and ${UNIQUE2}.f${FNUMBER}.err.uchime.fa2

rm ${UNIQUE2}.R_file.chi
rm ${UNIQUE2}.R_file.chisim
rm ${UNIQUE2}.R_file.err
rm ${UNIQUE2}.R_file.fis
rm ${UNIQUE2}.R_file.fisp
rm ${UNIQUE2}.R_file.in
rm ${UNIQUE2}.R_file.lic
rm ${UNIQUE2}.f${FNUMBER}.err.uchime.fa
rm ${UNIQUE2}.f${FNUMBER}.dst
rm ${UNIQUE2}.f${FNUMBER}.align
rm ${UNIQUE2}.f${FNUMBER}.align.report
rm ${UNIQUE2}.f${FNUMBER}.unaligned.dst
rm ${UNIQUE2}.f${FNUMBER}.mat
rm ${UNIQUE2}.f${FNUMBER}.log
rm ${UNIQUE2}.f${FNUMBER}.fa
rm ${UNIQUE2}.f${FNUMBER}.err.uchime.res