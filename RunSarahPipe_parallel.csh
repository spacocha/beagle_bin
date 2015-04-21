#! /bin/sh
#$ -S /bin/bash
#$ -t 1-40
# -cwd

#path to file where all of the data is
SEEDFILEF=./fa.list

SEEDF=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILEF)

source /etc/profile.d/modules.sh
module load qiime-default
module load R/2.12.1

#define your file paths
#where is the fasta file with all the sequences with trimmed primers
SEQFILE=${SEEDF}

#where the programs are called from
#use the following unless otherwise appropriate
BIN=/data/spacocha/bin

#unique prefix for your analysis
# it can not be a folder name only
# it can include a path which exists where you want to put it.
#example of what I want: /scratch/spacocha/tmp/unique
UNIQUE=./${SEEDF}_process

#the forward reference seqeunce to align to
#this is ok only for 77 bps in length from the end of the U515 primer
#ask if you have something else
FALIGN=/data/spacocha/tmp/new_silva_short_unique_1_151.fa

#filter out the low abundance seqeunces because they don't have statistical power
#this will increase the speed of the error calling program
#consider how many sequences you will need to find statistical power across your sample
#0 and 1 are the same, since it keeps things that are less than or equal to the number
# if you want to remove singletons use 2
FNUMBER=0
#Include a sequence cutoff distance filter
# must range from 0 -1 with 0.1 being a good cut-off
CUTOFF=0.2
#full transfile
TRANS=./unique.trans


#make a new trans file from the full
perl ${BIN}/filter_trans_use_fa.pl ${TRANS} ${SEQFILE} > ${UNIQUE}.trans

#make a first pass OTU table (100% identity OTUs) with filter
perl ${BIN}/OTU2lib_count_trans1.pl ${UNIQUE}.trans ${FNUMBER} > ${UNIQUE}.f${FNUMBER}.mat
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE}.f${FNUMBER}.mat ${SEQFILE} > ${UNIQUE}.f${FNUMBER}.fa

#Align the sequences with mothur
${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${FALIGN},candidate=${UNIQUE}.f${FNUMBER}.fa)"

#make the distance matrix from the aligned sequences
FastTree -nt -makematrix ${UNIQUE}.f${FNUMBER}.align > ${UNIQUE}.f${FNUMBER}.dst
perl ${BIN}/dst2tab_cutoff.pl ${UNIQUE}.f${FNUMBER}.dst ${CUTOFF} > ${UNIQUE}.f${FNUMBER}.dst.tab

#make a distance matrix with unaligned sequences
FastTree -nt -makematrix ${UNIQUE}.f${FNUMBER}.fa > ${UNIQUE}.unaligned.dst
perl ${BIN}/dst2tab_cutoff.pl ${UNIQUE}.unaligned.dst ${CUTOFF} > ${UNIQUE}.unaligned.dst.tab

#join distance files
cat ${UNIQUE}.unaligned.dst.tab ${UNIQUE}.f${FNUMBER}.dst.tab > ${UNIQUE}.both.dst.tab

#make the error checker
perl ${BIN}/find_seq_errors21.pl ${UNIQUE}.both.dst.tab ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.R_file ${UNIQUE}.f${FNUMBER}.err

#create a OTU list
perl ${BIN}/err2list.pl ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.f${FNUMBER}.err > ${UNIQUE}.f${FNUMBER}.err.list

#reduce the number of sequences to just parents
perl ${BIN}/filter_fasta_list.pl ${UNIQUE}.f${FNUMBER}.err.list ${UNIQUE}.f${FNUMBER}.fa err > ${UNIQUE}.f${FNUMBER}.err.fa

#fix fasta to go into uchime to identify chimera
perl ${BIN}/fasta2uchime_2.pl ${UNIQUE}.f${FNUMBER}.mat ${UNIQUE}.f${FNUMBER}.err.fa > ${UNIQUE}.f${FNUMBER}.err.uchime.fa

#Run uchime
${BIN}/uchime4.0.87/bin/uchime4.0.87_i86linux32 --input ${UNIQUE}.f${FNUMBER}.err.uchime.fa --uchimeout ${UNIQUE}.f${FNUMBER}.err.uchime.res --minchunk 20 --abskew 10

#remake the file
perl ${BIN}/filter_mat_uchime.pl ${UNIQUE}.f${FNUMBER}.err.uchime.res ${UNIQUE}.f${FNUMBER}.mat > ${UNIQUE}.f${FNUMBER}.err.uchime.mat

#make the fasta file
perl ${BIN}/fasta2filter_from_mat.pl ${UNIQUE}.f${FNUMBER}.err.uchime.mat ${UNIQUE}.f${FNUMBER}.err.fa > ${UNIQUE}.f${FNUMBER}.err.uchime.fa2

#get the lineage assignments
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${UNIQUE}.f${FNUMBER}.err.uchime.fa2 -o ${UNIQUE}.f${FNUMBER}.err.uchime.rdp -f fixrank

perl ${BIN}/rdp_fixrank2SM2.pl ${UNIQUE}.f${FNUMBER}.err.uchime.rdp 0.5 ${UNIQUE}.f${FNUMBER}.err.uchime.mat > ${UNIQUE}.f${FNUMBER}.err.uchime.mat.lin