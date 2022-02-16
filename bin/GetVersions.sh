#!/usr/bin/env bash
echo "fastp: $(fastp --version 2>&1 | grep -oP '\d+\.\d+\.?\d*')" > versions.txt
echo "maxbin2: $(run_MaxBin.pl -version | grep -oP '\d+\.\d+\.?\d*' | head -n 1)" >> versions.txt
echo "samtools: $(samtools --version | grep -oP '\d+\.\d+\.?\d*' | head -n 1)" >> versions.txt
echo "bwa: $(bwa 2>&1 | grep -i Version | grep -oP '\d+\.\d+\.?\d*')" >> versions.txt
echo "dastool: $(DAS_Tool -v | grep -oP '\d+\.\d+\.?\d*')" >> versions.txt
echo "megahit: $(megahit --version 2>&1 | grep -oP '\d+\.\d+\.?\d*')" >> versions.txt
echo "prodigal: $(prodigal 2>&1 | grep PRODIGAL | grep -oP '\d+\.\d+\.?\d*')" >> versions.txt
echo "quast: $(quast --version 2>&1 | grep -oP '\d+\.\d+\.?\d*')" >> versions.txt
