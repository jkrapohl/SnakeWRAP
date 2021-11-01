# metaWRAP-Snakemake
======
A Snakemake script for automation of the metaWRAP modules

This Snakefile is designed for use with the metaWRAP wrapper suite and the Snakemake workflow management system. Specifically, it makes use of the shell scripts provided within metaWRAP and is managed by Snakemake to llow for larger scale processing of data while maintaining much of the flexibility provided by the modular nature of metaWRAP. This may be of import in institutions where HPC is available.

## Instructions:

### 1) Install Snakemake and metaWRAP 
Install both Snakemake and metawrap according to best installation practices as detailed:
https://github.com/snakemake/snakemake
https://github.com/bxlab/metaWRAP

#### Download all databases as required by metaWRAP
