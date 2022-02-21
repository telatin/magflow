/* 
    MAGflow
*/

/* 
    Input parameters 
*/
nextflow.enable.dsl = 2
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = false

/*
  Modules
*/
include { VERSIONS; ASSEMBLE; QUAST; DEPTHS; MAXBIN; METABAT2; DASTOOL  } from './modules/mag'
include { MAP; INDEX } from './modules/bwa'
include { FASTP; PRODIGAL } from './modules/misc'
include { MULTIQC } from './modules/qc'


reads = Channel
        .fromFilePairs(params.reads, checkIfExists: true)

        
// prints to the screen and to the log
log.info """
         MagFlow
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}

         Specs        : ${params.max_cpus} CPUs, ${params.max_memory} RAM
         """
         .stripIndent()



workflow AB {
    // Abundance subworkflow
    take:
      reads
      contigs
    main:
        INDEX(contigs)
        MAP(reads, INDEX.out)
        DEPTHS( MAP.out)
    emit:
        DEPTHS.out
}

workflow {
    VERSIONS()
    FASTP ( reads )
    ASSEMBLE( FASTP.out.reads )
    AB( FASTP.out.reads, ASSEMBLE.out )
    PRODIGAL( ASSEMBLE.out )
    MAXBIN( FASTP.out.reads, ASSEMBLE.out )
    METABAT2(  ASSEMBLE.out.join(AB.out) )
    DASTOOL( ASSEMBLE.out.join(MAXBIN.out.bins).join(METABAT2.out.bins) )
    QUAST( ASSEMBLE.out.map{it -> it[1]}.collect() )

    // Collect all the relevant file for MultiQC
    MULTIQC( FASTP.out.json.mix( QUAST.out ).collect() )  

}