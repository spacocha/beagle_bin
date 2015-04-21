#! /bin/sh
#$ -S /bin/bash

#define you files and directories
SOLFILEF=100702_MystikLake_amaterna_Alm_L1_1_sequence.txt
SOLFILER=100702_MystikLake_amaterna_Alm_L1_2_sequence.txt
#the lib name\tbarcode file
BARFILE=ML_barcode_rc_names.txt2
#where the programs are called from
BIN=/home/spacocha/bin
#where the sequence and bar files are
HOMEBASE=/data/spacocha/100702_R
#where you want to put the output of the analysis
OUTBASE=/data/spacocha/100702_R/012011_dir
#where the alignment files are
TMP=/data/spacocha/tmp
#whether you need to reverse complement the bar codes
RC='yes'
#name of log file
LOGFILE=log.txt
#name of stats file
STATFILE=stats.txt
#name for the next step of the analysis input files
SEEDST2F=SEEDST2F.txt
SEEDST2R=SEEDST2R.txt
BARST2=BARFILEST2.txt
LIBST2=LIBST2.txt
#threshhold for keeping quality strains in percent
THRESH=75
#threshhold for chisq (depends on the number of libraries you are choosing)
PTHRESH=116
#divide the whole by barcodes
#use divide_16S_Solexa4.pl for barcodes that are already rc and divide_16S_Solexa3.pl for ones that need to be changed to rc
perl ${BIN}/divide_16S_Solexa_opt.pl ${HOMEBASE}/${SOLFILEF} ${HOMEBASE}/${BARFILE} ${OUTBASE}/F ${RC} ${OUTBASE}/${LOGFILE} ${OUTBASE}/${STATFILE} ${OUTBASE}/${SEEDST2F}

perl ${BIN}/divide_16S_Solexa_opt.pl ${HOMEBASE}/${SOLFILER} ${HOMEBASE}/${BARFILE} ${OUTBASE}/R ${RC} ${OUTBASE}/${LOGFILE} ${OUTBASE}/${STATFILE} ${OUTBASE}/${SEEDST2R}

sed 's/.*_\([ACTG][ATGC][ATGC][ATGC][ATGC][ATGC][ATGC]\)/\1/' ${OUTBASE}/${SEEDST2F} > ${OUTBASE}/$BARST2

sed 's/.*F.\(.*\)_[ACTG][ATGC][ATGC][ATGC][ATGC][ATGC][ATGC]/\1/' ${OUTBASE}/${SEEDST2F} > ${OUTBASE}/${LIBST2}

#! /bin/sh
#$ -S /bin/bash
#$ -t 1-79

export CLASSPATH=/home/ldavid/src/freclu/
BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2
OUTBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2
TMP=/data/spacocha/tmp

SEEDFILEF=${OUTBASE}/SEEDST2F.txt
SEEDFILER=${OUTBASE}/SEEDST2R.txt
JBARFILE=${OUTBASE}/BARFILEST2.txt
LIBFILE=${OUTBASE}/LIBST2.txt
FALIGN=new_silva_short.f
RALIGN=new_silva_short.r

SEEDF=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILEF)
SEEDR=$(sed -n -e "$SGE_TASK_ID p" $SEEDFILER)
BAR=$(sed -n -e "$SGE_TASK_ID p" $JBARFILE)
LIB=$(sed -n -e "$SGE_TASK_ID p" $LIBFILE)

#parse for quality
perl ${BIN}/parse_16S_Solexa_qual10.pl ${SEEDF} ${SEEDR} ${LIB} > ${OUTBASE}/${LIB}_${BAR}.tab

#make the data into a fasta files
#forward
perl ${BIN}/tab2fasta.pl ${OUTBASE}/${LIB}_${BAR}.tab 1 3 > ${OUTBASE}/${LIB}_${BAR}_F.fa

#reverse
perl ${BIN}/tab2fasta.pl ${OUTBASE}/${LIB}_${BAR}.tab 1 5 > ${OUTBASE}/${LIB}_${BAR}_R.fa

