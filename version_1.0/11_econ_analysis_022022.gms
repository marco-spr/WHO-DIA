*-------------------------------------------------------------------------------
*        Value of changes in mortality based on value of statistical life (VSL)
*-------------------------------------------------------------------------------

*        run together with health analysis

*        otherwise load health estimates:
*parameter health_scn       results of health analysis;
*$gdxin 3_health_analysis_022022.gdx
*$load  health_scn
*$gdxin

*-------------------------------------------------------------------------------

*        load regional VSL values:

parameter VSL_reg(*,*,*,*,*)         VSL differentiated by income group (million 2017-USD)
/
$offlisting
$ondelim
$include VSL_reg_10182021.csv
$offdelim
$onlisting
/;

*        load GDP data:

parameter socio_data(*,*,*)          socio-economic data from the World Bank (2017-USD)
/
$offlisting
$ondelim
$include socio_data_10182021.csv
$offdelim
$onlisting
/;

*        define sets for uncertainty analysis (in input_output file):

*set       vsl_stats        Stats of the VSL value     /mean, low, high/
*          elas_stats       Stats of the VSL transfer  /mean, low, high/;

*-------------------------------------------------------------------------------

*        calculate the value of health changes [million x 1000 = billion]:

parameter value_health       valuation of avoided deaths (2017-USD);

*        units: 2017-USD 
value_health("GDP","BMK",r,"all-rf","%yrs_ref%","mean","mean")
         = socio_data("GDP",r,"%yrs_ref%");

*        units: 2017-USD
value_health("VSL","BMK",r,"all-rf","%yrs_ref%",vsl_stats,elas_stats)
         = VSL_reg("all",r,"%yrs_ref%",vsl_stats,elas_stats)*1E6;
         
*        units: deaths 
value_health("deaths",diet_scn_p,r,riskf_p,"%yrs_ref%","mean",stats)
         = health_scn("deaths_avd",diet_scn_p,riskf_p,"all-c",r,"%yrs_ref%",stats);

*        units: 2017-USD
value_health("value",diet_scn_p,r,riskf_p,"%yrs_ref%",vsl_stats,elas_stats)
         = value_health("VSL","BMK",r,"all-rf","%yrs_ref%",vsl_stats,elas_stats)
         * value_health("deaths",diet_scn_p,r,riskf_p,"%yrs_ref%","mean",elas_stats);

*        units: percentage of GDP:
value_health("%GDP",diet_scn_p,r,riskf_p,yrs_scn,vsl_stats,elas_stats)
         $value_health("GDP","BMK",r,"all-rf",yrs_scn,"mean","mean")
         = 100* value_health("value",diet_scn_p,r,riskf_p,yrs_scn,vsl_stats,elas_stats)
              / value_health("GDP","BMK",r,"all-rf",yrs_scn,"mean","mean");

*-------------------------------------------------------------------------------

*        summarise in report:

*parameter report_vsl(itm_vsl,diet_scn_n,r,riskf_p,"%yrs_ref%",vsl_stats,elas_stats);

report_vsl("value (USD million)",diet_scn_n,r,riskf_p,"%yrs_ref%",vsl_stats,elas_stats)
         = sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           value_health("value",diet_scn_p,r,riskf_p,"%yrs_ref%",vsl_stats,elas_stats)/1E6);

report_vsl("value (% of GDP)",diet_scn_n,r,riskf_p,"%yrs_ref%",vsl_stats,elas_stats)
         = sum(diet_scn_p$map_scn(diet_scn_p,diet_scn_n),
           value_health("%GDP",diet_scn_p,r,riskf_p,"%yrs_ref%",vsl_stats,elas_stats));
         
*-------------------------------------------------------------------------------

*        write to database:

execute_unload '11_econ_analysis_022022.gdx' report_vsl, value_health;
*$exit

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------