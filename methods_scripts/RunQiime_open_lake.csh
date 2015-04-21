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
PARAMS=/home/spacocha/bin/methods_scripts/open_ref_params.txt

echo "Start time"
date +"%m-%d-%y"
date +"%T"


pick_reference_otus_through_otu_table.py -o ${OUTPUT} -i ${FASTAFILE} -r ${REFERENCEFA} -t ${REFERENCETAX} -p ${PARAMS}

pick_rep_set.py --input ./${OUTPUT}/uclust_ref_picked_otus/*_otus.txt --rep_set_picking_method most_abundant --fasta_file ${FASTAFILE} -o ./${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.fa 

echo "Done with clustering"
date +"%m-%d-%y"
date +"%T"

mothur "#align.seqs(fasta=${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.fa, reference=/data/spacocha/tmp/new_silva_short_unique_1_151.fa)"
mothur "#screen.seqs(fasta=${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.align, start=1, end=151, minlength=77)"

perl ~/bin/filter_mat_from_fasta.pl ./${OUTPUT}/uclust_ref_picked_otus/*_otus.txt ${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.good.align > ./${OUTPUT}/uclust_ref_picked_otus/otus.txt.good

perl ~/bin/fasta2filter_from_mat.pl ./${OUTPUT}/uclust_ref_picked_otus/otus.txt.good ./${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.fa > ./${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.good.fa

perl ~/bin/map2mock.pl /scratch/spacocha/100714_B/6_21m_cleaned.77.fa  ./${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.good.fa > ${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.map

perl ~/bin/methods_scripts/map2mock_QIIMETABLE.pl ${OUTPUT}/uclust_ref_picked_otus/otus_rep_set.map ./${OUTPUT}/uclust_ref_picked_otus/otu_table.txt > ./${OUTPUT}/uclust_ref_picked_otus/otu_table.txt.map

echo "End time"
date +"%m-%d-%y"
date +"%T"
