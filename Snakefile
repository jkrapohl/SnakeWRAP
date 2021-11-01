## Configuration file
import os
if len(config) == 0:
  if os.path.isfile("./config.yaml"):
    configfile: "./config.yaml"
  else:
    sys.exit("Make sure there is a config.yaml file in " + os.getcwd() + " or specify one with the --configfile commandline parameter.")

## Make sure that all expected variables from the config file are in the config dictionary
configvars = ['metatext', 'scripts', 'assembly', 'blobplot', 'kraken', 'salmon', 'taxator', 'prokka', 'output', 'readlength', 'ncores', 'input', 'fqext1', 'fqext2', 'fqsuffix', 'output']
for k in configvars:
	if k not in config:
		config[k] = None

## If any of the file paths is missing, replace it with ""
def sanitizefile(str):
	if str is None:
		str = ''
	return str

config['metatext'] = sanitizefile(config['metatext'])

## Read metadata
if not os.path.isfile(config["metatext"]):
  sys.exit("Metadata file " + config["metatext"] + " does not exist.")

import pandas as pd
samples = pd.read_csv(config["metatext"], sep='\t')

if not set(['names']).issubset(samples.columns):
  sys.exit("Make sure 'names' in column header in " + config["metatext"])


## Sanitize provided input and output directories
import re
def getpath(str):
	if str in ['', '.', './']:
		return ''
	if str.startswith('./'):
		regex = re.compile('^\./?')
		str = regex.sub('', str)
	if not str.endswith('/'):
		str += '/'
	return str

outputdir = getpath(config["output"])
inputdir = getpath(config["input"])
scriptdir = getpath(config["scripts"])


## ------------------------------------------------------------------------------------ ##
def rule_all_blob(wildcards):
	if config["blobplot"]:
		input = outputdir + "blobology/blobplot_figures_only_binned_contigs/final_assembly.binned.blobplot.bin.png"
	else:
		input = outputdir + "blobology/blobplot_figures_only_binned_contigs/skip.png"
	return input


def rule_all_quant(wildcards):
	if config["salmon"]:
		input = outputdir + "bin_quantification/bin_abundance_heatmap.png"
	else:
		input.append(outputdir + "bin_quantification/skip.txt")
	return input

rule all:
	input:
		rule_all_blob,
		outputdir + "kraken/kronagram.html",
		rule_all_quant,
		directory(outputdir + "bin_annotation/bin_funct_annotations"),
		outputdir + "bin_classification/bin_taxonomy.tab"
#
## ------------------------------------------------------------------------------------ ##
## Quality control
## ------------------------------------------------------------------------------------ ##
## QC Module
rule fastqc:
	input:
		fastq1 = inputdir + "{sample}_" + str(config["fqext1"]) + "." + str(config["fqsuffix"]) + ".gz",
		fastq2 = inputdir + "{sample}_" + str(config["fqext2"]) + "." + str(config["fqsuffix"]) + ".gz",
		script = scriptdir + "read_qc_snakemake.sh"
	output:
		outputdir + "QCModule/{sample}_final_pure_reads_1.fastq", 
		outputdir + "QCModule/{sample}_final_pure_reads_2.fastq"
	params:
		FastQC = outputdir + "QCModule",
		sample = "{sample}"
	log:
		outputdir + "logs/fastqc/{sample}.log"
	benchmark:
		outputdir + "benchmarks/fastqc/{sample}.txt"
	threads:
		config["ncores"]
	shell:
		"""
		echo "Starting QC Module"
		{input.script} -1 {input.fastq1} -2 {input.fastq2} -o {params.FastQC} -t {threads} -j {params.sample}
		"""

rule concatenate_files:
	input:
		forward = expand(outputdir + "QCModule/{sample}_final_pure_reads_1.fastq", sample = samples.names.values.tolist()),
		reverse = expand(outputdir + "QCModule/{sample}_final_pure_reads_2.fastq", sample = samples.names.values.tolist())
	output:
		forward = outputdir + "QCModule/all_pure_reads_1.fastq",
		reverse = outputdir + "QCModule/all_pure_reads_2.fastq"
	log:
		outputdir + "logs/concatenate"
	benchmark:
		outputdir + "benchmarks/concatenate"
	shell:
		"cat {input.forward} >> {output.forward} ; cat {input.reverse} >> {output.reverse}"
	
## Assembly Module
rule assembly:
	input:
		cleaned1 = outputdir + "QCModule/all_pure_reads_1.fastq",
		cleaned2 = outputdir + "QCModule/all_pure_reads_2.fastq",
		script = scriptdir + "assembly.sh"
	output:
		outputdir + "assembly_module/final_assembly.fasta"
	params:
		assembler = config["assembly"],
		output_assembly = outputdir + "assembly_module"
	log:
		outputdir + "logs/assembly.log"
	benchmark:
		outputdir + "benchmarks/assembly.txt"
	threads:
		config["ncores"] 	
	shell:
		"""
		echo "Starting Assembly Module"
		{input.script} -1 {input.cleaned1} -2 {input.cleaned2} -o {params.output_assembly} -t {threads} --{params.assembler}
		"""

