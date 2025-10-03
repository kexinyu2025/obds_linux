##read quality control
cd /project/sso/linux/2_rnaseq
cd 1_fastq 
#Run FastQC on your FASTQ files directing its output to 3_analysis/1_fastqc/ folder
fastqc -o /project/wolf7099/linux/2_rnaseq/3_analysis/1_fastqc *.fastq.gz
#Run MultiQC to collate reports directing its output to 3_analysis/reports/
multiqc -o /project/wolf7099/linux/2_rnaseq/3_analysis/reports *fastqc.zip

##writing and submitting a slurm job
#activate obds conda enviroment
load_mamba
#Run FastQC on your pair of fastq files as a job on the cluster
touch sbatch script_namen.sh
#copy template Slurm job script as below and edit:
#!/bin/bash
##########################################################################
## A script template for submitting batch jobs. To submit a batch job, 
## please type
##
##    sbatch script_name.sh
##
## Please note that anything after the characters "#SBATCH" on a line
## will be treated as a Slurm option.
##########################################################################

## Specify a partition. Check available partitions using sinfo Slurm command.
#SBATCH --partition=long

## The following line will send an email notification to your registered email
## address when the job ends or fails.
#SBATCH --mail-type=END,FAIL

## Specify the amount of memory that your job needs. This is for the whole job.
## Asking for much more memory than needed will mean that it takes longer to
## start when the cluster is busy.
#SBATCH --mem=10G

## Specify the number of CPU cores that your job can use. This is only relevant for
## jobs which are able to take advantage of additional CPU cores. Asking for more
## cores than your job can use will mean that it takes longer to start when the
## cluster is busy.
#SBATCH --ntasks=1

## Specify the maximum amount of time that your job will need to run. Asking for
## the correct amount of time can help to get your job to start quicker. Time is
## specified as DAYS-HOURS:MINUTES:SECONDS. This example is one hour.
#SBATCH --time=0-01:00:00

## Provide file name (files will be saved in directory where job was ran) or path
## to capture the terminal output and save any error messages. This is very useful
## if you have problems and need to ask for help.
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

## ################### CODE TO RUN ##########################
# Load modules (if required - e.g. when not using conda) 
# module load R-base/4.3.0

