function [DS_State,DS_State_No,N,index] = DS_Detection(DS_Probability,Random,Network,Decision)

if Network=="EPS" || Network == "WDS"
    if Decision == "OK"
        if Random <DS_Probability(6)
            DS_State='DS5';
            DS_State_No=5;
            index = 1;
        elseif Random>DS_Probability(6) && Random<DS_Probability(5)
            DS_State='DS4';
            DS_State_No=4;
            index = 2;
        elseif Random>DS_Probability(5) && Random<DS_Probability(4)
            DS_State='DS3';
            DS_State_No=3;
            index = 4;
        elseif Random>DS_Probability(4) && Random<DS_Probability(3)
            DS_State='DS2';
            DS_State_No=2;
            index = 6;
        elseif Random>DS_Probability(3) && Random<DS_Probability(2)
            DS_State='DS1';
            DS_State_No=1;
            index = 8;
        elseif Random>DS_Probability(2) && Random<DS_Probability(1)
            DS_State='DS0';
            DS_State_No=0;
            index = 11;
        end
    else
        if Random <DS_Probability(5)
            DS_State='DS5';
            DS_State_No=5;
            index = 1;
        elseif Random>DS_Probability(5) && Random<DS_Probability(4)
            DS_State='DS4';
            DS_State_No=4;
            index = 2;
        elseif Random>DS_Probability(4) && Random<DS_Probability(3)
            DS_State='DS3';
            DS_State_No=3;
            index = 4;
        elseif Random>DS_Probability(3) && Random<DS_Probability(2)
            DS_State='DS2';
            DS_State_No=2;
            index = 6;
        elseif Random>DS_Probability(2) && Random<DS_Probability(1)
            DS_State='DS1';
            DS_State_No=1;
            index = 8;
        elseif Random>DS_Probability(1)
            DS_State='DS0';
            DS_State_No=0;
            index = 11;
        end
    end
else
    if Random <DS_Probability(4)
        DS_State='DS4';
        DS_State_No=4;
        index=1;
    elseif Random>DS_Probability(4) && Random<DS_Probability(3)
        DS_State='DS3';
        DS_State_No=3;
        index=2;
    elseif Random>DS_Probability(3) && Random<DS_Probability(2)
        DS_State='DS2';
        DS_State_No=2;
        index=3;
    elseif Random>DS_Probability(2) && Random<DS_Probability(1)
        DS_State='DS1';
        DS_State_No=1;
        index=4;
    elseif Random>DS_Probability(1)
        DS_State='DS0';
        DS_State_No=0;
        index=5;
    end
end

if DS_State_No== 0
    N=1;
else
    N=DS_State_No-1;
end

end
