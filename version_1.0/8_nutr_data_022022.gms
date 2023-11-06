*-------------------------------------------------------------------------------
*        Nutrient data
*-------------------------------------------------------------------------------

*        load nutrient data:

set      nutr    nutrients /
calories
protein
carbohydrates
fat
saturatedFA
monounsatFA
polyunsatFA
vitaminC
vitaminA
folate
calcium
iron
zinc
potassium
fiber
copper
sodium
phosphorus
thiamin
riboflavin
niacin
vitaminB6
magnesium
pantothenate
vitaminB12
/;

*set       stats_n        /mean, low, high/;

*        overview:
$ontext
nutrient   /     unit                            /  min or max   /       source   * all data from Genus except for last two
calories         kcal/person/day
protein          g/person/day                       min                  WHO
fat              g/person/day                       max                  WHO
carbohydrates    g/person/day                       max                  WHO
vitaminC         mg/person/day                      min                  WHO
vitaminA         microgram RAE/person/day           min                  WHO
folate           microgram/person/day               min                  WHO
calcium          mg/person/day                      min                  WHO
iron             mg/person/day                      min                  WHO
zinc             mg/person/day                      min                  WHO
potassium        mg/person/day                      min                  WHO
fiber            g/person/day                       min                  US-IOM
copper           mg/person/day                      min                  US-IOM
sodium           mg/person/day                      max                  WHO
phosphorus       mg/person/day                      min                  US-IOM
thiamin          mg/person/day                      min                  WHO
riboflavin       mg/person/day                      min                  WHO
niacin           mg/person/day                      min                  WHO
vitaminB6        mg/person/day                      min                  WHO
magnesium        mg/person/day                      min                  WHO
saturatedFA      g/person/day                       max                  WHO
monounsatFA      g/person/day                       by diff (FAT-satFA-PUFA)
polyunsatFA      g/person/day                       min                  WHO
pantothenate     mg/person/day                      min                  WHO     * data from Harvard database
vitaminB12       microgram/person/day               min                  WHO     * data from Harvard database
$offtext

*        load nutrient data:

parameter nutr_fg_per_g(*,*,*,*)      nutrients per gram of food for agg food groups
/
$offlisting
$ondelim
$include nutr_data_10182021.csv
$offdelim
$onlisting
/;

parameter nutr_needs(*,*)         nutritional needs at a population level
/
$offlisting
$ondelim
$include nutr_recm_10182021.csv
$offdelim
$onlisting
/;

*-------------------------------------------------------------------------------

*        allocate consumption data:

parameter cons_ntr         consumption data for nutritional analysis;

*        - allocate baseline data:
cons_ntr(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         = cons_data(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%");

*        - allocate scenario data:        
if(%inp_data%,
cons_ntr(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = 0;
cons_ntr(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = input(r,"diet",fg,diet_scn_p);
);

*        run analysis only for regions with new scenario data:
if(%scn_data%,
cons_ntr(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")$(not r_mod(r)) = 0;
);

*-------------------------------------------------------------------------------

*        loaded for environmental analysis (uncomment of run as standalone):
$ontext
sets
         fg_p(fg_io) food groups /
         wheat, rice, maize, othr_grains, roots,
         legumes, soybeans, nuts_seeds, oil_veg, oil_palm, sugar,
         vegetables, fruits_trop, fruits_temp, fruits_starch
         beef, lamb, pork, poultry, eggs, milk,
         shellfish, fish_freshw, fish_pelag, fish_demrs,
         othrcrp, all-fg/
         fg(fg_io)   food groups without aggregate /
         wheat, rice, maize, othr_grains, roots,
         legumes, soybeans, nuts_seeds, oil_veg, oil_palm, sugar,
         vegetables, fruits_trop, fruits_temp, fruits_starch
         beef, lamb, pork, poultry, eggs, milk,
         shellfish, fish_freshw, fish_pelag, fish_demrs,
         othrcrp
         /         ;         

parameter g2kcal(*,*,*)        conversion factor from grams per day to kcals per day         
/
$offlisting
$ondelim
$include g2kcal_05282021.csv
$offdelim
$onlisting
/;
$offtext      

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------