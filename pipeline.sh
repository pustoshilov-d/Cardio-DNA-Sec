#!/bin/bash
ulimit -n 100000

export SPARK_LOCAL_HOSTNAME=localhost

fastp="/home/software/fastp"
fastqc="/home/software/FastQC/fastqc"
gatk4local="/home/software/gatk-4.1.6.0/gatk"
gatk4spark="/home/software/gatk-4.1.6.0/gatk"
gatk3="/home/software/GenomeAnalysisTK.jar"
annovar="/home/software/Annovar2019/table_annovar.pl"

ParallelGCThreads="4"
ConcGCThreads="4"
Xms="4g"
Xmx="16g"
paralleljobs=1
sparkthreads=4

GenomeReferenceFasta="/home/references/b37/human_g1k_v37.fasta"
GenomeReferenceFastaGZ="/home/references/b37/human_g1k_v37.fasta.gz"
knownSNP="/home/references/b37/dbsnp_138.b37.vcf"
knownIndels="/home/references/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"

TargetSystBED="/home/references/SureSelectCardioLQTPanel/Almazov_LQT_Panel_derived_from_ExomeV7_38liftto37_3176131_Covered.bed.wochr.bed6.bed"
TargetSystInterval="/home/references/SureSelectCardioLQTPanel/Almazov_LQT_Panel_derived_from_ExomeV7_38liftto37_3176131_Covered.bed.picard.interval_list"
ReferenceInterval="/home/references/SureSelectCardioLQTPanel/Almazov_LQT_Panel_derived_from_ExomeV7_38liftto37_3176131_Covered.bed.picard.interval_list"

InfoFolder="/home/genomicdata/CardioLQTINFO/"
TempFolder="$HOME/01.GATK-HC/TEMP"
WorkingFolder="$HOME/01.GATK-HC/Working"
ResultsFolder="$HOME/01.GATK-HC/Results"

FastQFilesTable="/home/genomicdata/CardioLQTINFO/samples_units_uBAMfromFastQ.tab"
#FastQFilesTable="/home/student1/01.GATK-HC/samples_units_uBAMfromFastQ_student1.tab"

mkdir -p $ResultsFolder
mkdir -p $WorkingFolder
rm -rf $TempFolder
mkdir -p $TempFolder

LogsFolder=$ResultsFolder/Logs
QCFolder=$ResultsFolder/QC
FastQProcessingFolder=$WorkingFolder/FastQProcessing
BAMProcessingFolder=$WorkingFolder/BAMProcessing
ReadyToAnalyzeBAMsFolder=$ResultsFolder/ReadyToAnalyzeBAMs
HaplotypeCallerProcessingFolder=$ResultsFolder/HaplotypeCaller

allVCFFolder=$ResultsFolder/allVCFFolder
allVCFannovarFolder=$ResultsFolder/allVCFannovar

mkdir -p $LogsFolder
mkdir -p $QCFolder
mkdir -p $FastQProcessingFolder
mkdir -p $BAMProcessingFolder
mkdir -p $ReadyToAnalyzeBAMsFolder
mkdir -p $HaplotypeCallerProcessingFolder
mkdir -p $allVCFFolder
mkdir -p $allVCFannovarFolder

cd $InfoFolder


