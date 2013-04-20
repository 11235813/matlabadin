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
config.soimodel='fermi';

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

%% analyze
Scomp=mean([[sb1.S];[sb2.S]],2)
meanComp=mean([[sb1.mean_ma];[sb2.mean_ma]],2)
meanAvoidPct=mean([[sb1.avoidsPct];[sb2.avoidsPct]],2)
meanHits=mean([[sb1.hits];[sb2.hits]],2)
meanHitsPct=mean([[sb1.hitsPct];[sb2.hitsPct]],2)