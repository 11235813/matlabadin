clear
fight_length=450; 

%old
%m=500
%c1=10*m/D
%c2=exp(D)

%new tests, assume D=10
C1=[500 1000 1000 5000 10000 10000];
C2=[exp(10) exp(10) 450*exp(10) 450*exp(10) 450*exp(10) 450*exp(10)];

for q=1:length(C1)
    
    D=10;
    
    % D=10;
    % b=10e3;
%     m=M(kk);
    c1=C1(q);
    c2=C2(q);
    % c2=fight_length/100*exp(D)
    c210=0;
    
    
    tmi_normalization_test_random
    rdc=rd;
    for j=1:24;
        tmi_normalization_test_random
        rdc.maxma=[rdc.maxma; rd.maxma];
        rdc.tmie=[rdc.tmie;rd.tmie];
        rdc.tmie2=[rdc.tmie2;rd.tmie2];
        rdc.meanma=[rdc.meanma;rd.meanma];
    end
    tmi_normalization_test_single_spike
    tmi_normalization_test_uniform
    
    
    figure(1)
    subplot(ceil(length(C1))/2,2,q)
    plot(ss.maxma,ss.tmie,rdc.maxma,rdc.tmie,'.',uf.maxma,uf.tmie,'MarkerSize',4)
    xlabel('max(MA)')
    ylabel('New TMI')
    legend('SS','RD','UF','Location','NorthWest')
    title(['exponential forms, D=' int2str(D) ', c1=' num2str(c1,'%5.1f') ', c2=' num2str(c2,'%1.5e')])
    minx=min([min(ss.maxma) min(rdc.maxma) min(uf.maxma)]);
    maxx=max([max(ss.maxma) max(rdc.maxma) max(uf.maxma)]);
    miny=min([min(ss.tmie) min(rdc.tmie) min(uf.tmie)]);
    maxy=max([max(ss.tmie) max(rdc.tmie) max(uf.tmie)]);
    xlim([minx maxx])
    ylim([miny maxy])
    
    figure(2)
    subplot(ceil(length(C1))/2,2,q)
    plot(ss.maxma,ss.tmie2,rdc.maxma,rdc.tmie2,'.',uf.maxma,uf.tmie2,rdc.maxma,zeros(size(rdc.maxma)),'k-','MarkerSize',4)
    xlabel('max(MA)')
    ylabel('New TMI')
    legend('SS','RD','UF','Location','NorthWest')
    title(['exponential forms, D=' int2str(D) ', c1=' num2str(c1,'%5.1f') ', c2=' num2str(c2,'%1.5e')])
    miny=min([min(ss.tmie2) min(rdc.tmie2) min(uf.tmie2)]);
    maxy=max([max(ss.tmie2) max(rdc.tmie2) max(uf.tmie2)]);
    xlim([minx maxx])
    ylim([miny maxy])
    
    x4(:,q)=ss.maxma;
    y4(:,q)=ss.tmie;
    z4(:,q)=ss.tmie2;
    L4{q}=['D=' int2str(D) ', c1=' num2str(c1,'%5.1f') ', c2=e^{' num2str(log(c2),'%2.1f') '}'];
    
end

%% Plot
figure(3)
plot(ss.tmie2./1e3,ss.maxma,rdc.tmie2./1e3,rdc.maxma,'.',uf.tmie2./1e3,uf.maxma,'MarkerSize',4)
ylabel('max(MA)')
xlabel('New TMI (k)')
legend('SS','RD','UF','Location','NorthWest')

figure(6)
plot(x4,y4./1e3)
xlabel('max(MA)')
ylabel('New TMI (k)')
legend(L4,'Location','NorthWest');

figure(7)
plot(x4,z4./1e3)
xlabel('max(MA)')
ylabel('New TMI (k)')
legend(L4,'Location','NorthWest');


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