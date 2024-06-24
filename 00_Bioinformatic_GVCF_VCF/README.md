### In breif
#### 1. Raw reads download 
   > module load  sra-tools
   >  
   > prefetch $sampledata --max-size 100G
   > 
   > fasterq-dump --threads 8 --split-files $sampledata/$sampledata.sra
   > 
   > gzip $sampledata*.fastq

#### 2. Raw reads trimming
   > trimmomatic PE -threads $thr $file1 $file2 $tDir/$name.R1.fq.gz $tDir/$name.U1.fq.gz $tDir/$name.R2.fq.gz $tDir/$name.U2.fq.gz ILLUMINACLIP:Adapters.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:75

#### 3. GVCF calling
   > cat list_of_gvcfs_n65.txt | sentieon driver -t $thr -r $ref --algo GVCFtyper --emit_mode all $output2/$output2.vcf -
   
#### 3. SNP filtering
   > vcftools --vcf $output2.vcf --remove-indels --max-missing-count 0 --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --mac 1 --maf 0.05 --recode --recode-INFO-all --out $output2.variant

   > vcftools --vcf $output2.vcf --remove-indels --max-maf 0 --min-meanDP 10 --max-meanDP 100 --recode --out $output2.invariant
