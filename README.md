# Snakemake-metaWRAP

A Snakemake script for automation of metaWRAP modules

This Snakefile is designed for use with the metaWRAP wrapper suite and the Snakemake workflow management system. Specifically, it makes use of the shell scripts provided within metaWRAP and is managed by Snakemake to allow for larger scale processing of data while maintaining much of the flexibility provided by the modular nature of metaWRAP. This may be of import in institutions where HPC is available.

## Instructions:

### 1) Install Snakemake and metaWRAP 
Install both Snakemake and metawrap according to best installation practices as detailed here:

https://github.com/snakemake/snakemake

https://github.com/bxlab/metaWRAP

##### Download all databases as required by metaWRAP

### 2) Update:
Paths in config-metawrap (found in metaWRAP bin)

Paths in Snakemake submission config (e.g. sample-config.yaml)

Input file names in metatext file

Core usage in mw-sample-sbatch-submission-script.sh

### 3) Copy read_qc_snakemake.sh into the directory containing the metaWRAP module scripts
This is in the metaWRAP bin/metawrap-modules directory. Scripts can be placed into another directory for easy access, but must have the path given in the submission config file as well as config-metawrap

### 4) Download all fastq files. Make sure they are gzipped, in correct format, and are listed correctly in the metatext.txt file, including names as header.

### 5) Run by submitting the mw-sample-sbatch-submission-script.sh with sbatch.
#### Alternatively this can be run on the command line:

##### source activate metawrap-env
##### source activate --stack snakemake
##### snakemake --nolock --cores # --configfile configfile_name


## Common bug fixes
### If using an older version of metaWRAP (such as 1.2.1) some bugs may result from conflicting or outdated environments.
### Some common fixes are:

ReadQC module error - check if inputs are in correct format (e.g. SRR1235678.sra.fq.gz, ERR0124567.fastq.gz, etc)

Joblib error- pip install joblib into snakemake environment and base

Cannot find/use NCBI database: Download newer version (such as version 4/5)

Copy config-metawrap into scripts folder (may resolve some path issues)

CheckM error- run at least 32 GB RAM per node (usually 4 or more cores)

Classify bins module error- update classify bins.sh and prunebasthits.py, found in metaWRAP github

Blobology module bowtie error- conda install tbb=2020.2 into metawrap env

Annotate module openssl error – in mw conda install metawrap-mg=1.2.1 openssl=1.0 (metawrap-mg=version)



