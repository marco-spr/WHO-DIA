*-------------------------------------------------------------------------------
*        Nutrient analysis
*-------------------------------------------------------------------------------

*        prepare consumption data:

*        - use split between whole grains for wheat:

cons_ntr(diet_scn_io,"g/d_w","wwheat",r,"%yrs_ref%")
         = cons_ntr(diet_scn_io,"g/d_w","wheat",r,"%yrs_ref%")
           * sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n),
             inputs(r,"diet","whole grains (%)",diet_scn_n))/100;

cons_ntr(diet_scn_io,"g/d_w","wheat",r,"%yrs_ref%")
         = cons_ntr(diet_scn_io,"g/d_w","wheat",r,"%yrs_ref%")
           * (1-sum(diet_scn_n$map_scn(diet_scn_io,diet_scn_n),
                inputs(r,"diet","whole grains (%)",diet_scn_n))/100);
           
g2kcal("wwheat",r,"%yrs_ref%") = g2kcal("wheat",r,"%yrs_ref%");
        
set      fg_n, fg_np;
fg_n(fg)       = yes;
fg_n("wwheat") = yes;
fg_np(fg_p)    = yes;
fg_np("wwheat")= yes;

set      map_fg_n;
map_fg_n(fg_p,fg_agg)$map_fg(fg_p,fg_agg) = yes;
map_fg_n("wwheat","grains")               = yes;

*        - convert to kcals:

cons_ntr(diet_scn_p,"kcal/d_w",fg_n,r,"%yrs_ref%")
         = cons_ntr(diet_scn_p,"g/d_w",fg_n,r,"%yrs_ref%")
         * g2kcal(fg_n,r,"%yrs_ref%");

cons_ntr(diet_scn_p,"kcal/d_w","all-fg",r,"%yrs_ref%")
         = sum(fg_n, cons_ntr(diet_scn_p,"kcal/d_w",fg_n,r,"%yrs_ref%"));
         
*-------------------------------------------------------------------------------
                  
*        prepare nutrient data:

*        - convert to nutrient per calorie:

parameter nutr_fg_per_kcal nutrient per kcal;

nutr_fg_per_kcal(nutr,r,fg_n,stats_n)
         $nutr_fg_per_g("calories",r,fg_n,stats_n)
         = nutr_fg_per_g(nutr,r,fg_n,stats_n)
         / nutr_fg_per_g("calories",r,fg_n,stats_n);
         
parameter nutr_scn         nutritional analysis;

nutr_scn("abs",diet_scn_p,nutr,r,fg_n,"%yrs_ref%",stats_n)
         = nutr_fg_per_kcal(nutr,r,fg_n,stats_n)
         * cons_ntr(diet_scn_p,"kcal/d_w",fg_n,r,"%yrs_ref%");

*nutr_scn("abs",diet_scn_p,nutr,r,fg_n,"%yrs_ref%",stats_n)
*         = nutr_fg_per_g(nutr,r,fg_n,stats_n)
*         * cons_ntr(diet_scn_p,"g/d_w",fg_n,r,"%yrs_ref%");

*        - account for different coloured veg in EAT-Lancet scenarios:
set      scn_veg  /EAT, VEG, VGN/;

nutr_fg_per_kcal(nutr,r,"veg_col",stats_n)
         $nutr_fg_per_g("calories",r,"veg_col",stats_n)
         = nutr_fg_per_g(nutr,r,"veg_col",stats_n)
         / nutr_fg_per_g("calories",r,"veg_col",stats_n);

nutr_scn("abs",scn_veg,nutr,r,"vegetables","%yrs_ref%",stats_n)
         = nutr_fg_per_kcal(nutr,r,"veg_col",stats_n)
         * cons_ntr(scn_veg,"kcal/d_w","vegetables",r,"%yrs_ref%"); 

