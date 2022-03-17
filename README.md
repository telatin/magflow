# magflow

```mermaid
graph TD;
 INPUT_READS --> FASTP;
 FASTP --> SEQ_SCREEN;
 SEQ_SCREEN --> KRAKEN2;
 KRAKEN2 --> KRONA_plot;
 SEQ_SCREEN --> ASSEMBLY;
 ASSEMBLY --> VirFinder;
 ASSEMBLY --> VirSorter;
 ASSEMBLY --> VIBRANT;
 ASSEMBLY --> Phigaro;
 VirFinder --> CD-HIT;
 VirSorter --> CD-HIT ;
 VIBRANT --> CD-HIT ;
 Phigaro --> CD-HIT ;
  
```
