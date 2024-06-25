# representative_tree

Full tree then subsample

1. Filter sequences to WGS
2. Annotate sequence header with serotype and genotype metadata
3. Build tree
4. Subsample tree by genotype using [smot](https://github.com/flu-crew/smot) or [parnas](https://github.com/flu-crew/parnas)
5. Perhaps assemble into a Nextclade dataset...