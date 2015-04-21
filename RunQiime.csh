#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default
module load mothur

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
#reference fasta file (latest greengenes OTUS)
REFERENCEFA=/data/spacocha/Qiime_dir/gg_otus_4feb2011/rep_set/gg_97_otus_4feb2011.fasta
#reference taxonomies
REFERENCETAX=/data/spacocha/Qiime_dir/gg_otus_4feb2011/taxonomies/greengenes_tax.txt


#Make the fake barcode read
perl ${BIN}/fastq2Qiime_barcode.pl ${SOLFILEF} > ${UNIQUE}_bar.txt

if [[ -s ${UNIQUE}_bar.txt ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE}_bar.txt is empty; stopped program after ${BIN}/fastq2Qiime_barcode.pl" ;
exit;
fi ;

#Split your fastq file with qiime
split_libraries_fastq.py -i ${SOLFILEF} -b ${UNIQUE}_bar.txt -o ${UNIQUE}_output -m ${MAPFILE} --barcode_type 7 --min_per_read_length 100 --rev_comp_barcode --last_bad_quality_char E --max_barcode_errors 0 --max_bad_run_length 0

if [[ -s ${UNIQUE}_output/seqs.fna ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE}_output/seqs.fna is empty; stopped program after split_libraries_fastq.py" ;
exit;
fi ;

#Trim the sequences with mothur
mothur "#trim.seqs(fasta=${UNIQUE}_output/seqs.fna, oligos=${OLIGO})"

if [[ -s ${UNIQUE}_output/seqs.trim.fasta ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE}_output/seqs.trim.fasta is empty; stopped program after trim.seqs" ;
exit;
fi ;

#revert the names from mothur to qiime names
perl ${BIN}/revert_names_mothur3.pl ${UNIQUE}_output/seqs.fna ${UNIQUE}_output/seqs.trim.fasta > ${UNIQUE}_output/seqs.trim.names.fasta

if [[ -s ${UNIQUE}_output/seqs.trim.names.fasta ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE}_output/seqs.trim.names.fasta is empty; stopped program after ${BIN}/revert_names_mothur3.pl" ;
exit;
fi ;


#Now pick otus from the qiime greengenesg ref
pick_otus.py -i ${UNIQUE}_output/seqs.trim.names.fasta -o ${UNIQUE}_output/ucrC/ -r ${REFERENCEFA} -C -m uclust_ref

if [[ -s ${UNIQUE}_output/ucrC/seqs.trim.names_otus.txt ]] ; then
NULLVAR=0
else
echo "PipeStop error:${UNIQUE}_output/ucrC/seqs.trim.names_otus.txt is empty; stopped program after ${BIN}/pick_otus.py" ;
exit;
fi ;

#make an otu table
make_otu_table.py -i ${UNIQUE}_output/ucrC/seqs.trim.names_otus.txt -t ${REFERENCETAX} -o ${UNIQUE}_output/ucrC/seqs_otus.mat