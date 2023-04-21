function [P_DS] = Probability_of_DS(PGA,Parameters)

NDS=size(Parameters);

    for i=1:NDS(1,1)
        P(i)=logncdf(PGA,Parameters(i,1),Parameters(i,2));
    end
    P_DS=P;

% a(i)=logncdf(PGA_random(i),CL100_mu,CL100_sigma);
% b(i)=logncdf(PGA_random(i),CL90_mu,CL90_sigma);
% c(i)=logncdf(PGA_random(i),CL70_mu,CL70_sigma);
% d(i)=logncdf(PGA_random(i),CL50_mu,CL50_sigma);
% e(i)=logncdf(PGA_random(i),CL30_mu,CL30_sigma);
% f(i)=logncdf(PGA_random(i),CL0_mu,CL0_sigma);
% 
% PF_CL100(i) = a(i);
% PF_CL90(i)  = b(i)-a(i);
% PF_CL70(i)  = c(i)-b(i);
% PF_CL50(i)  = d(i)-c(i);
% PF_CL30(i)  = e(i)-d(i);
% PF_CL0(i)   = f(i)-e(i);
% PF_nodamage(i) = 1-f(i);
% 
% all(i)=PF_CL100(i)+PF_CL90(i)+PF_CL70(i)+PF_CL50(i)+PF_CL30(i)+PF_CL0(i)+PF_nodamage(i);


end

