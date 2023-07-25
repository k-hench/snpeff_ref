# `snpEff` investigation

Testing for `snpEff` response to changing the `REF` allele with an ancestral `ALT` allele

## TL;DR

Run `snpEff` using `snakemake`

```sh
snakemake -c 1 --use-conda --use-singularity -R all
```

Compare the resulting annotations in `results/genome_1/genotypes_genome_1_ann.vcf` vs. `results/genome_2/genotypes_genome_2_ann.vcf`

## Basic idea

1. start codon
2. some amino acid (syn)
3. some amino acid (non-syn)
4. some amino acid (premature stop-codon)
5. stop codon

```
pos:    123456789012345678901234
codon:  .....1--2--3--4--5--....
v1:     AAAAAATGTTTGAATACTAGGGTT
v2:     AAAAAATGTTCGACTAATAGGGTT
amino:          F  E/DY/**
```

## DNA code from [ncbi](https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi?chapter=tgencodes#SG1)

```
TTT F Phe      TCT S Ser      TAT Y Tyr      TGT C Cys  
TTC F Phe      TCC S Ser      TAC Y Tyr      TGC C Cys  
TTA L Leu      TCA S Ser      TAA * Ter      TGA * Ter  
TTG L Leu i    TCG S Ser      TAG * Ter      TGG W Trp  

CTT L Leu      CCT P Pro      CAT H His      CGT R Arg  
CTC L Leu      CCC P Pro      CAC H His      CGC R Arg  
CTA L Leu      CCA P Pro      CAA Q Gln      CGA R Arg  
CTG L Leu i    CCG P Pro      CAG Q Gln      CGG R Arg  

ATT I Ile      ACT T Thr      AAT N Asn      AGT S Ser  
ATC I Ile      ACC T Thr      AAC N Asn      AGC S Ser  
ATA I Ile      ACA T Thr      AAA K Lys      AGA R Arg  
ATG M Met i    ACG T Thr      AAG K Lys      AGG R Arg  

GTT V Val      GCT A Ala      GAT D Asp      GGT G Gly  
GTC V Val      GCC A Ala      GAC D Asp      GGC G Gly  
GTA V Val      GCA A Ala      GAA E Glu      GGA G Gly  
GTG V Val      GCG A Ala      GAG E Glu      GGG G Gly  
```