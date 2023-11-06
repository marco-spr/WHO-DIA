*-------------------------------------------------------------------------------
*        Sets and parameters
*-------------------------------------------------------------------------------

*        ordering in gdx file (for easier analysis):

set      ordering   /all-a, all-c, all-fg, all-rf, total, BMK, abs, chg, pct,
                     diet, weight,
                     fruits, vegetables, nuts_seeds, legumes, whole_grains, fish, red_meat, prc_meat
                     underweight, overweight, obese
                     /;

*        set reference year:
$if not set yrs_ref      $set yrs_ref        2018

*-------------------------------------------------------------------------------
*        MIRO data contract for inputs:
*-------------------------------------------------------------------------------

set rgs        regions 
    riskf_c    category
    fg_inp     consumption parameters 
    diet_scn_n diet scenarios;
    
$onExternalInput
parameter inputs(rgs<,riskf_c<,fg_inp<,diet_scn_n<);
*$gdxin CRA_input_05272021.gdx
$gdxin input_05282021.gdx
$load  inputs=input
$offExternalInput

*-------------------------------------------------------------------------------

*        map input parameter (for further processing):

*        - regions:

set r_iso3(*)      countries/
$offlisting
$ondelim
$include r_iso3_05282021.csv
$offdelim
$onlisting
/;

*set r_iso3      countries;
*$gdxin ../DATASETS/regions/WHO_classification.gdx
*$load  r_iso3
*$gdxin

set r(rgs)   countries;
r(rgs) = yes;
r(rgs)$(not r_iso3(rgs)) = no;

*        - food groups and scenarios:

parameter cns_pct(*,*,*)          composition of aggregate food groups
/
$offlisting
$ondelim
$include fg_pct_05282021.csv
$offdelim
$onlisting
/;

*        fill missing value:
cns_pct("TKM","legumes","legumes")  = 0.75;   
cns_pct("TKM","legumes","soybeans") = 0.25;

*$gdxin CRA_data_05272021.gdx
*$load cns_pct
*$gdxin

set       fg_grains        /wheat, rice, maize, othr_grains/
          fg_legumes       /legumes, soybeans/
          fg_fruits        /fruits_trop, fruits_temp, fruits_starch/
          fg_fish          /shellfish, fish_freshw, fish_pelag, fish_demrs/
          fg_redmeat       /beef, lamb, pork/;

set      diet_scn_io        diet scenarios /
         BMK, NDG, EAT, VEG, VGN, SCN
         /
         map_scn(diet_scn_io,diet_scn_n)      mapping of diet scenarios  /
         BMK.0_Baseline
         NDG.1_Guidelines
         EAT.2_EAT-Lancet
*         PSC.2_Pescatarian
         VEG.3_Vegetarian
         VGN.4_Vegan
         SCN.5_Scenario
         /
         fg_io          food groups /
         wheat, rice, maize, othr_grains, roots, legumes, soybeans,
         nuts_seeds, oil_veg, oil_palm, sugar, vegetables, fruits_trop,
         fruits_temp, fruits_starch, beef, lamb, pork, poultry, eggs, milk,
         shellfish, fish_freshw, fish_pelag, fish_demrs, othrcrp, all-fg,
         whole_grains, prc_meat
         /
         riskf_io       risk factors /
         fruits, vegetables, nuts_seeds, legumes, fish, red_meat, prc_meat, whole_grains, 
         underweight, overweight, obese, obese_g1, obese_g2, obese_g3,
         weight, diet, all-rf
         /
         map_fg2riskf(fg_io,riskf_io) /
         whole_grains     .whole_grains
         legumes          .legumes
         soybeans         .legumes
         nuts_seeds       .nuts_seeds
         vegetables       .vegetables
         fruits_trop      .fruits
         fruits_temp      .fruits
         fruits_starch    .fruits
         beef             .red_meat
         lamb             .red_meat
         pork             .red_meat
         prc_meat         .prc_meat
         shellfish        .fish
         fish_freshw      .fish
         fish_pelag       .fish
         fish_demrs       .fish
         /;

parameter input   mapped input parameter;

