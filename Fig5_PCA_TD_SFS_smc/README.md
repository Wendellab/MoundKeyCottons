## angsd, SFS and Tajimas'd 

### angsd 
```
ref=/work/LAS/jfw-lab/weixuan/TX2094.genome.fasta
thr=10 #NUMBER_THREADS
name=MoundKey_SFS3 #Output_FileNamePrefix
DIR=/work/LAS/jfw-lab/weixuan/01_MoundKey_bam/

module purge
module load angsd

cd $DIR

angsd -bam bam.filelist2 -out $name -anc $ref -P 20 -doSaf 1 -doMaf 1 -doMajorMinor 1 -doGlf 3 -uniqueOnly -GL 2 -minMapQ 30 -minQ 20 -minInd 25
#-doMaf 1: Frequency (fixed major and minor)
#-doMajorMinor 1: Infer major and minor from GL
#-uniqueOnly: reads mapped to unique location
#GL 2: genotype likelihood model
#mapped quality filtering -minMapQ 30 -minQ 20 -minInd 25
#-doSaf 1: Calculate the Site allele frequency likelihood based on individual genotype likelihoods assuming HWE
#-doGlf 3: binary beagle in/out-put gz requires -doMajorMinor [1|2]


realSFS $name.saf.idx -maxIter 100 -P 20 -fold 1 > $name.sfs
realSFS saf2theta $name.saf.idx -outname $name -sfs $name.sfs -fold 1
thetaStat do_stat $name.thetas.idx
thetaStat do_stat $name.thetas.idx -win 50000 -step 10000  -outnames $name.thetasWindow.gz

```

### SMC++
```
ref=/work/LAS/jfw-lab/weixuan/TX2094.genome.fasta
thr=30 #NUMBER_THREADS
Dirgvcf=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/gvcf_n74/ #places to find gvcf
Dir=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/VCF_output3/MK_Known_n65/smcpp
bedfile=/work/LAS/jfw-lab/weixuan/04_MK_Known_gvcf/VCF_output3/TX2094_3_gene.bed
output1=MK_Known_n74
output2=MK_Known_n65

cd $Dir

module load gsl/2.7.1-uuykddp
module load mpfr/4.2.0-av6zkh3
module load gmp/6.2.1-dh2y7b4
module load gcc/12.2.0-khmr45w

#for i in {01..13}
#do
#smc++ vcf2smc MK_Known_n65.variant.rehead.vcf.gz A${i}.smc.gz A${i} MK:MKSite1_10,MKSite1_11,MKSite1_12,MKSite1_13,MKSite1_14,MKSite1_15,MKSite1_16,MKSite1_17,MKSite1_1,MKSite1_2,MKSite1_3,MKSite1_4,MKSite1_5,MKSite1_6,MKSite1_7,MKSite1_8,MKSite1_9,MKSite2_1,MKSite2_2,MKSite2_3,MKSite2_4,MKSite2_5,MKSite2_6,MKSite2_7,MKSite3_1
#smc++ vcf2smc MK_Known_n65.variant.rehead.vcf.gz D${i}.smc.gz D${i} MK:MKSite1_10,MKSite1_11,MKSite1_12,MKSite1_13,MKSite1_14,MKSite1_15,MKSite1_16,MKSite1_17,MKSite1_1,MKSite1_2,MKSite1_3,MKSite1_4,MKSite1_5,MKSite1_6,MKSite1_7,MKSite1_8,MKSite1_9,MKSite2_1,MKSite2_2,MKSite2_3,MKSite2_4,MKSite2_5,MKSite2_6,MKSite2_7,MKSite3_1
#done

#--timepoints 1000 1000000

#smc++ estimate --spline cubic --knots 10 --cores $thr -o analysis/MK_ 2.6e-9 data/*.smc.gz

#https://www.nature.com/articles/s41588-020-0614-5
smc++ estimate --spline cubic --knots 15 --timepoints 100 1000000 --cores $thr   -o analysis/MK2 3.48e-9 data/*.smc.gz
```
