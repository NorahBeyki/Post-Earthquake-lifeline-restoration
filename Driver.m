%% Driver

% This code calculates the post-earthquake restoration time of
% interdependent lifeline systems (power and water) for desired hazard
% levels and generates service restoration curves suitable to use for a
% single building functional recovery assessment

clear all; clc; close all; 
RP = [72, 108, 224, 475, 975, 2475, 4975]; %return periods in year

for z=1:length(RP)
    %Repeat process for each network per hazard level
    NTW="EPS"; %EPS,WDS,NGS,TS are the options
    EPS_key = 1 ;
    WDS_key = 1 ;
    TS_key  = 0 ;
    hazard   = RP(z);
    Framework    
    save(strcat('Utilities_',num2str(hazard),'.mat'),'Output')
    fclose('all');
end