input(rgs,"diet","roots",diet_scn_io)      = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","roots (g/d)",diet_scn_n));
input(rgs,"diet","sugar",diet_scn_io)      = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","sugar (g/d)",diet_scn_n));
input(rgs,"diet","nuts_seeds",diet_scn_io) = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","nuts&seeds (g/d)",diet_scn_n));
input(rgs,"diet","vegetables",diet_scn_io) = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","vegetables (g/d)",diet_scn_n));
input(rgs,"diet","oil_veg",diet_scn_io)    = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","veg oil (g/d)",diet_scn_n));
input(rgs,"diet","oil_palm",diet_scn_io)   = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","palm oil (g/d)",diet_scn_n));
input(rgs,"diet","beef",diet_scn_io)       = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","beef (g/d)",diet_scn_n));
input(rgs,"diet","lamb",diet_scn_io)       = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","lamb (g/d)",diet_scn_n));
input(rgs,"diet","pork",diet_scn_io)       = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","pork (g/d)",diet_scn_n));
input(rgs,"diet","poultry",diet_scn_io)    = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","poultry (g/d)",diet_scn_n));
input(rgs,"diet","milk",diet_scn_io)       = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","milk (g/d)",diet_scn_n));
input(rgs,"diet","eggs",diet_scn_io)       = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"diet","eggs (g/d)",diet_scn_n));

input(rgs,"diet",fg_grains,diet_scn_io)    = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), cns_pct(rgs,"grains",fg_grains)   * inputs(rgs,"diet","grains (g/d)",diet_scn_n));
input(rgs,"diet",fg_legumes,diet_scn_io)   = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), cns_pct(rgs,"legumes",fg_legumes) * inputs(rgs,"diet","legumes (g/d)",diet_scn_n));
input(rgs,"diet",fg_fruits,diet_scn_io)    = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), cns_pct(rgs,"fruits",fg_fruits)   * inputs(rgs,"diet","fruits (g/d)",diet_scn_n));
input(rgs,"diet",fg_fish,diet_scn_io)      = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), cns_pct(rgs,"fish",fg_fish)       * inputs(rgs,"diet","fish (g/d)",diet_scn_n));

input(rgs,"diet","whole_grains",diet_scn_io)
         = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n),
           inputs(rgs,"diet","whole grains (%)",diet_scn_n)/100
           * inputs(rgs,"diet","grains (g/d)",diet_scn_n));
                  
input(rgs,"diet","prc_meat",diet_scn_io)
         = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n),
           inputs(rgs,"diet","processed meat (%)",diet_scn_n)/100
           * (inputs(rgs,"diet","beef (g/d)",diet_scn_n)
             +inputs(rgs,"diet","lamb (g/d)",diet_scn_n)
             +inputs(rgs,"diet","pork (g/d)",diet_scn_n)) );

input(rgs,"diet","red_meat",diet_scn_io)
         = sum(fg_redmeat, input(rgs,"diet",fg_redmeat,diet_scn_io));       
         
input(rgs,"weight","underweight",diet_scn_io) = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"weight","underweight (%)",diet_scn_n));
input(rgs,"weight","overweight",diet_scn_io)  = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"weight","overweight (%)",diet_scn_n));
input(rgs,"weight","obese",diet_scn_io)       = sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n), inputs(rgs,"weight","obese (%)",diet_scn_n));
                

*-------------------------------------------------------------------------------
*        MIRO data contract for outputs:
*        - note that output parameters need to be defined over existing sets
*-------------------------------------------------------------------------------

*        sets for output parameters:

*        - health report:

set      report_itm_io      items of health analysis /
         deaths_avd, deaths_avd_prm, YLL_avd,
         "%deaths_avd/all", "%deaths_avd_prm/all", "deaths_avd/1000pop"
         /
         health_itm_n       health parameter        /
         "number of avoided deaths"
         "number of avoided premature deaths"
         "averted losses of life years"
         "percentage reduction in all deaths among adults"
         "percentage reduction in all premature deaths"
         "avoided deaths per 1000 people"
         /         
         map_health_itm(report_itm_io,health_itm_n)   mapping of health parameters        /
         deaths_avd."number of avoided deaths"
         deaths_avd_prm."number of avoided premature deaths"
         YLL_avd."averted losses of life years"
         "%deaths_avd/all"."percentage reduction in all deaths among adults"
         "%deaths_avd_prm/all"."percentage reduction in all premature deaths"
         "deaths_avd/1000pop"."avoided deaths per 1000 people"
         /