#align the sequences to a seed
~/bin/mothur/Mothur.source/mothur "#align.seqs(template=${TMP}/${FALIGN},candidate=${OUTBASE}/${LIB}_${BAR}_F.fa)"

~/bin/mothur/Mothur.source/mothur "#align.seqs(template=${TMP}/${RALIGN},candidate=${OUTBASE}/${LIB}_${BAR}_R.fa)"
#! /bin/sh
#$ -S /bin/bash

#not exactly sure what it means, but this is necessary to run FreClu on the cluster
export CLASSPATH=/home/ldavid/src/freclu/

#make all the variable here so they are easy to change
ALIGN=all_aligned.fa
SEED=all_tab
THRESH=75
BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/GWAS_dir/JustGWAS_dir

#keep only the aligned sequences of specific length and trim the sequences to the right length
perl ${BIN}/add_aligned_seq.pl ${HOMEBASE}/${ALIGN} ${HOMEBASE}/${SEED} ${THRESH} > ${HOMEBASE}/${SEED}.med.tab
perl ~/bin/tab2Solexa.pl ${HOMEBASE}/${SEED}.med.tab 1 3 4 > ${HOMEBASE}/${SEED}.med.f.sol

#run through FreClu
/usr/java/latest/bin/java QV_format1_fastq ${HOMEBASE}/${SEED}.med.f.sol
/usr/java/latest/bin/java QV_format2 ${HOMEBASE}/${SEED}.med.f.sol_seq-prb.txt
/usr/java/latest/bin/java -Xms10G -Xmx10G Radix_DNAseq ${HOMEBASE}/${SEED}.med.f.sol_seq-prb.txt_f2
/usr/java/latest/bin/java Merge_randomModel ${HOMEBASE}/${SEED}.med.f.sol_seq-prb.txt_f2_RadixSort_DNAseq
/usr/java/latest/bin/java Radix_num ${HOMEBASE}/${SEED}.med.f.sol_seq-prb.txt_f2_RadixSort_DNAseq_merge_randomModel
/usr/java/latest/bin/java ClusteringOfShortTags_searchReverse_hash_open2 -i ${HOMEBASE}/${SEED}.med.f.sol_seq-prb.txt_f2_RadixSort_DNAseq_merge_randomModel_RadixSortReverseBy3 -stat /home/ldavid/src/freclu/normal_distribution.txt -o ${HOMEBASE}/${SEED}.med.f.sol_clusterOutput.txt -q ${HOMEBASE}/${SEED}.med.f.sol_parent-childRelation.txt

# now prepare parents for uclust
perl ${BIN}/FreClu2parent_no.pl ${HOMEBASE}/${SEED}.med.f.sol_clusterOutput.txt > ${HOMEBASE}/${SEED}.med.FreClu.fa
perl ${BIN}/add_FreClu_cluster.pl ${HOMEBASE}/${SEED}.med.f.sol_parent-childRelation.txt ${HOMEBASE}/${SEED}.med.FreClu.fa ${HOMEBASE}/${SEED}.med.tab > ${HOMEBASE}/${SEED}.med.FreClu.tab

#UCLUST
/home/ldavid/src/uclust2.0.5 --sort ${HOMEBASE}/${SEED}.med.FreClu.fa --output ${HOMEBASE}/${SEED}.med.FreClu.st.fa
/home/ldavid/src/uclust2.0.5 --input ${HOMEBASE}/${SEED}.med.FreClu.st.fa --uc ${HOMEBASE}/${SEED}.med.FreClu.uc --id 0.90

perl ${BIN}/add_UC_cluster.pl  ${HOMEBASE}/${SEED}.med.FreClu.uc ${HOMEBASE}/${SEED}.med.FreClu.tab > ${HOMEBASE}/${SEED}.med.FreClu.UC.tab

