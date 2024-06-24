#!/bin/bash

# set up directories
DIR=/Path/to/working/dir
tDir=/Path/to/dir/with/trimmed/reads
ref=/Path/to/dir/with/reference
thr=20

# load forward and reverse reads
file1=$(ls -1 $DIR/*_1.fastq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p)
file2=$(ls -1 $DIR/*_1.fastq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p| sed 's/_1[.]fastq/_2\.fastq/')

name=$(basename $file1 _1.fastq.gz)

echo "the first file is " $file1
echo "the second file is " $file2

#trim reads with Trimmomatic:
module load  trimmomatic/0.39-zwxnnrx
cd $Dir
trimmomatic PE -threads $thr $file1 $file2 $tDir/$name.R1.fq.gz $tDir/$name.U1.fq.gz $tDir/$name.R2.fq.gz $tDir/$name.U2.fq.gz ILLUMINACLIP:Adapters.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:75
mv $name.R[12].fq.gz $tDir
module purge

#map reads with bwa:
module load bwa
cd $tDir
bwa mem -M -R "@RG\tID:$name \tSM:$name \tPL:ILLUMINA" -t $thr $ref $tDir/$name.R1.fq.gz $tDir/$name.R2.fq.gz > $name.sam
module purge 

#scoring with sentieon-genomics:
export SENTIEON_LICENSE=reimu.las.iastate.edu:8990
module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr --sam2bam -i $name.sam

#extimate stats with sentieon-genomics:
sentieon driver -t $thr -r $ref -i $name.sort.bam --algo GCBias --summary $name.GC.summary $name.GC.metric --algo MeanQualityByCycle $name.MQ.metric --algo QualDistribution $name.QD.metric --algo InsertSizeMetricAlgo $name.IS.metric --algo AlignmentStat $name.ALN.metric 
sentieon plot metrics -o $name.metric.pdf gc=$name.GC.metric mq=$name.MQ.metric qd=$name.QD.metric isize=$name.IS.metric 

sentieon driver -t $thr -i $name.sort.bam --algo LocusCollector --fun score_info $name.score 
sentieon driver -t $thr -i $name.sort.bam --algo Dedup --rmdup --score_info $name.score --metrics $name.dedup.metric $name.dedup.bam 

#realign with sentieon-genomics:
sentieon driver -t $thr -r $ref -i $name.dedup.bam --algo Realigner $name.realign.bam

#create gvcf files with sentieon-genomics:
sentieon driver -t $thr -r $ref -i $name.realign.bam  --algo Haplotyper $name.gVCF --emit_mode gvcf 

#cleanups:
#rm $name.sam 

mkdir dedupBam
mkdir metrics
mkdir realignBam
mkdir sortBam
mkdir score
mkdir gvcf

mv $name*.dedup.bam* dedupBam 
mv $name*.metric* metrics
mv $name*.summary* metrics 
mv $name*.realign.bam* realignBam 
mv $name*.sort.bam* sortBam 
mv $name*.score* score
mv $name*.gVCF* gvcf

