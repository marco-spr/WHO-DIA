*-------------------------------------------------------------------------------
*        Health data:
*-------------------------------------------------------------------------------

*        - Mortality rates and population levels
*        - Exposure data (diets, weight levels)
*        - Relative risks

*-------------------------------------------------------------------------------
*        Define sets
*-------------------------------------------------------------------------------

sets
*         diet_scn_p(diet_scn_io)  diet scenarios /
*         BMK, NDG, WHO, EAT, PSC, VEG, VGN, SCN
*         /
*         diet_scn(diet_scn_p)     diet scenarios without BMK /
*         BMK, NDG, WHO, EAT, PSC, VEG, VGN, SCN
*         /
         riskf_p(riskf_io)        risk factors /
         fruits, vegetables, nuts_seeds, legumes, fish, red_meat, prc_meat, whole_grains, 
         underweight, overweight, obese, obese_g1, obese_g2, obese_g3,
         weight, diet, all-rf
         /
         riskf                    risk factors (for RR calc) /
         fruits, vegetables, nuts_seeds, legumes, red_meat, prc_meat, whole_grains,
*        fish,
         underweight, overweight, obese, obese_g1, obese_g2, obese_g3
         /
         riskf_d(riskf_p)         diet-related risk factors /
         fruits, vegetables, nuts_seeds, legumes, fish, red_meat, prc_meat, whole_grains
         /
         riskf_redmeat            risk factors related to red meat (associated with colorectal cancer) /
         red_meat, prc_meat
         /
         riskf_w(riskf_io)        weight-related risk factors /
         weight, underweight, overweight, obese_g1, obese_g2, obese_g3
         /
         riskf_ws(riskf_p)        weight-related risk factors with aggregate obesity /
         underweight, overweight, obese
         /
         weight                   weight classification /
         underweight, normal, overweight, obese_g1, obese_g2, obese_g3
         /             
         weight_obese             obesity categories /
         obese_g1, obese_g2, obese_g3
         /
         cause_p(cause_io)        causes of death /
         "all-c", CHD, Stroke, Cancer, "Colon and rectum cancers", T2DM, Resp_Dis
         /
         cause(cause_p)           causes of death
         /CHD, Stroke, Cancer, "Colon and rectum cancers", T2DM, Resp_Dis
         /
         age_p                    age groups plus aggregate /
         20-24, 25-29, 30-34, 35-39, 40-44, 45-49, 50-54, 55-59, 60-64, 65-69, 70-74,
         75-79, 80-84, 85-89, 90-94, 95+, "all-a"
         /
         age(age_p)               age groups (RRs apply from age 20 onwards) /
         20-24, 25-29, 30-34, 35-39, 40-44, 45-49, 50-54, 55-59, 60-64, 65-69, 70-74,
         75-79, 80-84, 85-89, 90-94, "95+"
         /
         age_prm(age_p)           age groups for which deaths is premature (age 30-70 according to WHO) /
         30-34, 35-39, 40-44, 45-49, 50-54, 55-59, 60-64, 65-69
         /
         stats(stats_io)          statistics /
         mean, low, high, std
         /
         report_itm(report_itm_io) items of health analysis /
         deaths_avd, deaths_avd_prm, YLL_avd,
         "%deaths_avd/all", "%deaths_avd_prm/all", "deaths_avd/1000pop"
         /;

*-------------------------------------------------------------------------------
*        Mortality and population data
*-------------------------------------------------------------------------------

*        load population data and death rates:

parameter dr(*,*,*,*)                    death rates (rate per thousand)
/
$offlisting
$ondelim
$include dr_05282021.csv
$offdelim
$onlisting
/;

Parameter pop(*,*,*)                     population numbers (in thousands)
/
$offlisting
$ondelim
$include pop_05282021.csv
$offdelim
$onlisting
/;

parameter life_exp(*)                    life expectancy (GBD life table)
/
$offlisting
$ondelim
$include lftable_05282021.csv
$offdelim
$onlisting
/;

*-------------------------------------------------------------------------------
*        Consumption data
*-------------------------------------------------------------------------------

*        load baseline consumption estimates (uncomment if cons_analysis not run):
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

*        assign data:
parameter cons_scn(*,*,*,*,*) consumption scenario (grams per day);
         
*        - baseline data:
cons_scn(diet_scn_p,"g/d_w",riskf_p,r,"%yrs_ref%")
         = sum(fg_io$map_fg2riskf(fg_io,riskf_p), cons_data(diet_scn_p,"g/d_w",fg_io,r,"%yrs_ref%"));
         
