bcftools annotate --set-id +"%CHROM:%POS" MK_Known_n65.variant.rehead.vcf.gz  > MK_Known_n65.variant.rehead.id.vcf
bcftools norm -m-any MK_Known_n65.variant.rehead.id.vcf -Ov > MK_Known_n65.variant.rehead.id.norm.vcf

##############################################

paste <(bcftools view MK_Known_n65.variant.rehead.id.norm.vcf |\
    awk -F"\t" 'BEGIN {print "CHR\tPOS\tID\tREF\tALT"} \
      !/^#/ {print $1"\t"$2"\t"$3"\t"$4"\t"$5}') \
    \
  <(bcftools query -f '[\t%SAMPLE=%GT]\n' MK_Known_n65.variant.rehead.id.norm.vcf |\
    awk 'BEGIN {print "nHet"} {print gsub(/0\|1|1\|0|0\/1|1\/0/, "")}') \
    \
  <(bcftools query -f '[\t%SAMPLE=%GT]\n' MK_Known_n65.variant.rehead.id.norm.vcf |\
    awk 'BEGIN {print "nHomAlt"} {print gsub(/1\|1|1\/1/, "")}') \
    \
  <(bcftools query -f '[\t%SAMPLE=%GT]\n' MK_Known_n65.variant.rehead.id.norm.vcf |\
    awk 'BEGIN {print "nHomRef"} {print gsub(/0\|0|0\/0/, "")}') \
    \
  <(bcftools view MK_Known_n65.variant.rehead.id.norm.vcf | awk -F"\t" '/^#CHROM/ {split($0, header, "\t"); print "HetSamples"} \
    !/^#CHROM/ {for (i=10; i<=NF; i++) {if ($(i) ~ /0\/1|1\/0/) {printf header[i]","}; if (i==NF) {printf "\n"}}}') \
    \
  <(bcftools view MK_Known_n65.variant.rehead.id.norm.vcf | awk -F"\t" '/^#CHROM/ {split($0, header, "\t"); print "HomSamplesAlt"} \
    !/^#CHROM/ {for (i=10; i<=NF; i++) {if ($(i) ~ /1\/1/) {printf header[i]","}; if (i==NF) {printf "\n"}}}') \
    \
  <(bcftools view MK_Known_n65.variant.rehead.id.norm.vcf | awk -F"\t" '/^#CHROM/ {split($0, header, "\t"); print "HomSamplesRef"} \
    !/^#CHROM/ {for (i=10; i<=NF; i++) {if ($(i) ~ /0\/0/) {printf header[i]","}; if (i==NF) {printf "\n"}}}') \
    \
  | sed 's/,\t/\t/g' | sed 's/,$//g' > MK_Know_genotypecount.csv


###############

paste <(cut -f 3 MK_Know_genotypecount.csv) \
\
<(awk -F'\t' -v OFS=',' '{print $9}' MK_Know_genotypecount.csv |\
awk -F',' 'BEGIN{print "Line", "\tMK_HetSamples", "\tWild_HetSamples", "\tLandrace_HetSamples", "\tCultivar_HetSamples"}\
NR>1 {print NR "\t" gsub(/MK/,"") "\t" gsub(/Wild/,"") "\t" gsub(/Landrace|Cultivar/,"") }') \
\
<(awk -F'\t' -v OFS=',' '{print $10}' MK_Know_genotypecount.csv |\
awk -F',' 'BEGIN{print "Line", "\tMK_HomSamplesAlt", "\tWild_HomSamplesAlt", "\tLandrace_HomSamplesAlt", "\tCultivar_HomSamplesAlt"}\
NR>1 {print NR "\t" gsub(/MK/,"") "\t" gsub(/Wild/,"") "\t" gsub(/Landrace|Cultivar/,"") }') \
\
<(awk -F'\t' -v OFS=',' '{print $11}' MK_Know_genotypecount.csv |\
awk -F',' 'BEGIN{print "Line", "\tMK_HomSamplesRef", "\tWild_HomSamplesRef", "\tLandrace_HomSamplesRef", "\tCultivar_HomSamplesRef"}\
NR>1 {print NR "\t" gsub(/MK/,"") "\t" gsub(/Wild/,"") "\t" gsub(/Landrace|Cultivar/,"") }') >  MK_Know_genotypecount3.csv