# Execute these commands 
fastqc  --nogroup --threads 1 --extract -o /project/wolf7099/linux/2_rnaseq/3_analysis/1_fastqc /project/wolf7099/linux/2_rnaseq/1_fastq/*.fastq.gz

##sumbit your job to queue
sbatch sbatch script_namen.sh
#monitor your job
watch squeue --me
#view log files created by job (eg job 711)
less 711....err/out


##mapping-run HISAT2 to map reads
#read the hisat2 manual to establish mapping options
HISAT2 -h
#Write a Slurm job submission script
#!/bin/bash
##########################################################################
## A script template for submitting batch jobs. To submit a batch job, 
## please type
##
##    sbatch script_name.sh
##
## Please note that anything after the characters "#SBATCH" on a line
## will be treated as a Slurm option.
##########################################################################

## Specify a partition. Check available partitions using sinfo Slurm command.
#SBATCH --partition=short

## The following line will send an email notification to your registered email
## address when the job ends or fails.
#SBATCH --mail-type=END,FAIL

## Specify the amount of memory that your job needs. This is for the whole job.
## Asking for much more memory than needed will mean that it takes longer to
## start when the cluster is busy.
#SBATCH --mem=10G

## Specify the number of CPU cores that your job can use. This is only relevant for
## jobs which are able to take advantage of additional CPU cores. Asking for more
## cores than your job can use will mean that it takes longer to start when the
## cluster is busy.
#SBATCH --ntasks=8

## Specify the maximum amount of time that your job will need to run. Asking for
## the correct amount of time can help to get your job to start quicker. Time is
## specified as DAYS-HOURS:MINUTES:SECONDS. This example is one hour.
#SBATCH --time=0-01:00:00

## Provide file name (files will be saved in directory where job was ran) or path
## to capture the terminal output and save any error messages. This is very useful
## if you have problems and need to ask for help.
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

## ################### CODE TO RUN ##########################
# Load modules (if required - e.g. when not using conda) 
# module load R-base/4.3.0

# Execute these commands 
 hisat2 --threads 8 \
-x /project/shared/linux/5_rnaseq/hisat2_index/grcm39 \
-1 /project/wolf7099/linux/2_rnaseq/1_fastq/cd4_rep1_read1.fastq.gz \
-2 /project/wolf7099/linux/2_rnaseq/1_fastq/cd4_rep1_read2.fastq.gz \
--rna-strandness RF \
--summary-file stats.txt \
-S aln-pe.sam

#submit to the queue
sbatch 2_hisat2
#monitor
squeue --me/
watch squeue --me
#examine the HISAT2 output files
less aln-pe.sam


##mapping QC and quantification
#Use SAMtools to generate mapping QC
#!/bin/bash
##########################################################################
## A script template for submitting batch jobs. To submit a batch job, 
## please type
##
##    sbatch script_name.sh
##
## Please note that anything after the characters "#SBATCH" on a line
## will be treated as a Slurm option.
##########################################################################

## Specify a partition. Check available partitions using sinfo Slurm command.
#SBATCH --partition=short

## The following line will send an email notification to your registered email
## address when the job ends or fails.
#SBATCH --mail-type=END,FAIL

## Specify the amount of memory that your job needs. This is for the whole job.
## Asking for much more memory than needed will mean that it takes longer to
## start when the cluster is busy.
#SBATCH --mem=100G

## Specify the number of CPU cores that your job can use. This is only relevant for
## jobs which are able to take advantage of additional CPU cores. Asking for more
## cores than your job can use will mean that it takes longer to start when the
## cluster is busy.
#SBATCH --ntasks=8

## Specify the maximum amount of time that your job will need to run. Asking for
## the correct amount of time can help to get your job to start quicker. Time is
## specified as DAYS-HOURS:MINUTES:SECONDS. This example is one hour.
#SBATCH --time=0-01:00:00

## Provide file name (files will be saved in directory where job was ran) or path
## to capture the terminal output and save any error messages. This is very useful
## if you have problems and need to ask for help.
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

## ################### CODE TO RUN ##########################
# Load modules (if required - e.g. when not using conda) 
# module load R-base/4.3.0

# Execute these commands 
 samtools view -b /project/wolf7099/linux/2_rnaseq/3_analysis/aln-pe.sam > aln-pe.bam 
 samtools sort -@ 8 aln-pe.bam > sorted.bam 
 samtools index sorted.bam 
 samtools idxstats sorted.bam > sorted.idxstats 
 samtools flagstat sorted.bam > sorted.flagstat 

sbatch 3_mappingQC....




#Use MultiQC to visualise mapping QC
multiqc /project/sso/linux/2_rnaseq/3_analysis
#Run featureCounts to generate a count matrix
#!/bin/bash
##########################################################################
## A script template for submitting batch jobs. To submit a batch job, 
## please type
##
##    sbatch script_name.sh
##
## Please note that anything after the characters "#SBATCH" on a line
## will be treated as a Slurm option.
##########################################################################

## Specify a partition. Check available partitions using sinfo Slurm command.
#SBATCH --partition=short

## The following line will send an email notification to your registered email
## address when the job ends or fails.
#SBATCH --mail-type=END,FAIL

## Specify the amount of memory that your job needs. This is for the whole job.
## Asking for much more memory than needed will mean that it takes longer to
## start when the cluster is busy.
#SBATCH --mem=10G

## Specify the number of CPU cores that your job can use. This is only relevant for
## jobs which are able to take advantage of additional CPU cores. Asking for more
## cores than your job can use will mean that it takes longer to start when the
## cluster is busy.
#SBATCH --ntasks=8

## Specify the maximum amount of time that your job will need to run. Asking for
## the correct amount of time can help to get your job to start quicker. Time is
## specified as DAYS-HOURS:MINUTES:SECONDS. This example is one hour.
#SBATCH --time=0-01:00:00

## Provide file name (files will be saved in directory where job was ran) or path
## to capture the terminal output and save any error messages. This is very useful
## if you have problems and need to ask for help.
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

## ################### CODE TO RUN ##########################
# Load modules (if required - e.g. when not using conda) 
# module load R-base/4.3.0

# Execute these commands 
featureCounts -t exon -g gene_id -p -s 2 -a /project/wolf7099/linux/2_rnaseq/2_genome/Mus_muscu>
/project/wolf7099/linux/2_rnaseq/3_analysis/sorted.bam

#read the featureCounts maunal and uss the appopriate options

sbatch 4_counts



#Use MultiQC to visualise quantification QC
multiqc count.txt.summary

#Visualise BAM file with IGV on your laptop


