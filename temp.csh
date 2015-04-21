#! /bin/sh
#$ -S /bin/bash
# -cwd

for i in 97 96 95 94 93 92 91 90
do
before=`expr $i - 1`
echo "Before $before"
echo "I $i"
done
