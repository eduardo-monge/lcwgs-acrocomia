#!/bin/bash
BASE="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens"
RESULTS="$BASE/results"
NRUNS=300
TOPN=5                           
mkdir -p $RESULTS

MODELS=(intu_2a intu_2b intu_2c intu_2d intu_2e intu_2f)

declare -A KPAR
KPAR[intu_2a]=10
KPAR[intu_2b]=10
KPAR[intu_2c]=12
KPAR[intu_2d]=12
KPAR[intu_2e]=10
KPAR[intu_2f]=12                  

EST_DIR="/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test2_Intumescens"


#1. Collect MaxEstLhood.

for MODEL in "${MODELS[@]}"; do
  echo "Collecting $MODEL results"
  > $RESULTS/${MODEL}_likelihoods.txt
  nfail=0
  for i in $(seq 1 $NRUNS); do
    FILE="$BASE/$MODEL/run_$i/$MODEL/$MODEL.bestlhoods"
    if [ -f "$FILE" ]; then
      keep=$(awk 'NR==2 && $(NF-1)+0 < 0 {print $(NF-1)}' "$FILE")
      if [ -n "$keep" ]; then
        awk -v r=$i 'NR==2 {print r"\t"$(NF-1)"\t"$NF}' "$FILE" >> $RESULTS/${MODEL}_likelihoods.txt
      else
        nfail=$((nfail+1))
      fi
    fi
  done
  nvalid=$(wc -l < $RESULTS/${MODEL}_likelihoods.txt)
  echo "  $MODEL: $nvalid valid runs, $nfail failed (excluded)"
done


#2. Top 5 valid runs per model
for MODEL in "${MODELS[@]}"; do
  echo "TOP 5 VALID RUNS - $MODEL"
  echo "Run    MaxEstLhood    MaxObsLhood"
  sort -k2 -g -r $RESULTS/${MODEL}_likelihoods.txt | head -5
done


#3. Best valid run per model
echo "BEST RUNS"
declare -A BESTRUN
for MODEL in "${MODELS[@]}"; do
  if [ ! -s "$RESULTS/${MODEL}_likelihoods.txt" ]; then
    echo "  $MODEL: NO VALID RUNS"; BESTRUN[$MODEL]=""; continue
  fi
  BESTRUN[$MODEL]=$(sort -k2 -g -r $RESULTS/${MODEL}_likelihoods.txt | head -1 | awk '{print $1}')
  echo "$MODEL best run: ${BESTRUN[$MODEL]}"
done

#4. Full params of each best run
for MODEL in "${MODELS[@]}"; do
  [ -z "${BESTRUN[$MODEL]}" ] && continue
  echo ""
  echo "=== $MODEL Best Parameters (run ${BESTRUN[$MODEL]}) ==="
  cat $BASE/$MODEL/run_${BESTRUN[$MODEL]}/$MODEL/$MODEL.bestlhoods
done

#5. AIC
echo "AIC COMPARISON"
> $RESULTS/aic_table.txt
for MODEL in "${MODELS[@]}"; do
  [ -z "${BESTRUN[$MODEL]}" ] && { echo "$MODEL: skipped"; continue; }
  L=$(awk 'NR==2 {print $(NF-1)}' $BASE/$MODEL/run_${BESTRUN[$MODEL]}/$MODEL/$MODEL.bestlhoods)
  K=${KPAR[$MODEL]}
  AIC=$(awk -v L=$L -v k=$K 'BEGIN{print 2*k - 2*L*log(10)}')
  printf "%s\t%s\t%s\t%s\n" "$MODEL" "$K" "$L" "$AIC" >> $RESULTS/aic_table.txt
  echo "$MODEL: k=$K, MaxEstLhood=$L, AIC=$AIC"
done


