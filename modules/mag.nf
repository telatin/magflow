process ASSEMBLE {
    tag "$sample_id"
    label "process_high"
    publishDir "$params.outdir/assemblies/", 
        mode: 'copy'

    input:
    tuple val(sample_id), path(reads) 

    
    output:
    tuple val(sample_id), path("${sample_id}.contigs.fa")  

    script:
    """
    megahit -1 ${reads[0]} -2 ${reads[1]} --min-contig-len 200 --out-dir megahit \\
         --out-prefix "${sample_id}" --num-cpu-threads ${task.cpus} --memory 0.9 

    seqfu cat --prefix ${sample_id} --add-name --strip-name megahit/${sample_id}.contigs.fa > ${sample_id}.contigs.fa
    """ 

    stub:
    """
    # Random number
    NUM=\$((\$RANDOM % 3 ))
    sleep \$NUM
    touch ${sample_id}.contigs.fa
    """
}

process QUAST  {
    tag "quast"
    
    publishDir "$params.outdir/", 
        mode: 'copy'
    
    input:
    path("*")  
    
    
    output:
    path("quast")

    script:
    """
    quast --threads ${task.cpus} --output-dir quast *.fa
    """

    stub:
    """
    mkdir quast
    touch quast/report.txt

    """
}
 
process MAXBIN {
    tag "$sample_id"
    label "process_medium"
    publishDir "$params.outdir/maxbin/", 
        pattern: "*.fasta",
        mode: 'copy'

    input:
    tuple val(sample_id), path(contigs), path(reads)
    
    output:
    tuple val(sample_id), path("*.maxbin.*.fasta"), optional: true, emit: bins    //Mock1.maxbin.001.fasta

    script:
    """
    run_MaxBin.pl  \
        -contig "${contigs}" \
        -out ./${sample_id}.maxbin \
        -thread ${task.cpus} \
        -reads "${reads[0]}" \
        -reads2 "${reads[1]}"
    """     

    stub:
    """
    for i in 001 002 003 004;
    do
        touch ${sample_id}.maxbin.\$i.fasta
    done
    """
}

process DEPTHS {
    tag "$sample_id"
    label "process_medium"
 

    input:
    tuple val(sample_id), path(bamfile) 
    
    output:
    tuple val(sample_id), path("${sample_id}.depth.txt")

    script:
    """
    jgi_summarize_bam_contig_depths \\
        --outputDepth ${sample_id}.depth.txt \\
        ${sample_id}.bam
 
    """     

    stub:
    """
    touch ${sample_id}.depth.txt
    """
}


process METABAT2 {
    tag "$sample_id"
    label "process_medium"
    publishDir "$params.outdir/metabat/",
        mode: 'copy'
 

    input:
    tuple val(sample_id), path(contigs), path(depth) 
    
    
    
    output:
    tuple val(sample_id), path("*metabat.*.fa"), optional: true, emit: bins //Mock1.metabat.5.fa

    script:
    """
    echo ${sample_id}
    if [[ -e "${sample_id}.depth.txt" ]] &&  [[ -e "${sample_id}.contigs.fa" ]]; then
        metabat2 \\
            -i ${contigs} \\
            -a ${depth} \\
            -o ${sample_id}.metabat \\
            -t ${task.cpus}  -m 1500  -v --unbinned
    fi
    """     
    stub:
    """
    for i in 1 2 3 4;
    do
        touch ${sample_id}.metabat.\$i.fa
    done
    """
}

process DASTOOL {
    tag "$sample_id"
    label "process_medium"
    publishDir "$params.outdir/bins/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), file('contigs.fna'), file("*"), file("*"), file("*")
    
    output:
    tuple val(sample_id), file("${sample_id}.summary.txt"), optional: true, emit: summary
    tuple val(sample_id), file("${sample_id}/*.fa"),    optional: true, emit: bins

    script:
    """
    BinningStep.pl --failsafe -p ${sample_id} -t ${task.cpus} 
    #mv refine_DASTool_summary.txt ${sample_id}.summary.txt
    #mv refine_DASTool_bins ${sample_id}
    """
    stub:
    """
    ls -l > ${sample_id}.summary.txt
    mkdir -p ${sample_id}
    touch ${sample_id}/bins.{1,2,3}.fa
    """
}

process DASTOOL2 {
    tag "$sample_id"
    label "process_medium"
    publishDir "$params.outdir/bins/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), file('contigs.fna'), file("*"), file("*"), file("*")
    
    output:
    tuple val(sample_id), file("${sample_id}.summary.txt"), optional: true, emit: summary
    tuple val(sample_id), file("${sample_id}/*.fa"),    optional: true, emit: bins

    script:
    """
    dastool.py --failsafe -t ${task.cpus} -i . -o refine
    """
    stub:
    """
    ls -l > ${sample_id}.summary.txt
    mkdir -p ${sample_id}
    touch ${sample_id}/bins.{1,2,3}.fa
    """
}

process VERSIONS {
    publishDir "$params.outdir/",
        mode: 'copy'     

    output:
    path("versions.txt"), optional: true

    script:
    """
    GetVersions.sh
    """
}