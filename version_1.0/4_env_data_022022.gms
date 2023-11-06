*-------------------------------------------------------------------------------
*        Environmental data
*-------------------------------------------------------------------------------

*        prepare data:
*        - consumption data
*        - environmental footprints
*        - planetary boundary values

*-------------------------------------------------------------------------------
*        Define sets
*-------------------------------------------------------------------------------
 
$ontext       
*        defined as output parameters for MIRO:
parameter report_env     report of environmental analysis
          report_PB      report of planetary boundary analysis;
         
*        defined in sets and parameters:
report_PB(PB_itm,r,diet_scn_p,env_itm,fg_agg,year_all)
report_env("abs",env_itm,diet_scn_p,fg_agg,rgs,yrs_scn)
                              
sets
         diet_scn_p(diet_scn_io) diet scenarios /
         BMK, NDG, WHO, EAT, PSC, VEG, VGN, SCN
         /
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
         /
         itm_chg_env     environmental item of change /
         abs, chg, pct
         /;        
$offtext
          
*-------------------------------------------------------------------------------
*        Consumption, environmental, and waste data
*-------------------------------------------------------------------------------
          
*        load consumption data (uncomment if run without health analysis):
$ontext
parameter cons_data(*,*,*,*,*)            diet scenarios
/
$offlisting
$ondelim
$include diet_05282021.csv
$offdelim
$onlisting
/;
$offtext

*        load population data (uncomment if run without health analysis):
$ontext
Parameter pop(*,*,*)                     population numbers (in thousands)
/
$offlisting
$ondelim
$include pop_05282021.csv
$offdelim
$onlisting
/;
$offtext

*        load calorie conversion factors (uncomment if run without cons analysis):
$ontext
parameter g2kcal(*,*,*)        conversion factor from grams per day to kcals per day         
/
$offlisting
$ondelim
$include g2kcal_05282021.csv
$offdelim
$onlisting
/;
$offtext   

*        load waste percentages (uncomment if run without cons analysis):
$ontext
parameter waste_fac(*,*,*)     fraction of food wasted    
/
$offlisting
$ondelim
$include waste_fac_05282021.csv
$offdelim
$onlisting
/;
$offtext

parameter loss_pct(*,*,*)      proportion of food that is lost       
/
$offlisting
$ondelim
$include loss_pct_05282021.csv
$offdelim
$onlisting
/; 

parameter efoot(*,*,*,*,*,*,*,*) environmental footprints       
/
$offlisting
$ondelim
$include efoot_05282021.csv
$offdelim
$onlisting
/;

parameter PB_values(*,*)       food-related planetary boundary values     
/
$offlisting
$ondelim
$include PB_values_05282021.csv
$offdelim
$onlisting
/;

parameter pop_2050(*,*,*)      population projections for 2050     
/
$offlisting
$ondelim
$include pop_2050_05282021.csv
$offdelim
$onlisting
/;

*-------------------------------------------------------------------------------

*        allocate consumption data:

parameter cons_prd      demand for food production;

*        - allocate baseline data:
cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         = cons_data(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%");

*        - allocate scenario data:        
if(%inp_data%,
cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = 0;
cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = input(r,"diet",fg,diet_scn_p);
);

*-------------------------------------------------------------------------------
     
*        identify scenario changes:
*        (uncomment if not run without health analysis)

$ontext
parameter diet_chg change in dietary exposure;
set       r_mod    country with changed data
          r_sel    countres for which to run analysis;

if(%scn_data%,

diet_chg(diet_scn_p,"diet",r)
         = sum(riskf_d, cons_scn(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%"))
         - sum(riskf_d, cons_data(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%"));
         
diet_chg(diet_scn_p,"weight",r)
         = sum(weight,  weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%"))
         - sum(weight,  weight_scn_ref(diet_scn_p,weight,r,"%yrs_ref%"));

r_mod(r)$(diet_chg("SCN","diet",r) or diet_chg("SCN","weight",r)) = yes;
);
$offtext

*        run analysis only for regions with new scenario data:
if(%scn_data%,
cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")$(not r_mod(r)) = 0;
);

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------