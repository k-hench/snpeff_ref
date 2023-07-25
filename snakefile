"""
snakemake -n --use-conda  --use-singularity
snakemake -c 1 --use-conda --use-singularity
snakemake --dag  --rerun-triggers mtime -R all | dot -Tsvg > dag_snpeff_db.svg
"""
import os
GENOMES = ["genome_1", "genome_2"]
c_ml = "docker://khench/re_load:v0.1"
code_dir = os.getcwd()

rule all:
  input: expand("results/{genome}/data/dummy/genes.gtf.gz", genome = GENOMES)

rule index_genome:
  input: "data/genomes/{genome}.fa"
  output: "data/genomes/{genome}.fa.fai"
  conda: "popgen_basics"
  shell:
    """
    samtools faidx {input}
    """

rule create_snpeff_config:
    output:
      conf = "results/{genome}/snpEff.config"
    shell:
      """
      echo "# dummy genome, version {wildcards.genome}" > {output.conf}
      echo "dummy.genome : dummy" >> {output.conf}
      """

rule extract_cds:
    input:
      fa = "data/genomes/{genome}.fa",
      fai = "data/genomes/{genome}.fa.fai",
      gff = "data/genomes/{genome}.gff",
    output:
      cds = "results/{genome}/data/dummy/cds.fa"
    params:
      cds_prefix = "results/{genome}/data/dummy"
    conda: "gff3toolkit"
    shell:
      """
      gff3_to_fasta \
        -g {input.gff} \
        -f {input.fa} \
        -st cds \
        -d complete \
        -o {params.cds_prefix}/dummy
      
      mv {params.cds_prefix}/dummy_cds.fa {params.cds_prefix}/cds.fa
      """

rule extract_prot:
    input:
      fa = "data/genomes/{genome}.fa",
      fai = "data/genomes/{genome}.fa.fai",
      gff = "data/genomes/{genome}.gff"
    output:
      pep = "results/{genome}/data/dummy/protein.fa"
    params:
      pep_prefix = "results/{genome}/data/dummy"
    conda: "gff3toolkit"
    shell:
      """
      gff3_to_fasta \
        -g {input.gff} \
        -f {input.fa} \
        -st pep \
        -d complete \
        -o {params.pep_prefix}/dummy
      
      mv {params.pep_prefix}/dummy_pep.fa {params.pep_prefix}/protein.fa
      """

rule setup_dp_env:
    input:
      fa = "data/genomes/{genome}.fa",
      gtf = "data/genomes/{genome}.gtf",
      cds = "results/{genome}/data/dummy/cds.fa",
      prot = "results/{genome}/data/dummy/protein.fa",
      conf = "results/{genome}/snpEff.config"
    output:
      snp_fa = "results/{genome}/data/genomes/dummy.fa",
      snp_gff = "results/{genome}/data/dummy/genes.gtf.gz"
    params:
      snpeff_path = "results/{genome}"
    shell:
      """
      mkdir -p {params.snpeff_path}/data/dummy {params.snpeff_path}/data/genomes
      cd {code_dir}/{params.snpeff_path}/data/dummy
      ln -s {code_dir}/{input.gtf} ./genes.gtf.gz
      cd {code_dir}/{params.snpeff_path}/data/genomes
      ln -s {code_dir}/{input.fa} ./dummy.fa
      """

rule create_snpeff_db:
    input:
      fa = "data/genomes/{genome}.fa",
      gtf = "data/genomes/{genome}.gtf",
      cds = "results/{genome}/data/dummy/cds.fa",
      prot = "results/{genome}/data/dummy/protein.fa",
      conf = "results/{genome}/snpEff.config",
      snp_fa = "results/{genome}/data/genomes/dummy.fa",
      snp_gff = "results/{genome}/data/dummy/genes.gtf.gz"
    output:
      check = touch( "results/{genome}/done.check" )
    params:
      snpeff_path = "results/{genome}"
    container: c_ml
    shell:
      """
      cd {code_dir}/{params.snpeff_path}
      snpEff build -Xmx24G -c {code_dir}/{input.conf} -dataDir $(pwd)/data -gtf22 -v dummy
      """