#6. delta-AIC + OVERFLOW-SAFE Akaike weights
echo "MODEL RANKING"
awk '
  {model[NR]=$1; aic[NR]=$4; n=NR}
  END{
    if(n==0){print "  no models"; exit}
    best=aic[1]; for(i=2;i<=n;i++) if(aic[i]<best) best=aic[i]
    Z=0
    for(i=1;i<=n;i++){
      d[i]=aic[i]-best
      # guard: exp(-0.5*d) underflows to 0 well before d~1400; treat as 0
      if(d[i] < 700) w[i]=exp(-0.5*d[i]); else w[i]=0
      Z+=w[i]
    }
    printf "%-9s %16s %14s %10s\n","model","AIC","dAIC","weight"
    for(i=1;i<=n;i++){
      wt = (Z>0)? w[i]/Z : 0
      printf "%-9s %16.2f %14.2f %10.3g\n", model[i], aic[i], d[i], wt
    }
  }' $RESULTS/aic_table.txt | sort -k3 -g
echo "  (weights ~0 mean dAIC is so large that support is effectively nil;"
echo "   with dAIC in the thousands, report dAIC directly, not weights.)"

#7. Factorial contrasts 
echo "FACTORIAL CONTRASTS (dAIC > 0 favors the bottleneck model) "
get_aic(){ awk -v m=$1 '$1==m{print $4}' $RESULTS/aic_table.txt; }
A2A=$(get_aic intu_2a); A2B=$(get_aic intu_2b); A2C=$(get_aic intu_2c)
A2D=$(get_aic intu_2d); A2E=$(get_aic intu_2e); A2F=$(get_aic intu_2f)

contrast(){ # $1=label $2=AIC_nobot $3=AIC_bot $4=name_bot $5=name_nobot
  if [ -n "$2" ] && [ -n "$3" ]; then
    awk -v nb=$2 -v b=$3 -v L="$1" -v NB="$5" -v B="$4" 'BEGIN{
      d=nb-b
      printf "%-34s dAIC = %.2f  -> ", L, d
      if(d>0) print B" better (bottleneck helps)"; else print NB" better (no bottleneck)"
    }'
  else echo "$1: cannot compute (missing model)"; fi
}
contrast "Bottleneck | MIN-sister (2d vs 2a)"  "$A2A" "$A2D" "2d" "2a"
contrast "Bottleneck | admixture  (2c vs 2b)"  "$A2B" "$A2C" "2c" "2b"
contrast "Bottleneck | AMAZ-sister(2f vs 2e)"  "$A2E" "$A2F" "2f" "2e"

echo "ORIGIN CONTRASTS (no-bottleneck family; lower AIC = better origin)"
awk -v a=$A2A -v b=$A2B -v e=$A2E 'BEGIN{
  printf "  MIN-sister (2a):  %.2f\n", a
  printf "  hybrid     (2b):  %.2f  (dAIC vs 2a = %.2f)\n", b, b-a
  printf "  AMAZ-sister(2e):  %.2f  (dAIC vs 2a = %.2f)\n", e, e-a
}'

---
#PARAMETER-STABILITY for the winning model
echo "PARAMETER STABILITY: winning model, top $TOPN runs"
WINNER=$(sort -k4 -g $RESULTS/aic_table.txt | head -1 | awk '{print $1}')
echo "Winning model: $WINNER"
echo ""
TOPRUNS=$(sort -k2 -g -r $RESULTS/${WINNER}_likelihoods.txt | head -$TOPN | awk '{print $1}')

# header from the best run's bestlhoods
BR=${BESTRUN[$WINNER]}
HDRFILE="$BASE/$WINNER/run_$BR/$WINNER/$WINNER.bestlhoods"
{
  printf "run\t"; head -1 "$HDRFILE"
  for r in $TOPRUNS; do
    F="$BASE/$WINNER/run_$r/$WINNER/$WINNER.bestlhoods"
    [ -f "$F" ] && { printf "%s\t" "$r"; sed -n '2p' "$F"; }
  done
} | column -t
