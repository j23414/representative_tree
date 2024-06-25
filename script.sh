#! /usr/bin/env bash

set -e
set -u

if [[ ! -d "data" ]]; then
    mkdir data
    wget https://data.nextstrain.org/files/workflows/dengue/sequences_all.fasta.zst -O data/sequences_all.fasta.zst
    wget https://data.nextstrain.org/files/workflows/dengue/metadata_all.tsv.zst -O data/metadata_all.tsv.zst
    zstd -d data/sequences_all.fasta.zst
    zstd -d data/metadata_all.tsv.zst
fi

if [[ ! -f "data/filtered.fasta" ]]; then
  csvtk filter \
  -t -f "genome_coverage>=0.9" \
  data/metadata_all.tsv \
  > data/filtered.tsv

  augur filter \
    --sequences data/sequences_all.fasta \
    --metadata data/filtered.tsv \
    --metadata-id-columns genbank_accession \
    --min-length 10000 \
    --output data/filtered.fasta
fi

if [[ ! -f "data/fixed_headers.fasta" ]]; then
  python bin/annotate_headers.py \
  --sequences data/filtered.fasta \
  --metadata data/filtered.tsv \
  --metadata-id-columns genbank_accession \
  --header "serotype_genbank,genotype_nextclade,date" \
  --output_sequences data/fixed_headers.fasta
fi

if [[ ! -f "data/aligned.fasta" ]]; then
  # augur align \
  #   --sequences data/fixed_headers.fasta \
  #   --output data/aligned.fasta \
  #   --nthreads 4
  mafft --auto data/fixed_headers.fasta > data/aligned.fasta
fi

if [[ ! -f "data/tree.nwk" ]]; then
  fasttree -nt \
    data/aligned.fasta \
    > data/tree.nwk
fi

if [[ ! -f "data/subsampled_tree.nwk" ]]; then
  smot sample para \
  --proportion=0.1 \
  data/tree.nwk \
  --factor-by-capture="(denv1|denv2|denv3|denv4)" \
  --newick \
  > data/subsampled_tree.tre
fi