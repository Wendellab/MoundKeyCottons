# Mound Key Wild Cotton

Ciation: [Ning, W., Rogers, K.M., Hsu, CY. et al. Origin and diversity of the wild cottons (*Gossypium hirsutum*) of Mound Key, Florida. Sci Rep 14, 14046 (2024). https://doi.org/10.1038/s41598-024-64887-8](https://www.nature.com/articles/s41598-024-64887-8)

This is needs some work to clean the code and put things in a logical ways! - Weixuan is on it   😝

<img src="https://github.com/Wendellab/MoundKeyCottons/blob/main/Supplymentary/IMG_3837.JPG" width="300" />

### Codes following the data analysis order presented in the paper, including:

####  ▪️ Pop gene analysis (PCA, NJ-tree, Structure)
1. All AD1 65 samples' raw reads were trimmed with [Trimmomatic](https://github.com/usadellab/Trimmomatic.git).
   > trimmomatic PE -threads $thr $file1 $file2 $tDir/$name.R1.fq.gz $tDir/$name.U1.fq.gz $tDir/$name.R2.fq.gz $tDir/$name.U2.fq.gz ILLUMINACLIP:Adapters.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:75

3. Following [sentieon-dnaseq](https://github.com/Sentieon/sentieon-dnaseq.git), trimmmed reads mapping; GVCF calling; VCF calling; SNPs filtering.
   > vcftools --vcf $output2.vcf --remove-indels --max-missing-count 0 --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --mac 1 --maf 0.05 --recode --recode-INFO-all --out $output2.variant

4. Using biallelic SNPs to estimate population genetic groups via [PLINK](https://www.cog-genomics.org/plink/) (PCA) and [LEA](https://bioconductor.org/packages/release/bioc/html/LEA.html).
5. Including additional two AD4 samples as outgroup, and calling bialleic SNPs from the 'combined' VCF with 65 AD1 samples, which include variable and invariable sites.

####  ▪️ Genetic variation comparison (Pi, Dxy, Fst, He, Fis, LD)
1. [Pixy](https://github.com/ksamuk/pixy.git) was applied to 

####  ▪️ Novel SNPs tabulating
1. Bcftools

####  ▪️ MK cotton population demographic analysis (PCA, Tajima's D, SFS, Ne)


