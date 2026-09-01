#Selecte the genes closest 20kb
for file in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai; do
bedtools window -w 2000 \
  -a bed_files/outlier_ohana_${file}.bed \
  -b <(awk '$3=="gene"'  annotation_macauba.gff3) \
  > close_20kb/${file}_closest_gene.txt
done

#Do teh candidated genes files
for file in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai; do

  # gene_id <tab> snp
  awk -F'\t' '{
    match($13, /ID=[^;]+/);
    gid = substr($13, RSTART+3, RLENGTH-3);
    print gid"\t"$4
  }' close_20kb/${file}_closest_gene.txt | sort -u > close_20kb/${file}_gene_snp_pairs.txt

  # gene <tab> n_snps <tab> snp_list
  awk -F'\t' '{
    genes[$1] = genes[$1]==""? $2 : genes[$1]";"$2;
    count[$1]++
  } END {
    for (g in genes) print g"\t"count[g]"\t"genes[g]
  }' close_20kb/${file}_gene_snp_pairs.txt | sort -k2,2nr > candidates_genes/${file}_candidate_genes.txt

  echo "${file}: $(wc -l < candidates_genes/${file}_candidate_genes.txt) candidate genes"
done

#Back
zcat full_85_samples.beagle.gz | tail -n +2 | cut -f1 \
  | awk -F'_' '{print $1"\t"$2-1"\t"$2"\t"$1"_"$2}' | sort -k1,1 -k2,2n > structure_sites.bed

bedtools window -w 2000 -a structure_sites.bed \
  -b <(awk '$3=="gene"' annotation_clean.gff3) \
| awk -F'\t' '{match($0,/ID=[^;\t]+/); print substr($0,RSTART+3,RLENGTH-3)}' \
| sort -u > background_genes.txt

wc -l background_genes.txt 

#Fob per pop
for file in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai; do

  cut -f1 candidates_genes/${file}_candidate_genes.txt | sort -u > cand.tmp

  comm -12 cand.tmp has_go.tmp   > foreground_back/${file}_foreground_GO.txt
  comm -12 cand.tmp has_path.tmp > foreground_back/${file}_foreground_PATH.txt

  echo "${file} -> GO fg: $(wc -l < foreground_back/${file}_foreground_GO.txt) | KEGG fg: $(wc -l < foreground_back/${file}_foreground_PATH.txt)"
done

echo "Background -> GO bg: $(wc -l < foreground_back/background_GO.txt) | KEGG bg: $(wc -l < foreground_back/background_PATH.txt)"

rm -f has_go.tmp has_path.tmp bg.tmp cand.tmp