*        - sum over food groups:
nutr_scn("abs",diet_scn_p,nutr,r,"all-fg","%yrs_ref%",stats_n)
         = sum(fg_n, nutr_scn("abs",diet_scn_p,nutr,r,fg_n,"%yrs_ref%",stats_n));
         
*        - account for calcium intake through drinking water
*         (42 mg, see Beal et al, 2017):
nutr_scn("abs",diet_scn_p,"calcium",r,"water","%yrs_ref%",stats_n)$r_mod(r) = 42;
nutr_scn("abs",diet_scn_p,"calcium",r,"all-fg","%yrs_ref%",stats_n)$r_mod(r)
         = nutr_scn("abs",diet_scn_p,"calcium",r,"all-fg","%yrs_ref%",stats_n) + 42;

*        - calculate changes with respect to baseline:
nutr_scn("pct",diet_scn_p,nutr,r,fg_p,"%yrs_ref%",stats_n)
         $nutr_scn("abs","BMK",nutr,r,fg_p,"%yrs_ref%",stats_n)
         = 100 * (  nutr_scn("abs",diet_scn_p,nutr,r,fg_p,"%yrs_ref%",stats_n)
                  / nutr_scn("abs","BMK",nutr,r,fg_p,"%yrs_ref%",stats_n) -1);
                  
*-------------------------------------------------------------------------------

*        compare to nutrient recommendations:

*        - assign recommendations:
nutr_scn("rec","BMK",nutr,r,"all-fg","%yrs_ref%","mean")$r_mod(r)
         = nutr_needs(nutr,r);

*        - update kcal rec:
nutr_scn("rec","BMK","calories",r,"all-fg","%yrs_ref%","mean")$r_mod(r)
         = cons_ntr("EAT","kcal/d_w","all-fg",r,"%yrs_ref%");
         
*        - use calcium recommendation from WHO chapter (520 mg):
nutr_scn("rec","BMK","calcium",r,"all-fg","%yrs_ref%","mean")$r_mod(r)
         = nutr_needs("calcium_WHO",r);

*        omit sodium as not all can be captured:
*nutr_scn("rec","BMK","sodium",r,"all-fg","%yrs_ref%","mean")       = 0;
*nutr_scn("abs",diet_scn_p,"sodium",r,"all-fg","%yrs_ref%",stats_n) = 0;
                  
*        omit recommendations on fats and carbohydrates:
set      nutr_s  selected nutrients;
nutr_s(nutr)            = yes;
nutr_s("fat")           = no;
nutr_s("carbohydrates") = no;
nutr_s("sodium")        = no;

*        - calculate percentage difference:
nutr_scn("%rec",diet_scn_p,nutr_s,r,fg_p,"%yrs_ref%",stats_n)
         $nutr_scn("rec","BMK",nutr_s,r,"all-fg","%yrs_ref%","mean")
         = 100 * ( nutr_scn("abs",diet_scn_p,nutr_s,r,fg_p,"%yrs_ref%",stats_n)
                 / nutr_scn("rec","BMK",nutr_s,r,"all-fg","%yrs_ref%","mean") -1);

*-------------------------------------------------------------------------------

*        compile report:

*parameter report_nutr      report of nutrient analysis;
*set       itm_nutr         /abs, pct, rec, "%rec"/;

report_nutr(itm_nutr_n,diet_scn_n,nutr_n,r,fg_agg,"%yrs_ref%",stats_n)
         = sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           sum(fg_np$map_fg_n(fg_np,fg_agg),
           sum(nutr$map_nutr(nutr,nutr_n),
           sum(itm_nutr$map_itm_nutr(itm_nutr,itm_nutr_n),
           nutr_scn(itm_nutr,diet_scn_p,nutr,r,fg_np,"%yrs_ref%",stats_n) ))));
           
*-------------------------------------------------------------------------------

execute_unload '9_nutr_analysis_022022.gdx' report_nutr, nutr_scn, cons_ntr, nutr_needs, nutr_fg_per_g, nutr_fg_per_kcal;
*$exit

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------