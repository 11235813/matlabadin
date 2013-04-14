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
config.finisher='S';
config.enableSS=0;
config.priority='default';

tstart=tic;
for i=1:10
    
    sb1(i)=pally_mc(config);
    
end
T1=toc(tstart)

config2=config;
config2.bossSwingTimer=1500;

tstart2=tic;
for i=1:10
    
    sb2(i)=pally_mc_2(config2);
    
end
T2=toc(tstart2)

%% analyze