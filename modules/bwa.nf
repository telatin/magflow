
process INDEX {
    /*   input.amb
         input.ann
         input.bwt
         input.pac
         input.sa
    */
    tag "$sample_id"
    label "process_medium"
 
    input:
    tuple val(sample_id), path(contigs) 

    
    output:
    tuple val("${contigs}"), path("${contigs}.*")  

    script:
    """
    bwa index ${contigs}
    """    

    stub:
    """
    touch ${contigs}.amb ${contigs}.ann ${contigs}.bwt ${contigs}.pac ${contigs}.sa
    """
}

process MAP {
    tag "$sample_id"
    label "process_medium"
    publishDir "$params.outdir/mapping",
        mode: 'copy'

    input:
    tuple val(sample_id), path(reads) 
    tuple val(index_name), path(index)
    
    output:
    tuple val(sample_id), path("${sample_id}.bam*")  

    script:
    """
    bwa mem -t ${task.cpus} ${index_name} ${reads[0]} ${reads[1]} | samtools view -bS > temp.bam
    samtools fixmate temp.bam fixed.bam
    samtools sort -@ ${task.cpus} -o ${sample_id}.bam fixed.bam
    samtools index ${sample_id}.bam
    """    

    stub:
    """
    touch ${sample_id}.bam ${sample_id}.bam.bai
    """
}
