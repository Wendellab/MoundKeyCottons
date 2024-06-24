# setup directory and a list of SRA samples for downloading 

dir=$(pwd)
file=$dir/ListofSample.txt

sampledata=$(cat $file | sed -n ${SLURM_ARRAY_TASK_ID}p)
echo "Samplebam = " $sampledata

module load  sra-tools

#fasterq-dump SRR6311485

prefetch $sampledata --max-size 100G
fasterq-dump --threads 8 --split-files $sampledata/$sampledata.sra
gzip $sampledata*.fastq
