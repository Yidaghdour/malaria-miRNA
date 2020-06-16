# malaria-miRNA
Integrative genomic analysis reveals mechanisms of immune evasion in P. falciparum malaria

Types of analysis:

1) [miRNA-Analysis](#miRNA-Analysis)

    a. [miRNA profiling](#Usage-Pipeline:-miRNA-Data-Analysis)
  
    b. [eQTL analysis](#miRNA-eQTL-analysis)
  
    c. [Mediation analysis](#Mediation-analysis)
    

2) [mRNA-Analysis](#mRNA-Analysis)

# miRNA-Analysis

#### Data
Whole blood miRNAs expression profiles across matched individuals  in the four stages sampled: 

**Visit 1** : before infection (BI)

**Visit 2** : asymptomatic parasitemia (AP)

**Visit 3** : symptomatic  parasitemia (SP) and

**Visit 4** : after treatment (AT)

### Command Line Utilities
[Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic): v0.36

[FASTX Toolkit](http://hannonlab.cshl.edu/fastx_toolkit/): v0.0.14

[OASIS](http://oasis.ims.bio/)

[plink](https://www.cog-genomics.org/plink/): v1.90b5.3 

### Usage Pipeline : miRNA  Data Analysis


**Step 1:** Trim Reads for adaptors, quality and polyA tails:

```
java -jar trimmomatic-0.36.jar SE -threads 12 -phred33 -trimlog Sample_miRNA-NAME.log Sample_miRNA-NAME_read1.fastq.gz TRIMMED/Sample_miRNA-NAME_read1.fastq ILLUMINACLIP:trimmomatic_adapter.fa:2:30:10 TRAILING:3 LEADING:3 SLIDINGWINDOW:4:15

fastx_trimmer -l 25 -i  TRIMMED/Sample_miRNA-NAME_read1.fastq -o  TRIMMED/Sample_miRNA-NAME_R1.fastq -Q33 -m 16

```
**Step 2:** Map Sequencing Data using OASIS

Fastq files are compressed using [Oasis compressor](http://oasis.ims.bio/manual/srna_input.html#oasis-compressor) and submiited online for Oasis sRNA detection pipeline.

**Step 3:**  Filtering Count

miRNAs expressed at a minimum count of 10 reads in at least 50% of the samples per experimental condition were retained, producing a final dataset of 320 miRNAs in the discovery and replication sets. This was achieved by running two perl programs as shown below. First the results from oasis were merged per Sample and filtered there after
```
perl Join_Count_miRNA.pl /PATH/TO/OASIS/OUPUT/FOLDER

perl Filter_On_Consolidated_miRNA.pl /PATH/TO/CONSOLIDATED_RESULT File 

```
**Step 4:** Normalization of data 

Filtered row counts were  log2 transformed, before being mean normalized using JMP Genomics 8 (SAS Institute).

### miRNA-eQTL analysis

For each miRNA in our replication dataset, the level of expression was tested against all variants (MAF > 5%, HWE p-value >0.05) located within a window of **200 kb** centered from the miRNA.

The following model was used to test for miRNA-SNP associations using **100,000** permutations to assess statistical significance:

**miRNA expression = μ + SNP + Age + Sex + WBC + Parasitemia + ε**

**Step 1:** Fetch SNP's in cis region of each miRNA

```
plink --bfile $MAIN_PLINK_FILE_NAME --chr $chr  --from-bp $s1 --to-bp $s2 --recode --out $ID --make-bed

```

$ID: miRNAID       

$chr: miRNA Chromosome      

$s1: miRNA START-100000 

$s2: miRNA END+100000

$COV: Covariate file

**Step 2:** miRNA-SNP associations with  100,000 permutation
```
plink --all-pheno --bfile $ID --covar $COV --linear interaction --no-sex --pheno PHENOFOLDER/$ID\.txt --out  100000/nontdtINT  --parameters 1-10 --mperm 100000 --seed 1234567--tests 10

```
### Mediation analysis
Mediation analysis was performed using the R package “Mediation”. This analysis was restricted to the miRNAs under genetic control and that are significantly associated with parasitemia. An example code of the analysis between SNP **rs114136945** and miRNA **miR_598_3p** is provided below

```
model.0 <- lm(Log2_Parasitemia ~ rs114136945, data)
summary(model.0)

model.miR <- lm(miR_598_3p ~ rs114136945, data)
summary(model.miR)

model.paras <- lm(Log2_Parasitemia ~ rs114136945 + miR_598_3p, data)
summary(model.paras)

results <- mediate(model.miR, model.paras, treat = "rs114136945", mediator = "miR_598_3p", boot = TRUE, sims=1000)
summary(results)
```

# mRNA-Analysis:

### Dependencies
**REFERENCE**: Ensembl494 GRCh38 release-84

[**STAR**](https://github.com/alexdobin/STAR): v2.5.0c

[**cufflinks**](http://cole-trapnell-lab.github.io/cufflinks/):  v2.2.1


### Usage Pipeline

**Step 1:** Align trimmed RNA Sequencing Data and create Index of the bam
```
STAR --genomeDir /PATH/STAR/REFERENCE/INDEX/ --readFilesCommand gunzip -c  --readFilesIn Sample_NAME_read1_trimmomatic_1PE.gz Sample_NAME_read2_trimmomatic_2PE.gz --outReadsUnmapped Fastx --outSAMunmapped Within --runThreadN 28 --outFileNamePrefix Sample_NAME --outSAMtype BAM SortedByCoordinate

samtools index Sample_NAME/Aligned.sortedByCoord.out.bam
```
**Step 2:** Calculate FPKM 
```
cufflinks -p 10 --library-type fr-firststrand -o Sample_NAME/ -G REFERENCE.gtf Sample_NAME/Aligned.sortedByCoord.out.bam
```

**Step 3:** Convert FPKM To tpm 
```
perl Convert_FPKM_To_TPM_mRNA.pl /PATH/TO/CUFFLINK
```
**Step 4:** Filter TPM based on the experimental condition

```
Filter_TPM_mRNA.pl /PATH/TO/Consolidate_TPM.txt
```

**Step 5:** Normalization of Data 

Filterd TPM data is log10-scaled before being  IQR normalized using JMP Genomics (SAS Institute).
