function [Parameters,Median_Sa] = Damage_info(Curves,Network,Decision)
% This function determines the parameters of lognormal distributions for 
% network fragility functions


if Network~="TS"
    
    CL0=Curves(:,1);
    CL0(isnan(CL0))=[];
    CL30=Curves(:,2);
    CL30(isnan(CL30))=[];
    CL50=Curves(:,3);
    CL50(isnan(CL50))=[];
    CL70=Curves(:,4);
    CL70(isnan(CL70))=[];
    CL90=Curves(:,5);
    CL90(isnan(CL90))=[];
    CL100=Curves(:,6);
    CL100(isnan(CL100))=[];
    
    
    T100=mle(CL100(:,1)','distribution','LogNormal');
    CL100_mu=T100(1,1);
    CL100_sigma=T100(1,2);
    
    
    T90=mle(CL90(:,1)','distribution','LogNormal');
    CL90_mu=T90(1,1);
    CL90_sigma=T90(1,2);
    
    
    T70=mle(CL70(:,1)','distribution','LogNormal');
    CL70_mu=T70(1,1);
    CL70_sigma=T70(1,2);
    
    
    T50=mle(CL50(:,1)','distribution','LogNormal');
    CL50_mu=T50(1,1);
    CL50_sigma=T50(1,2);
    
    
    T30=mle(CL30(:,1)','distribution','LogNormal');
    CL30_mu=T30(1,1);
    CL30_sigma=T30(1,2);
    
    
    T0=mle(CL0(:,1)','distribution','LogNormal');
    CL0_mu=T0(1,1);
    CL0_sigma=T0(1,2);
    
    Parameters = [T0 ; T30; T50; T70; T90; T100];
    if Decision == "NG"  %it determines if we want to keep DS0 as a curve or not
        Parameters = [T30; T50; T70; T90; T100];
    end
    Median_Sa = exp(Parameters(:,1));
    
        
else
    DS1=Curves(:,1);
    DS1(isnan(DS1))=[];
    DS2=Curves(:,2);
    DS2(isnan(DS2))=[];
    DS3=Curves(:,3);
    DS3(isnan(DS3))=[];
    DS4=Curves(:,4);
    DS4(isnan(DS4))=[];
    
    DS1=mle(DS1(:,1)','distribution','LogNormal');
    DS1_mu=DS1(1,1);
    DS1_sigma=DS1(1,2);
    
    
    DS2=mle(DS2(:,1)','distribution','LogNormal');
    DS2_mu=DS2(1,1);
    DS2_sigma=DS2(1,2);
    
    
    DS3=mle(DS3(:,1)','distribution','LogNormal');
    DS3_mu=DS3(1,1);
    DS3_sigma=DS3(1,2);
    
    
    DS4=mle(DS4(:,1)','distribution','LogNormal');
    DS4_mu=DS4(1,1);
    DS4_sigma=DS4(1,2);
    
    Parameters = [DS1;DS2;DS3;DS4];
    Median_Sa = exp(Parameters(:,1));
end
end