*         riskf_io         risk factors (for output) /
*         fruits, vegetables, nuts_seeds, legumes, fish, red_meat, prc_meat, whole_grains, 
*         underweight, overweight, obese, obese_g1, obese_g2, obese_g3, weight, diet, all-rf
*         /
         cause_io         causes of death /
         "all-c", CHD, Stroke, Cancer, "Colon and rectum cancers", T2DM, Resp_Dis
         /
         stats_io         statistics /
         mean, low, high, std
         /;
         
*        - environmental report:

set      env_itm_io       environmental domains /
         GHGe, GHGf, land, water, nitr, phos
         /
         env_itm_n        environmental impacts /
         "Greenhouse gas emissions (CH4, N2O) (MtCO2eq)"
         "Greenhouse gas emissions (life-cycle) (MtCO2eq)"
         "Cropland use (1000 Mkm2)"
         "Freshwater use (km3)"
         "Nitrogen application (GgN)"
         "Phosphorus application (GgP)"
         /
         map_env_itm(env_itm_io,env_itm_n) /
         GHGe."Greenhouse gas emissions (CH4, N2O) (MtCO2eq)"
         GHGf."Greenhouse gas emissions (life-cycle) (MtCO2eq)"
         land."Cropland use (1000 Mkm2)"
         water."Freshwater use (km3)"
         nitr."Nitrogen application (GgN)"
         phos."Phosphorus application (GgP)"
         /
         fg_agg           food groups /
         grains, roots, fruit_veg, legumes, nuts_seeds, oils, sugar,
         beef, lamb, pork, poultry, milk, eggs, fish, other, total/
         map_fg(fg_io,fg_agg)      /
         wheat            .grains
         rice             .grains
         maize            .grains
         othr_grains      .grains
         roots            .roots
         sugar            .sugar
         legumes          .legumes
         soybeans         .legumes
         nuts_seeds       .nuts_seeds
         oil_veg          .oils
         oil_palm         .oils
         vegetables       .fruit_veg
         fruits_trop      .fruit_veg
         fruits_temp      .fruit_veg
         fruits_starch    .fruit_veg
         beef             .beef
         lamb             .lamb
         pork             .pork
         poultry          .poultry
         eggs             .eggs
         milk             .milk
         shellfish        .fish
         fish_freshw      .fish
         fish_pelag       .fish
         fish_demrs       .fish
         othrcrp          .other
         all-fg           .total
         /
         itm_chg_env      measure /
         abs, chg, pct
         /
         yrs_scn          year  /2018/
         yrs_all          year  /2018, 2050/
         ;      

*        - planetary boundary report:

set      PB_itm           measure /
         abs, "%PB", "%PB_min", "%PB_max"
         /
         PB_itm_n         measure /
         "Global impacts"
         "Percentage of food-related planetary boundary (mean)"
         "Percentage of food-related planetary boundary (min)"
         "Percentage of food-related planetary boundary (max)"
         /
         map_PB_itm(PB_itm,PB_itm_n) /
         abs."Global impacts"
         "%PB"."Percentage of food-related planetary boundary (mean)"
         "%PB_min"."Percentage of food-related planetary boundary (min)"
         "%PB_max"."Percentage of food-related planetary boundary (max)"
         /;
         
*        - cost report:

set      itm_chg_cst       measure /
         abs, chg, pct, comp
         /
         itm_chg_cst_n     parameter  /
         "cost (USD/d)"                   
         "change in cost (USD/d)"
         "change in cost (%)"    
         "composition of costs"  
         /
         map_itm_cst(itm_chg_cst,itm_chg_cst_n)  map of cost measures       /
         abs."cost (USD/d)"
         chg."change in cost (USD/d)"
         pct."change in cost (%)"
         comp."composition of costs"
         /
         waste_scn_cst     waste scenarios   /
         full_waste, half_waste, no_waste
         /
         stats_c           statistics    /
         mean, low, high
         /;

*        - nutrient report:

