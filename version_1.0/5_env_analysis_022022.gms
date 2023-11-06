*-------------------------------------------------------------------------------
*        Environmental analysis
*-------------------------------------------------------------------------------

*        - food system analysis (consumption -> production needs)
*        - environmental analysis
*        - planetary boundary analysis

*-------------------------------------------------------------------------------
*        Food system analysis
*-------------------------------------------------------------------------------
          
parameter waste_scn     food waste in scenarios
          loss_scn      food loss in scenarios;

*        calculate total annual food demand:
   
*        - include waste at the consumption level:

waste_scn(diet_scn_p,fg,r,"%yrs_ref%")
         = (waste_fac(fg,r,"%yrs_ref%")-1) * cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%");
         
cons_prd(diet_scn_p,"g/d",fg,r,"%yrs_ref%")
         = waste_scn(diet_scn_p,fg,r,"%yrs_ref%") + cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%");

*        - convert to annual consumption:

cons_prd(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%")
         = cons_prd(diet_scn_p,"g/d",fg,r,"%yrs_ref%")
         * pop("all-a",r,"%yrs_ref%") * 365/1E6;

*        - include loss at the production level
*         (consumption-based footprints include attribution to imports)

loss_scn(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%") 
         = cons_prd(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%") * loss_pct(fg,r,"%yrs_ref%");

loss_scn(diet_scn_p,"g/d",fg,r,"%yrs_ref%")$pop("all-a",r,"%yrs_ref%")
         = loss_scn(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%")
         / pop("all-a",r,"%yrs_ref%") / 365*1E6;
         
cons_prd(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%")
         = cons_prd(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%") + loss_scn(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%");
         
*-------------------------------------------------------------------------------
*        Environmental analysis
*-------------------------------------------------------------------------------

*        environmental impacts:

parameter env_scn environmental impacts (MtCO2-eq -- 1000 Mkm2 -- km3 -- GgN -- GgP);

set       env_itm(env_itm_io) environmetnal domains
          /GHGe, GHGf, land, water, nitr, phos/;

env_scn(env_itm,diet_scn_p,fg,r,"%yrs_ref%")
         = cons_prd(diet_scn_p,"kt/yr",fg,r,"%yrs_ref%")/1E3
         * efoot("abs","per_kg","TECH",env_itm,"cons",fg,r,"%yrs_ref%");

env_scn(env_itm,diet_scn_p,"all-fg",r,"%yrs_ref%")
         = sum(fg, env_scn(env_itm,diet_scn_p,fg,r,"%yrs_ref%"));

env_scn(env_itm,diet_scn_p,fg_p,"all-r","%yrs_ref%")
         = sum(r, env_scn(env_itm,diet_scn_p,fg_p,r,"%yrs_ref%"));
     
*-------------------------------------------------------------------------------
*        Environmental report
*-------------------------------------------------------------------------------

*        compile summary report:

$ontext
set      env_itm_n         names of environmental parameters   /
         "Greenhouse gas emissions (CH4, N2O) (MtCO2eq)"
         "Greenhouse gas emissions (life-cycle) (MtCO2eq)"
         "Cropland use (1000 Mkm2)"
         "Freshwater use (km3)"
         "Nitrogen application (GgN)"
         "Phosphorus application (GgP)"
         /
         map_env_itm(env_itm_io,env_itm_n)    /
         GHGe."Greenhouse gas emissions (CH4, N2O) (MtCO2eq)"
         GHGf."Greenhouse gas emissions (life-cycle) (MtCO2eq)"
         land."Cropland use (1000 Mkm2)"
         water."Freshwater use (km3)"
         nitr."Nitrogen application (GgN)"
         phos."Phosphorus application (GgP)"
         /
         fg_agg        aggregate food groups (for output) /
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
         itm_chg_env   environment-related measure /
         abs, chg, pct
         /;
$offtext

*parameter report_env     report of environmental analysis;

report_env("abs",env_itm_n,diet_scn_n,fg_agg,rgs,"%yrs_ref%")
         = sum(env_itm$map_env_itm(env_itm,env_itm_n),
           sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           sum(fg_p$map_fg(fg_p,fg_agg),
           env_scn(env_itm,diet_scn_p,fg_p,rgs,"%yrs_ref%") )));
         
report_env("chg",env_itm_n,diet_scn_n,fg_agg,rgs,"%yrs_ref%")
         = report_env("abs",env_itm_n,diet_scn_n,fg_agg,rgs,"%yrs_ref%")
         - report_env("abs",env_itm_n,"0_Baseline",fg_agg,rgs,"%yrs_ref%");

report_env("pct",env_itm_n,diet_scn_n,fg_agg,rgs,"%yrs_ref%")
         $report_env("abs",env_itm_n,"0_Baseline",fg_agg,rgs,"%yrs_ref%")
         = 100 * ( report_env("abs",env_itm_n,diet_scn_n,fg_agg,rgs,"%yrs_ref%")
                 / report_env("abs",env_itm_n,"0_Baseline",fg_agg,rgs,"%yrs_ref%") -1 );;

*-------------------------------------------------------------------------------
*        Planetary boundary analysis
*-------------------------------------------------------------------------------

*        calculate impacts of everybody ate according to FBDGs:

parameter PB_scn impacts on planetary boundaries;
alias(r,s);

*        - halve waste for that

PB_scn("abs",r,diet_scn_p,env_itm,fg,"2050")
         = ( cons_prd(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
           + 0.5 * (waste_scn(diet_scn_p,fg,r,"%yrs_ref%") + loss_scn(diet_scn_p,"g/d",fg,r,"%yrs_ref%")))
         * sum(s, pop_2050("all-a",s,"2050") * 365/1E6 /1E3
         * efoot("abs","per_kg","TECH",env_itm,"cons",fg,s,"2050"));

PB_scn("abs",r,diet_scn_p,env_itm,"all-fg","2050")
         = sum(fg, PB_scn("abs",r,diet_scn_p,env_itm,fg,"2050"));
 
*        compare to planetary boundaries:

PB_scn("%PB",r,diet_scn_p,env_itm,fg_p,"2050")
         $(PB_scn("abs",r,diet_scn_p,env_itm,fg_p,"2050") and PB_values("PB_diet",env_itm))
         = 100 * (PB_scn("abs",r,diet_scn_p,env_itm,fg_p,"2050")/PB_values("PB_diet",env_itm));
         
PB_scn("%PB_min",r,diet_scn_p,env_itm,fg_p,"2050")
         $(PB_scn("abs",r,diet_scn_p,env_itm,fg_p,"2050") and PB_values("PB_diet",env_itm))
         = 100 * (PB_scn("abs",r,diet_scn_p,env_itm,fg_p,"2050")/PB_values("PB_min_diet",env_itm));
         
PB_scn("%PB_max",r,diet_scn_p,env_itm,fg_p,"2050")
         $(PB_scn("abs",r,diet_scn_p,env_itm,fg_p,"2050") and PB_values("PB_diet",env_itm))
         = 100 * (PB_scn("abs",r,diet_scn_p,env_itm,fg_p,"2050")/PB_values("PB_max_diet",env_itm));
         
*-------------------------------------------------------------------------------
*        Planetary boundary report
*-------------------------------------------------------------------------------

*        compile summary report:

$ontext
set      PB_itm   planetary boundary items /
         abs, "%PB", "%PB_min", "%PB_max"
         /
         PB_itm_n names of PB items /
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
$offtext

*parameter report_PB        report of planetary boundary analysis;

report_PB(PB_itm_n,r,diet_scn_n,env_itm_n,fg_agg,"2050")
         = sum(PB_itm$map_PB_itm(PB_itm,PB_itm_n),
           sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           sum(env_itm$map_env_itm(env_itm,env_itm_n),
           sum(fg_p$map_fg(fg_p,fg_agg),
           PB_scn(PB_itm,r,diet_scn_p,env_itm,fg_p,"2050") ))));

*-------------------------------------------------------------------------------

*        write to database:

execute_unload '5_env_analysis_022022.gdx' report_env, report_PB, PB_scn, env_scn, cons_prd, efoot;
*$exit

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------