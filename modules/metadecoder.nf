process SAM {
    tag "$sample_id"
    label "process_low"

    input:
    tuple val(sample_id), path(ctg),path(bam)
    
    output:
    tuple val(sample_id), path("${sample_id}.sam")


    script:
    """
    samtools view -h ${bam} > ${sample_id}.sam
    """  

    stub:
    """
    touch ${sample_id}.sam
    """    
}

process COVERAGE {
    label "process_low"

    container "/nbi/software/testing/GMH-Tools/images/metadecoder-1.0.13.simg"

    input:
    path("*") 
    
    output:
    path("metadecoder.coverage")


    script:
    """
    metadecoder coverage -s *.sam -o metadecoder.coverage
    """  

    stub:
    """
    ls *.sam > metadecoder.coverage
    """    
}

process SEED {
    tag "$sample_id"
    label "process_low"
    container "/nbi/software/testing/GMH-Tools/images/metadecoder-1.0.13.simg"

    input:
    tuple val(sample_id), path(contigs),path(bam)
    
    output:
    tuple val(sample_id), path("${sample_id}.seed")

    script:
    """
    metadecoder seed --threads ${task.cpus} -f ${contigs} -o ${sample_id}.seed
    """  

    stub:
    """
    ls * >  ${sample_id}.seed
    """    
    
}

process METADECODER {
    tag "$sample_id"
    label "process_high"
    container "/nbi/software/testing/GMH-Tools/images/metadecoder-1.0.13.simg"


    input:
    tuple val(sample_id), path(contigs), path(bam)
    tuple val(sample_id), path(seed)
    path(coverage)
    
    output:
    tuple val(sample_id), path("${sample_id}.metadecode*"), optional: true

    script:
    """
    metadecoder cluster --min_sequence_length 2000 -f ${contigs} -c ${coverage} -s ${seed} -o ${sample_id}.metadecode
    """  

    stub:
    """
    for i in 1 2 3 4 5 6;
    do 
         echo "metadecoder cluster --min_sequence_length 2000 -f ${contigs} -c ${coverage} -s ${seed} -o ${sample_id}.metadecode" > ${sample_id}.metadecode.\$i.fasta
    done
    """    
    
}
