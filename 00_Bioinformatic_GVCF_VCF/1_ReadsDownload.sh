#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --open-mode=append
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --output="job.vcf.%J.out"
#SBATCH --job-name="Moving"
#SBATCH --exclude=legion-[1-8]
#SBATCH --array=1-3

dir=$(pwd)
file=$dir/AD2list.txt

sampledata=$(cat $file | sed -n ${SLURM_ARRAY_TASK_ID}p)
echo "Samplebam = " $sampledata

module load  sra-tools

#fasterq-dump SRR6311485

#prefetch $sampledata --max-size 100G
fasterq-dump --threads 8 --split-files $sampledata/$sampledata.sra
gzip $sampledata*.fastq
