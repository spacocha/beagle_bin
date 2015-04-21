#! /bin/sh
#$ -S /bin/bash
#$ -t 1-55
#$ -o /scratch/ldavid/huge/proc/10_08_27_1/tmp

export CLASSPATH=/home/ldavid/src/freclu/
SEEDFILE=/home/ldavid/alm/projects/huge/data/Chip5.barcodes.f
BARFILE=/home/ldavid/alm/projects/huge/data/Chip5.barcodes.r
#SEED=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILE)
SEED=$(sed -n -e "$SGE_TASK_ID p" $BARFILE)
BIN=/data/spacocha/bin
HOMEBASE=/scratch/ldavid/huge/proc/10_08_27_1/pipe
TMP=/scratch/ldavid/huge/proc/10_08_27_1/tmp

SOLFILEF=/home/ldavid/alm/shared_data/huge/data/100702_HuGE_amaterna_Alm_L3_1_sequence.txt
SOLFILER=/home/ldavid/alm/shared_data/huge/data/100702_HuGE_amaterna_Alm_L3_2_sequence.txt


#parse for quality
perl ${BIN}/parse_16S_Solexa_qual6.pl ${HOMEBASE}/div1.${SEED} ${HOMEBASE}/div2.${SEED} ${HOMEBASE}/${SEED}

#run through FreClu
/usr/java/latest/bin/java QV_format1_fastq ${HOMEBASE}/${SEED}.f.sol
/usr/java/latest/bin/java QV_format2 ${HOMEBASE}/${SEED}.f.sol_seq-prb.txt
/usr/java/latest/bin/java Radix_DNAseq ${HOMEBASE}/${SEED}.f.sol_seq-prb.txt_f2
/usr/java/latest/bin/java Merge_randomModel ${HOMEBASE}/${SEED}.f.sol_seq-prb.txt_f2_RadixSort_DNAseq
/usr/java/latest/bin/java Radix_num ${HOMEBASE}/${SEED}.f.sol_seq-prb.txt_f2_RadixSort_DNAseq_merge_randomModel

/usr/java/latest/bin/java ClusteringOfShortTags_searchReverse_hash_open2 -i ${HOMEBASE}/${SEED}.f.sol_seq-prb.txt_f2_RadixSort_DNAseq_merge_randomModel_RadixSortReverseBy3 -stat /home/ldavid/src/freclu/normal_distribution.txt -o ${HOMEBASE}/${SEED}.f.sol_clusterOutput.txt -q ${HOMEBASE}/${SEED}.f.sol_parent-childRelation.txt

# now prepare parents for uclust as fasta

perl ${BIN}/FreClu2chimera.pl ${HOMEBASE}/${SEED}.f.sol_clusterOutput.txt > ${HOMEBASE}/${SEED}_FreClu

#UCLUST
/home/ldavid/src/uclust2.0.5 --input ${HOMEBASE}/${SEED}_FreClu --uc ${HOMEBASE}/${SEED}_FreClu.uc --id 0.95

/home/ldavid/src/uclust2.0.5 --uc2fasta ${HOMEBASE}/${SEED}_FreClu.uc --input ${HOMEBASE}/${SEED}_FreClu --types S --output ${HOMEBASE}/${SEED}_FreClu.uc.fa

#make the consensus out of the uclust-ed FreClu clusters using the FreClu and UC files as input
perl ${BIN}/UC_FreClu2consensus2.pl ${HOMEBASE}/${SEED}.f.sol_parent-childRelation.txt ${HOMEBASE}/${SEED}_FreClu.uc ${HOMEBASE}/${SEED}_FreClu ${HOMEBASE}/${SEED}.concat ${HOMEBASE}/${SEED}_prechim

#check the consensus for chimeras either at f, r or in concat
${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${TMP}/silva.v19.align.172.short,candidate=${HOMEBASE}/${SEED}_prechim.concat.con)"

${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${TMP}/silva_short_align.f,candidate=${HOMEBASE}/${SEED}_prechim.f.con)"

${BIN}/mothur/Mothur.source/mothur "#align.seqs(template=${TMP}/silva_short_align.r,candidate=${HOMEBASE}/${SEED}_prechim.r.con)"

${BIN}/mothur/Mothur.source/mothur "#chimera.slayer(fasta=${HOMEBASE}/${SEED}_prechim.concat.align,template=${TMP}/silva.v19.align.172.short,minsnp=100,realign=T)"

${BIN}/mothur/Mothur.source/mothur "#chimera.slayer(fasta=${HOMEBASE}/${SEED}_prechim.f.align,template=${TMP}/silva_short_align.f,minsnp=50,realign=T)"

${BIN}/mothur/Mothur.source/mothur "#chimera.slayer(fasta=${HOMEBASE}/${SEED}_prechim.r.align,template=${TMP}/silva_short_align.r,minsnp=50,realign=T)"

# combine all sequences that need to be removed
cat ${HOMEBASE}/${SEED}_prechim.concat.flip.accnos ${HOMEBASE}/${SEED}_prechim.f.flip.accnos ${HOMEBASE}/${SEED}_prechim.r.flip.accnos ${HOMEBASE}/${SEED}_prechim.concat.slayer.accnos ${HOMEBASE}/${SEED}_prechim.f.slayer.accnos ${HOMEBASE}/${SEED}_prechim.r.slayer.accnos > ${HOMEBASE}/${SEED}_allremove.txt

#remove them from the rdp consensus files
perl ${BIN}/remove_chimera.pl ${HOMEBASE}/${SEED}_prechim.rdp.con ${HOMEBASE}/${SEED}_allremove.txt > ${HOMEBASE}/${SEED}_postchim.rdp.con
 
#run rdp
/usr/java/latest/bin/java -Xmx600m -jar /home/ldavid/src/rdp_classifier/rdp_classifier-2.0.jar ${HOMEBASE}/${SEED}_postchim.rdp.con ${HOMEBASE}/${SEED}_postchim.rdp.con.rdp

#group by the same rdp classes
perl ${BIN}/parse_rdp.pl ${HOMEBASE}/${SEED}_postchim.rdp.con.rdp ${HOMEBASE}/${SEED}_final

