#! /bin/sh
#$ -S /bin/bash
# -cwd

#define you files and directories
SOLFILEF=100702_MystikLake_amaterna_Alm_L1_1_sequence.txt
SOLFILER=100702_MystikLake_amaterna_Alm_L1_2_sequence.txt
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

#divide the whole by barcodes
#use divide_16S_Solexa4.pl for barcodes that are already rc and divide_16S_Solexa3.pl for ones that need to be changed to rc
perl ${BIN}/divide_16S_Solexa_opt2.pl ${HOMEBASE}/${SOLFILEF} ${HOMEBASE}/${BARFILE} ${OUTBASE}/F ${RC} ${OUTBASE}/${LOGFILE} ${OUTBASE}/${STATFILE} ${OUTBASE}/${SEEDST2F}

perl ${BIN}/divide_16S_Solexa_opt2.pl ${HOMEBASE}/${SOLFILER} ${HOMEBASE}/${BARFILE} ${OUTBASE}/R ${RC} ${OUTBASE}/${LOGFILE} ${OUTBASE}/${STATFILE} ${OUTBASE}/${SEEDST2R}

sed 's/.*_\([ACTG][ATGC][ATGC][ATGC][ATGC][ATGC][ATGC]\)/\1/' ${OUTBASE}/${SEEDST2F} > ${OUTBASE}/$BARST2

sed 's/.*F.\(.*\)_[ACTG][ATGC][ATGC][ATGC][ATGC][ATGC][ATGC]/\1/' ${OUTBASE}/${SEEDST2F} > ${OUTBASE}/${LIBST2}

