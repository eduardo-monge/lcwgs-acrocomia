#!/bin/bash

BASE="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima"
RESULTS="$BASE/results"
mkdir -p $RESULTS


#1. Collect bestlhoods
echo "Collecting Model 1a results"
> $RESULTS/Model1a_likelihoods.txt
for i in $(seq 1 100); do
  FILE="$BASE/Model1a/run_$i/Model1a/Model1a.bestlhoods"
  if [ -f "$FILE" ]; then
    awk -v r=$i 'NR==2 {print r"\t"$(NF-1)"\t"$NF}' "$FILE" >> $RESULTS/Model1a_likelihoods.txt
  fi
done

echo "Collecting Model 1b results"
> $RESULTS/Model1b_likelihoods.txt
for i in $(seq 1 100); do
  FILE="$BASE/Model1b/run_$i/Model1b/Model1b.bestlhoods"
  if [ -f "$FILE" ]; then
    awk -v r=$i 'NR==2 {print r"\t"$(NF-1)"\t"$NF}' "$FILE" >> $RESULTS/Model1b_likelihoods.txt
  fi
done

echo "Model 1a: $(wc -l < $RESULTS/Model1a_likelihoods.txt) successful runs"
echo "Model 1b: $(wc -l < $RESULTS/Model1b_likelihoods.txt) successful runs"

#2. Find BEST runs 
echo "TOP 5 RUNS - Model 1a"
echo "Run    MaxEstLhood    MaxObsLhood"
sort -k2 -g -r $RESULTS/Model1a_likelihoods.txt | head -5

echo "TOP 5 RUNS - Model 1b"
echo "Run    MaxEstLhood    MaxObsLhood"
sort -k2 -g -r $RESULTS/Model1b_likelihoods.txt | head -5

#3. Identify best run number for each model
BEST_M1A=$(sort -k2 -g -r $RESULTS/Model1a_likelihoods.txt | head -1 | awk '{print $1}')
BEST_M1B=$(sort -k2 -g -r $RESULTS/Model1b_likelihoods.txt | head -1 | awk '{print $1}')

echo "Model 1a best run: $BEST_M1A"
echo "Model 1b best run: $BEST_M1B"


#4. Full parameters of best runs
echo "Model 1a Best Parameters"
cat $BASE/Model1a/run_$BEST_M1A/Model1a/Model1a.bestlhoods

echo "Model 1b Best Parameters"
cat $BASE/Model1b/run_$BEST_M1B/Model1b/Model1b.bestlhoods


#5. AIC calculation
echo "AIC COMPARISON"

LL_M1A=$(awk 'NR==2 {print $(NF-1)}' $BASE/Model1a/run_$BEST_M1A/Model1a/Model1a.bestlhoods)
LL_M1B=$(awk 'NR==2 {print $(NF-1)}' $BASE/Model1b/run_$BEST_M1B/Model1b/Model1b.bestlhoods)
K_M1A=7
K_M1B=9

#convert log10 likelihood to natural log
AIC_M1A=$(awk -v L=$LL_M1A -v k=$K_M1A 'BEGIN{print 2*k - 2*L*log(10)}')
AIC_M1B=$(awk -v L=$LL_M1B -v k=$K_M1B 'BEGIN{print 2*k - 2*L*log(10)}')

echo "Model 1a: k=$K_M1A parameters, MaxEstLhood=$LL_M1A, AIC=$AIC_M1A"
echo "Model 1b: k=$K_M1B parameters, MaxEstLhood=$LL_M1B, AIC=$AIC_M1B"

# Delta AIC
echo "RESULT"
awk -v a=$AIC_M1A -v b=$AIC_M1B 'BEGIN{
  if (a < b) {
    delta = b - a
    print "Model 1a wins (lower AIC)"
    print "Delta AIC = " delta
  } else {
    delta = a - b
    print "Model 1b wins (lower AIC)"
    print "Delta AIC = " delta
  }
}'
