## angsd

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


zcat MoundKey_SFS3.mafs.gz | cut -f5 |sed 1d > $name.freq
./ngsrelate  -g angsdput.glf.gz -n 100 -f freq  -O newres
```





