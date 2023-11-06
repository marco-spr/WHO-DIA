*-------------------------------------------------------------------------------
*        Diet Impact Assessment (DIA)
*-------------------------------------------------------------------------------

*        Manual:
*        Springmann M, The Diet Impact Assessment (DIA) model:
*        an interactive modelling tool for analysing the health,
*        environmental, and affordability implications of dietary
*        change. Version: 8 April

*        Contact:
*        Marco Springmann, Nuffield Department of Population Health,
*        University of Oxford, marco.springmann.ndph.ox.ac.uk.

*-------------------------------------------------------------------------------
*        Controls
*-------------------------------------------------------------------------------

*        set reference year:
$if not set yrs_ref      $set yrs_ref        2018

*        set reference scenario:
$if not set scn_ref      $set scn_ref        BMK

*        insert input data from MIRO (yes,no):
$if not set inp_data     $set inp_data       yes

*        run only for countries with modified values (yes,no):
$if not set scn_data     $set scn_data       yes

*-------------------------------------------------------------------------------
*        Subroutines
*-------------------------------------------------------------------------------

*        define input and output parameters:
$include 1_input_output_022022

*        run consumption analysis:
$include 10_cons_analysis_022022

*        prepare health data:
$include 2_health_data_022022

*        run health analysis:
$include 3_health_analysis_022022_2

*        prepare environmental data:
$include 4_env_data_022022

*        run environmental analysis:
$include 5_env_analysis_022022

*        prepare cost data:
$include 6_cost_data_022022

*        run cost analysis:
$include 7_cost_analysis_022022

*        prepare nutrient data:
$include 8_nutr_data_022022

*        run nutrient analysis:
$include 9_nutr_analysis_022022

*        run economic analysis:
$include 11_econ_analysis_022022

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------