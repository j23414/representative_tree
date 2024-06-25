#! /usr/bin/env python

import argparse
from Bio import SeqIO
import pandas as pd

def parse_args():
    parser = argparse.ArgumentParser(description="Annotate FASTA headers with metadata")
    parser.add_argument("--sequences", required=True, help="Input FASTA file")
    parser.add_argument("--metadata", required=True, help="Input metadata TSV file")
    parser.add_argument("--metadata-id-columns", required=True, help="Column in metadata that matches sequence IDs")
    parser.add_argument("--header", required=True, help="Comma-separated list of columns to add to header")
    parser.add_argument("--output_sequences", required=True, help="Output FASTA file with annotated headers")
    return parser.parse_args()

def annotate_headers(sequences, metadata, metadata_id_columns, header_columns, output_sequences):
    """
    Annotate headers of sequences in a FASTA file with metadata from a TSV file
    """
    # Read metadata
    metadata = pd.read_csv(metadata, sep='\t', low_memory=False)
    metadata.set_index(metadata_id_columns, inplace=True)

    # Read sequences and write new file with updated headers
    with open(output_sequences, 'w') as outfile:
        for record in SeqIO.parse(sequences, "fasta"):
            seq_id = record.id
            if seq_id in metadata.index:
                new_header_parts = [seq_id]
                for col in header_columns:
                    if col in metadata.columns:
                        new_header_parts.append(str(metadata.loc[seq_id, col]))
                    else:
                        new_header_parts.append("NA")
                new_header = "|".join(new_header_parts)
                outfile.write(f">{new_header}\n{record.seq}\n")
            else:
                print(f"Warning: {seq_id} not found in metadata. Keeping original header.")
                outfile.write(f">{record.description}\n{record.seq}\n")

def main():
    args = parse_args()

    annotate_headers(
        sequences=args.sequences,
        metadata=args.metadata,
        metadata_id_columns=args.metadata_id_columns,
        header_columns=args.header.split(","),
        output_sequences=args.output_sequences,
    )


if __name__ == "__main__":
    main()