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
include { SAM; COVERAGE; SEED; METADECODER } from './modules/metadecoder'
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
    take:
      ctgReadsCh 
    main:
        INDEX(ctgReadsCh)
        MAP(ctgReadsCh, INDEX.out)
        DEPTHS( MAP.out)
    emit:
        DEPTHS.out  
        MAP.out 

} 

workflow METADEC {
    // Abundance subworkflow
    take:
      contigsBamCh
      
    main:
        SAM(contigsBamCh)
        COVERAGE(SAM.out.map{it -> it[1]}.collect())
        SEED(contigsBamCh)
        METADECODER(contigsBamCh,  SEED.out, COVERAGE.out)
    emit:
        METADECODER.out
}

workflow {
    VERSIONS()
    FASTP ( reads )
    ASSEMBLE( FASTP.out.reads )
    AB( ASSEMBLE.out.join(FASTP.out.reads) )
    
    PRODIGAL( ASSEMBLE.out )
    
    //Binning
    MAXBIN(    ASSEMBLE.out.join(FASTP.out.reads) )
    METABAT2(  ASSEMBLE.out.join(AB.out[0]) )
    METADEC(   ASSEMBLE.out.join(AB.out[1]))

    DASTOOL( ASSEMBLE.out.join(MAXBIN.out.bins).join(METABAT2.out.bins).join(METADEC.out) )
    QUAST( ASSEMBLE.out.map{it -> it[1]}.collect() )

    // Collect all the relevant file for MultiQC
    MULTIQC( FASTP.out.json.mix( QUAST.out ).collect() )  
   
}