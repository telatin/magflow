# magflow

```mermaid
graph TD;
 INPUT_READS --> FASTP;
 FASTP --> ASSEMBLE;
 FASTP --> "mix;
 ASSEMBLE --> AB_INDEX;
 AB_INDEX --> p6;
 FASTP --> AB_MAP;
 AB_MAP --> AB_COV;
 AB_COV --> "join";
 ASSEMBLE --> PRODIGAL;
 PRODIGAL --> "point";
 PRODIGAL --> ".";
 FASTP --> MAXBIN;
 ASSEMBLE --> MAXBIN;
 MAXBIN --> "join";
 ASSEMBLE --> "join";
 METABAT --> "join";
 ASSEMBLE --> "join";
 "join" --> DASTOOL

```
