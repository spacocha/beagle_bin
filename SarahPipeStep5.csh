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
