--- 
title: 'METASnake: A Snakemake Workflow to facilitate automated processing of metagenomic data through the metaWRAP pipeline'
tags:
  - metaWRAP
  - snakemake
  - metagenomics
  - whole genome shotgun sequencing
  - metagenome assembled genome
  - pipeline
 authors:
  - name: John Krapohl
    orcid: 0000-0003-0364-6387
    affiliation: 1
  - name: Brett E. Pickett
    orcid: 0000-0001-7930-8160
    affiliation: 1
    affiliations:
 - name: Department of Microbiology and Molecular Biology, Brigham Young University; Provo, UT, USA
   index: 1
date: 23 November 2021
bibliography: paper.bib
--- 

# Summary

As sequencing technology has become cheaper and more readily accessible, the need for the computational capacity to process sequencing data has become apparent. The merits of
Whole Genome Sequencing have been particularly useful in relation to the field of metagenomics. Substantial effort has been spent developing software and computational pipelines 
to cater to this growing need, notably MetaWRAP. MetaWRAP combines many of the necessary tools to process reads, create bins, and visualize data within a robust modular design 
(Uritskiy, DiRuggiero, & Taylor, 2018). The primary limitation arising from such a design is the inability to scale its usage to massive datasets. Snakemake is a widely-used 
Python based workflow management system that automates repetitive tasks, allowing it to be both scalable and reproducible (Mölder et al., 2021). By integrating the MetaWRAP 
pipeline into Snakemake, the customizable nature of MetaWRAP can be preserved even when automatically processing large datasets through a Snakemake workflow. This script 
automates the tasks performed within MetaWRAP, allowing for individual modules to be toggled on and off using Snakemake defined “rules”.

# Statement of need

While the processing of metagenomics datasets is untractable for most personal computers, researchers with access to high-performance computing infrastructure can make take full 
advantage of this script. The core functions found within MetaWRAP which involve read quality control, assembly, and binning are required and cannot be toggled off. This 
includes several refinement steps that are unique to MetaWRAP, which allow it to create higher quality bins than existing standalone programs (Uritskiy et al., 2018). The user 
can decide whether computationally-expensive modules that generate figures, such as Kraken and Blobology, can be skipped. 

Snakemake automatically generates a directed acyclic graph (DAG) to order tasks, track the progress of each task for each sample, and eliminate duplicate tasks for the same 
sample (Mölder et al., 2021). This is vital to efficiently processing large datasets, as jobs can fail due to insufficient memory or timing out. The input paths, output paths, 
and parameters for each job are assigned by the end-user within a configuration file. This file is read by Snakemake to prevent data from being incorrectly assigned or lost and 
to facilitate reuse and customization of the workflow. 


# Acknowledgements

We would like to thank the BYU Office of Research Computing as well as BYU for providing the funding for this work.

# References