## Kraken Module
rule kraken:	
	input:
		final_assembly = outputdir + "assembly_module/final_assembly.fasta",
		cleaned1 = outputdir + "QCModule/all_pure_reads_1.fastq",
                cleaned2 = outputdir + "QCModule/all_pure_reads_2.fastq",
		script = scriptdir + "kraken.sh"
	output:
		outputdir + "kraken/kronagram.html"
	params:
		output_kraken = outputdir + "kraken",
		kraken_run = str(config["kraken"])
	log:
		outputdir + "logs/kraken/kraken.log"
	benchmark:
		outputdir + "benchmarks/kraken.txt"
	threads:
		config["ncores"]
	shell:
		"""
		if [ {params.kraken_run} == 'False' ]
		then
			echo 'Skipping Kraken Module'
			if [ ! -d {params.output_kraken} ] ; then mkdir {params.output_kraken} ; fi
			if [ ! -f {params.output_kraken}/kronagram.html ] ; then touch {params.output_kraken}/kronagram.html ; fi
			echo 'THIS FILE IS INTENTIONALLY LEFT BLANK' >> {params.output_kraken}/kronagram.html
			echo 'DELETE THIS FILE IF YOU WISH TO RUN KRAKEN' >> {params.output_kraken}/kronagram.html
		else
			echo 'Starting Kraken Module'
			{input.script} -o {params.output_kraken} -t {threads} {input.final_assembly} {input.cleaned1} {input.cleaned2}
		fi
		"""

## Binning Module
rule binning:
	input:
		final_assembly = outputdir + "assembly_module/final_assembly.fasta",
		forward = expand(outputdir + "QCModule/{sample}_final_pure_reads_1.fastq", sample = samples.names.values.tolist()),
		reverse = expand(outputdir + "QCModule/{sample}_final_pure_reads_2.fastq", sample = samples.names.values.tolist()),
		script = scriptdir + "binning.sh"
	output: 
		directory(outputdir + "binning/metabat2_bins"),
		directory(outputdir + "binning/maxbin2_bins"),
		directory(outputdir + "binning/concoct_bins")
	params:
		bin_output = outputdir + "binning"
	log:
		outputdir + "logs/binning"
	benchmark:
		outputdir + "benchmarks/binning.txt"
	threads:
		config["ncores"]
	shell:
		"""
		echo "Starting Binning Module"
		{input.script} --run-checkm --metabat2 --maxbin2 --concoct -o {params.bin_output} -t {threads} -a {input.final_assembly} {input.forward} {input.reverse}
		"""

## Bin Refinement Module
rule bin_refinement:
	input:
		metabat2_bin = directory(outputdir + "binning/metabat2_bins"),
		maxbin2_bin = directory(outputdir + "binning/maxbin2_bins"),
		concoct_bin = directory(outputdir + "binning/concoct_bins"),
		script = scriptdir + "bin_refinement.sh"
	output:
		directory(outputdir + "refined_bins/metawrap_70_10_bins")
	params:
		rbin_output = outputdir + "refined_bins"
	log:
		outputdir + "logs/bin_refinement"
	benchmark:
		outputdir + "benchmarks/bin_refinement.txt"
	threads:
		config["ncores"]
	shell:
		"""
		echo "Starting Bin Refinement Module"
		{input.script} -o {params.rbin_output} -t {threads} -A {input.metabat2_bin} -B {input.maxbin2_bin} -C {input.concoct_bin}
		"""

## Quantify Bins Module
rule bin_quantify:
	input:
		final_assembly = outputdir + "assembly_module/final_assembly.fasta",
		bins_refined = directory(outputdir + "refined_bins/metawrap_70_10_bins"),
		script = scriptdir + "quant_bins.sh"
	output:
		outputdir + "bin_quantification/bin_abundance_heatmap.png"

	params:
		output_q = outputdir + "bin_quantification",
		salmon_run = str(config["salmon"]),
		salmon_not = outputdir + "bin_quantification",
		od = outputdir
	log:
		outputdir + "logs/bin_quantification"
	benchmark:
		outputdir + "benchmarks/bin_quantification.txt"
	threads:
		config["ncores"]
	shell:
		"""
		if [ {params.salmon_run} == "FALSE" ]
		then
			echo "Skipping Quantification Module"
			if [ ! -d {params.salmon_not} ] ; then mkdir {params.salmon_not} ; fi
			if [ ! -f {params.salmon_not}/skip.txt ] ; then touch {params.salmon_not}/skip.txt ; fi
			echo "THIS FILE IS INTENTIONALLY LEFT BLANK" >> {params.salmon_not}/skip.txt
			echo "DELETE THIS FILE IF YOU WISH TO RUN QUANTIFY BINS" >> {params.salmon_not}/skip.txt
		else
			echo "Starting Quantify Bins Module"
			{input.script} -t {threads} -b {input.bins_refined} -o {params.output_q} -a {input.final_assembly} {params.od}QCModule/*_final_pure_reads_*
		fi
		"""

