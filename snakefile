"""
snakemake -n --use-conda 
snakemake -c 1 --use-conda 
"""

GENOMES = ["genome_1", "genome_2"]

rule all:
  input: expand("data/genomes/{genome}.fa.fai", genome = GENOMES)

rule index_genome:
  input: "data/genomes/{genome}.fa"
  output: "data/genomes/{genome}.fa.fai"
  conda: "popgen_basics"
  shell:
    """
    samtools faidx {input}
    """