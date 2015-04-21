#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load mothur

# you should run this by typing in the prefix for your files then the mothur oligo mapping file
# should be something like this qsub -cwd RunMothur_Miseq.csh test mothured_test.tab

mothur "#trim.seqs(fasta=${1}.fasta, qfile=${1}.qual, oligos=${2}, maxambig=0, maxhomop=8, qthreshold=15, minlength=250, maxlength=350); unique.seqs(); align.seqs(fasta=${1}.trim.unique.fasta, reference=/data/spacocha/tmp/silva.bacteria/silva.bacteria.fasta); screen.seqs(fasta=${1}.trim.unique.align, name=${1}.trim.names, group=${1}.groups, start=13862, end=23444); filter.seqs(fasta=${1}.trim.unique.good.align, vertical=T, trump=.); degap.seqs(fasta=${1}.trim.unique.good.filter.fasta); count.seqs(name=${1}.trim.good.names, group=${1}.good.groups)"

perl /data/spacocha/bin/truncate_fasta.pl ${1}.trim.unique.good.filter.ng.fasta 252 > ${1}.trim.unique.good.filter.ng.252.fasta

perl /data/spacocha/bin/QIIMEIZE_fasta_from_mat.pl ${1}.trim.good.seq.count ${1}.trim.unique.good.filter.ng.252.fasta > ${1}.trim.unique.good.filter.ng.252.QIIMEIZED.fasta