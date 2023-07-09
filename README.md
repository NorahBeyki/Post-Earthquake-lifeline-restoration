# Post-Earthquake-lifeline-restoration
This repository presents the MATLAB codes for calculating the interdependent lifeline systems' restoration, suitable to be used for a single building functional recovery assessments.

#inputs:
1- Staticdata.xlsx:
This file includes the assumed network fragility curves, mapping functions, and component restoration times. The current assumptions use Shelby County network fragility curves, mapping functions described in Mohammadgholibeyki et al. (2023), and component restoration times from HAZUS document.
2- Dynamic data:
This file is customized per the region of interest. It includes component quantities, max PGA of the region per return period, and crew assignment. 

Outputs:
Outputs can be generated for each assumed crew size and each hazard level. It contains a structure data for each utility system, and indicates the damage state for each. The user can calculate mean, median or STV of the data for n number of Monte Carlo realizations they assumed, per the utility system. 
