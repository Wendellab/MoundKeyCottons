
## Plink, LEA & Pixy  
### select genic regions for all samples
```
#module load bedops/2.4.41
#convert2bed --input=gtf  < TX2094.renamed.gtf | grep -wF gene > TX2094_3_gene.bed

mkdir $Dir/$output1/Plink_n65
cd $Dir/$output1/Plink_n65/

module purge 
module load plink/1.90b6.21
ml  vcftools bcftools
vcftools --vcf MK_Known_n67.variant.recode.id.vcf --bed /work/LAS/jfw-lab/weixuan/05_n319/TX2094_3_gene.bed --out MK_Known_n67.variant.recode.id.genic --recode --keep-INFO-all
```
### Plink running
```
bcftools annotate --set-id +"%CHROM:%POS" $output1.variant.rehead.genic.vcf > $output1.variant.rehead.genic.id.vcf
plink --vcf-filter --vcf $output1.variant.rehead.genic.id.vcf --allow-extra-chr --recode  --make-bed --geno 0 --const-fid --out $output1
plink --indep-pairwise 50 10 0.1 --file $output1 --allow-extra-chr --out $output1
plink --extract $output1.prune.in --out $output1-pruned --file $output1 --make-bed --allow-extra-chr --recode --distance square 1-ibs
plink --pca 20 var-wts --file $output1-pruned --allow-extra-chr --out $output1
plink --freq --het 'small-sample' --ibc --file $output1-pruned --allow-extra-chr -out $output1-pruned
paste -d '\t' $output1-pruned.mdist.id $output1-pruned.mdist > $output1-pruned.distmatrix
```

### LEA calucation 
```
module purge
module load r

mkdir $Dir/$output1/LEA_n65
cd $Dir/$output1/LEA_n65/
mv $Dir/LEA_n65.R $Dir/$output1/LEA_n65/
cp $Dir/$output1/Plink_n65/$output1-pruned.ped $Dir/$output1/LEA_n65/
Rscript LEA_n65.R
```

### Pixy run
```
module purge
mkdir $Dir/$output2/Pixy_n65
cd $Dir/$output2/Pixy_n65

awk '{print $1, $NF}' $Dir/subset_n65samples.txt | awk -F' ' -vOFS='\t' '{ gsub("_.*", "", $2); gsub("MK.*", "MK", $2)  ; print }' > pixy_populationlist.txt

module load micromamba/1.4.2-7jjmfkf
eval "$(micromamba shell hook --shell=bash)"
micromamba activate
pixy --stats pi fst dxy --vcf $Dir/$output2/$output2.combined.vcf.gz --populations pixy_populationlist.txt --window_size 10000 --n_cores $thr --output_prefix $output2
micromamba deactivate
```
