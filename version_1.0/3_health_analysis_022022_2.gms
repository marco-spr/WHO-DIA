*-------------------------------------------------------------------------------
*        Health analysis:
*-------------------------------------------------------------------------------

*        sets and parameters:

set       health_itm      items of health analysis
          /deaths_avd, deaths_avd_prm, YLL_avd, deaths, deaths_prm, YLL/
          
          health_itmm     items of health analysis (selected)
          /deaths_avd, deaths_avd_prm, YLL_avd/;
          
alias     (weight, weightt);

parameter PAF_scn(*,*,*,*,*,*,*)           population attributable fractions by scenario
          health_scn(*,*,*,*,*,*,*)        health analysis of diet scenarios
*         report_health(*,*,*,*,*,*)       report of health analysis
;       

*-------------------------------------------------------------------------------
*        Population atttributable/impact fractions:
*-------------------------------------------------------------------------------

*        PAF related to diet:
*        - for FV and meat, everybody in a country is exposed (p_food=1):
*          PAF_food = ( (p_food*RR_food)_ref -(p_food*RR_food)_scn )/(p_food*RR_food)_ref;
*                   = 1 - (p_food*RR_food)_scn/(p_food*RR_food)_ref;
*                   = 1 - ( power(RR_food,cns_chg_food)_scn/power(RR_food,cns_chg_food)_ref );

PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%",stats)
         $RR_scn_age("%scn_ref%",riskf_d,cause,r_sel,age,"%yrs_ref%",stats)
         = 1 - RR_scn_age(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%",stats)
             / RR_scn_age("%scn_ref%",riskf_d,cause,r_sel,age,"%yrs_ref%",stats);

*        Uncertainty of PAF related to diet:
*        - d_PAF_food = PAF_food * sqrt(  power(d_RR_food/RR_food, 2)_ref
*                                       + power(d_RR_food/RR_food, 2)_scn );
*          with RR_food = RR**cns_chg; d_RR_food = RR**cns_chg * (cns_chg * d_RR/RR)
*          d_PAF_food = PAF_food * sqrt(  power(d_RR_food/RR_food,2)_ref
*                                       + power(d_RR_food/RR_food,2)_scn;

PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","std")
         $(RR_scn_age("%scn_ref%",riskf_d,cause,r_sel,age,"%yrs_ref%","mean") and RR_scn_age(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","mean"))
         = PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","mean")
         * sqrt( power(RR_scn_age("%scn_ref%",riskf_d,cause,r_sel,age,"%yrs_ref%","std")/RR_scn_age("%scn_ref%",riskf_d,cause,r_sel,age,"%yrs_ref%","mean") ,2)
               + power(RR_scn_age(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","std") /RR_scn_age(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","mean")  ,2) );


*        PAF for all dietary risks combined:
PAF_scn(diet_scn,"diet",cause,r_sel,age,"%yrs_ref%",stats)
         = 1 - prod(riskf_d, 1-PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%",stats));

*        Uncertainty of combined PAFs:
*        PAF_cns = 1 - (1-PAF_fvc)*(1-PAF_mtc)
*                = PAF_fvc + PAF_mtc - PAF_fvc*+PAF_mtc
*        -> d_PAF_cns = sqrt(  power(d_PAF_fvc,2) + power(d_PAF_mtc,2)
*                            + power(PAF_fvc*PAF_mtc,2)
*                              * (  power(d_PAF_fvc/PAF_fvc,2)
*                                 + power(d_PAF_mtc/PAF_mtc,2) ) );
*        PAF_all_scn is analogous;

PAF_scn(diet_scn,"diet",cause,r_sel,age,"%yrs_ref%","std")
         = sqrt(   sum(riskf_d,   power(PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","std") ,2))
                 + prod(riskf_d,  power(PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","mean"),2))
                 * ( sum(riskf_d, power(PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","std")
                 /PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","mean"),2)$PAF_scn(diet_scn,riskf_d,cause,r_sel,age,"%yrs_ref%","mean")) ) );

*-------------------------------------------------------------------------------

*        PAF related to weight:
*        - reformulate PAF for ease of calculation:
*          PAF_wgh = ( sum(p_weight*RR_weight)-sum(p'_weight*RR_weight) )/ sum(p_weight*RR_weight);
*                  = 1 - sum(p'_weight*RR_weight)/sum(p_weight*RR_weight);

*alias (weight, weightt);
PAF_scn(diet_scn,"weight",cause,r_sel,age,"%yrs_ref%","mean")
         $sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean"))
         = 1- ( sum(weightt, weight_scn_sum(diet_scn,weightt,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weightt,cause,r_sel,age,"%yrs_ref%","mean"))
               /sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean")) );

*        Uncertainty of PAF related to weight:
*        -   PAF_wgh = 1 - sum(p'_weight*RR_weight)/sum(p_weight*RR_weight);
*        - d_PAF_wgh = PAF_wgh * sqrt(  power(d_sum(p'_weight*RR_weight)/sum(p'_weight*RR_weight),2)
*                                     + power(d_sum(p_weight*RR_weight)/sum(p_weight*RR_weight),2) );
*                      with d_sum(p_weight*RR_weight) = sqrt( sum( power(p_weight*d_RR_weight,2) ) );
*          d_PAF_wgh = PAF_wgh * sqrt(  sum( power(p'_weight*d_RR_weight,2) )/power(sum(p'_weight*RR_weight),2)
*                                     + sum( power(p_weight*d_RR_weight,2) )/power(sum(p_weight*RR_weight),2) );

PAF_scn(diet_scn,"weight",cause,r_sel,age,"%yrs_ref%","std")
         $sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean"))
         = PAF_scn(diet_scn,"weight",cause,r_sel,age,"%yrs_ref%","mean")
         * sqrt(   sum(weight, power(weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","mean")),2)
                 + sum(weight, power(weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean")),2) );

*        PAF disagg for underweight:
weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")        = weight_scn_sum("BMK",weight,r_sel,"%yrs_ref%");
weight_scn_sum(diet_scn,"underweight",r_sel,"%yrs_ref%") = weight_scn_ref(diet_scn,"underweight",r_sel,"%yrs_ref%");
weight_scn_sum(diet_scn,"normal",r_sel,"%yrs_ref%")      = 1 - sum(riskf_w, weight_scn_sum(diet_scn,riskf_w,r_sel,"%yrs_ref%"));
PAF_scn(diet_scn,"underweight",cause,r_sel,age,"%yrs_ref%","mean")
         $sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean"))
         = 1- ( sum(weightt, weight_scn_sum(diet_scn,weightt,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weightt,cause,r_sel,age,"%yrs_ref%","mean"))
               /sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean")) );

PAF_scn(diet_scn,"underweight",cause,r_sel,age,"%yrs_ref%","std")
         $sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean"))
         = PAF_scn(diet_scn,"underweight",cause,r_sel,age,"%yrs_ref%","mean")
         * sqrt(   sum(weight, power(weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","mean")),2)
                 + sum(weight, power(weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean")),2) );

*        PAF disagg for overweight:
weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")       = weight_scn_sum("BMK",weight,r_sel,"%yrs_ref%");
weight_scn_sum(diet_scn,"overweight",r_sel,"%yrs_ref%") = weight_scn_ref(diet_scn,"overweight",r_sel,"%yrs_ref%");
weight_scn_sum(diet_scn,"normal",r_sel,"%yrs_ref%")     = 1 - sum(riskf_w, weight_scn_sum(diet_scn,riskf_w,r_sel,"%yrs_ref%"));
PAF_scn(diet_scn,"overweight",cause,r_sel,age,"%yrs_ref%","mean")
         $sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean"))
         = 1- ( sum(weightt, weight_scn_sum(diet_scn,weightt,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weightt,cause,r_sel,age,"%yrs_ref%","mean"))
               /sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean")) );

PAF_scn(diet_scn,"overweight",cause,r_sel,age,"%yrs_ref%","std")
         $sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean"))
         = PAF_scn(diet_scn,"overweight",cause,r_sel,age,"%yrs_ref%","mean")
         * sqrt(   sum(weight, power(weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","mean")),2)
                 + sum(weight, power(weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean")),2) );

*        PAF disagg for obesity:
*set      weight_obese    /obese_g1, obese_g2, obese_g3/;
weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")   = weight_scn_sum("BMK",weight,r_sel,"%yrs_ref%");
weight_scn_sum(diet_scn,weight_obese,r_sel,"%yrs_ref%")  = weight_scn_ref(diet_scn,weight_obese,r_sel,"%yrs_ref%");
weight_scn_sum(diet_scn,"normal",r_sel,"%yrs_ref%") = 1 - sum(riskf_w, weight_scn_sum(diet_scn,riskf_w,r_sel,"%yrs_ref%"));
PAF_scn(diet_scn,"obese",cause,r_sel,age,"%yrs_ref%","mean")
         $sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean"))
         = 1- ( sum(weightt, weight_scn_sum(diet_scn,weightt,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weightt,cause,r_sel,age,"%yrs_ref%","mean"))
               /sum(weightt, weight_scn_sum("%scn_ref%",weightt,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weightt,cause,r_sel,age,"%yrs_ref%","mean")) );

PAF_scn(diet_scn,"obese",cause,r_sel,age,"%yrs_ref%","std")
         $sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean"))
         = PAF_scn(diet_scn,"obese",cause,r_sel,age,"%yrs_ref%","mean")
         * sqrt(   sum(weight, power(weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum(diet_scn,weight,r_sel,"%yrs_ref%")*RR_scn_age(diet_scn,weight,cause,r_sel,age,"%yrs_ref%","mean")),2)
                 + sum(weight, power(weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","std"),2) )
                 / power( sum(weight, weight_scn_sum("%scn_ref%",weight,r_sel,"%yrs_ref%")*RR_scn_age("%scn_ref%",weight,cause,r_sel,age,"%yrs_ref%","mean")),2) );

*-------------------------------------------------------------------------------

*        - combined risk factors:
PAF_scn(diet_scn,"all-rf",cause,r_sel,age,"%yrs_ref%",stats)
         = 1 - prod(riskf_c, 1-PAF_scn(diet_scn,riskf_c,cause,r_sel,age,"%yrs_ref%",stats));

PAF_scn(diet_scn,"all-rf",cause,r_sel,age,"%yrs_ref%","std")
         = sqrt(   sum(riskf_c,   power(PAF_scn(diet_scn,riskf_c,cause,r_sel,age,"%yrs_ref%","std") ,2))
                 + prod(riskf_c,  power(PAF_scn(diet_scn,riskf_c,cause,r_sel,age,"%yrs_ref%","mean"),2))
                 * ( sum(riskf_c, power(PAF_scn(diet_scn,riskf_c,cause,r_sel,age,"%yrs_ref%","std")
         /PAF_scn(diet_scn,riskf_c,cause,r_sel,age,"%yrs_ref%","mean"),2)$PAF_scn(diet_scn,riskf_c,cause,r_sel,age,"%yrs_ref%","mean")) ) );

*-------------------------------------------------------------------------------
*        Health impacts:
*-------------------------------------------------------------------------------

*        - avoided deaths:
health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         = sum(age, PAF_scn(diet_scn,riskf_p,cause,r_sel,age,"%yrs_ref%","mean")
         *  dr(age,cause,r_sel,"%yrs_ref%") * pop(age,r_sel,"%yrs_ref%") );

health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std")
         = sum(age, PAF_scn(diet_scn,riskf_p,cause,r_sel,age,"%yrs_ref%","std")
         *  dr(age,cause,r_sel,"%yrs_ref%") * pop(age,r_sel,"%yrs_ref%") );

health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","low")
         = health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         - health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std");

health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","high")
         = health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         + health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std");

health_scn("deaths_avd",diet_scn,riskf_p,"all-c",r_sel,"%yrs_ref%",stats)
         = sum(cause, health_scn("deaths_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%",stats));

*        - avoided premature deaths:
health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         = sum(age_prm, PAF_scn(diet_scn,riskf_p,cause,r_sel,age_prm,"%yrs_ref%","mean")
         *  dr(age_prm,cause,r_sel,"%yrs_ref%") * pop(age_prm,r_sel,"%yrs_ref%") );

health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std")
         = sum(age_prm, PAF_scn(diet_scn,riskf_p,cause,r_sel,age_prm,"%yrs_ref%","std")
         *  dr(age_prm,cause,r_sel,"%yrs_ref%") * pop(age_prm,r_sel,"%yrs_ref%") );

health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","low")
         = health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         - health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std");

health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","high")
         = health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         + health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std");

health_scn("deaths_avd_prm",diet_scn,riskf_p,"all-c",r_sel,"%yrs_ref%",stats)
         = sum(cause, health_scn("deaths_avd_prm",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%",stats));

*        - Years of Life Lost (YLL):
health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         = sum(age, PAF_scn(diet_scn,riskf_p,cause,r_sel,age,"%yrs_ref%","mean")
         * dr(age,cause,r_sel,"%yrs_ref%") * pop(age,r_sel,"%yrs_ref%")
         * life_exp(age) );

health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std")
         = sum(age, PAF_scn(diet_scn,riskf_p,cause,r_sel,age,"%yrs_ref%","std")
         * dr(age,cause,r_sel,"%yrs_ref%") * pop(age,r_sel,"%yrs_ref%")
         * life_exp(age) );

health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","low")
         = health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         - health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std");

health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","high")
         = health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","mean")
         + health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%","std");

health_scn("YLL_avd",diet_scn,riskf_p,"all-c",r_sel,"%yrs_ref%",stats)
         = sum(cause, health_scn("YLL_avd",diet_scn,riskf_p,cause,r_sel,"%yrs_ref%",stats));

*        - allocate colorectal cancer to all cancers:
health_scn(health_itm,diet_scn_p,riskf_redmeat,"cancer",r_sel,"%yrs_ref%",stats)
         = health_scn(health_itm,diet_scn_p,riskf_redmeat,"Colon and rectum cancers",r_sel,"%yrs_ref%",stats);

health_scn(health_itm,diet_scn_p,"all-rf","cancer",r_sel,"%yrs_ref%",stats)
         = health_scn(health_itm,diet_scn_p,"all-rf","cancer",r_sel,"%yrs_ref%",stats)
         + health_scn(health_itm,diet_scn_p,"all-rf","Colon and rectum cancers",r_sel,"%yrs_ref%",stats);

health_scn(health_itm,diet_scn_p,riskf_p,"Colon and rectum cancers",r_sel,"%yrs_ref%",stats) = 0;

*        - remove std values to decrease parameter size:
health_scn(health_itmm,diet_scn_p,riskf_p,cause_p,r_sel,"%yrs_ref%","std") = 0;

*-------------------------------------------------------------------------------

*        adjust risks of single risk factors to sum to total:
*        (even if looking at single risks, this is to account for co-exposure)

parameter fct_risk_comb    scaling factor for combining risk factors;

*        ratio of sum of aggregagted risks to all risks:
fct_risk_comb(health_itmm,diet_scn,"diet_weight_fct",cause_p,r_sel,"%yrs_ref%",stats)
         $health_scn(health_itmm,diet_scn,"all-rf",cause_p,r_sel,"%yrs_ref%",stats)
         =  ( health_scn(health_itmm,diet_scn,"diet",cause_p,r_sel,"%yrs_ref%",stats)
            + health_scn(health_itmm,diet_scn,"weight",cause_p,r_sel,"%yrs_ref%",stats) )
            / health_scn(health_itmm,diet_scn,"all-rf",cause_p,r_sel,"%yrs_ref%",stats);
            
*        ratio of sum of dietary risks to all diet risks:
fct_risk_comb(health_itmm,diet_scn,"diet_fct",cause_p,r_sel,"%yrs_ref%",stats)
         $health_scn(health_itmm,diet_scn,"diet",cause_p,r_sel,"%yrs_ref%",stats) 
         = (  sum(riskf_d, health_scn(health_itmm,diet_scn,riskf_d,cause_p,r_sel,"%yrs_ref%",stats))
            / health_scn(health_itmm,diet_scn,"diet",cause_p,r_sel,"%yrs_ref%",stats) )
         * fct_risk_comb(health_itmm,diet_scn,"diet_weight_fct",cause_p,r_sel,"%yrs_ref%",stats);

*        ratio of sum of weight-related risks to all weight risks (this should be 1 anyway):
fct_risk_comb(health_itmm,diet_scn,"weight_fct",cause_p,r_sel,"%yrs_ref%",stats)
         $health_scn(health_itmm,diet_scn,"weight",cause_p,r_sel,"%yrs_ref%",stats)
         = (  sum(riskf_ws, health_scn(health_itmm,diet_scn,riskf_ws,cause_p,r_sel,"%yrs_ref%",stats))
            / health_scn(health_itmm,diet_scn,"weight",cause_p,r_sel,"%yrs_ref%",stats) )
         * fct_risk_comb(health_itmm,diet_scn,"diet_weight_fct",cause_p,r_sel,"%yrs_ref%",stats);

*        adjust sums to equal multiplicative combinations:

health_scn(health_itmm,diet_scn,riskf_c,cause_p,r_sel,"%yrs_ref%",stats)
         $fct_risk_comb(health_itmm,diet_scn,"diet_weight_fct",cause_p,r_sel,"%yrs_ref%",stats)
         = health_scn(health_itmm,diet_scn,riskf_c,cause_p,r_sel,"%yrs_ref%",stats)
         / fct_risk_comb(health_itmm,diet_scn,"diet_weight_fct",cause_p,r_sel,"%yrs_ref%",stats);

health_scn(health_itmm,diet_scn,riskf_d,cause_p,r_sel,"%yrs_ref%",stats)
         $fct_risk_comb(health_itmm,diet_scn,"diet_fct",cause_p,r_sel,"%yrs_ref%",stats)
         = health_scn(health_itmm,diet_scn,riskf_d,cause_p,r_sel,"%yrs_ref%",stats)
         / fct_risk_comb(health_itmm,diet_scn,"diet_fct",cause_p,r_sel,"%yrs_ref%",stats);

health_scn(health_itmm,diet_scn,riskf_ws,cause_p,r_sel,"%yrs_ref%",stats)
         $fct_risk_comb(health_itmm,diet_scn,"weight_fct",cause_p,r_sel,"%yrs_ref%",stats)
         = health_scn(health_itmm,diet_scn,riskf_ws,cause_p,r_sel,"%yrs_ref%",stats)
         / fct_risk_comb(health_itmm,diet_scn,"weight_fct",cause_p,r_sel,"%yrs_ref%",stats);
         
*-------------------------------------------------------------------------------
*        Analysis:
*-------------------------------------------------------------------------------

*        - compare to all deaths and premature deaths:

health_scn("deaths","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean")$r_data("both",r_sel,"%yrs_ref%")
         = sum(age, dr(age,cause_p,r_sel,"%yrs_ref%") * pop(age,r_sel,"%yrs_ref%") );

health_scn("deaths_prm","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean")$r_data("both",r_sel,"%yrs_ref%")
         = sum(age_prm, dr(age_prm,cause_p,r_sel,"%yrs_ref%") * pop(age_prm,r_sel,"%yrs_ref%") );

health_scn("YLL","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean")$r_data("both",r_sel,"%yrs_ref%")
         = sum(age, dr(age,cause_p,r_sel,"%yrs_ref%") * pop(age,r_sel,"%yrs_ref%")
         * life_exp(age) );

*-------------------------------------------------------------------------------

*        - calculate percentages:
health_scn("%deaths_avd/all",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
         $health_scn("deaths","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean")
         = 100 * health_scn("deaths_avd",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
               / health_scn("deaths","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean");

health_scn("deaths_avd/1000pop",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
         $pop("all-a",r_sel,"%yrs_ref%")
         = health_scn("deaths_avd",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
               / pop("all-a",r_sel,"%yrs_ref%");

health_scn("%deaths_avd_prm/all",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
         $health_scn("deaths_prm","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean")
         = 100 * health_scn("deaths_avd_prm",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
               / health_scn("deaths_prm","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean");

health_scn("%YLL_avd/all",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
         $health_scn("YLL","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean")
         = 100 * health_scn("YLL_avd",diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
               / health_scn("YLL","BMK","all-rf",cause_p,r_sel,"%yrs_ref%","mean");

*-------------------------------------------------------------------------------
*        Reporting:
*-------------------------------------------------------------------------------

*        define reporting items:

$ontext
set      diet_scn_n(diet_scn_n)    scenario names    /
0_Baseline
1_Guidelines 
2_EAT-Lancet 
2_Pescatarian
3_Vegetarian 
4_Vegan      
5_Scenario
/
         map_scn(diet_scn_p,diet_scn_n)      mapping of diet scenarios  /
BMK.0_Baseline
NDG.1_Guidelines
EAT.2_EAT-Lancet
PSC.2_Pescatarian
VEG.3_Vegetarian
VGN.4_Vegan
SCN.5_Scenario
/
         health_itm_n      names of health items      /
"number of avoided deaths"
"number of avoided premature deaths"
"percentage reduction in all deaths among adults"
"percentage reduction in all premature deaths"
"avoided deaths per 1000 people"
/         
         map_health_itm(report_itm,health_itm_n)   mapping of health parameters        /
deaths_avd."number of avoided deaths"
deaths_avd_prm."number of avoided premature deaths"
"%deaths_avd/all"."percentage reduction in all deaths among adults"
"%deaths_avd_prm/all"."percentage reduction in all premature deaths"
"deaths_avd/1000pop"."avoided deaths per 1000 people"
/;
$offtext

*        compile report:

report_health(health_itm_n,diet_scn_n,riskf_p,cause_p,r,"%yrs_ref%",stats)$r_sel(r)
         = sum(diet_scn$map_scn(diet_scn,diet_scn_n),
           sum(report_itm$map_health_itm(report_itm,health_itm_n),
           health_scn(report_itm,diet_scn,riskf_p,cause_p,r,"%yrs_ref%",stats) ));

report_health(health_itm_n,diet_scn_n,riskf_p,cause_p,r,"%yrs_ref%","std") = 0;


*report_health("abs",report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
*         = health_scn(report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats);

*report_health("abs",report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%","std") = 0;

*report_health("chg",report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
*         = report_health("abs",report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
*         - report_health("abs",report_itm,"TMREL",riskf_p,cause_p,r_sel,"%yrs_ref%",stats);

*report_health("pct",report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
*         $report_health("abs",report_itm,"TMREL",riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
*         = 100 * (report_health("abs",report_itm,diet_scn,riskf_p,cause_p,r_sel,"%yrs_ref%",stats)
*                 /report_health("abs",report_itm,"TMREL",riskf_p,cause_p,r_sel,"%yrs_ref%",stats)-1);

*-------------------------------------------------------------------------------

*        write to database:

execute_unload '3_health_analysis_022022.gdx' health_scn, report_health, cons_scn, weight_scn_ref, weight_chg, r_sel;
*$exit

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
