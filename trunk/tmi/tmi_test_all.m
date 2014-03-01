clear
fight_length=500; 

q=0;
for D=[10 20]
    
    q=q+1;
    % D=10;
    % b=10e3;
    m=500;
    c1=10*m/D
    c2=exp(D)
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
    
    
    figure(5)
    subplot(2,1,q)
    plot(ss.maxma,ss.tmie,rdc.maxma,rdc.tmie,'.',uf.maxma,uf.tmie,'MarkerSize',4)
    xlabel('max(MA)')
    ylabel('New TMI')
    legend('SS','RD','UF','Location','NorthWest')
    title(['exponential forms, D=' int2str(D)])
    minx=min([min(ss.maxma) min(rdc.maxma) min(uf.maxma)]);
    maxx=max([max(ss.maxma) max(rdc.maxma) max(uf.maxma)]);
    miny=min([min(ss.tmie) min(rdc.tmie) min(uf.tmie)]);
    maxy=max([max(ss.tmie) max(rdc.tmie) max(uf.tmie)]);
    xlim([minx maxx])
    ylim([miny maxy])
    
    %determine the spread of the data
    divisions=1000;
    xwid=(maxx-minx)/divisions;
    ywid=(maxy-miny)/divisions;
    for i=1:divisions 
        yspread=rdc.tmie(and(rdc.maxma>(minx+(i-1)*xwid),rdc.maxma<(minx+i*xwid)));
        if ~isempty(yspread)
            yrange(i)=max(yspread)-min(yspread); %#ok<*SAGROW>
        else
            yrange(i)=NaN;
        end
        xspread=rdc.maxma(and(rdc.tmie<i*ywid,rdc.tmie>(i-1)*ywid));
        if ~isempty(xspread)
            xrange(i)=max(xspread)-min(xspread);
        else
            xrange(i)=NaN;
        end
    end
    figure(6)
    subplot(4,1,2*q-1)
    plot(minx+[1:divisions]*xwid-xwid/2,yrange);
    xlim([minx maxx])
    xlabel('max(MA)')
    ylabel('Y TMI Spread')
    subplot(4,1,2*q)
    plot([1:divisions]*xwid-xwid/2,xrange);
    xlim([minx maxx])
    ylim([min(xrange) max(xrange)])
    xlabel('max(MA)')
    ylabel('X TMI Spread')
    
end
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