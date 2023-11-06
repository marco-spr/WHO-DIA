# WHO-DIA
This repository contains the source files for the Diet Impact Assessment (DIA) model. The DIA model was commissioned by WHO Europe and developed by Marco Springmann. 

How to access and use the DIA model is described in its manual of use which is available in the repository and at: https://www.who.int/europe/publications/i/item/WHO-EURO-2023-8349-48121-71370

The DIA model was written in General Algebraic Modeling Language (GAMS) making use of the Model Interface with Rapid Orchestration (GAMS MIRO). It can be run with a free demo licence, provided it's used for non-commercial purposes, available at: https://www.gams.com/products/gams/gams-language/. 

Please direct any comments and suggestions to Marco Springmann, either via the [University of Oxford](https://www.eci.ox.ac.uk/person/dr-marco-springmann "Oxford profile page") (marco.springmann@ouce.ox.ac.uk) or the [London School of Hygiene and Tropical Medicine](https://www.lshtm.ac.uk/aboutus/people/springmann.marco "LSHTM profile page") (marco.springmann@lshtm.ac.uk). If you would like to use the tool for research with the intent to publish the results in the academic literature, please get in touch before submission. 

# How to run the model
The DIA model can be directly run from the servers of WHO Europe. To do this, please visit https://gams.ncd.digital/ and follow the instructions outlined in the user manual available at: https://www.who.int/europe/publications/i/item/WHO-EURO-2023-8349-48121-71370.  

You can also download and run the DIA model on your local PC.  No data are collected from you or about how the model runs, and you are free to use it for your own work, provided it is for non-commercial use. To download the DIA model, please download its source file 'DIA_version_1.zip' from the public repository https://github.com/marco-spr/WHO-DIA/ and unpack the content into a folder at a convenient location on your hard drive, e.g., /WHO-DIA/.

The modelling tool is coded in the algebraic modelling language GAMS (General Algebraic Modeling System; GAMS Software GmbH, Frechen, Germany) and designed to be run via its graphical user interface GAMS MIRO (Model Interface with Rapid Orchestration). 
To use the DIA model, you will have to install GAMS and GAMS MIRO and register for a free demo license. The demo license can be renewed as necessary, and all aspects of the modelling tool can be used with it. 
To install GAMS, go to https://www.gams.com/download/, and download the latest version for your operating system. GAMS and its editor GAMS Studio (included in the download) run on Mac, Windows and Linux operating systems. Please follow the instructions for installing GAMS.
 
On the same download page (https://www.gams.com/download/), you will find a registration form to apply for a free demo license. The license is all that is needed to run the modelling tool. Please request a demo license and, once you have received it, copy it to the GAMS model directory (the folder in which you installed GAMS). Then, start GAMS Studio to register the licence (via the tab 'GAMS Licensing'). You can find more detailed instructions on how to install GAMS for your platform at https://www.gams.com/latest/docs/UG_MAIN.html#UG_INSTALL (see “Installation Notes”). 

After you have installed GAMS and GAMS Studio, download and install GAMS MIRO from https://www.gams.com/miro/download.html.
Follow the installation notes to link GAMS MIRO with your version of GAMS STUDIO. In particular, make sure that the correct MIRO directory is linked to GAMS STUDIO. To check, open GAMS STUDIO, click on the “File” tab in the menu bar, and select “Settings”. (For Mac OS, “Studio” and “Preferences”.) Then, go to the “MIRO” tab, select the directory in which you installed GAMS MIRO, and click “OK”. You can find more detailed instructions on setting up and using MIRO at https://www.gams.com/miro/start.html. 

You are now ready to start using the tool. Open the file 'DIA.gms' in GAMS Studio and in the 'MIRO' tab click 'Run Base Mode'. The model completes one run and then automatically opens GAMS MIRO. When GAMS MIRO opens, you will see a pre-formatted pivot table without entries. Please load the model data by clicking “Load data” on the left, then select the last run/scenario, usually denoted “default”, and click “Import”. The pivot table for the input parameters should now be populated. 

All other steps are described in detail in the manual of use available at: https://www.who.int/europe/publications/i/item/WHO-EURO-2023-8349-48121-71370. 