#Make the chisq files, group and fasta files:
#change the outgroup file depending on the total length chosen in the 
perl ${BIN}/UC2bar_count_010711.pl ${HOMEBASE}/${SEED}.med.FreClu.UC.tab ${TMP}/outgroup_172.tab ${SEED}

#make the list of all the files
ls /data/spacocha/101222_dir/Chicken_Soil_dir2/*.chisq.dat | sed 's/.*\/\(${SEED}.FC[0-9]*P.chisq.dat\)/\1/' > ${OUTBASE}/datlist

#change the list of all the files to bases
sed 's/\(${SEED}.FC[0-9]*P\).chisq.dat/\1/' < ${OUTBASE}/datlist > ${OUTBASE}/baselist
#! /bin/sh
#$ -S /bin/bash
#$ -t 1-253

#make all the variable here so they are easy to change
BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/GWAS_dir
OUTBASE=/data/spacoch/101222_dir/GWAS_dir/JustGWAS_dir
#this file lists all the .dat files for man chisq
SEEDFILE=datlist
SEED=$(sed -n -e "$SGE_TASK_ID p" ${OUTBASE}/$SEEDFILE)
BASEFILE=baselist
BASE=$(sed -n -e "$SGE_TASK_ID p" ${OUTBASE}/$BASEFILE)
#threshhold for 80 degrees of freedom (should be 82)
PTHRESH=116

perl ${BIN}/man_chisq.pl ${OUTBASE}/${SEED} > ${OUTBASE}/${BASE}.chisq.tab
perl ${BIN}/run_trees2.pl ${OUTBASE}/${BASE}.chisq.tab ${PTHRESH} >> ${OUTBASE}/phylist


#! /bin/sh
#$ -S /bin/bash
#$ -t 1-253

#make all the variable here so they are easy to change
export PYTHONPATH=/home/jahn/usr/mpl-svn-old/lib/python2.5/site-packages:/home/csmillie/lib/python/
BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/GWAS_dir/JustGWAS_dir
OUTBASE=/data/spacocha/101222_dir/GWAS_dir/JustGWAS_dir
#this file lists all the .dat files for man chisq
BASEFILE=baselist
BASE=$(sed -n -e "$SGE_TASK_ID p" ${OUTBASE}/$BASEFILE)
PTHRESH=116

if [$OUTBASE/${BASE}.fa];then
    /opt/Bio/clustalw/bin/clustalw2 -INFILE=${OUTBASE}/${BASE}.fa -convert -output=PHYLIP
    /home/digev/Softs/phyml_v2.4.4/exe/phyml_linux ${OUTBASE}/${BASE}.phy 0 i 1 0 GTR e e 4 e BIONJ y y
    module add python/2.6.4
    module add numpy
    module add scipy
    module add ipython
    module add matplotlib
    module add dendropy
    python ${BIN}/extract_features_011311.py -d ${OUTBASE}/${BASE}.chisq.tab -t ${PTHRESH} ${OUTBASE}/${BASE}.phy_phyml_tree.txt > ${OUTBASE}/${BASE}.group
fi
#! /bin/sh
#$ -S /bin/bash

#make all the variable here so they are easy to change
#This is a list of all the .group files
SEED=grouplist
#This is the name of the tab file you are adding the groups to
BASE=all_tab.med.FreClu.UC

BIN=/home/spacocha/bin
HOMEBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2
OUTBASE=/data/spacocha/101222_dir/Chicken_Soil_dir2

#join all the groups and make another column in the .tab file
perl ${BIN}/join_group.pl ${OUTBASE}/${SEED} ${OUTBASE}/${BASE}.tab > ${OUTBASE}/${BASE}.OTU.tab

#now make a count of the groups across libraries
perl ${BIN}/OTU2lib_count.pl ${OUTBASE}/${BASE}.OTU.tab > ${OUTBASE}/${BASE}.OTU.lib.mat

#now make a consensus
perl ${BIN}/OTU2rdp_seq.pl ${OUTBASE}/${BASE}.OTU.tab > ${OUTBASE}/${BASE}.OTU.fa
