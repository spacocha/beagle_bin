#! /bin/sh
#$ -S /bin/bash
# -cwd

source /etc/profile.d/modules.sh
module load R/2.12.1

perl /home/spacocha/bin/generate_random_errors4.pl $1 ${SGE_TASK_ID}