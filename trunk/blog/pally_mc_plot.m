function pally_mc_plot(config,statblock,sF)
%% unpack
temp=fields(statblock);
for i=1:length(temp)
   eval([char(temp(i)) '=statblock.' char(temp(i)) ';']);
end

if ~isfield(config,'plotNum')
    plotNum=1;
    warning(['plot number defaulting to ' int2str(plotNum)])
else
    plotNum=config.plotNum;
end
if nargin<3
    sF=5;
end

%% calculate
maDTPS=filter(ones(1,sF)./sF,1,dmg);
mean_ma=mean(maDTPS);
std_ma=std(maDTPS);

%% plot
%plot #1, hit size distribution
if config.plotFlag~='2only'
    figure(1+2.*(plotNum-1))
    [yout xout]=hist(100.*dmg,100.*[0:0.05:1]);
    xout=round(xout);
    if max(yout)>1e3
        sf=1e3;
        ylstr='Number of events (in thousands)';
    else
        sf=1;
        ylstr='Number of events';
    end
    youtn=yout./sf;
    bar(xout,youtn);
    xlim([-10 110])
    ylim([0 1.25.*max(youtn)])
    xlabel('Hit size (in % of full hit)')
    ylabel(ylstr)
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsotr=' num2str(Tsotr,'%2.1f') ', DR_{SotR}=' num2str(100.*(1-DRmod),'%2.1f') '%, DTPS=' num2str(DTPS.*100,'%2.2f')])
    
    %labeling
    offset=diff(get(gca,'YLim'))./20;
    
    text(-7,youtn(xout==0)+offset,[num2str(avoidsPct.*100,'%2.1f') '% avoids'])
    
    text(100*0.7*DRmod-5,youtn(xout==100*round(0.7*DRmod*20)/20)+2.*offset,[num2str(bMitsPct.*100,'%2.1f') '%'])
    text(100*0.7*DRmod-15,youtn(xout==100*round(0.7*DRmod*20)/20)+offset,'mitigated blocks')
    
    text(100.*DRmod-7,youtn(xout==100*round(20*DRmod)/20)+2.*offset,[num2str(hMitsPct.*100,'%2.1f') '%'])
    text(100.*DRmod-12,youtn(xout==100*round(20*DRmod)/20)+offset,'mitigated hits')
    
    text(70-5,youtn(xout==70)+2.*offset,[num2str((blocksPct-bMitsPct).*100,'%2.1f') '%'])
    text(70-15,youtn(xout==70)+offset,'unmitigated blocks')
    
    text(100-5,youtn(xout==100)+2.*offset,[num2str(unmitsPct.*100,'%2.1f') '%'])
    text(100-18,youtn(xout==100)+offset,'unmitigated hits')
end

%plot #2, histogram of DTPS distribution
if config.plotFlag~='1only'
    figure(2+2.*(plotNum-1))
    [yout2 xout2]=hist(maDTPS,50);
    yout2n=yout2.*100./length(maDTPS);
    bar(xout2,yout2n);
    xlim([0 1])
    xlabel([ int2str(sF) '-attack moving average DTPS'])
    ylabel('Percentage of events')
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsotr=' num2str(Tsotr,'%2.1f') ', DR_{SotR}=' num2str(100.*(1-DRmod),'%2.1f') '%, DTPS=' num2str(DTPS.*100,'%2.2f')])
    temp=get(gca,'YLim');mval=temp(2);
    text(0.1,0.8*mval,['mean = ' num2str(mean_ma,'%1.4f')]);
    text(0.1,0.73*mval,['std  = ' num2str(std_ma,'%1.4f')]);
    ylim([0 12])
    pause(0.1)
end
end