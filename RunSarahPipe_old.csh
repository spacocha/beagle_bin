#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default
module load R/2.12.1

#define your file paths
#where is the fasta file with all the sequences with trimmed primers
SEQFILE=
#where the programs are called from
BIN=/data/spacocha/bin
#where you want to put the output of the analysis
UNIQUE=
#the forward reference seqeunce to align to
FALIGN=/data/spacocha/tmp/new_silva_short_unique_1_151.fa
#the number of libraries (a good number to use to filter your samples)
FNUMBER=
#Include a seqeunce cutoff distance filter
CUTOFF=

#reduce sequences by only using 
perl ${BIN}/fasta2unique_table3.pl ${SEQFILE} ${UNIQUE}

#Align the sequences with mothur
${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${FALIGN},candidate=${UNIQUE}.fa)"

#make a first pass OTU table (100% identity OTUs) with filter
perl ${BIN}/OTU2lib_count_trans1.pl ${UNIQUE}.trans ${FNUMBER} > ${UNIQUE}.f${FNUMBER}.mat

#filter the fasta both unaligned and aligned
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.fa > ${UNIQUE}.f${FNUMBER}.fa 
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.align > ${UNIQUE}.f${FNUMBER}.align.fa

#make the distance matrix from the aligned sequences
FastTree -nt -makematrix ${UNIQUE}.f${FNUMBER}.align.fa > ${UNIQUE}.f${FNUMBER}.dst
perl ${BIN}/dst2tab_cutoff.pl ${UNIQUE}.f${FNUMBER}.dst ${CUTOFF} > ${UNIQUE}.f${FNUMBER}.dst.tab

#make a distance matrix with unaligned sequences
FastTree -nt -makematrix ${UNIQUE}.f${FNUMBER}.fa > ${UNIQUE}.unaligned.dst
perl ${BIN}/dst2tab_cutoff.pl ${UNIQUE}.unaligned.dst ${CUTOFF} > ${UNIQUE}.unaligned.dst.tab

#join distance files
cat ${UNIQUE}.unaligned.dst.tab ${UNIQUE}.f${FNUMBER}.dst.tab > ${UNIQUE}.both.dst.tab

#make the error checker
perl ${BIN}/find_seq_errors20.pl ${UNIQUE}.both.dst.tab ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.f${FNUMBER}.fa ${UNIQUE}.R_file ${UNIQUE}.f${FNUMBER}.err

#Change the sequencing errors
perl ${BIN}/change_seq_errors8.pl ${UNIQUE}.f${FNUMBER}.err ${UNIQUE}.trans > ${UNIQUE}.f${FNUMBER}.err.trans

#make the mat file
perl ${BIN}/OTU2lib_count_trans1.pl ${UNIQUE}.f${FNUMBER}.err.trans ${FNUMBER} > ${UNIQUE}.f${FNUMBER}.err.mat

#make the fasta file
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE}.f${FNUMBER}.err.mat ${UNIQUE}.f${FNUMBER}.fa > ${UNIQUE}.f${FNUMBER}.err.fa

#fix fasta to go into uchime to identify chimera
perl ${BIN}/fasta2uchime_2.pl ${UNIQUE}.f${FNUMBER}.err.mat ${UNIQUE}.f${FNUMBER}.err.fa > ${UNIQUE}.f${FNUMBER}.err.uchime.fa

#Run uchime
${BIN}/uchime4.0.87/bin/uchime4.0.87_i86linux32 --input ${UNIQUE}.f${FNUMBER}.err.uchime.fa --uchimeout ${UNIQUE}.f${FNUMBER}.err.uchime.res --minchunk 20 --abskew 10

#remove chimera
perl ${BIN}/remove_chimera.pl ${UNIQUE}.f${FNUMBER}.err.uchime.res ${UNIQUE}.f${FNUMBER}.err.trans > ${UNIQUE}.f${FNUMBER}.err.uchime.trans

#remake the file
perl ${BIN}/OTU2lib_count_trans1.pl ${UNIQUE}.f${FNUMBER}.err.uchime.trans  ${FNUMBER} > ${UNIQUE}.f${FNUMBER}.err.uchime.mat

#make the fasta file
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE}.f${FNUMBER}.err.uchime.mat ${UNIQUE}.f${FNUMBER}.err.fa > ${UNIQUE}.f${FNUMBER}.err.uchime.fa2

#get the lineage assignments
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${UNIQUE}.f${FNUMBER}.err.uchime.fa2 -o ${UNIQUE}.f${FNUMBER}.err.uchime.rdp -f fixrank

perl ${BIN}/rdp_fixrank2SM2.pl ${UNIQUE}.f${FNUMBER}.err.uchime.rdp 0.5 ${UNIQUE}.f${FNUMBER}.err.uchime.mat > ${UNIQUE}.f${FNUMBER}.err.uchime.mat.lin