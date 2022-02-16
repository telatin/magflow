process FASTP {
    /* 
       fastp process to remove adapters and low quality sequences
    */
    tag "filter $sample_id"
    label "process_low"

    input:
    tuple val(sample_id), path(reads) 
    
    output:
    tuple val(sample_id), path("${sample_id}_filt_R*.fastq.gz"), emit: reads
    path("${sample_id}.fastp.json"), emit: json

    /*
       "sed" is a hack to remove _R1 from sample names for MultiQC
        (clean way via config "extra_fn_clean_trim:\n    - '_R1'")
   */
    script:
    """
    fastp -i "${reads[0]}" -I "${reads[1]}" \\
      -o "${sample_id}_filt_R1.fastq.gz" -O "${sample_id}_filt_R2.fastq.gz" \\
      --detect_adapter_for_pe  -j report.json -w ${task.cpus}

    
    sed 's/_R1//g' report.json | sed 's/_1\\.//g' > ${sample_id}.fastp.json 
    """  

    stub:
    """
    touch ${sample_id}.fastp.json "${sample_id}_filt_R1.fastq.gz" "${sample_id}_filt_R2.fastq.gz"

    """
}  
process PRODIGAL {
    tag { sample_id }
    label "process_medium" 
    
    publishDir "$params.outdir/proteins/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), path(contigs) 
    
    
    output:
    path("*faa"),  emit: faa
    path("*.gff"), emit: gff
    path("*.ffn"), emit: ffn

    script:
    """
    prodigal -f gff -i ${contigs} -o ${sample_id}.gff -a ${sample_id}.faa -d ${sample_id}.ffn -q -p meta -g 11
    """

    stub:
    """
    touch ${sample_id}.gff  ${sample_id}.faa ${sample_id}.ffn
    """
}

process COVERAGE {
tag { sample_id }
    label "process_medium"
    
    publishDir "$params.outdir/coverage/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), path(contigs) 
    
    
    output:
    path("*txt"),  emit: faa

    script:
    """
    bamtocov -r 
    """    

    stub:
    """
    touch id
    """
}
process MLST_SUMMARY {
    tag { sample_id }
    
    publishDir "$params.outdir/MLST/", 
        mode: 'copy'

    input:
    path("*")

    output:
    path("mlst_mqc.tsv")

    script:
    """    
    mlstToMqc.py -i summary.tsv -o mlst_mqc.tsv
    """
}