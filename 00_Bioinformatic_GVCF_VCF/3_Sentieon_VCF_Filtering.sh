#!/bin/bash

# setup working directory 
ref=/work/LAS/jfw-lab/weixuan/TX2094.genome.fasta
thr=30 #NUMBER_THREADS
Dirgvcf=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/gvcf_n74/ #places to find gvcf
Dir=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/VCF_output3/
bedfile=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/VCF_output3/TX2094_3_gene.bed
output1=MK_Known_n74

mkdir $output1

module load sentieon-genomics/202308-mdtz2zq

#joint SNP calling:
cat list_of_gvcfs_n65.txt | sentieon driver -t $thr -r $ref --algo GVCFtyper --emit_mode all $output1/$output1.vcf -

######################################################
######################################################

# filtering SNPs to keep only bialleic SNPs
cd $output1
ml vcftools bcftools
vcftools --vcf $output1.vcf --remove-indels --max-missing-count 0 --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --mac 1 --maf 0.05 --recode --recode-INFO-all --out $output1.variant
bcftools reheader -s $Dir/reheader2.txt $output1.variant.recode.vcf -o $output1.variant.rehead.vcf
bgzip $output1.variant.rehead.vcf
tabix $output1.variant.rehead.vcf.gz


#filter out variable sites:
vcftools --vcf $output1.vcf --remove-indels --max-maf 0 --min-meanDP 10 --max-meanDP 100 --recode --out $output1.invariant
bcftools reheader -s $Dir/reheader2.txt $output1.invariant.recode.vcf -o $output1.invariant.rehead.vcf
bgzip $output1.invariant.rehead.vcf
tabix $output1.invariant.rehead.vcf.gz

#merge filtered and invarient files:
bcftools concat --allow-overlaps $output1.variant.rehead.vcf.gz $output1.invariant.rehead.vcf.gz -Oz -o $output1.combined.vcf.gz
tabix $output1.combined.vcf.gz


vcftools --gzvcf $output1.variant.rehead.vcf.gz --relatedness2 --out $output1.relatedness2


######################################################
######################################################

# Count the number of Indels

vcftools --vcf $output1.vcf --keep-only-indels --min-meanDP 10 --max-meanDP 100 --recode --out $output1.indels
bcftools reheader -s $Dir/reheader2.txt $output1.indels.recode.vcf -o $output1.indels.rehead.vcf
bgzip $output1.indels.rehead.vcf
tabix $output1.indels.rehead.vcf.gz