## Classify Bins Module
rule classify_bins:
	input:
		bins = directory(outputdir + "refined_bins/metawrap_70_10_bins"),
		script = scriptdir + "classify_bins.sh"
	output:
		outputdir + "bin_classification/bin_taxonomy.tab"
	params:
		output_class = outputdir + "bin_classification",
		taxator_run = str(config["taxator"])
	log:
		outputdir + "logs/bin_classification"
	benchmark:
		outputdir + "benchmarks/bin_classification"
	threads:
		config["ncores"]
	shell:
		"""
		if [ {params.taxator_run} == "FALSE" ]
		then
			echo "Skipping Classify Bins Module"
			if [ ! -d {params.output_class} ] ; then mkdir {params.output_class} ; fi
			if [ ! -f {params.output_class}/bin_taxonomy.tab ] ; then touch {params.output_class}/bin_taxonomy.tab ; fi
			echo "THIS FILE IS INTENTIONALLY LEFT BLANK" >> {params.output_class}/bin_taxonomy.tab
			echo "DELETE THIS DIRECTORY IF YOU WISH TO RUN CLASSIFY BINS" >> {params.output_class}/bin_taxonomy.tab
		else
			echo "Starting Classify Bins Module"
			{input.script} -t {threads} -b {input.bins} -o {params.output_class}
		fi
		"""

## Annotate Bins Module
rule annotate_bins:
	input:
		r_bins = directory(outputdir + "refined_bins/metawrap_70_10_bins"),
		script = scriptdir + "annotate_bins.sh"
	output:
		directory(outputdir + "bin_annotation/bin_funct_annotations")
	params:
		output_an = outputdir + "bin_annotation",
		prokka_run = str(config["prokka"])
	log:
		outputdir + "logs/bin_annotation"
	benchmark:
		outputdir + "benchmarks/bin_annotation"
	threads:
		config["ncores"]
	shell:
		"""
		if [ {params.prokka_run} == "FALSE" ]
		then
			echo "Skipping Annotate Bins Module"
			if [ ! -d {params.output_an} ] ; then mkdir {params.output_an} ; fi
			if [ ! -f {params.output_an}/skip.gff ] ; then touch {params.output_an}/skip.gff ; fi
			echo "THIS FILE IS INTENTIONALLY LEFT BLANK" >> {params.output_an}/bin_skip.gff
			echo "DELETE THIS DIRECTORY IF YOU WISH TO RUN CLASSIFY BINS" >> {params.output_an}/skip.gff
		else
			echo "Starting Annotate Bins Module"
			{input.script} -t {threads} -o {params.output_an} -b {input.r_bins}
		fi
		"""

## Blobology Module
rule blobology:
	input:
		final_assembly = outputdir + "assembly_module/final_assembly.fasta",
		bins_refined = directory(outputdir + "refined_bins/metawrap_70_10_bins"),
		script = scriptdir + "blobology.sh"
	output:
		outputdir + "blobology/blobplot_figures_only_binned_contigs/final_assembly.binned.blobplot.bin.png"
	params:
		output_blob = outputdir + "blobology",
		blob_run = str(config["blobplot"]),
		od = outputdir
	log:
		outputdir + "logs/blobology/blobology.log"
	benchmark:
		outputdir + "benchmarks/blobology/blobology.txt"
	threads:
		config["ncores"]
	shell:
		"""
		if [ {params.blob_run} == "FALSE" ]
		then
			echo "Skipping Blobology Module"
			if [ ! -d {params.output_blob}/blobplot_figures ] ; then mkdir {params.output_blob}/blobplot_figures ; fi
			if [ ! -f {params.output_blob}/blobplot_figures/skip.png ] ; then touch {params.output_blob}/blobplot_figures/skip.png ; fi
			echo "THIS FILE IS INTENTIONALLY LEFT BLANK" >> {params.output_blob}/blobplot_figures_only_binned_contigs/skip.png
			echo "DELETE THIS FILE IF YOU WISH TO RUN BLOBOLOGY" >> {params.output_blob}/blobplot_figures_only_binned_contigs/skip.png
		else
			echo "Starting Blobology Module"
			{input.script} --bins {input.bins_refined} -t {threads} -a {input.final_assembly} -o {params.output_blob} {params.od}QCModule/*_final_pure_reads_*
		fi
		"""

## ------------------------------------------------------------------------------------ ##
## Success and failure messages
## ------------------------------------------------------------------------------------ ##
onsuccess:
	print("Success! The Snakemake metaWRAP workflow is completed.")

onerror:
	print("Error! The Snakemake metaWRAP workflow aborted.")
