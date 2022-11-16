#!/bin/bash
set -euxo pipefail
mamba create -n magflow -c conda-forge -c bioconda -y \
 fastp seqfu bwa samtools kraken2 \
 das_tool maxbin2 metabat2 megahit semibin \
 prodigal multiqc quast \
 "bamtocov>=2.7" checkm-genome drep

echo "conda env export > env.yaml"
echo "head -n -1 env.yaml | tail -n +2 > microenv.yaml"
conda env export -n magflow > env.yaml
cat env.yaml | head -n -1 | tail -n +2  > microenv.yaml
