#! /bin/sh
#$ -S /bin/bash
#$ -t 1-5

#define paths to your samples
#Where is the list of split fastq files that you want to process
SEEDFILEF=./test.tab
SOLFILEF=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILEF)

source /etc/profile.d/modules.sh
module load qiime-default

#define your file paths
#Where it the assoicated mapping file (they all must have the same mapping file)
MAPFILE=../mapping_file_SARAHsamples_All.txt
#the oligo file (they all must have the same oligo file)
OLIGO=oligos.tab
#where the programs are called from
BIN=/data/spacocha/bin
#where you want to put the output of the analysis (must have either ${SOLFILEF} or ${SGE_TASK_ID} in the name)
UNIQUE=${SGE_TASK_ID}_unique

#Make the fake barcode read
perl ${BIN}/fastq2Qiime_barcode.pl ${SOLFILEF} > ${UNIQUE}_bar.txt

#Split your fastq file with qiime
split_libraries_fastq.py -i ${SOLFILEF} -b ${UNIQUE}_bar.txt -o ${UNIQUE}_output -m ${MAPFILE} --barcode_type 7 --min_per_read_length 100 --last_bad_quality_char E

#Trim the sequences with mothur
${BIN}/mothur/Mothur.source/mothur "#trim.seqs(fasta=${UNIQUE}_output/seqs.fna, oligos=${OLIGO})"

#revert the names from mothur to qiime names
perl ${BIN}/revert_names_mothur.pl ${UNIQUE}_output/seqs.fna ${UNIQUE}_output/seqs.trim.fasta > ${UNIQUE}_output/seqs.trim.names.fasta

#Now pick otus from the qiime greengenesg ref
python /home/software/python/python-27/software/qiime/qiime-1.3.0/bin//pick_otus.py -i ${UNIQUE}_output/seqs.trim.names.fasta -o ${UNIQUE}_output/ucrC/ -r /data/spacocha/Qiime_dir/gg_otus_4feb2011/rep_set/gg_97_otus_4feb2011.fasta -C -m uclust_ref

#make an otu table
python /home/software/python/python-27/software/qiime/qiime-1.3.0/bin//make_otu_table.py -i ${UNIQUE}_output/ucrC/seqs.trim.names_otus.txt -t /data/spacocha/Qiime_dir/gg_otus_4feb2011/taxonomies/greengenes_tax.txt -o ${UNIQUE}_output/ucrC/seqs_otus.mat