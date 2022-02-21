 
process MULTIQC {
    publishDir params.outdir, mode:'copy'
       
    input:
    path '*'  
    
    output:
    path 'multiqc_*'
     
    script:
    """
    multiqc  . 
    """

    stub:
    """
    ls -l > multiqc_input_files.txt
    """
} 