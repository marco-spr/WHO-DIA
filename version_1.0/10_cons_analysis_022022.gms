*-------------------------------------------------------------------------------
*        Consumption data
*-------------------------------------------------------------------------------

sets
         diet_scn_p(diet_scn_io)  diet scenarios /
         BMK, NDG, EAT, VEG, VGN, SCN
         /
         diet_scn(diet_scn_p)     diet scenarios without BMK /
         NDG, EAT, VEG, VGN, SCN
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
         othrcrp/
         fg_o(fg_io)   food groups without aggregate and other crops/
         wheat, rice, maize, othr_grains, roots,
         legumes, soybeans, nuts_seeds, oil_veg, oil_palm, sugar,
         vegetables, fruits_trop, fruits_temp, fruits_starch
         beef, lamb, pork, poultry, eggs, milk,
         shellfish, fish_freshw, fish_pelag, fish_demrs/
;

*-------------------------------------------------------------------------------
*        Baseline data
*-------------------------------------------------------------------------------

*        load baseline consumption estimates:

parameter cons_data(*,*,*,*,*)            diet scenarios
/
$offlisting
$ondelim
$include diet_05282021.csv
$offdelim
$onlisting
/;

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

*-------------------------------------------------------------------------------
*        Assign and identify scenario changes
*-------------------------------------------------------------------------------

*        allocate consumption data:

parameter cons_ovw                        consumption estimates in scenarios;

*        - allocate baseline data:
cons_ovw(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         = cons_data(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%");

*        - allocate scenario data:        
if(%inp_data%,
cons_ovw(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = 0;
cons_ovw(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%") = input(r,"diet",fg,diet_scn_p);
);

*-------------------------------------------------------------------------------

*        identify scenario changes:

parameter cons_chg change in food consumption;
set       r_mod    country with changed diet data;

r_mod(r)$sum((diet_scn_p,fg,yrs_scn), cons_data(diet_scn_p,"g/d_w",fg,r,yrs_scn)) = yes;

if(%scn_data%,

cons_chg("inp", diet_scn_p,fg_o,r)
         = cons_ovw(diet_scn_p,"g/d_w",fg_o,r,"%yrs_ref%");

cons_chg("bsl", diet_scn_p,fg_o,r)
         = cons_data(diet_scn_p,"g/d_w",fg_o,r,"%yrs_ref%");
         
cons_chg("chg", diet_scn_p,fg_o,r)
         = cons_ovw(diet_scn_p,"g/d_w",fg_o,r,"%yrs_ref%")
         - cons_data(diet_scn_p,"g/d_w",fg_o,r,"%yrs_ref%");

cons_chg("chg","all-scn","all-fg",r)
         = sum((diet_scn_p,fg_o), cons_chg("chg",diet_scn_p,fg_o,r));
         
r_mod(r)$(abs(cons_chg("chg","all-scn","all-fg",r))>1E-6) = yes;
r_mod(r)$(abs(cons_chg("chg","all-scn","all-fg",r))<1E-6) = no;

*        keep only the data for countries where changes occured:

cons_ovw(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         $(not r_mod(r))
         = 0;
);

*-------------------------------------------------------------------------------

*        include food waste:

cons_ovw(diet_scn_p,"g/d",fg,r,"%yrs_ref%")
         = cons_ovw(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         * waste_fac(fg,r,"%yrs_ref%");

*-------------------------------------------------------------------------------

*        convert grams per day into calories per day:   

cons_ovw(diet_scn_p,"kcal/d_w",fg,r,"%yrs_ref%")
         = cons_ovw(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         * g2kcal(fg,r,"%yrs_ref%");
         
cons_ovw(diet_scn_p,"kcal/d",fg,r,"%yrs_ref%")
         = cons_ovw(diet_scn_p,"g/d",fg,r,"%yrs_ref%")
         * g2kcal(fg,r,"%yrs_ref%");

         
*-------------------------------------------------------------------------------
*        Analysis and report
*-------------------------------------------------------------------------------

*        analyse changes in food consumption and compile report:

$ontext
parameter report_cons      overview of food consumption;
set       cons_itm         consumption items /
          "g/d_w", "kcal/d_w", "g/d", "kcal/d")
          /
          cons_itm_n       name of consumption items/
          "Food intake (g/d)"              
          "Food intake (kcal/d)"           
          "Food intake (g/d) incl waste"   
          "Food intake (kcal/d) incl waste"
          /
          map_cons_itm     map of consumption items /
          "g/d_w"          ."Food intake (g/d)"
          "kcal/d_w"       ."Food intake (kcal/d)"
          "g/d_w"          ."Food intake (g/d) incl waste"
          "kcal/d_w"       ."Food intake (kcal/d) incl waste"
          /;
$offtext       
   
report_cons("abs",diet_scn_n,cons_itm_n,fg_agg,r,"%yrs_ref%")
         = sum(cons_itm$map_cons_itm(cons_itm,cons_itm_n),
           sum(fg_p$map_fg(fg_p,fg_agg),
           sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           cons_ovw(diet_scn_p,cons_itm,fg_p,r,"%yrs_ref%") )));

report_cons("abs",diet_scn_n,cons_itm_n,"total",r,"%yrs_ref%")
         = sum(fg_agg, report_cons("abs",diet_scn_n,cons_itm_n,fg_agg,r,"%yrs_ref%"));         

report_cons("chg",diet_scn_n,cons_itm_n,fg_agg,r,"%yrs_ref%")
         = report_cons("abs",diet_scn_n,cons_itm_n,fg_agg,r,"%yrs_ref%")
         - report_cons("abs","0_Baseline",cons_itm_n,fg_agg,r,"%yrs_ref%");
         
report_cons("pct",diet_scn_n,cons_itm_n,fg_agg,r,"%yrs_ref%")
         $report_cons("abs","0_Baseline",cons_itm_n,fg_agg,r,"%yrs_ref%")
         = 100 * ( report_cons("abs",diet_scn_n,cons_itm_n,fg_agg,r,"%yrs_ref%")
                  /report_cons("abs","0_Baseline",cons_itm_n,fg_agg,r,"%yrs_ref%") -1);
                  
*-------------------------------------------------------------------------------

execute_unload '10_cons_analysis_022022.gdx' report_cons, cons_ovw, cons_chg, r_mod, input, inputs, cons_data, cns_pct;
*$exit

*-------------------------------------------------------------------------------