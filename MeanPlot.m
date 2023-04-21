function [Hor,Vert] = MeanPlot(Initial_DS_Realz,Rest,Connectivity,initial)

First_2=mean(Initial_DS_Realz);


if First_2==0
    index_2=1;
elseif First_2>0 && First_2<=10
    index_2=2;
elseif First_2>10 && First_2<=20
    index_2=3;
elseif First_2>20 && First_2<=30
    index_2=4;
elseif First_2>30 && First_2<=40
    index_2=5;
elseif First_2>40 && First_2<=50
    index_2=6;
elseif First_2>50 && First_2<=60
    index_2=7;
elseif First_2>60 && First_2<=70
    index_2=8;
elseif First_2>70 && First_2<=80
    index_2=9;
elseif First_2>80 && First_2<=90
    index_2=10;
elseif First_2>90 && First_2<=100
    index_2=11;
end


Vert=cat(2,First_2,(First_2+Connectivity(index_2))/2,Connectivity(index_2:length(Connectivity)));
Rest=Rest(:,index_2:length(Connectivity));
Hor1=mean(Rest,1);
Hor=cat(2,initial,Hor1);

end

