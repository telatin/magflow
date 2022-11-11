# magflow

```bash
conda activate magflow
nextflow run telatin/magflow \
  --reads "/data/*_R{1,2}.fastq.gz" --outdir "mags" \
  --max_cpus 32 --max_memory 64.GB
 ``` 
