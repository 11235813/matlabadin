function warr_mc_plot(config,statblock,sF)
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
if ~strcmp(config.plotFlag,'2only')
    
    figure(1+2.*(plotNum-1))
    [yout xout]=hist(100.*dmg,100.*[0:0.05:1]);
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
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsb=' num2str(Tsb,'%2.1f') 's, R_{rage}=' num2str(Rrage,'%2.3f') '/s, DTPS=' num2str(DTPS.*bossSwingTimer.*100,'%2.2f') '%, Fin=' config.finisher])
    
    
    %labeling
    offset=diff(get(gca,'YLim'))./40;
    
    text(-7,youtn(xout==0)+3.*offset,[num2str(avoidsPct.*100,'%2.1f') '% avoids'])
    text(-7,youtn(xout==0)+offset,[num2str(allFullAbsorbsPct.*100,'%2.2f') '% full Absorbs'])
    
    text(100.*critBlockDmg-10,youtn(xout==40)+5*offset,[num2str(critblocksPct.*100,'%2.1f') '% crit blocks'])
    text(100.*critBlockDmg-10,youtn(xout==40)+3.*offset,[num2str(cbPartialAbsorbsPct.*100,'%2.2f') '% partially absorbed'])
    text(100.*critBlockDmg-10,youtn(xout==40)+offset,[num2str(cbFullAbsorbsPct.*100,'%2.2f') '% fuly absorbed'])
    
    text(100.*blockDmg-15,youtn(xout==70)+5*offset,[num2str(blocksPct.*100,'%2.1f') '% blocked'])
    text(100.*blockDmg-15,youtn(xout==70)+3.*offset,[num2str(bPartialAbsorbsPct.*100,'%2.2f') '% partially absorbed'])
    text(100.*blockDmg-15,youtn(xout==70)+offset,[num2str(bFullAbsorbsPct.*100,'%2.2f') '% fully absorbed'])
    
    text(100-20,youtn(xout==100)+5*offset,[num2str(hitsPct.*100,'%2.1f') '% full hits'])
    text(100-20,youtn(xout==100)+3.*offset,[num2str(hPartialAbsorbsPct.*100,'%2.2f') '% partially absorbed'])
    text(100-20,youtn(xout==100)+offset,[num2str(hFullAbsorbsPct.*100,'%2.2f') '% fully absorbed'])
end

%plot #2, histogram of DTPS distribution
if ~strcmp(config.plotFlag,'1only')
    
    figure(2+2.*(plotNum-1))
    [yout2 xout2]=hist(maDTPS,50);
    yout2n=yout2.*100./length(maDTPS);
    bar(xout2,yout2n);
    xlabel([ int2str(sF) '-attack moving average DTPS'])
    ylabel('Percentage of events')
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsb=' num2str(Tsb,'%2.1f') 's, R_{rage}=' num2str(Rrage,'%2.3f') '/s, DTPS=' num2str(DTPS.*bossSwingTimer.*100,'%2.2f') '%, Fin=' config.finisher])
    temp=get(gca,'YLim');mval=temp(2);
    text(0.1,0.8*mval,['mean = ' num2str(mean_ma,'%1.4f')]);
    text(0.123,0.73*mval,['std  = ' num2str(std_ma,'%1.4f')]);
end

pause(0.1)

end