#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default

#define your file paths
#where is the fastq file you want to process
SOLFILEF=
#Where it the assoicated mapping file
MAPFILE=
#the oligo file
OLIGO=
#where the programs are called from
BIN=/data/spacocha/bin
#where you want to put the output of the analysis
UNIQUE=

#Make the fake barcode read
perl ${BIN}/fastq2Qiime_barcode.pl ${SOLFILEF} > ${UNIQUE}_bar.txt

#Split your fastq file with qiime
split_libraries_fastq.py -i ${SOLFILEF} -b ${UNIQUE}_bar.txt -o ${UNIQUE}_output -m ${MAPFILE} --barcode_type 7 --min_per_read_length 100 --rev_comp_barcode --last_bad_quality_char E

#Trim the sequences with mothur
${BIN}/mothur/Mothur.source/mothur "#trim.seqs(fasta=${UNIQUE}_output/seqs.fna, oligos=${OLIGO})"

#revert the names from mothur to qiime names
perl ${BIN}/revert_names_mothur.pl ${UNIQUE}_output/seqs.fna ${UNIQUE}_output/seqs.trim.fasta > ${UNIQUE}_output/seqs.trim.names.fasta

#Now pick otus from the qiime greengenesg ref
python /home/software/python/python-27/software/qiime/qiime-1.3.0/bin//pick_otus.py -i ${UNIQUE}_output/seqs.trim.names.fasta -o ${UNIQUE}_output/ucrC/ -r /data/spacocha/Qiime_dir/gg_otus_4feb2011/rep_set/gg_97_otus_4feb2011.fasta -C -m uclust_ref

#make an otu table
python /home/software/python/python-27/software/qiime/qiime-1.3.0/bin//make_otu_table.py -i ${UNIQUE}_output/ucrC/seqs.trim.names_otus.txt -t /data/spacocha/Qiime_dir/gg_otus_4feb2011/taxonomies/greengenes_tax.txt -o ${UNIQUE}_output/ucrC/seqs_otus.mat