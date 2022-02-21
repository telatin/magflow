#!/bin/bash

mamba create -n magflow -c conda-forge -c bioconda -y \
 fastp seqfu bwa samtools \
 das_tool maxbin2 metabat2 megahit \
 prodigal multiqc quast \
 "bamtocov>=2.6.1" checkm-genome drep

echo conda env export > env.yaml
echo head -n -1 env.yaml | tail -n +2 > microenv.yaml
