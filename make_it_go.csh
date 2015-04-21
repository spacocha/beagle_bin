#! /bin/sh
#$ -S /bin/bash

BIN=/home/spacocha/bin
#divide the whole by barcodes
#use divide_16S_Solexa4.pl for barcodes that are already rc and divide_16S_Solexa3.pl for ones that need to be changed to rc
${BIN}/SarahPipeStep1.csh
wait_command_pid=`jobs -l | awk '{print $2}'`

wait $wait_command_pid

echo "Done"