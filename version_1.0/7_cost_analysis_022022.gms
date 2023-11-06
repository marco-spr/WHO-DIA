*-------------------------------------------------------------------------------
*        Cost-of-diet analysis
*-------------------------------------------------------------------------------

*        prepare consumption data:

*        - include food waste:

cons_cst(diet_scn_p,"g/d",fg,r,"%yrs_ref%")
         = cons_cst(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         * waste_fac(fg,r,"%yrs_ref%");
         
*        - convert to kcals:

cons_cst(diet_scn_p,"kcal/d_w",fg,r,"%yrs_ref%")
         = cons_cst(diet_scn_p,"g/d_w",fg,r,"%yrs_ref%")
         * g2kcal(fg,r,"%yrs_ref%");
         
cons_cst(diet_scn_p,"kcal/d",fg,r,"%yrs_ref%")
         = cons_cst(diet_scn_p,"g/d",fg,r,"%yrs_ref%")
         * g2kcal(fg,r,"%yrs_ref%");
         
*-------------------------------------------------------------------------------

*        calculate cost of diet:

parameter diet_cost        cost of diets (in USD per person per day);
*set       waste_scn_cst      /full_waste, half_waste, no_waste/;

diet_cost(diet_scn_p,"full_waste",fg,r,"%yrs_ref%",stats_c)
         = cons_cst(diet_scn_p,"kcal/d",fg,r,"%yrs_ref%")/1000
         * price_data("per_Mcal",fg,r,"%yrs_ref%",stats_c);

diet_cost(diet_scn_p,"no_waste",fg,r,"%yrs_ref%",stats_c)
         = cons_cst(diet_scn_p,"kcal/d_w",fg,r,"%yrs_ref%")/1000
         * price_data("per_Mcal",fg,r,"%yrs_ref%",stats_c);

diet_cost(diet_scn_p,"half_waste",fg,r,"%yrs_ref%",stats_c)
         = (cons_cst(diet_scn_p,"kcal/d_w",fg,r,"%yrs_ref%")
            + (cons_cst(diet_scn_p,"kcal/d",fg,r,"%yrs_ref%") - cons_cst(diet_scn_p,"kcal/d_w",fg,r,"%yrs_ref%"))/2)
         /1000 * price_data("per_Mcal",fg,r,"%yrs_ref%",stats_c);

diet_cost(diet_scn_p,waste_scn_cst,"all-fg",r,"%yrs_ref%",stats_c)
         = sum(fg, diet_cost(diet_scn_p,waste_scn_cst,fg,r,"%yrs_ref%",stats_c));

*-------------------------------------------------------------------------------

*        summarise in report:

*parameter report_cost(itm_chg_cst,diet_scn_n,waste_scn_cst,fg_agg,rgs,stats_c)       cost-of-diet analysis;
*parameter report_cost    report of cost of diets for aggregate food groups;

report_cost("cost (USD/d)",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
         = sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           sum(fg_p$map_fg(fg_p,fg_agg),
           diet_cost(diet_scn_p,waste_scn_cst,fg_p,r,"%yrs_ref%",stats_c) ));           

report_cost("change in cost (USD/d)",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
         = report_cost("cost (USD/d)",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
         - report_cost("cost (USD/d)","0_Baseline","full_waste",fg_agg,r,"%yrs_ref%",stats_c);

report_cost("change in cost (%)",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
         $report_cost("cost (USD/d)","0_Baseline","full_waste",fg_agg,r,"%yrs_ref%",stats_c)
         = 100 * (report_cost("cost (USD/d)",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
                 /report_cost("cost (USD/d)","0_Baseline","full_waste",fg_agg,r,"%yrs_ref%",stats_c)-1);

report_cost("composition of costs",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
         $report_cost("cost (USD/d)",diet_scn_n,waste_scn_cst,"total",r,"%yrs_ref%",stats_c)
         = report_cost("cost (USD/d)",diet_scn_n,waste_scn_cst,fg_agg,r,"%yrs_ref%",stats_c)
         / report_cost("cost (USD/d)",diet_scn_n,waste_scn_cst,"total",r,"%yrs_ref%",stats_c);
         
*-------------------------------------------------------------------------------

execute_unload '7_cost_analysis_022022.gdx' report_cost, diet_cost, price_data, cons_cst, price_data;
*$exit

*-------------------------------------------------------------------------------