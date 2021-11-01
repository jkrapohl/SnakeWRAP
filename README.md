# metaWRAP-Snakemake

A Snakemake script for automation of metaWRAP modules

This Snakefile is designed for use with the metaWRAP wrapper suite and the Snakemake workflow management system. Specifically, it makes use of the shell scripts provided within metaWRAP and is managed by Snakemake to allow for larger scale processing of data while maintaining much of the flexibility provided by the modular nature of metaWRAP. This may be of import in institutions where HPC is available.

## Instructions:

### 1) Install Snakemake and metaWRAP 
Install both Snakemake and metawrap according to best installation practices as detailed here:

https://github.com/snakemake/snakemake

https://github.com/bxlab/metaWRAP

##### Download all databases as required by metaWRAP

### 2) Update:
#### Paths in config-metawrap (found in metaWRAP bin)
#### Paths in Snakemake submission config (e.g. sample-config.yaml)
#### Input file names in metatext file
#### Core usage in mw-sample-sbatch-submission-script.sh

### 3) Copy read_qc_snakemake.sh into the directory containing the metaWRAP module scripts
#### This is in the metaWRAP bin/metawrap-modules directory. Scripts can be placed into another directory for easy access, but must have the path given in the submission config file

### 4) Download all fastq files. 

### 5) Run by submitting the mw-sample-sbatch-submission-script.sh with sbatch.
#### Alternatively this can be run on the command line:

##### source activate metawrap-env
##### source activate --stack snakemake
##### snakemake --nolock --cores # --configfile configfile_name
