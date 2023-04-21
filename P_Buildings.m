function [P_no_srv,P_LQ] = P_Buildings(CL,P_lack_Mean,Weight)
% if NTW~="TS"
CL=round(CL,1);
    if CL==1
        P_lack   = 1;
        P_no_srv = P_lack;
        P_LQ     = 0;
    elseif CL>=0.9 && CL<1
        P_lack   =  P_lack_Mean(2);
        P_no_srv = (Weight(2)/(Weight(2)+1))*P_lack;
        P_LQ     = (1/(Weight(2)+1))*P_lack;
    elseif CL>=0.8 && CL<0.9
        P_lack   =  P_lack_Mean(3);
        P_no_srv = (Weight(3)/(Weight(3)+1))*P_lack;
        P_LQ     = (1/(Weight(3)+1))*P_lack;
    elseif CL>=0.7 && CL<0.8
        P_lack   =  P_lack_Mean(4);
        P_no_srv = (Weight(4)/(Weight(4)+1))*P_lack;
        P_LQ     = (1/(Weight(4)+1))*P_lack;
    elseif CL>=0.6 && CL<0.7
        P_lack   =  P_lack_Mean(5);
        P_no_srv = (Weight(5)/(Weight(5)+1))*P_lack;
        P_LQ     = (1/(Weight(5)+1))*P_lack;
    elseif CL>=0.5 && CL<0.6
        P_lack   =  P_lack_Mean(6);
        P_no_srv = (Weight(6)/(Weight(6)+1))*P_lack;
        P_LQ     = (1/(Weight(6)+1))*P_lack;
    elseif CL>=0.4 && CL<0.5
        P_lack   =  P_lack_Mean(7);
        P_no_srv = (Weight(7)/(Weight(7)+1))*P_lack;
        P_LQ     = (1/(Weight(7)+1))*P_lack;
    elseif CL>=0.3 && CL<0.4
        P_lack   =  P_lack_Mean(8);
        P_no_srv = (Weight(8)/(Weight(8)+1))*P_lack;
        P_LQ     = (1/(Weight(8)+1))*P_lack;
    elseif CL>=0.2 && CL<0.3
        P_lack   =  P_lack_Mean(9);
        P_no_srv = (Weight(9)/(Weight(9)+1))*P_lack;
        P_LQ     = (1/(Weight(9)+1))*P_lack;
    elseif CL>=0.1 && CL<0.2
        P_lack   =  P_lack_Mean(10);
        P_no_srv = (Weight(10)/(Weight(10)+1))*P_lack;
        P_LQ     = (1/(Weight(10)+1))*P_lack;
    elseif CL>0 && CL<0.1
        P_lack   =  P_lack_Mean(11);
        P_no_srv = (Weight(11)/(Weight(11)+1))*P_lack;
        P_LQ     = (1/(Weight(11)+1))*P_lack;
    else
        P_lack = 0;
        P_no_srv = 0;
        P_LQ = 0;
    end
% else
%     if CL==1
%         P_lack   = 1;
%         P_no_srv = P_lack;
%         P_LQ     = 0;
%     elseif CL>=0.75 && CL<1
%         P_lack   =  P_lack_Mean(2);
%         P_no_srv = (Weight(2)/(Weight(2)+1))*P_lack;
%         P_LQ     = (1/(Weight(2)+1))*P_lack;
%     elseif CL>=0.5 && CL<0.75
%         P_lack   =  P_lack_Mean(3);
%         P_no_srv = (Weight(3)/(Weight(3)+1))*P_lack;
%         P_LQ     = (1/(Weight(3)+1))*P_lack;
%     elseif CL>=0.25 && CL<0.5
%         P_lack   =  P_lack_Mean(4);
%         P_no_srv = (Weight(4)/(Weight(4)+1))*P_lack;
%         P_LQ     = (1/(Weight(4)+1))*P_lack;
%     elseif CL>0 && CL<0.25
%         P_lack   =  P_lack_Mean(5);
%         P_no_srv = (Weight(5)/(Weight(5)+1))*P_lack;
%         P_LQ     = (1/(Weight(5)+1))*P_lack;
%     else
%         P_lack = 0;
%         P_no_srv = 0;
%         P_LQ = 0;
%     end
% end
end

