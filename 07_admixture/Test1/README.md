## Test 1: Roraima Bottleneck
* [7.6.1.1. Created 3DSFS](7.6.1.1.3DSFS.sh) - With REALSFS ANGSD
* [7.6.1.2. Convert 3DSFSF to fastsimcoal2 format](7.6.1.2.convert_files.py) - With python
* [7.6.1.3. Run model a](7.6.1.3.run_model_a.sh) - With fastsimcoal2
* [7.6.1.4. Run model b](7.6.1.4.run_model_a.sh) - With fastsimcoal2
* [7.6.1.5. Select best model](7.6.1.5.select_best_model.sh) - With bash
* [7.6.1.6. Created files for bootstrap on winner model](7.6.1.6.created_files_boot.sh) - With bash 
* [7.6.1.7. Run simulated bootstrap on winner model](7.6.1.7.boot_best_model.sh) - With fastsimcoal2
* [7.6.1.8. Calculated bootstrap values on winner model](7.6.1.8.calc_boot.sh) -  With fastsimcoal2
* [7.6.1.9. Collect bootstrap results](7.6.1.3.colect_boot.sh) -  With 

Files used for the Test 1: Roraima Bottleneck
*Obs file: [Model1a.obs](model1a.obs)
* Model A: No Bottleneck
  * [Model1a.est](model1a.est)
  * [Model1a.tpl](model1a.tpl)
* Model B: Bottleneck
  * [Model2a.est](model2b.est)
  * [Model2a.tpl](model2b.tpl)