#parallel --lb --jobs 40 --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/paralelllog_FastQCLanes.txt \
#$fastqc {FASTQ1} {FASTQ2} --outdir=$FastQProcessingFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/consolelog_FastQCLanes.txt
#
#
#parallel --lb --jobs $paralleljobs --plus --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/FastQfiltering_paralelllog.txt $fastp \
#--thread 4 \
#--in1 {FASTQ1} \
#--in2 {FASTQ2} \
#--json $FastQProcessingFolder/{sample_lane}.fastp.json \
#--html $FastQProcessingFolder/{sample_lane}.fastp.html \
#--out1 $FastQProcessingFolder/{sample_lane}.filtered.R1.fastq.gz \
#--out2 $FastQProcessingFolder/{sample_lane}.filtered.R2.fastq.gz \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/FastQfiltering_consolelog.txt
#
#multiqc -f --data-dir $FastQProcessingFolder --filename $QCFolder/FastQ_QCreport
#
#parallel --lb --will-cite --jobs 20 --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/FastqToSam_fastq_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#FastqToSam \
#--FASTQ={FASTQ1} \
#--FASTQ2={FASTQ2} \
#--OUTPUT=$BAMProcessingFolder/{sample_lane}.FastqToSam.bam \
#--READ_GROUP_NAME={READ_GROUP_NAME} \
#--SAMPLE_NAME={SAMPLE_NAME} \
#--LIBRARY_NAME={LIBRARY_NAME} \
#--PLATFORM_UNIT={PLATFORM_UNIT} \
#--PLATFORM={PLATFORM} \
#--SEQUENCING_CENTER=almazov \
#--RUN_DATE={RUN_DATE} \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/FastqToSam_fastq_consolelog.txt
#
## cd $InfoFolder
## 
## echo "SAMPLE_NAME bams" > $TableBAMs
## sample_names=$(csvcut -t -c "SAMPLE_NAME" $FastQFilesTable | sed '1d' | sort | uniq | tr "\n" " ")
## 
## for sample in $sample_names
## do
##   bams=$(csvcut -x -t -c "SAMPLE_NAME" -c "sample_lane" $FastQFilesTable | grep $sample | awk '{print "--INPUT='$BAMProcessingFolder'"$1".FastqToSam.bam"}' | tr "\n" " "| awk '{$1=$1};1') #remove the awk statment if the suffix is already present
##   echo "aligments for $sample are $bams"
##   echo "aligments for $sample are $bams">>$LogsFolder/MergeSamFiles_table.txt
##   echo -e "$sample"'\t'"$bams">>$TableBAMs
##   $gatk --java-options "-Xms$Xms -Xmx$Xmx" MergeSamFiles $bams \
##   --SORT_ORDER=queryname \
##   --OUTPUT=$BAMProcessingFolder/$sample.merged.unmapped.bam \
##   --TMP_DIR=$TempFolder&
## done
## wait
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/MarkIlluminaAdapters_fastq_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#MarkIlluminaAdapters \
#--INPUT=$BAMProcessingFolder/{sample_lane}.FastqToSam.bam \
#--OUTPUT=$BAMProcessingFolder/{SAMPLE_NAME}.merged.unmapped.markillumina.bam \
#--METRICS=$BAMProcessingFolder/{SAMPLE_NAME}.merged.unmapped.markillumina.metrics.txt \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/MarkIlluminaAdapters_fastq_consolelog.txt
#
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/SamToFastq_fastq_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#SamToFastq \
#--INPUT=$BAMProcessingFolder/{SAMPLE_NAME}.merged.unmapped.markillumina.bam \
#--FASTQ=$BAMProcessingFolder/{SAMPLE_NAME}.bamtofastq.interleaved.fastq \
#--CLIPPING_ATTRIBUTE=XT \
#--CLIPPING_ACTION=2 \
#--INTERLEAVE=true \
#--NON_PF=true \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/SamToFastq_fastq_consolelog.txt
#
##bwa index -a bwtsw /home/references/b37/human_g1k_v37.fasta.gz
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/BWA_MEM_fastq_paralelllog.txt \
#bwa mem \
#-t 8 \
#-M \
#-p \
#$GenomeReferenceFastaGZ \
#$BAMProcessingFolder/{SAMPLE_NAME}.bamtofastq.interleaved.fastq \
#">" $BAMProcessingFolder/{SAMPLE_NAME}.bwamem.sam \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/BWA_MEM_fastq_consolelog.txt
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/SortSam_fastq_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#SortSam \
#--INPUT=$BAMProcessingFolder/{SAMPLE_NAME}.bwamem.sam \
#--OUTPUT=$BAMProcessingFolder/{SAMPLE_NAME}.bwamem.bam \
#--SORT_ORDER=coordinate \
#--CREATE_INDEX=true \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/SortSam_fastq_consolelog.txt
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/MergeBamAlignment_fastq_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#MergeBamAlignment \
#--R=$GenomeReferenceFasta \
#--UNMAPPED_BAM=$BAMProcessingFolder/{sample_lane}.FastqToSam.bam \
#--ALIGNED_BAM=$BAMProcessingFolder/{SAMPLE_NAME}.bwamem.bam \
#--O=$BAMProcessingFolder/{SAMPLE_NAME}.bam \
#--CREATE_INDEX=true \
#--ADD_MATE_CIGAR=true \
#--CLIP_ADAPTERS=false \
#--CLIP_OVERLAPPING_READS=true \
#--INCLUDE_SECONDARY_ALIGNMENTS=true \
#--MAX_INSERTIONS_OR_DELETIONS=-1 \
#--PRIMARY_ALIGNMENT_STRATEGY=MostDistant \
#--ATTRIBUTES_TO_RETAIN=XS \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/MergeBamAlignment_fastq_consolelog.txt
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/MarkDuplicates_fastq_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#MarkDuplicates \
#--INPUT=$BAMProcessingFolder/{SAMPLE_NAME}.bam \
#--OUTPUT=$BAMProcessingFolder/{SAMPLE_NAME}.dedup.bam \
#--METRICS_FILE=$BAMProcessingFolder/{SAMPLE_NAME}.dedup.metrics.txt \
#--CREATE_INDEX=true \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/MarkDuplicates_fastq_consolelog.txt
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/BaseRecalibrator_pre_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#BaseRecalibrator \
#--input $BAMProcessingFolder/{SAMPLE_NAME}.dedup.bam \
#--output $QCFolder/{SAMPLE_NAME}.BQSR.pre_recal_data.table \
#--known-sites $knownSNP \
#--known-sites $knownIndels \
#--reference $GenomeReferenceFasta \
#--tmp-dir $TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/BaseRecalibrator_pre_consolelog.txt
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/ApplyBQSR_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#ApplyBQSR \
#--input $BAMProcessingFolder/{SAMPLE_NAME}.dedup.bam \
#--bqsr-recal-file $QCFolder/{SAMPLE_NAME}.BQSR.pre_recal_data.table \
#--output $ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam \
#--reference $GenomeReferenceFasta \
#--tmp-dir $TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/ApplyBQSR_pre_consolelog.txt
#
#parallel --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/BaseRecalibrator_post_paralelllog.txt \
#$gatk4local  --java-options "-Xms$Xms -Xmx$Xmx" \
#BaseRecalibrator \
#--input $ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam \
#--output $QCFolder/{SAMPLE_NAME}.BQSR.post_recal_data.table \
#--known-sites $knownSNP \
#--known-sites $knownIndels \
#--reference $GenomeReferenceFasta \
#--tmp-dir $TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/BaseRecalibrator_post_consolelog.txt
#
#parallel --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/AnalyzeCovariates_paralelllog.txt \
#$gatk4local  --java-options "-Xms$Xms -Xmx$Xmx" \
#AnalyzeCovariates \
#--before-report-file $QCFolder/{SAMPLE_NAME}.BQSR.pre_recal_data.table \
#--after-report-file  $QCFolder/{SAMPLE_NAME}.BQSR.post_recal_data.table \
#--plots-report-file $QCFolder/{SAMPLE_NAME}.BQSR.recal.pdf \
#--tmp-dir $TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/AnalyzeCovariates_consolelog.txt
#
#multiqc -f --data-dir $QCFolder/*.BQSR.pre_recal_data.table --filename PreBQSR --outdir $QCFolder
#multiqc -f --data-dir $QCFolder/*.BQSR.post_recal_data.table --filename PostBQSR --outdir $QCFolder
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/CollAlSumMetrics_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#CollectAlignmentSummaryMetrics \
#--REFERENCE_SEQUENCE=$GenomeReferenceFastaGZ \
#--INPUT=$ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam \
#--OUTPUT=$QCFolder/{SAMPLE_NAME}.PicardCollAlSum.metrics.txt \
#--METRIC_ACCUMULATION_LEVEL=ALL_READS \
#--VALIDATION_STRINGENCY=LENIENT \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/CollAlSumMetrics_consolelog.txt
#
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/CollectInsertSizeMetrics_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#CollectInsertSizeMetrics \
#--INPUT=$ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam \
#--OUTPUT=$QCFolder/{SAMPLE_NAME}.InsertSizeMetSum.metrics.txt \
#--Histogram_FILE=$QCFolder/{SAMPLE_NAME}.InsertSizeMetSum.hist \
#--TMP_DIR=$TempFolder \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/CollectInsertSizeMetrics_consolelog.txt
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/CollectHsMetrics_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#CollectHsMetrics \
#--INPUT=$ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam \
#--BAIT_INTERVALS=$TargetSystInterval \
#--TARGET_INTERVALS=$ReferenceInterval \
#--OUTPUT=$QCFolder/{SAMPLE_NAME}.PicardCollectHsMetrics.metrics.txt \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/CollectHsMetrics_consolelog.txt
#
#parallel --lb --will-cite --jobs 21 --plus --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/SamtoolsFlagstatMetrics_paralelllog.txt \
#samtools flagstat $ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam ">" $QCFolder/{SAMPLE_NAME}.samtoolsflagstat.txt \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/SamtoolsFlagstatMetrics_consolelog.txt
#
#multiqc -f --data-dir $QCFolder \
#--ignore *.pre_recal_data.table \
#--filename allreportsSamplesQC --outdir $QCFolder
#
#parallel --lb --will-cite --jobs $paralleljobs --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/HaplotypeCaller_paralelllog.txt \
#$gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
#HaplotypeCaller \
#-R $GenomeReferenceFasta \
#-I $ReadyToAnalyzeBAMsFolder/{SAMPLE_NAME}.bam \
#--intervals $TargetSystInterval \
#--tmp-dir $TempFolder \
#--emit-ref-confidence GVCF \
#--enable-all-annotations \
#-G StandardAnnotation \
#-G AS_StandardAnnotation \
#-G StandardHCAnnotation \
#-O $HaplotypeCallerProcessingFolder/{SAMPLE_NAME}.vcf.gz \
#--native-pair-hmm-threads 8 \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/HaplotypeCaller_consolelog.txt
#
#find $HaplotypeCallerProcessingFolder -name "*.vcf.gz" > $HaplotypeCallerProcessingFolder/input.list
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#CombineGVCFs \
#-R $GenomeReferenceFasta \
#--variant $HaplotypeCallerProcessingFolder/input.list \
#--intervals $TargetSystInterval \
#-O $HaplotypeCallerProcessingFolder/genotypes_unfiltered.vcf.gz
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#GenotypeGVCFs \
#-R $GenomeReferenceFasta \
#--dbsnp $knownSNP \
#-V $HaplotypeCallerProcessingFolder/genotypes_unfiltered.vcf.gz \
#-O $HaplotypeCallerProcessingFolder/unfiltered.vcf.gz
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#SelectVariants \
#-R $GenomeReferenceFasta \
#--intervals $TargetSystInterval \
#-V $HaplotypeCallerProcessingFolder/unfiltered.vcf.gz \
#-O $HaplotypeCallerProcessingFolder/snps.unfiltered.vcf \
#--select-type-to-include SNP
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#VariantFiltration \
#-R $GenomeReferenceFasta \
#--intervals $TargetSystInterval \
#-V $HaplotypeCallerProcessingFolder/snps.unfiltered.vcf \
#-O $HaplotypeCallerProcessingFolder/snps.filtered.vcf \
#--filter-expression "QD < 2.0" \
#--filter-expression "MQ < 40.0" \
#--filter-expression "FS > 60.0" \
#--filter-expression "SOR > 3.0" \
#--filter-name SNP_QD \
#--filter-name SNP_MQ \
#--filter-name SNP_FS \
#--filter-name SNP_SOR
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#SelectVariants \
#-R $GenomeReferenceFasta \
#--intervals $TargetSystInterval \
#-V $HaplotypeCallerProcessingFolder/unfiltered.vcf.gz \
#-O $HaplotypeCallerProcessingFolder/indel.unfiltered.vcf \
#--select-type-to-include INDEL
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#VariantFiltration \
#-R $GenomeReferenceFasta \
#--intervals $TargetSystInterval \
#-V $HaplotypeCallerProcessingFolder/indel.unfiltered.vcf \
#-O $HaplotypeCallerProcessingFolder/indel.filtered.vcf \
#--filter-expression "FS>200.0" \
#--filter-expression "QD<2.0" \
#--filter-expression "ReadPosRankSum<-20.0" \
#--filter-expression "InbreedingCoeff<-0.8" \
#--filter-expression "SOR>10.0" \
#--filter-name Indel_FS \
#--filter-name Indel_QD \
#--filter-name Indel_ReadPosRankSum \
#--filter-name Indel_InbreedingCoeff \
#--filter-name Indel_SOR
#
#java -Xmx16g -jar $gatk3 \
#--analysis_type CombineVariants \
#--intervals $TargetSystInterval \
#--reference_sequence $GenomeReferenceFasta \
#-V:indels $HaplotypeCallerProcessingFolder/indel.filtered.vcf \
#-V:snps $HaplotypeCallerProcessingFolder/snps.filtered.vcf \
#--out $HaplotypeCallerProcessingFolder/unannotated.vcf \
#-filteredRecordsMergeType KEEP_IF_ANY_UNFILTERED \
#-assumeIdenticalSamples \
#
#$gatk4local --java-options "-XX:+UseParallelGC -XX:ParallelGCThreads=24 -XX:ConcGCThreads=24 -Xms16g -Xms16g -Djava.io.tmpdir=$TempFolder" \
#LeftAlignAndTrimVariants \
#-R $GenomeReferenceFasta \
#--intervals $TargetSystInterval \
#--variant $HaplotypeCallerProcessingFolder/unannotated.vcf \
#--output $HaplotypeCallerProcessingFolder/unannotated_La.vcf \
#--dont-trim-alleles \
#--keep-original-ac
#
#perl $annovar \
#--operation "g,f,f" \
#--buildver "hg19" \
#--protocol "knownGene,avsnp150,gnomad211_exome" \
#$HaplotypeCallerProcessingFolder/unannotated_La.vcf \
#/home/references/Annovar/ \
#--outfile $HaplotypeCallerProcessingFolder/annovar \
#--dot2underline \
#--thread 4 \
#--remove \
#--vcfinput \

