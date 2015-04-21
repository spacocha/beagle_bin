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
