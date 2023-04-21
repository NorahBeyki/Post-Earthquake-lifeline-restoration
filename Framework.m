
%Reading Inputs

%Static Inputs:

% - Network Fragility Curves: EPS, WDS, TS
% - Component Restoration Times From HAZUS
% - Mapping Functions for Translating Network Damage to Component Damage
% - Mean values of P(lack Srv|DS of NTW) and P distribution Weights for
% linking to buildings

% Dynamic Inputs:

% - Regional Hazard Info: Mean of MAX PGA, STD of MAX PGA
% - Component Quantities: Magnitudes, STD assumed
% - Crew options
% - Connectivity intervals
%% STATIC INPUTS

%Network Fragilities
Static.Fragilities.EPS = xlsread('Static_Data.xlsx','Frag_EPS');
Static.Fragilities.WDS = xlsread('Static_Data.xlsx','Frag_WDS');
Static.Fragilities.TS  = xlsread('Static_Data.xlsx','Frag_TS');

%Component Restoration Times From HAZUS:
Static.Comp_Rest.other.Mean = xlsread('Static_Data.xlsx','RT_HAZUS','C2:G9');
Static.Comp_Rest.other.STD  = xlsread('Static_Data.xlsx','RT_HAZUS','C11:G18');
persons_each_crew_pipes = 8;   %based on HAZUS (it can be 4 or 8; only for water pipelines)
%pipeline rest time
Four_person_pipe_Break = ((8+12)/2)/24 ; %a four person crew can repair a break at 8 and 12 hours for small and large  (turned to days; average is taken)
Four_person_pipe_Leak  = ((4+6)/2)/24 ; %a four person crew can repair a break at 4 and 6 hours  small and large (turned to days; average is taken)
%unit restoration time for pipelines
Pipe_leak_rest  = persons_each_crew_pipes*Four_person_pipe_Leak/4 ;
Pipe_break_rest = persons_each_crew_pipes*Four_person_pipe_Break/4 ;
Static.Comp_Rest.pipe.Mean = [0 Pipe_leak_rest Pipe_break_rest];

%Mapping Functions for Translating Network Damage to Component Damage
Static.MapFunc.other = xlsread('Static_Data.xlsx','Map_Func','B2:F11');
Static.MapFunc.Pipes = xlsread('Static_Data.xlsx','Map_Func','B16:D25');

%Definition of Mean values of P(lack Srv|DS of NTW) and P distribution Weights
P_lack_Mean    = [1 0.9 0.85 0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05];
P_lack_Mean_TS = [1 0.9 0.85 0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05];
Weight         = [0 8 7 4 2 1 0.5 0.2 0.05 0.01 0.001];
Weight_TS      = [0 8 7 4 2 1 0.5 0.2 0.05 0.01 0.001];
STD_P          = 0.5;
STD_W          = 1;
%% DYNAMIC INPUTS

%Regional Hazard Info
Dynamic.Max_PGA.mean   = xlsread('Dynamic_Data_LA.xlsx','Hazard','C2:C8');
Dynamic.Max_PGA.STD    = xlsread('Dynamic_Data_LA.xlsx','Hazard','D2:D8');
Dynamic.Max_PGA.RT     = xlsread('Dynamic_Data_LA.xlsx','Hazard','E2:E8');
%Component Quantities
Dynamic.Comp_Quant.EPS = xlsread('Dynamic_Data_LA.xlsx','Comp_Quantity','B3:C7');
Dynamic.Comp_Quant.WDS = xlsread('Dynamic_Data_LA.xlsx','Comp_Quantity','B9:B13');
Dynamic.Comp_Quant.TS  = xlsread('Dynamic_Data_LA.xlsx','Comp_Quantity','B21:B21');
Dynamic.Comp_Quant.STD = 0.4;

%Crew Options
Dynamic.Crew.Option1   = xlsread('Dynamic_Data_LA.xlsx','Crew','B2');
Dynamic.Crew.Option2   = xlsread('Dynamic_Data_LA.xlsx','Crew','B4:B9');
%% Constants
nMCS1 = 2500;
nMCS2 = 2500;
initial=0.01;
Connectivity  = 0:10:100;
EPS_flag = zeros(nMCS1,3);
WDS_flag = zeros(nMCS1,3);
TS_flag = zeros(nMCS1,3);
%% Questions for the user


%Determine What hazard level you want to assess

PGA_local_mean = Dynamic.Max_PGA.mean(Dynamic.Max_PGA.RT==hazard);
PGA_local_STD = Dynamic.Max_PGA.STD(Dynamic.Max_PGA.RT==hazard);
[mu_PGA,sigma_PGA] = lognormal_parameters(PGA_local_mean,PGA_local_STD);

%Determine if you want to assess building restoration or not

