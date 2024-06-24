#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G 
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.vcf_n65.%J.out"
#SBATCH --job-name="jointGeno_n65"

ref=/work/LAS/jfw-lab/weixuan/TX2094.genome.fasta
thr=30 #NUMBER_THREADS
Dirgvcf=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/gvcf_n74/ #places to find gvcf
Dir=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/VCF_output3/
bedfile=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/VCF_output3/TX2094_3_gene.bed
output1=MK_Known_n74
output2=MK_Known_n65

mkdir $output2

module load sentieon-genomics/202308-mdtz2zq

#joint SNP calling:
#cat reheader.txt | grep -v 'AD' | awk '{print "/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/gvcf_n74/"$1}' | sed 's/\\/.gVCF/g' > ../VCF_output3/list_of_gvcfs_n65.txt
#echo "Run sentieon for all 74 samples with to extract only variant sites"
cat list_of_gvcfs_n65.txt | sentieon driver -t $thr -r $ref --algo GVCFtyper --emit_mode all $output2/$output2.vcf -

#echo "Filtering VCF file using vcftools and rename samples using bcftools"
#filter out conserved sites:

grep -v 'AD' $Dir/reheader.txt | sed 's/B11SA0825\\ /B11SA0825/' > $Dir/reheader2.txt

cd $output2
ml vcftools bcftools
vcftools --vcf $output2.vcf --remove-indels --max-missing-count 0 --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --mac 1 --maf 0.05 --recode --recode-INFO-all --out $output2.variant
bcftools reheader -s $Dir/reheader2.txt $output2.variant.recode.vcf -o $output2.variant.rehead.vcf
bgzip $output2.variant.rehead.vcf
tabix $output2.variant.rehead.vcf.gz


#filter out variable sites:
vcftools --vcf $output2.vcf --remove-indels --max-maf 0 --min-meanDP 10 --max-meanDP 100 --recode --out $output2.invariant
bcftools reheader -s $Dir/reheader2.txt $output2.invariant.recode.vcf -o $output2.invariant.rehead.vcf
bgzip $output2.invariant.rehead.vcf
tabix $output2.invariant.rehead.vcf.gz

#merge filtered and invarient files:
bcftools concat --allow-overlaps $output2.variant.rehead.vcf.gz $output2.invariant.rehead.vcf.gz -Oz -o $output2.combined.vcf.gz
tabix $output2.combined.vcf.gz


vcftools --gzvcf $output2.variant.rehead.vcf.gz --relatedness2 --out $output2.relatedness2


######################################################
######################################################
######################################################
### Count the number of Indels

vcftools --vcf $output2.vcf --keep-only-indels --min-meanDP 10 --max-meanDP 100 --recode --out $output2.indels
bcftools reheader -s $Dir/reheader2.txt $output2.indels.recode.vcf -o $output2.indels.rehead.vcf
bgzip $output2.indels.rehead.vcf
tabix $output2.indels.rehead.vcf.gz



##### #Plink calucation 
### select genic regions for 74 samples
#module load bedops/2.4.41
#convert2bed --input=gtf  < TX2094.renamed.gtf | grep -wF gene > TX2094_3_gene.bed

mkdir $Dir/$output2/Plink_n65
cd $Dir/$output2/Plink_n65/

tabix -R $bedfile -h $Dir/$output2/$output2.variant.rehead.vcf.gz > $Dir/$output2/Plink_n65/$output2.variant.rehead.genic.vcf

module purge 
module load plink/1.90b6.21
ml bcftools

bcftools annotate --set-id +"%CHROM:%POS" $output2.variant.rehead.genic.vcf > $output2.variant.rehead.genic.id.vcf
plink --vcf-filter --vcf $output2.variant.rehead.genic.id.vcf --allow-extra-chr --recode  --make-bed --geno 0 --const-fid --out $output2
plink --indep-pairwise 50 10 0.1 --file $output2 --allow-extra-chr --out $output2
plink --extract $output2.prune.in --out $output2-pruned --file $output2 --make-bed --allow-extra-chr --recode --distance square 1-ibs
plink --pca 20 var-wts --file $output2-pruned --allow-extra-chr --out $output2
plink --freq --het 'small-sample' --ibc --file $output2-pruned --allow-extra-chr -out $output2-pruned
paste -d '\t' $output2-pruned.mdist.id $output2-pruned.mdist > $output2-pruned.distmatrix

##### #LEA calucation 
### select genic regions for 74 samples

module purge
module load r

mkdir $Dir/$output2/LEA_n65
cd $Dir/$output2/LEA_n65/
mv $Dir/LEA_n65.R $Dir/$output2/LEA_n65/
cp $Dir/$output2/Plink_n65/$output2-pruned.ped $Dir/$output2/LEA_n65/
Rscript LEA_n65.R


##### Pixy run
#####################
module purge
mkdir $Dir/$output2/Pixy_n65
cd $Dir/$output2/Pixy_n65

awk '{print $1, $NF}' $Dir/subset_n65samples.txt | awk -F' ' -vOFS='\t' '{ gsub("_.*", "", $2); gsub("MK.*", "MK", $2)  ; print }' > pixy_populationlist.txt

module load micromamba/1.4.2-7jjmfkf
eval "$(micromamba shell hook --shell=bash)"
micromamba activate
pixy --stats pi fst dxy --vcf $Dir/$output2/$output2.combined.vcf.gz --populations pixy_populationlist.txt --window_size 10000 --n_cores $thr --output_prefix $output2
micromamba deactivate

