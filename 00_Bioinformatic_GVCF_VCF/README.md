#### For rawreads downloading from NCBI using SRA code
> module load  sra-tools
>
> prefetch $sampledata --max-size 100G
> 
> fasterq-dump --threads 8 --split-files $sampledata/$sampledata.sra
> 
> gzip $sampledata*.fastq
