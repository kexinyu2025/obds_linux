cd 1_fastq 
fastqc -o /project/wolf7099/linux/2_rnaseq/3_analysis/1_fastqc *.fastq.gz
multiqc -o /project/wolf7099/linux/2_rnaseq/3_analysis/reports *fastqc.zip

