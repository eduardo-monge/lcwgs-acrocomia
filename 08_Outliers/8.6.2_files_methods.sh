#SNPS withing genes 
Window SNPs
bedtools window -w 2000 \
  -a <(sort -k1,1 -k2,2n outlier_intersection_99_candidates.bed) \
  -b <(awk '$3=="gene"' annotation_clean.gff3 | sort -k1,1 -k4,4n) \
  > candidates_closest_gene.txt

#Cacnidates genes
awk -F'\t' '{
  # extract gene ID from attributes (col 13): ID=g123
  match($13, /ID=[^;]+/);
  gid = substr($13, RSTART+3, RLENGTH-3);
  print gid"\t"$4          # gene_id <tab> snp
}' candidates_within_2kb.txt | sort -u > gene_snp_pairs.txt

# genes with their SNP count and the SNP list
awk -F'\t' '{
  genes[$1] = genes[$1]==""? $2 : genes[$1]";"$2;
  count[$1]++
} END {
  for (g in genes) print g"\t"count[g]"\t"genes[g]
}' gene_snp_pairs.txt | sort -k2,2nr > candidate_genes.txt



#1. Parse eggNOG-mapper output into gene-level maps
#gene -> GO 
awk -F'\t' '!/^#/ && $10!="-" && $10!="" {
  gene=$1; sub(/\.t[0-9]+$/,"",gene);
  n=split($10, go, ",");
  for(i=1;i<=n;i++) print gene"\t"go[i]
}' query.emapper.annotations | sort -u > gene2go.txt

#gene -> KEGG KO
awk -F'\t' '!/^#/ && $12!="-" && $12!="" {
  gene=$1; sub(/\.t[0-9]+$/,"",gene);
  n=split($12, ko, ",");
  for(i=1;i<=n;i++){ gsub(/ko:/,"",ko[i]); print gene"\t"ko[i] }
}' query.emapper.annotations | sort -u > gene2ko.txt

#gene -> KEGG Pathway
awk -F'\t' '!/^#/ && $13!="-" && $13!="" {
  gene=$1; sub(/\.t[0-9]+$/,"",gene);
  n=split($13, p, ",");
  for(i=1;i<=n;i++){
    id=p[i]; gsub(/[^0-9]/,"",id);
    if(id!="") print gene"\tmap"id
  }
}' query.emapper.annotations | sort -u > gene2pathway.txt


Back 
zcat full_85_samples.beagle.gz | tail -n +2 | cut -f1 \
  | awk -F'_' '{print $1"\t"$2-1"\t"$2"\t"$1"_"$2}' | sort -k1,1 -k2,2n > structure_sites.bed

bedtools window -w 2000 -a structure_sites.bed \
  -b <(awk '$3=="gene"' annotation_clean.gff3) \
| awk -F'\t' '{match($0,/ID=[^;\t]+/); print substr($0,RSTART+3,RLENGTH-3)}' \
| sort -u > background_genes.txt

wc -l background_genes.txt 



#2. Build  foreground/background sets

# annotation-presence lists
cut -f1 gene2go.txt      | sort -u > has_go.tmp
cut -f1 gene2pathway.txt | sort -u > has_path.tmp

sort -u background_genes.txt                > bg.tmp
cut -f1 candidate_genes_final.txt | sort -u > cand.tmp

# GO 
comm -12 bg.tmp   has_go.tmp > background_GO.txt
comm -12 cand.tmp has_go.tmp > foreground_GO.txt

#KEGG PATHWAY
comm -12 bg.tmp   has_path.tmp > background_PATH.txt
comm -12 cand.tmp has_path.tmp > foreground_PATH.txt

echo "GO   -> fg:"   $(wc -l < foreground_GO.txt)   " bg:" $(wc -l < background_GO.txt)
echo "KEGG -> fg:"   $(wc -l < foreground_PATH.txt) " bg:" $(wc -l < background_PATH.txt)

rm -f has_go.tmp has_path.tmp bg.tmp cand.tmp