*        - scenario data:
if(%inp_data%,
cons_scn(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%") = 0;        
cons_scn(diet_scn_p,"g/d_w",riskf_p,r,"%yrs_ref%")
         = sum(fg_io$map_fg2riskf(fg_io,riskf_p), input(r,"diet",fg_io,diet_scn_p));
);

*-------------------------------------------------------------------------------
*        Weight data
*-------------------------------------------------------------------------------

*        load baseline weight distribution:

parameters weight_scn(*,*,*,*)           weight distribution in diet scenarios
/
$offlisting
$ondelim
$include weight_05282021.csv
$offdelim
$onlisting
/;

*        assign data:

parameter weight_scn_sum(*,*,*,*) weight scenario (proportion)
          weight_scn_ref(*,*,*,*) weight distribution in reference scenario;

*        - baseline data:
weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%")
         = weight_scn(diet_scn_p,weight,r,"%yrs_ref%");
         

parameter pct_obese(*,*) distribution within obese category;

weight_scn(diet_scn_p,"obese",r,"%yrs_ref%")
         = sum(weight_obese, weight_scn(diet_scn_p,weight_obese,r,"%yrs_ref%"));

pct_obese(weight_obese,r)$weight_scn("BMK","obese",r,"%yrs_ref%")
         = weight_scn("BMK",weight_obese,r,"%yrs_ref%")
         / weight_scn("BMK","obese",r,"%yrs_ref%");


*        - scenario data:
if(%inp_data%,
weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%")       = 0;
weight_scn_sum(diet_scn_p,riskf_ws,r,"%yrs_ref%")     = input(r,"weight",riskf_ws,diet_scn_p)/100;
weight_scn_sum(diet_scn_p,weight_obese,r,"%yrs_ref%") = pct_obese(weight_obese,r) * input(r,"weight","obese",diet_scn_p)/100;
weight_scn_sum(diet_scn_p,"normal",r,"%yrs_ref%")     = 1 - sum(weight, weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%"));
);

*        save weight scenarios for decomposition:
weight_scn_ref(diet_scn_p,weight,r,"%yrs_ref%")
         = weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%");

*-------------------------------------------------------------------------------
*        Scenario changes
*-------------------------------------------------------------------------------

*        identify scenario changes:

parameter weight_chg change in dietary exposure;
set       r_mod_w    country with changed weight data
          r_sel      countries for which to run the health analysis;

r_mod_w(r)$sum((diet_scn_p,weight),weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%")) = yes;

if(%scn_data%,
         
weight_chg(diet_scn_p,weight,r)
         = weight_scn_sum(diet_scn_p,weight,r,"%yrs_ref%")
         - weight_scn_ref(diet_scn_p,weight,r,"%yrs_ref%");

r_mod_w(r)$(abs(sum((diet_scn_p,weight), weight_chg(diet_scn_p,weight,r)))>1E-6) = yes;
r_mod_w(r)$(abs(sum((diet_scn_p,weight), weight_chg(diet_scn_p,weight,r)))<1E-6) = no;
);

*        select regions for health analysis:

set      r_data(*,*,*)     regions with data for analysis;
r_data("cons",r,"%yrs_ref%")$cons_scn("BMK","g/d_w","vegetables",r,"%yrs_ref%") = yes;
r_data("dr",r,"%yrs_ref%")  $dr("35-39","CHD",r,"%yrs_ref%")    = yes;
r_data("both",r,"%yrs_ref%")$r_data("dr",r,"%yrs_ref%"        ) = yes;
r_data("both",r,"%yrs_ref%")$(not r_data("cons",r,"%yrs_ref%")) = no;

*        run analysis only for regions with new scenario data:
if(%scn_data%,
r_data("both",r,"%yrs_ref%")$(r_mod_w(r) or r_mod(r))          = yes;
r_data("both",r,"%yrs_ref%")$(not r_mod_w(r) and not r_mod(r)) = no;
);

*        harmonise data:
cons_scn(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%")$(not r_data("both",r,"%yrs_ref%")) = 0;
dr(age_p,cause_p,r,"%yrs_ref%")                   $(not r_data("both",r,"%yrs_ref%")) = 0;
pop(age_p,r,"%yrs_ref%")                          $(not r_data("both",r,"%yrs_ref%")) = 0;

*        select countries for which to run the analysis:
r_sel(r)$(r_mod_w(r) or r_mod(r)) = yes;

*-------------------------------------------------------------------------------
*        Relative risks
*-------------------------------------------------------------------------------

*        load relative-risk estimates:

parameter RR_int(*,*,*,*)  relative risks schedule for dietary risks (dose-response function)
/
$offlisting
$ondelim
$include RR_int_05282021.csv
$offdelim
$onlisting
/;

parameter intake_max(*)    maximum intake (exposure) in dose-response functions
/
$offlisting
$ondelim
$include RR_max_05282021.csv
$offdelim
$onlisting
/;

parameter RR_data(*,*,*)   relative risk for 100g intake and weight-related risks
/
$offlisting
$ondelim
$include RR_data_05282021.csv
$offdelim
$onlisting
/;

parameter age_effects(*,*) age effects on relative risks
/
$offlisting
$ondelim
$include RR_age_05282021.csv
$offdelim
$onlisting
/;
      
*        load data (MOVE TO CSV):   
*$gdxin ../DATASETS/relative_risks/RR_0326_2021.gdx
*$load  RR_data, RR_int, age_effects, intake_max
*$gdxin

*       assign relative risk values:

parameter RR_scn        relative risks in scenarios;
set       intake        intake (exposure) level  /0*800/;
      
*       - assign diet-related relative risk value at consumption level:
RR_scn(diet_scn_p,riskf_d,cause,r,"%yrs_ref%",stats)
         $(r_data("both",r,"%yrs_ref%") and cons_scn(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%")<intake_max(riskf_d))
         = sum(intake$(intake.val=round(cons_scn(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%"))),
           RR_int(riskf_d,cause,intake,stats));

*       - ensure value is within range of dose-response function:
RR_scn(diet_scn_p,riskf_d,cause,r,"%yrs_ref%",stats)
         $(r_data("both",r,"%yrs_ref%") and cons_scn(diet_scn_p,"g/d_w",riskf_d,r,"%yrs_ref%")>intake_max(riskf_d))
         = sum(intake$(intake.val=intake_max(riskf_d)), RR_int(riskf_d,cause,intake,stats));
      
*       - assign categorical age-standardised RRs for weight-related risks:
RR_scn(diet_scn_p,riskf_w,cause,r,"%yrs_ref%",stats)
         $r_data("both",r,"%yrs_ref%")
         = RR_data(riskf_w,cause,stats);
    
RR_scn(diet_scn_p,"normal",cause,r,"%yrs_ref%",stats)
         $r_data("both",r,"%yrs_ref%")
         = 1;

*-------------------------------------------------------------------------------
     
*       include age effects (decreasing RR with age):
         
*        determine positive and negative risk factors:
parameter risk_dir   direction of risk factor (-1 for negative RRs +1 for positive RRs);
risk_dir(riskf,cause)$(RR_data(riskf,cause,"mean")<1) = -1;
risk_dir(riskf,cause)$(RR_data(riskf,cause,"mean")>1) = +1;
risk_dir(riskf,cause)$(RR_data(riskf,cause,"mean")=1) =  0;
risk_dir(riskf,cause)$(RR_data(riskf,cause,"mean")=0) =  0;

*        low and high CI intervals as pct deviation from mean:
RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","std_low")
    $RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","mean")
         = RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","low")
         / RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","mean") - 1;

RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","std_high")
    $RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","mean")
         = RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","high")
         / RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","mean") - 1;

*        apply age effects by loop to ensure no change of impact:

parameter RR_scn_age    relative risks in scenarios with age effects;
loop(age,

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")
        = RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","mean")
        * (1 + risk_dir(riskf,cause)*age_effects(age,"mean"));

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")
         $(risk_dir(riskf,cause) * (RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")-1) < 0)
         = RR_scn_age(diet_scn_p,riskf,cause,r,age-1,"%yrs_ref%","mean");

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","low")
         = RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")
         * (1+ RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","std_low") * age_effects(age,"std"));

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","low")
        $(risk_dir(riskf,cause) * (RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","low")-1) < 0)
         = RR_scn_age(diet_scn_p,riskf,cause,r,age-1,"%yrs_ref%","low");

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","high")
         = RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")
         * (1+ RR_scn(diet_scn_p,riskf,cause,r,"%yrs_ref%","std_high") * age_effects(age,"std"));

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","high")
         $(risk_dir(riskf,cause) * (RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","high")-1) < 0)
         = RR_scn_age(diet_scn_p,riskf,cause,r,age-1,"%yrs_ref%","high");

    RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%",stats)
         $(r_data("both",r,"%yrs_ref%") and risk_dir(riskf,cause)=0)
         = 1;

*        insert RRs for normal weight to prevent division by zero:         
    RR_scn_age(diet_scn_p,"normal",cause,r,age,"%yrs_ref%",stats)$r_data("both",r,"%yrs_ref%") = 1;
    RR_scn_age(diet_scn_p,"normal",cause,r,age,"%yrs_ref%","std")$r_data("both",r,"%yrs_ref%") = 0;
);

*        calc standard deviation for PAF calculations:
RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","std")
         = RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")
         - RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","low");

RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","std")
         $(RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","std")
            < (RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","high")-RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")))
         = RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","high")
         - RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean");

*        free up unused values:
RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","std_low")  = 0;
RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","std_high") = 0;

*        disable age effects (for testing):
*        RR_scn_age(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean")
*        = RR_scn(diet_scn_p,riskf,cause,r,age,"%yrs_ref%","mean");
    
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------