set      nutr_n            nutrients /
         "Calories (kcal/d)"        
         "Protein (g/d)"            
         "Carbohydrates (g/d)"      
         "Fat (g/d)"                
         "Saturated fat (g/d)"      
         "MUPAs (g/d)"              
         "PUFAs (g/d)"              
         "Vitamin C (mg/d)"         
         "Vitamin A (microgram RAE/d)"
         "Folate (microgram/d)"     
         "Calcium (mg/d)"           
         "Iron (mg/d)"              
         "Zinc (mg/d)"              
         "Potassium (mg/d)"         
         "Fibre (g/d)"              
         "Copper (mg/d)"            
         "Phosphorus (mg/d)"        
         "Thiamin (mg/d)"           
         "Riboflavin (mg/d)"        
         "Niacin (mg/d)"            
         "Vitamin B6 (mg/d)"        
         "Magnesium (mg/d)"         
         "Pantothenate (mg/d)"       
         "Vitamin B12 (microgram/d)"      
         /
         map_nutr(*,nutr_n)         map to nutrient names      /
         calories          ."Calories (kcal/d)"
         protein           ."Protein (g/d)"
         carbohydrates     ."Carbohydrates (g/d)"
         fat               ."Fat (g/d)"
         saturatedFA       ."Saturated fat (g/d)"
         monounsatFA       ."MUPAs (g/d)"
         polyunsatFA       ."PUFAs (g/d)"
         vitaminC          ."Vitamin C (mg/d)"
         vitaminA          ."Vitamin A (microgram RAE/d)"
         folate            ."Folate (microgram/d)"
         calcium           ."Calcium (mg/d)"
         iron              ."Iron (mg/d)"
         zinc              ."Zinc (mg/d)"
         potassium         ."Potassium (mg/d)"
         fiber             ."Fibre (g/d)"
         copper            ."Copper (mg/d)"
         phosphorus        ."Phosphorus (mg/d)"
         thiamin           ."Thiamin (mg/d)"
         riboflavin        ."Riboflavin (mg/d)"
         niacin            ."Niacin (mg/d)"
         vitaminB6         ."Vitamin B6 (mg/d)"
         magnesium         ."Magnesium (mg/d)"
         pantothenate      ."Pantothenate (mg/d)"
         vitaminB12        ."Vitamin B12 (microgram/d)"
         /
         stats_n           statistics/
         mean, low, high
         /
         itm_nutr          item of nutritional analysis   /
         abs, pct, rec, "%rec"
         /
         itm_nutr_n        parameter         /
         "nutrient content"
         "change in nutrients (%)"
         "recommended intake"
         "deviation from recommendation (%)"
         /
         map_itm_nutr(itm_nutr,itm_nutr_n)   /
         abs."nutrient content"
         pct."change in nutrients (%)"
         rec."recommended intake"
         "%rec"."deviation from recommendation (%)"
         /;
         
*        - consumption report:

set       cons_itm         consumption items /
          "g/d_w", "kcal/d_w", "g/d", "kcal/d"
          /
          cons_itm_n       consumption parameter/
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
          /
          itm_chg_cons     measure /
          abs, chg, pct
          /;

*-------------------------------------------------------------------------------

$onExternalOutput

*        consumption analysis:
parameter report_cons(itm_chg_cons,diet_scn_n,cons_itm_n,fg_agg,rgs,yrs_scn)     consumption analysis;

*        health analysis:
parameter report_health(health_itm_n,diet_scn_n,riskf_io,cause_io,rgs,yrs_scn,stats_io)  health analysis;

*        environmental analysis:
parameter report_env(itm_chg_env,env_itm_n,diet_scn_n,fg_agg,rgs,yrs_scn)        environmental analysis
          report_PB(PB_itm_n,rgs,diet_scn_n,env_itm_n,fg_agg,yrs_all)            planetary boundary analysis;

*        cost analysis:
parameter report_cost(itm_chg_cst_n,diet_scn_n,waste_scn_cst,fg_agg,rgs,yrs_scn,stats_c)   cost-of-diet analysis;

*        nutritional analysis:
parameter report_nutr(itm_nutr_n,diet_scn_n,nutr_n,rgs,fg_agg,yrs_scn,stats_n)     nutritional analysis;

$offExternalOutput

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

