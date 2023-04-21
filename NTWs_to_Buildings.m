function [step,init_Any,init_Full] = NTWs_to_Buildings(figure_key,nMCS,Conn,Rest,P_Lack_MEAN,WEIGHT,STD_P,STD_W,NTW,year)

dim=size(Rest);
hazard=strcat(num2str(year),' year');

PGA_No=dim(2);

for i=1:PGA_No
    C=Conn(:,i)/100;
    if NTW~="TS"
        C(C==0)=[];
    end
    CL = 1-C;
    CL=CL';
    dims=size(CL);
    for k=1:dims(1,2)
        for j=1:nMCS
            P_lack_mean=lognrnd(P_Lack_MEAN,STD_P);
            P_lack_mean(P_lack_mean>1)=1;
            for n=1:nMCS
                Weights=lognrnd(WEIGHT,STD_W);
                [P_no_srv(j,n,k,i),P_LQ(j,n,k,i)]=P_Buildings(CL(k),P_lack_mean,Weights);
                
                number(n,k)=n;
            end
            PNoSrv_L1(j,k,i)=sum(P_no_srv(j,1:n,k,i))/n;
            PLQ_L1(j,k,i)= sum(P_LQ(j,1:n,k,i))/n;
            if k==1
                init_Any(j,i) =100-100*PNoSrv_L1(j,k,i);
                init_Full(j,i)=100-100*PNoSrv_L1(j,k,i)-100*PLQ_L1(j,k,i);
            end
        end
        P_noSrv_L2(k,i)=sum(PNoSrv_L1(1:j,k,i))/j;
        P_LQ_L2(k,i)=sum(PLQ_L1(1:j,k,i))/j;
        if 100-P_noSrv_L2(k,i)*100 > 99
            step(k,i) = k;
        end
    end
    init_Any(init_Any<0)=0;
    init_Full(init_Full<0) = 0;
    P_noSrv_L2(2,i)=(P_noSrv_L2(1,i)+P_noSrv_L2(3,i))/2;
    P_LQ_L2(2,i) =(P_LQ_L2(1,i)+P_LQ_L2(3,i))/2;
    if figure_key == 1
        figure(4)
        set(gcf,'units','inches','position',[0.01   0.05   3.5   2.5],'PaperPositionMode','auto');  %Suitable for copying to word document (120% - 125%)
        set(gca,'Fontname','Arial','Fontsize',10,'FontWeight','normal');
        file_name1 = 'Results/%s_Full_service_restoration_%s.mat';
        %Full = 100-P_noSrv_L2(:,i)*100-P_LQ_L2(:,i)*100;
        %         save(sprintf(file_name1,NTW,hazard),'Full')
        %         file_name2 = 'Results/%s_Restoration_time_%s.mat';
        Rest = Rest(1:k,i);
        %Full_data = [Full Rest];
        %save(sprintf(file_name1,NTW,hazard),'Full_data')
        plot(Rest(1:k,i),100-P_noSrv_L2(:,i)*100-P_LQ_L2(:,i)*100,'-.','DisplayName',strcat(hazard,' Full service'),'MarkerSize',5,'LineWidth',0.75)
        ylabel('Probability of service restoration','FontWeight','bold','Fontname','Arial','Fontsize',9)
        xlabel({'Restoration time (days)'},'FontWeight','bold','Fontname','Arial','Fontsize',9)
        %xlim([0,80])
        ylim([0,100])
        box on; grid on;
        hold on
        file_name3 = 'Results/%s_Any_service_restoration_%s.mat';
        Any  = 100-P_noSrv_L2(:,i)*100;
        %save(sprintf(file_name3,NTW,hazard),'Any')
        plot(Rest(1:k,i),100-P_noSrv_L2(:,i)*100,'-','DisplayName',strcat(hazard,' Any service'),'MarkerSize',5,'LineWidth',0.75)
        hold on
        legend('location','southeast')
        %title({NTW;"Restoration Curve:% Buildings Restored"},'Fontname','Arial','Fontsize',9,'FontWeight','bold')
        set(legend,'Fontname','Arial','Fontsize',6,'FontWeight','normal');
        %xticks(0:10:80);
    end
end


Noservbig=P_no_srv;
lqbig=P_LQ;
end

