clear
fight_length=500; 

q=0;
for fight_length=[300 400 500 600 700];
    
    q=q+1;
    D=10;
    % b=10e3;
    m=500;
    c1=10*m/D;
    c2=exp(D);
    % c2=fight_length/100*exp(D)
    c210=10.^D;
    
    
    tmi_normalization_test_random
    rdc=rd;
    for j=1:24;
        tmi_normalization_test_random
        rdc.maxma=[rdc.maxma; rd.maxma];
        rdc.tmie=[rdc.tmie;rd.tmie];
        rdc.tmi10=[rdc.tmi10;rd.tmi10];
        rdc.meanma=[rdc.meanma;rd.meanma];
    end
    tmi_normalization_test_single_spike
    tmi_normalization_test_uniform
    
    uni.maxma(:,q)=uf.maxma;
    uni.tmie(:,q)=uf.tmie;
    
    ssp.maxma(:,q)=ss.maxma;
    ssp.tmie(:,q)=ss.tmie;
    
    ran.maxma(:,q)=rdc.maxma;
    ran.tmie(:,q)=rdc.tmie;
    
end

%% plot
figure(6)
subplot 211
    plot(ssp.maxma,ssp.tmie,'b',uni.maxma,uni.tmie,'r')
    xlabel('max(MA)')
    ylabel('New TMI')
    title(['exponential forms, D=' int2str(D)])
    minx=min([min(ss.maxma) min(rdc.maxma) min(uf.maxma)]);
    maxx=max([max(ss.maxma) max(rdc.maxma) max(uf.maxma)]);
    miny=min([min(ss.tmie) min(rdc.tmie) min(uf.tmie)]);
    maxy=max([max(ss.tmie) max(rdc.tmie) max(uf.tmie)]);
    xlim([minx maxx])
    ylim([miny maxy])
    
subplot 212
    plot(ssp.maxma,ssp.tmie,'b',uni.maxma,uni.tmie,'r',ran.maxma,ran.tmie,'.','MarkerSize',4)
    xlabel('max(MA)')
    ylabel('New TMI')
    title(['exponential forms, D=' int2str(D)])
    minx=min([min(ss.maxma) min(rdc.maxma) min(uf.maxma)]);
    maxx=max([max(ss.maxma) max(rdc.maxma) max(uf.maxma)]);
    miny=min([min(ss.tmie) min(rdc.tmie) min(uf.tmie)]);
    maxy=max([max(ss.tmie) max(rdc.tmie) max(uf.tmie)]);
    xlim([minx maxx])
    ylim([miny maxy])
    
    
%% plots
% figure(5)
% subplot 211
% plot(ss.maxma,ss.tmie,rdc.maxma,rdc.tmie,'.',uf.maxma,uf.tmie)
% xlabel('max(MA)')
% ylabel('New TMI')
% legend('SS','RD','UF','Location','NorthWest')
% title(['exponential forms, D=' int2str(D)])
% minx=min([min(ss.maxma) min(rdc.maxma) min(uf.maxma)]);
% maxx=max([max(ss.maxma) max(rdc.maxma) max(uf.maxma)]);
% miny=min([min(ss.tmie) min(rdc.tmie) min(uf.tmie)]);
% maxy=max([max(ss.tmie) max(rdc.tmie) max(uf.tmie)]);
% xlim([minx maxx])
% ylim([miny maxy])
% 
% 
% subplot 212
% plot(ss.maxma,ss.tmi10,rdc.maxma,rdc.tmi10,'.',uf.maxma,uf.tmi10)
% xlabel('max(MA)')
% ylabel('New TMI')
% legend('SS','RD','UF','Location','NorthWest')
% title(['base-10 forms, D=' int2str(D)])
% xlim([0 max(ss.maxma)])