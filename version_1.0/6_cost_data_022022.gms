*-------------------------------------------------------------------------------
*        Costing data
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

parameter waste_fac(*,*,*)     fraction of food wasted    
/
$offlisting
$ondelim
$include waste_fac_05282021.csv
$offdelim
$onlisting
/;
$offtext

*-------------------------------------------------------------------------------

*        load price data:

parameter price_data(*,*,*,*,*)      food prices (2017-USD per Mcal)     
/
$offlisting
$ondelim
$include prices_10182021.csv
$offdelim
$onlisting
/;
         
*-------------------------------------------------------------------------------

*        allocate consumption data:

parameter cons_cst         consumption data for cost estimates;

*        - allocate baseline data:
cons_cst(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         = cons_data(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%");

*        - allocate scenario data:        
if(%inp_data%,
cons_cst(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = 0;
cons_cst(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = input(r,"diet",fg,diet_scn_p);
);

*        run analysis only for regions with new scenario data:
if(%scn_data%,
cons_cst(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")$(not r_mod(r)) = 0;
);

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------