#parallel --lb --will-cite --jobs 10 --plus --quote --header : --colsep '\t' --verbose \
#--joblog $LogsFolder/SelectVariants_paralelllog.txt \
#java -Xmx4g -jar $gatk3 \
#--analysis_type SelectVariants \
#--reference_sequence $GenomeReferenceFasta \
#--variant $HaplotypeCallerProcessingFolder/annovar.hg19_multianno.vcf \
#-env \
#-trimAlternates \
#-sn {SAMPLE_NAME} \
#--out $allVCFannovarFolder/{SAMPLE_NAME}.vcf \
#:::: $FastQFilesTable \
#2>&1 | tee $LogsFolder/SelectVariants_consolelog.txt


f#or vcffile in $allVCFannovarFolder/*.vcf
d#o
 #   vcfbasename=$(basename $vcffile .vcf)
 #   $gatk4local --java-options "-Xms$Xms -Xmx$Xmx" \
 #   VariantsToTable \
 #   --tmp-dir $TempFolder \
 #   -R $GenomeReferenceFasta \
 #   -V $vcffile \
 #   -O $allVCFannovarFolder/$vcfbasename.tsv \
 #   -F CHROM \
 #   -F POS \
 #   -F ID \
 #   -F REF \
 #   -F ALT \
 #   -F FILTER \
 #   -F avsnp150 \
 #   -F Gene_knownGene \
 #   -F Gene_refGene \
 #   -F GeneDetail_knownGene \
 #   -F GeneDetail_refGene \
 #   -F Func_knownGene \
 #   -F ExonicFunc_knownGene \
 #   -F AAChange_knownGene \
 #   -F AF \
 #   -F AF_popmax \
 #   -F QUAL \
 #   -F BaseQRankSum \
 #   -F InbreedingCoeff \
 #   -F MQRankSum \
 #   -F ReadPosRankSum \
 #   -F RAW_MQandDP
 #
 #done