Bldg_key = 1;

%Determine what option you want to have for crews
Crew_Option = 1;
%option 1
No_Crews=Dynamic.Crew.Option1;
%Option 2
EPS_Subs_Crew  = Dynamic.Crew.Option2(1);
EPS_Gate_Crew  = Dynamic.Crew.Option2(2);
EPS_Trans_Crew = Dynamic.Crew.Option2(3);
WDS_Pump_Crew  = Dynamic.Crew.Option2(4);
WDS_Tank_Crew  = Dynamic.Crew.Option2(5);
WDS_Pipe_Crew  = Dynamic.Crew.Option2(6);

figure_key = 0; %or 1 (if on)
%% % input fragility curves (pull out lognormal distribution parameters)
[EPS_Parameters,EPS_Median_Sa] = Damage_info((Static.Fragilities.EPS).*3,"EPS","NG"); %NG is a decision key (if we want to keep DS0 in curves or not, refer to Osorio's 2010 paper)
[WDS_Parameters,WDS_Median_Sa] = Damage_info((Static.Fragilities.WDS).*3,"WDS","NG");
[TS_Parameters,TS_Median_Sa]   = Damage_info((Static.Fragilities.TS).*3,"TS","OK");
%% Component Quantity
EPS_Gate_Secondary_WDS    = Dynamic.Comp_Quant.EPS(1);
EPS_Subs_Primary_WDS      = Dynamic.Comp_Quant.EPS(2);
EPS_Subs_NoRel            = Dynamic.Comp_Quant.EPS(3);
EPS_TR_INT                = Dynamic.Comp_Quant.EPS(4);
EPS_Subs_Primary_TS       = Dynamic.Comp_Quant.EPS(5);

WDS_Pump_Secondary_EPS    = Dynamic.Comp_Quant.WDS(1);
WDS_INT_Primary_EPS       = Dynamic.Comp_Quant.WDS(2);
WDS_INT_NoRel             = Dynamic.Comp_Quant.WDS(3);
WDS_Tanks                 = Dynamic.Comp_Quant.WDS(4);
WDS_Pipe                  = Dynamic.Comp_Quant.WDS(5);

TS_Central_Secondary_EPS  = Dynamic.Comp_Quant.TS(1);
STD_Comp                  = Dynamic.Comp_Quant.STD;
gas                       = zeros(nMCS1,1);
%%  Mapping network damage to component damage

%Coefficients used for mapping network damage to the damage of components
Damage_Matrix       = Static.MapFunc.other;
Damage_Matrix_Pipes = Static.MapFunc.Pipes;

%Repair quantities (Component quantities)*(mapping matrix)
DS_EPS_Gate_Secondary_WDS = EPS_Gate_Secondary_WDS*Damage_Matrix ;
DS_EPS_Subs_Primary_WDS   = EPS_Subs_Primary_WDS*Damage_Matrix;
DS_EPS_Subs_NoRel         = EPS_Subs_NoRel*Damage_Matrix;
DS_EPS_TR_INT             = EPS_TR_INT*Damage_Matrix;
DS_EPS_Subs_Primary_TS    = EPS_Subs_Primary_TS*Damage_Matrix;

DS_WDS_Pump_Secondary_EPS = WDS_Pump_Secondary_EPS*Damage_Matrix;
DS_WDS_INT_Primary_EPS    = WDS_INT_Primary_EPS*Damage_Matrix_Pipes;
DS_WDS_INT_NoRel          = WDS_INT_NoRel*Damage_Matrix;
DS_WDS_Tanks              = WDS_Tanks*Damage_Matrix;
DS_WDS_Pipe               = WDS_Pipe*Damage_Matrix_Pipes;

DS_TS_Central_Secondary_EPS     = TS_Central_Secondary_EPS*Damage_Matrix;

N = size(Damage_Matrix);
M = size(Damage_Matrix_Pipes);

for i=1:N(1)
    for j=1:N(2)
        [mu_DS_EPS_Gate_Secondary_WDS(i,j),sigma_DS_EPS_Gate_Secondary_WDS(i,j)]     = lognormal_parameters(DS_EPS_Gate_Secondary_WDS(i,j),STD_Comp);
        [mu_DS_EPS_Subs_Primary_WDS(i,j),sigma_DS_EPS_Subs_Primary_WDS(i,j)]         = lognormal_parameters(DS_EPS_Subs_Primary_WDS(i,j),STD_Comp);
        [mu_DS_EPS_Subs_NoRel(i,j),sigma_DS_EPS_Subs_NoRel(i,j)]                     = lognormal_parameters(DS_EPS_Subs_NoRel(i,j),STD_Comp);
        [mu_DS_EPS_TR_INT(i,j),sigma_DS_EPS_TR_INT(i,j)]                             = lognormal_parameters(DS_EPS_TR_INT(i,j),STD_Comp);
        [mu_DS_EPS_Subs_Primary_TS(i,j),sigma_DS_EPS_Subs_Primary_TS(i,j)]           = lognormal_parameters(DS_EPS_Subs_Primary_TS(i,j),STD_Comp);

        [mu_DS_WDS_Pump_Secondary_EPS(i,j),sigma_DS_WDS_Pump_Secondary_EPS(i,j)]     = lognormal_parameters(DS_WDS_Pump_Secondary_EPS(i,j),STD_Comp);
        [mu_DS_WDS_INT_NoRel(i,j),sigma_DS_WDS_INT_NoRel(i,j)]                       = lognormal_parameters(DS_WDS_INT_NoRel(i,j),STD_Comp);
        [mu_DS_WDS_Tanks(i,j),sigma_DS_WDS_Tanks(i,j)]                               = lognormal_parameters(DS_WDS_Tanks(i,j),STD_Comp);

        [mu_DS_TS_Central_Secondary_EPS(i,j),sigma_DS_TS_Central_Secondary_EPS(i,j)] = lognormal_parameters(DS_TS_Central_Secondary_EPS(i,j),STD_Comp);
    end
end

for i=1:M(1)
    for j=1:M(2)
        [mu_DS_WDS_INT_Primary_EPS(i,j),sigma_DS_WDS_INT_Primary_EPS(i,j)]           = lognormal_parameters(DS_WDS_INT_Primary_EPS(i,j),STD_Comp);
        [mu_DS_WDS_Pipe(i,j),sigma_DS_WDS_Pipe(i,j)]                                 = lognormal_parameters(DS_WDS_Pipe(i,j),STD_Comp);
    end
end

%% Component restoration time from hazus

Rest_Mean_Matrix     = Static.Comp_Rest.other.Mean;
Rest_STD_Matrix      = Static.Comp_Rest.other.STD;

EPS_Gate_Mean_Rest   = Rest_Mean_Matrix(1,:);
EPS_Gate_STD_Rest    = Rest_STD_Matrix(1,:);

EPS_Subs_Mean_Rest   = Rest_Mean_Matrix(2,:);
EPS_Subs_STD_Rest    = Rest_STD_Matrix(2,:);

WDS_Pump_Mean_Rest   = Rest_Mean_Matrix(3,:);
WDS_Pump_STD_Rest    = Rest_STD_Matrix(3,:);

WDS_Tank_Mean_Rest   = Rest_Mean_Matrix(4,:);
WDS_Tank_STD_Rest    = Rest_STD_Matrix(4,:);

EPS_Trans_Mean_Rest  = Rest_Mean_Matrix(7,:);
EPS_Trans_STD_Rest   = Rest_STD_Matrix(7,:);

TS_Central_Mean_Rest = Rest_Mean_Matrix(8,:);
TS_Central_STD_Rest  = Rest_STD_Matrix(8,:);

Pipe_Mean_Rest       = Static.Comp_Rest.pipe.Mean;
%% PHASE I - LIFELINE RESTORATION CALCULATIONS
for j=1:nMCS1

    PGA_random(j) = lognrnd(mu_PGA,sigma_PGA);

    % Probabilities of Different DS's in a specific PGA
    [EPS_P] = Probability_of_DS(PGA_random(j),EPS_Parameters);
    [WDS_P] = Probability_of_DS(PGA_random(j),WDS_Parameters);
    [TS_P]  = Probability_of_DS(PGA_random(j),TS_Parameters);

    %randomizing the probability of damage by uniform distribution
    X1=rand;
    random_Prob(j)=X1;
    % Inital Damage state detection for all networks
    [DS_State_EPS,EPS_DS_No,N_EPS,EPS_index] = DS_Detection(EPS_P,X1,"EPS","NG");
    [DS_State_WDS,WDS_DS_No,N_WDS,WDS_index] = DS_Detection(WDS_P,X1,"WDS","NG");
    [DS_State_TS,TS_DS_No,N_TS,TS_index]     = DS_Detection(TS_P,X1,"TS","OK");

    %ranodmizing component restoration time

    random_EPS_Gate_Rest=[0,normrnd(EPS_Gate_Mean_Rest(2),EPS_Gate_STD_Rest(2)),...
        normrnd(EPS_Gate_Mean_Rest(3),EPS_Gate_STD_Rest(3)),...
        normrnd(EPS_Gate_Mean_Rest(4),EPS_Gate_STD_Rest(4)),...
        normrnd(EPS_Gate_Mean_Rest(5),EPS_Gate_STD_Rest(5))];
    random_EPS_Gate_Rest(random_EPS_Gate_Rest<0)=0;


    random_EPS_Subs_Rest=[0,normrnd(EPS_Subs_Mean_Rest(2),EPS_Subs_STD_Rest(2)),...
        normrnd(EPS_Subs_Mean_Rest(3),EPS_Subs_STD_Rest(3)),...
        normrnd(EPS_Subs_Mean_Rest(4),EPS_Subs_STD_Rest(4)),...
        normrnd(EPS_Subs_Mean_Rest(5),EPS_Subs_STD_Rest(5))];
    random_EPS_Subs_Rest(random_EPS_Subs_Rest<0)=0;


    random_WDS_Pump_Rest=[0,normrnd(WDS_Pump_Mean_Rest(2),WDS_Pump_STD_Rest(2)),...
        normrnd(WDS_Pump_Mean_Rest(3),WDS_Pump_STD_Rest(3)),...
        normrnd(WDS_Pump_Mean_Rest(4),WDS_Pump_STD_Rest(4)),...
        normrnd(WDS_Pump_Mean_Rest(5),WDS_Pump_STD_Rest(5))];
    random_WDS_Pump_Rest(random_WDS_Pump_Rest<0)=0;


    random_WDS_Tank_Rest=[0,normrnd(WDS_Tank_Mean_Rest(2),WDS_Tank_STD_Rest(2)),...
        normrnd(WDS_Tank_Mean_Rest(3),WDS_Tank_STD_Rest(3)),...
        normrnd(WDS_Tank_Mean_Rest(4),WDS_Tank_STD_Rest(4)),...
        normrnd(WDS_Tank_Mean_Rest(5),WDS_Tank_STD_Rest(5))];
    random_WDS_Tank_Rest(random_WDS_Tank_Rest<0)=0;


    random_EPS_Trans_Rest=[0,normrnd(EPS_Trans_Mean_Rest(2),EPS_Trans_STD_Rest(2)),...
        normrnd(EPS_Trans_Mean_Rest(3),EPS_Trans_STD_Rest(3)),...
        normrnd(EPS_Trans_Mean_Rest(4),EPS_Trans_STD_Rest(4)),...
        normrnd(EPS_Trans_Mean_Rest(5),EPS_Trans_STD_Rest(5))];
    random_EPS_Trans_Rest(random_EPS_Trans_Rest<0)=0;

    random_TS_Central_Rest=[0,normrnd(TS_Central_Mean_Rest(2),TS_Central_STD_Rest(2)),...
        normrnd(TS_Central_Mean_Rest(3),TS_Central_STD_Rest(3)),...
        normrnd(TS_Central_Mean_Rest(4),TS_Central_STD_Rest(4)),...
        normrnd(TS_Central_Mean_Rest(5),TS_Central_STD_Rest(5))];
    random_TS_Central_Rest(random_TS_Central_Rest<0)=0;

    %randomizing the repair quantity (EPS)
    DS_EPS_Gate_Secondary_WDS_rand  = lognrnd(mu_DS_EPS_Gate_Secondary_WDS,sigma_DS_EPS_Gate_Secondary_WDS);
    DS_EPS_Subs_Primary_WDS_rand    = lognrnd(mu_DS_EPS_Subs_Primary_WDS,sigma_DS_EPS_Subs_Primary_WDS);
    DS_EPS_Subs_Primary_TS_rand     = lognrnd(mu_DS_EPS_Subs_Primary_TS,sigma_DS_EPS_Subs_Primary_TS);
    DS_EPS_Subs_NoRel_rand          = lognrnd(mu_DS_EPS_Subs_NoRel,sigma_DS_EPS_Subs_NoRel);

    DS_EPS_Trans_rand               = lognrnd(mu_DS_EPS_TR_INT,sigma_DS_EPS_TR_INT);
    %randomizing the repair quantity (WDS)
    DS_WDS_Pump_Secondary_EPS_rand  = lognrnd(mu_DS_WDS_Pump_Secondary_EPS,sigma_DS_WDS_Pump_Secondary_EPS);

    DS_WDS_INT_Primary_EPS_rand     = lognrnd(mu_DS_WDS_INT_Primary_EPS,sigma_DS_WDS_INT_Primary_EPS);
    DS_WDS_INT_NoRel_rand           = lognrnd(mu_DS_WDS_INT_NoRel,sigma_DS_WDS_INT_NoRel);

    DS_WDS_Tanks_rand               = lognrnd(mu_DS_WDS_Tanks,sigma_DS_WDS_Tanks);

    DS_WDS_Pipe_rand                = lognrnd(mu_DS_WDS_Pipe,sigma_DS_WDS_Pipe);

    %randomizing the repair quantity (TS)
    DS_TS_Central_Secondary_EPS_rand  = lognrnd(mu_DS_TS_Central_Secondary_EPS,sigma_DS_TS_Central_Secondary_EPS);

    %Calculating the total repair time for all network DSs and EPS portions
    %EPS
    EPS_Gate_Secondary_WDS_Itself_T = DS_EPS_Gate_Secondary_WDS_rand*random_EPS_Gate_Rest';
    EPS_Subs_Primary_WDS_T          = DS_EPS_Subs_Primary_WDS_rand*random_EPS_Subs_Rest';
    EPS_Subs_Primary_TS_T           = DS_EPS_Subs_Primary_TS_rand*random_EPS_Subs_Rest';
    EPS_DS_EPS_Subs_NoRel_T         = DS_EPS_Subs_NoRel_rand*random_EPS_Subs_Rest' ;

    EPS_Trans_T                     = DS_EPS_Trans_rand*random_EPS_Trans_Rest';
    %WDS (intersection nodes are invulnerable ; for Primarys, we take pipeline recovery times)
    WDS_Pump_Secondary_EPS_Itself_T = DS_WDS_Pump_Secondary_EPS_rand*random_WDS_Pump_Rest';

    WDS_INT_Primary_EPS_T       = DS_WDS_INT_Primary_EPS_rand*Pipe_Mean_Rest';

    %WDS_INT_NoRel_T            = DS_WDS_INT_NoRel_rand*random_EPS_Subs_Rest';
    WDS_Tanks_T                 = DS_WDS_Tanks_rand*random_WDS_Tank_Rest';
    WDS_Pipe_T                  = DS_WDS_Pipe_rand*Pipe_Mean_Rest' ;

    %TS
    TS_Central_Secondary_EPS_Itself_T    = DS_TS_Central_Secondary_EPS_rand*random_TS_Central_Rest';

    %assume 1 resource unit available and 1 assigned to each component
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %EPS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %--------------------------------------------------------------
    %Calculating the total restoration time for Interdependent EPS
    %--------------------------------------------------------------

    if EPS_DS_No~=0 && WDS_DS_No~=0

        EPS_delay_of_WDS = WDS_INT_Primary_EPS_T(WDS_index);

        if EPS_delay_of_WDS > EPS_Gate_Secondary_WDS_Itself_T(EPS_index)
            EPS_Gate_SecondaryofWDS_T =  WDS_INT_Primary_EPS_T(WDS_index:10);
            govern_EPS(j) = 1;
        else
            EPS_Gate_SecondaryofWDS_T = EPS_Gate_Secondary_WDS_Itself_T(EPS_index:10);
            govern_EPS(j) = 2;
        end

        R1=length(EPS_Gate_SecondaryofWDS_T);
        if  WDS_DS_No~=5 || EPS_DS_No~=5
            EPS_Gate_SecondaryofWDS_T1=cat(1,zeros([abs(10-R1),1]), EPS_Gate_SecondaryofWDS_T);
        else
            EPS_Gate_SecondaryofWDS_T1=EPS_Gate_SecondaryofWDS_T;
        end

        EPS_Gate_T   = EPS_Gate_SecondaryofWDS_T1(EPS_index:10);
        if Crew_Option == 1
            EPS_Sum_Intdep= (EPS_Gate_T + EPS_Trans_T(EPS_index:10) + EPS_Subs_Primary_WDS_T(EPS_index:10)+...
                EPS_DS_EPS_Subs_NoRel_T(EPS_index:10))/No_Crews;
        else
            %Diff crew sizes for various components:
            T1 = EPS_Gate_T/EPS_Gate_Crew;
            T2 = EPS_Trans_T(EPS_index:10)/EPS_Trans_Crew;
            T3 = EPS_Subs_Primary_WDS_T(EPS_index:10)/EPS_Subs_Crew;
            T4 = EPS_DS_EPS_Subs_NoRel_T(EPS_index:10)/EPS_Subs_Crew;
            T5 = [T1 T2 T3 T4];

            for tt=1:size(T5,1)
                max1 = 0;
                for ttt=1:size(T5,2)
                    if T5(tt,ttt)>max1
                        max1 = T5(tt,ttt);
                    end
                end
                EPS_Sum_Intdep(tt,1) = max1;
            end
        end
        EPS_Sum_Intdep=sort(EPS_Sum_Intdep,'descend');
        EPS_Sum_Intdep=flip(EPS_Sum_Intdep);
        EPS_Rest_Intdep=cat(2,initial,EPS_Sum_Intdep');

        for k=1:length(EPS_Rest_Intdep)
            if EPS_Rest_Intdep(k) <0
                EPS_Rest_Intdep(k)=0.4;
            end
            EPS_Restoration_T_intdep(j,length(EPS_Rest_Intdep)+1-k)=EPS_Rest_Intdep(k);

        end

        EPS_REST_Intdep=flip(EPS_Restoration_T_intdep,2);

    else
        EPS_Sum_Intdep=0;
    end

    EPS_Intdep_initDS(j)=Connectivity(EPS_index);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %WDS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %--------------------------------------------------------------
    %Calculating the total restoration time for Interdependent WDS
    %--------------------------------------------------------------

    if EPS_DS_No~=0 && WDS_DS_No~=0

        WDS_delay_of_EPS = EPS_Subs_Primary_WDS_T(EPS_index);

        if WDS_delay_of_EPS > WDS_Pump_Secondary_EPS_Itself_T(WDS_index)
            WDS_Pump_SecondaryofEPS_T =  EPS_Subs_Primary_WDS_T(EPS_index:10);
            govern_WDS(j) = 1;
        else
            WDS_Pump_SecondaryofEPS_T = WDS_Pump_Secondary_EPS_Itself_T(WDS_index:10);
            govern_WDS(j) = 2;
        end

        R1=length(WDS_Pump_SecondaryofEPS_T);
        if  WDS_DS_No~=5 || EPS_DS_No~=5
            WDS_Pump_SecondaryofEPS_T1=cat(1,zeros([abs(10-R1),1]),WDS_Pump_SecondaryofEPS_T);
        else
            WDS_Pump_SecondaryofEPS_T1=WDS_Pump_SecondaryofEPS_T;
        end

        WDS_Pump_T   = WDS_Pump_SecondaryofEPS_T1(WDS_index:10);

        %One crew size for whole network:
        if Crew_Option == 1
            WDS_Sum_Intdep =(WDS_Pump_T+WDS_Tanks_T(WDS_index:10)+...
                + WDS_Pipe_T(WDS_index:10))/No_Crews;
        else

            %Diff crew sizes for various components:
            T1 = WDS_Pump_T/WDS_Pump_Crew;
            T2 = WDS_Tanks_T(WDS_index:10)/WDS_Tank_Crew;
            T3 = WDS_Pipe_T(WDS_index:10)/WDS_Pipe_Crew;
            T4 = [T1 T2 T3];

            for tt=1:size(T4,1)
                max1 = 0;
                for ttt=1:size(T4,2)
                    if T4(tt,ttt)>max1
                        max1 = T4(tt,ttt);
                    end
                end
                WDS_Sum_Intdep(tt,1) = max1;
            end
        end

        WDS_Sum_Intdep=flip(WDS_Sum_Intdep);
        WDS_Rest_Intdep=cat(2,initial,WDS_Sum_Intdep');

        for k=1:length(WDS_Rest_Intdep)
            if WDS_Rest_Intdep(k) <0
                WDS_Rest_Intdep(k)=0.4;
            end
            WDS_Restoration_T_intdep(j,length(WDS_Rest_Intdep)+1-k)=WDS_Rest_Intdep(k);

        end

        WDS_REST_Intdep=flip(WDS_Restoration_T_intdep,2);

    else
        WDS_Sum_Intdep=0;
    end
    WDS_Intdep_initDS(j)=Connectivity(WDS_index);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %TS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %--------------------------------------------------------------
    %Calculating the total restoration time for Interdependent TS
    %--------------------------------------------------------------

    if EPS_DS_No~=0 && TS_DS_No~=0

        TS_delay_of_EPS = EPS_Subs_Primary_TS_T(EPS_index);
        if TS_delay_of_EPS > TS_Central_Secondary_EPS_Itself_T(TS_index)
            TS_Central_SecondaryofEPS_T =  EPS_Subs_Primary_TS_T(EPS_index:10);
            govern_TS(j) = 1;
        else
            TS_Central_SecondaryofEPS_T = TS_Central_Secondary_EPS_Itself_T(TS_index:10);
            govern_EPS(j) = 2;
        end

        R1=length(TS_Central_SecondaryofEPS_T);
        if  TS_DS_No~=4 || EPS_DS_No~=5
            TS_Central_SecondaryofEPS_T1=cat(1,zeros([abs(10-R1),1]),TS_Central_SecondaryofEPS_T);
        else
            TS_Central_SecondaryofEPS_T1=TS_Central_SecondaryofEPS_T;
        end

        TS_Central_T   = TS_Central_SecondaryofEPS_T1(TS_index:10);

        TS_Sum_Intdep =(TS_Central_T)/No_Crews;

        TS_Sum_Intdep=flip(TS_Sum_Intdep);
        TS_Rest_Intdep=cat(2,initial,TS_Sum_Intdep');

        for k=1:length(TS_Rest_Intdep)
            if TS_Rest_Intdep(k) <0
                TS_Rest_Intdep(k)=0.4;
            end
            TS_Restoration_T_intdep(j,length(TS_Rest_Intdep)+1-k)=TS_Rest_Intdep(k);

        end

        TS_REST_Intdep=flip(TS_Restoration_T_intdep,2);

    else
        TS_Sum_Intdep=0;
        TS_REST_Intdep = zeros(length(Connectivity),1)';
    end

    TS_Intdep_initDS(j)=Connectivity(TS_index);
end
if figure_key==1
    set(gcf,'units','inches','position',[0.01   0.05   3.5   2.5],'PaperPositionMode','auto');  %Suitable for copying to word document (120% - 125%)
    set(gca,'Fontname','Arial','Fontsize',10,'FontWeight','normal');
    set(legend,'Fontname','Arial','Fontsize',6,'FontWeight','normal');
end
%%%%%%%%%%%%%%%%%%%%%  EPS PLOT  %%%%%%%%%%%%%%%%%%%%%%%
%mean of Interdependent EPS

[meanRest_EPS_Intdep,meanConn_EPS_Intdep]=MeanPlot(EPS_Intdep_initDS,EPS_REST_Intdep,Connectivity,initial);
if EPS_key == 1 && figure_key == 1
    plot(meanRest_EPS_Intdep,meanConn_EPS_Intdep,'-','DisplayName',num2str(hazard))
    hold on
    legend('location','southeast')
    EDP = " Connectivity (%)";
end

%%%%%%%%%%%%%%%%%%%%%  WDS PLOT  %%%%%%%%%%%%%%%%%%%%%%%

%mean of interdependent WDS
[meanRest_WDS_Intdep,meanConn_WDS_Intdep]=MeanPlot(WDS_Intdep_initDS,WDS_REST_Intdep,Connectivity,initial);
if WDS_key == 1 && figure_key == 1
    semilogx(meanRest_WDS_Intdep,meanConn_WDS_Intdep,'-','DisplayName',num2str(hazard))
    hold on
    %legend('location','southeast')
    EDP = " Connectivity (%)";
end

%%%%%%%%%%%%%%%%%%%%%  TS PLOT  %%%%%%%%%%%%%%%%%%%%%%%

%mean of interdependent TS
[meanRest_TS_Intdep,meanConn_TS_Intdep]=MeanPlot(TS_Intdep_initDS,TS_REST_Intdep,Connectivity,initial);
if TS_key ==1 && figure_key == 1
    plot(meanRest_TS_Intdep,meanConn_TS_Intdep,'-*','DisplayName',num2str(hazard))
    hold on
    legend('location','southeast')
    EDP = " Performance (%)";
end
%
if figure_key==1
    ylabel({NTW ;EDP},'FontWeight','bold','Fontname','Arial','Fontsize',8)
    xlabel({'Restoration time (days)'},'FontWeight','bold','Fontname','Arial','Fontsize',9)
    set(legend,'Fontname','Arial','Fontsize',6,'FontWeight','normal');
    ylim([0,100])
    box on; grid on;
    %xticks(0:10:80)
end
%% PHASE 2 - BUILDING RESTORATION LINKED

if Bldg_key == 1
    for i=1:length(P_lack_Mean)
        [mu_P_lack_Mean(i),sigma_P_lack_Mean(i)]=lognormal_parameters(P_lack_Mean(i),STD_P);
        [mu_P_lack_Mean_TS(i),sigma_P_lack_Mean_TS(i)]=lognormal_parameters(P_lack_Mean_TS(i),STD_P);
        [mu_Weight(i),sigma_Weight(i)]=lognormal_parameters(Weight(i),STD_W);
        [mu_Weight_TS(i),sigma_Weight_TS(i)]=lognormal_parameters(Weight_TS(i),STD_W);
    end
    if EPS_key == 1
        [EPS_step,EPS_init_Any,EPS_init_Full]=NTWs_to_Buildings(figure_key,nMCS2,meanConn_EPS_Intdep',meanRest_EPS_Intdep',mu_P_lack_Mean,mu_Weight,sigma_P_lack_Mean,sigma_Weight,"EPS",hazard);
        EPS_step(EPS_step==0)=[];
        %output for functional recovery code
        EPS_SEQ1_NLF = EPS_REST_Intdep(:,length(Connectivity));
        EPS_SEQ3_LF  = EPS_REST_Intdep(:,EPS_step(2));
        EPS_SEQ2_NF  = EPS_SEQ1_NLF-EPS_SEQ3_LF ;

        if length(EPS_SEQ1_NLF)<nMCS1
            DS0s = zeros(nMCS1-length(EPS_SEQ1_NLF),1);
            EPS_SEQ1_NLF = cat(1,EPS_SEQ1_NLF,DS0s);
            EPS_SEQ2_NF  = cat(1,EPS_SEQ2_NF,DS0s);
            EPS_SEQ3_LF  = cat(1,EPS_SEQ3_LF,DS0s);
        end
        for o=1:nMCS1
            XX=random_Prob(o)*100;
            if XX <= mean(EPS_init_Full)
                Bldg_state(o,1) = "Full";
            elseif mean(EPS_init_Any)>XX && XX>mean(EPS_init_Full)
                Bldg_state(o,1) = "SEQ3";
            elseif XX>=mean(EPS_init_Any)
                if XX>=(100+mean(EPS_init_Any))/2
                    Bldg_state(o,1)="SEQ2";
                else
                    Bldg_state(o,1)="SEQ1";
                end
            end
        end
        EPS_state = Bldg_state;
%         save(strcat('EPS_SEQ1_NLF_',num2str(hazard),'.mat'),'EPS_SEQ1_NLF')
%         save(strcat('EPS_SEQ2_NF_',num2str(hazard),'.mat'),'EPS_SEQ2_NF')
%         save(strcat('EPS_SEQ3_LF_',num2str(hazard),'.mat'),'EPS_SEQ3_LF')
%         save(strcat('EPS_Bldg_state_',num2str(hazard),'.mat'),'EPS_state')
    end
    if WDS_key == 1
        [WDS_step,WDS_init_Any,WDS_init_Full]=NTWs_to_Buildings(figure_key,nMCS2,meanConn_WDS_Intdep',meanRest_WDS_Intdep',mu_P_lack_Mean,mu_Weight,sigma_P_lack_Mean,sigma_Weight,"WDS",hazard);
        WDS_step(WDS_step==0)=[];
        %output for functional recovery code
        WDS_SEQ1_NLF = WDS_REST_Intdep(:,length(Connectivity));
        WDS_SEQ3_LF  = WDS_REST_Intdep(:,WDS_step(2));
        WDS_SEQ2_NF  = WDS_SEQ1_NLF-WDS_SEQ3_LF ;

        if length(WDS_SEQ1_NLF)<nMCS1
            DS0s = zeros(nMCS1-length(WDS_SEQ1_NLF),1);
            WDS_SEQ1_NLF = cat(1,WDS_SEQ1_NLF,DS0s);
            WDS_SEQ2_NF  = cat(1,WDS_SEQ2_NF,DS0s);
            WDS_SEQ3_LF  = cat(1,WDS_SEQ3_LF,DS0s);
        end
        for o=1:nMCS1
            XX=random_Prob(o)*100;
            if XX <= mean(WDS_init_Full)
                Bldg_state(o,1) = "Full";
            elseif mean(WDS_init_Any)>XX && XX>mean(WDS_init_Full)
                Bldg_state(o,1) = "SEQ3";
            elseif XX>=mean(WDS_init_Any)
                if XX>=(100+mean(WDS_init_Any))/2
                    Bldg_state(o,1)="SEQ2";
                else
                    Bldg_state(o,1)="SEQ1";
                end
            end
        end
        WDS_state=Bldg_state;
%         save(strcat('WDS_SEQ1_NLF_',num2str(hazard),'.mat'),'WDS_SEQ1_NLF')
%         save(strcat('WDS_SEQ2_NF_',num2str(hazard),'.mat'),'WDS_SEQ2_NF')
%         save(strcat('WDS_SEQ3_LF_',num2str(hazard),'.mat'),'WDS_SEQ3_LF')
%         save(strcat('WDS_Bldg_state_',num2str(hazard),'.mat'),'WDS_state')
    end
    if TS_key == 1
        [step,init_Any,init_Full]=NTWs_to_Buildings(figure_key,nMCS2,meanConn_TS_Intdep',meanRest_TS_Intdep',mu_P_lack_Mean_TS,mu_Weight_TS,sigma_P_lack_Mean_TS,sigma_Weight_TS,"TS",hazard);
    end
    if EPS_key == 1 && WDS_key == 1
        %formatspec = '{"electrical":[%f],"water":[%f],"gas":[%f]}';
        % Jsonname = sprintf('utility_downtime.json');
        %fid=fopen(Jsonname,'w');
        Output = struct("utilities",struct("electrical",struct("NLF",EPS_SEQ1_NLF,...
            "NF",EPS_SEQ2_NF,"LF",EPS_SEQ3_LF,"FULL",zeros(nMCS1,1),"state",EPS_state),"water",struct("NLF",WDS_SEQ1_NLF,"NF",WDS_SEQ2_NF,"LF",WDS_SEQ3_LF,"FULL",zeros(nMCS1,1),"state",WDS_state),...
            "gas",gas,"state",Bldg_state));
        %encodedJSON = jsonencode(s);
        %fprintf(fid,encodedJSON);
    end
end


