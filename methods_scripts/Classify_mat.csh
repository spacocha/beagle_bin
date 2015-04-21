#! /bin/sh
#$ -S /bin/bash
# -cwd

#path to file where all of the data is
#load in the variables from the second command line input
. ./$1

#mothur is required
source /etc/profile.d/modules.sh
module load qiime-default
module load R/2.12.1
module load mothur

#classify with RDP using the fixrank
java -Xmx600m -jar ${BIN}/rdp_classifier_2.3/rdp_classifier-2.3.jar -q ${UNIQUE}.final.fa -o ${UNIQUE}.final.rdp -f fixrank
#add classifications onto mat
perl ${BIN}/rdp_fixrank2SM2.pl ${UNIQUE}.final.rdp 0.5 ${UNIQUE}.final.mat > ${UNIQUE}.final.mat.lin