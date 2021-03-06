#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load qiime-default
module load mothur
#fasta file name in QIIME format
FASTAFILE=$1
#output folder (unique)
OUTPUT=$2
#reference fasta file (latest greengenes OTUS)
REFERENCEFA=/data/spacocha/Qiime_dir/greengenes/gg_12_10_otus/rep_set/97_otus.fasta
#reference taxonomies
REFERENCETAX=/data/spacocha/Qiime_dir/greengenes/gg_12_10_otus/taxonomy/97_otu_taxonomy.txt
PARAMS=/home/spacocha/bin/methods_scripts/denovo_params.txt



pick_otus_through_otu_table.py -o ${OUTPUT} -i ${FASTAFILE} -p ${PARAMS}

perl ~/bin/map2mock.pl /scratch/spacocha/Polz/mock_set_trim_49fix.fa ./${OUTPUT}/rep_set/*_rep_set.fasta > ${OUTPUT}/rep_set/rep_set.fa.map

perl ~/bin/methods_scripts/map2mock_QIIMETABLE.pl ${OUTPUT}/rep_set/rep_set.fa.map ./${OUTPUT}/otu_table.txt > ./${OUTPUT}/otu_table.txt.map