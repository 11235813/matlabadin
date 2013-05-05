%% simulation conditions
config.simMins=1000;
config.plotFlag='noplot';
config.tocFlag='toc';
config.stat=' ';
config.val=0;
config.plotnum=1;
config.sF=5;
config.bossSwingTimer=1.5;
config.WoGfakeBubbleDuration=0;
config.WoGoverheal=1;
config.t152pcEquipped=0;
config.useDivineProtection=0;
config.finisher='S';
config.enableSS=0;
config.priority='default';
config.bossSwingDamage=200000;
config.t154pcEquipped=0;
config.soimodel='fermi-1.5-0.15';
config.soimodel='nooverheal-1.5-0.15';
config.soiDuration='back';

tstart=tic;
for i=1:10
    
    sb1(i)=pally_mc(config);
    
end
T1=toc(tstart)


tstart2=tic;
for i=1:10
    
    sb2(i)=pally_mc_old(config);
    
end
T2=toc(tstart2)


tstart3=tic;
config3=config;config3.soiDirection='back';
for i=1:10
    
    sb3(i)=pally_mc_back(config3);
    
end
T3=toc(tstart3)

%% analyze
Scomp=mean([[sb1.S];[sb2.S];[sb3.S]],2)
meanComp=mean([[sb1.mean_ma];[sb2.mean_ma];[sb3.mean_ma]],2)
meanAvoidPct=mean([[sb1.avoidsPct];[sb2.avoidsPct];[sb3.avoidsPct]],2)
meanHits=mean([[sb1.hits];[sb2.hits];[sb3.hits]],2)
meanHitsPct=mean([[sb1.hitsPct];[sb2.hitsPct];[sb3.hitsPct]],2)