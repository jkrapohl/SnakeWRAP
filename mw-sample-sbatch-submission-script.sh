#!/bin/bash
#submit with 'sbatch mw-script </path/name_of_config_file>'

#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=8   # number of processor cores (i.e. tasks)
#SBATCH --nodes=12   # number of nodes
#SBATCH --mem-per-cpu=16G   # memory per CPU core
#SBATCH -J "metaWRAP"   # job name

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
#initialize conda and activate environment
#module load miniconda3
#source path/to/source/bin
#source activate metawrap-env

source activate metawrap-env
source activate --stack snakemake

#call metaWRAP workflow
#date
echo "Running metaWRAP pipeline workflow..."
echo "command: snakemake --nolock --use-conda --cores 16 --configfile $1"
snakemake --nolock --use-conda --cores 16 --configfile $1

#snakemake --use-conda --cores 16 --configfile configs/test.yaml

