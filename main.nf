/* 
 *   An assembly pipeline in Nextflow DSL2
 *   -----------------------------------------

 == V6 ==
 Added MLST support
 and optional assembler (Unicycler)

 */

/* 
 *   Input parameters 
 */
nextflow.enable.dsl = 2
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = false
params.unicycler = false

/*
  Import processes from external files
  It is common to name processes with UPPERCASE strings, to make
  the program more readable (this is of course not mandatory)
*/
include { VERSIONS; ASSEMBLE; QUAST; DEPTHS; MAXBIN; METABAT2; DASTOOL  } from './modules/mag'
include { MAP; INDEX } from './modules/bwa'
include { FASTP; PRODIGAL } from './modules/misc'
/* 
 *   DSL2 allows to reuse channels
 */
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



workflow ABUND {
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
    ABUND( FASTP.out.reads, ASSEMBLE.out )
    PRODIGAL( ASSEMBLE.out )
    MAXBIN( FASTP.out.reads, ASSEMBLE.out )
    METABAT2(  ASSEMBLE.out.join(ABUND.out) )
    DASTOOL( ASSEMBLE.out.join(MAXBIN.out.bins).join(METABAT2.out.bins) )
    QUAST( ASSEMBLE.out.map{it -> it[1]}.collect() )
    /* 
    
    // QUAST requires all the contigs to be in the same directory
    QUAST( CONTIGS.map{it -> it[1]}.collect() )
    MLST(  CONTIGS.map{it -> it[1]}.collect() )

    // Prepare the summaries
    ABRICATE_SUMMARY( ABRICATE.out.map{it -> it[1]}.collect() )
    MLST_SUMMARY( MLST.out.tab )

    // Collect all the relevant file for MultiQC
    MULTIQC( FASTP.out.json.mix( QUAST.out , PROKKA.out, MLST_SUMMARY.out, ABRICATE_SUMMARY.out.multiqc).collect() )  
    */
}