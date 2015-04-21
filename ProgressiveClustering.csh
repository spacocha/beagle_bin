#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default

#define your file paths
#where is the fasta file with all the sequences with trimmed primers
SEQFILE=../013112_dir/H_unique_output/unique.fa
MATFILE=../020212_dir/H_unique_output/unique.mat

#where the programs are called from
#use the following unless otherwise appropriate
BIN=/home/spacocha/bin

#unique prefix for your analysis
# it can not be a folder name only
# it can include a path which exists where you want to put it.
#example of what I want: /scratch/spacocha/tmp/unique
UNIQUE=./H_unique_output/unique

#prepare the file for uclust
perl ~/bin/fasta2uchime_2.pl ${MATFILE} ${SEQFILE} > ${UNIQUE}.ab.fa

#progressively cluster, but 0.99 doesn't do anything,  so start with 0.98
uclust --input ${SEQFILE} --id 0.98 --uc ${UNIQUE}.98.uc --maxrejects 500 --maxaccepts 20

uclust --input ${SEQFILE} --uc2fasta ${UNIQUE}.98.uc  --output ${UNIQUE}.98.fa --types S

perl ~/bin/fasta_remove_seed.pl ${UNIQUE}.98.fa > ${UNIQUE}.98.fa2

perl ~/bin/UC2list.pl ${UNIQUE}.98.uc > ${UNIQUE}.98.uc.list
#repeat for 97-90

for i in 97 96 95 94 93 92 91 90
do
before=`expr $i + 1`
uclust --input ${UNIQUE}.${before}.fa2 --id 0.${i} --uc ${UNIQUE}.${i}.uc --maxrejects 500 --maxaccepts 20

uclust --input ${UNIQUE}.${before}.fa2 --uc2fasta ${UNIQUE}.${i}.uc  --output ${UNIQUE}.${i}.fa --types S

perl ~/bin/fasta_remove_seed.pl ${UNIQUE}.${i}.fa > ${UNIQUE}.${i}.fa2

perl ~/bin/UC2list.pl ${UNIQUE}.${i}.uc > ${UNIQUE}.${i}.uc.list

done

perl ~/bin/merge_progressive_clustering.pl ${UNIQUE}*.uc.list > ${UNIQUE}.final_list

perl ~/bin/list2parallel_processing.pl ${UNIQUE}.final_list ${SEQFILE} ${UNIQUE}.parallel
