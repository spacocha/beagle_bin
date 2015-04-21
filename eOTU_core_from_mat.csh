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


#align the sequences
mothur "#align.seqs(template=${FALIGN},candidate=${PREFIXFA}.fasta)"

if [[ -s ${PREFIXFA}.align ]] ; then
NULLVAR=0
else
echo "PipeStop error:${PREFIXFA}.align is empty; stopped program after mothur:align.seqs" ;
exit;
fi ;

perl ${BIN}/${ERRORPROGRAM} -d ${PREFIXFA}.dist -m ${PREFIXMAT}.mat -R ${PREFIXFA}.R_file -out ${PREFIXFA}.err -log ${PREFIXFA}.log -dist ${CUTOFF} ${VARSTRING}

if [[ -s ${PREFIXFA}.err ]] ; then
NULLVAR=0
else
echo "PipeStop error:${PREFIXFA}.err is empty; stopped program after ${ERRORPROGRAM}" ;
exit;
fi ;

#make a new fasta file from the errs with only the parents in a special uchime format incluing abundances
perl ${BIN}/err2uchime.pl ${PREFIXFA}.err ${UNIQUE2}.f${FNUMBER}.fa ${PREFIXMAT}.mat > ${PREFIXFA}.err.uchime.fa

if [[ -s ${PREFIXFA}.err.uchime.fa ]] ; then
NULLVAR=0
else
echo "PipeStop error:${PREFIXFA}.err.uchime.fa is empty; stopped program after err2uchime.pl" ;
exit;
fi ;

#Run uchime to find chimeras
${BIN}/uchime4.0.87/bin/uchime4.0.87_i86linux32 --input ${PREFIXFA}.err.uchime.fa --uchimeout ${PREFIXFA}.err.uchime.res --minchunk 20 --abskew 10

if [[ -s ${PREFIXFA}.err.uchime.res ]] ; then
NULLVAR=0
else
echo "PipeStop error:${PREFIXFA}.err.uchime.res is empty; stopped program after uchime" ;
exit;
fi ;

#filter the fasta file to remove chimeras
perl ${BIN}/filter_fasta_uchime.pl ${PREFIXFA}.err.uchime.res ${PREFIXFA}.err.uchime.fa > ${PREFIXFA}.err.uchime.fa2

if [[ -s ${PREFIXFA}.err.uchime.fa2 ]] ; then
NULLVAR=0
else
echo "PipeStop error:${PREFIXFA}.err.uchime.fa2 is empty; stopped program after filter_fasta_uchime.pl" ;
exit;
fi ;

#get the lineage assignments
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${PREFIXFA}.err.uchime.fa2 -o ${PREFIXFA}.err.uchime.rdp -f fixrank

if [[ -s ${PREFIXFA}.err.uchime.rdp ]] ; then
NULLVAR=0
else
echo "PipeStop error:${PREFIXFA}.err.uchime.rdp is empty; stopped program after rdp" ;
exit;
fi ;

perl ${BIN}/rdp_fixrank2SM2.pl ${PREFIXFA}.err.uchime.rdp 0.5 ${PREFIXMAT}.mat > ${PREFIXFA}.err.uchime.mat.lin

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
rm ${UNIQUE2}.f${FNUMBER}.fa
rm ${UNIQUE2}.f${FNUMBER}.err.uchime.res