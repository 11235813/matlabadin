clear
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'
%% simulation conditions
config.simMins=10000;
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
config.finisher='SH1';
config.priority='default';
config.enableSS=1;
config.t154pcEquipped=0;
config.useDivineProtection=0;
config.bossSwingDamage=350000;
config.soimodel='fermi-1.55-0.15';
disp(['-----------------Finisher is ' config.finisher '----------------------------'])
jMin=2;
jMax=7;
jStep=1;
config.jbounds=[jMin jStep jMax];

%% set up stat configs
i=1;
statSetup(i).name='C/Ha';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=12000;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/St';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=34000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=8000;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/Sg';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=31000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=8000;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/Shm';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=31000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=4750;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=4750;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/Ma';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=13500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/Av';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=7500;
statSetup(i).dodgeRating=7500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/Bal';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=4125;
statSetup(i).dodgeRating=4125;
statSetup(i).masteryRating=4125;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=4125;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/HM';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=6750;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=6750;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Ha';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=18650;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Avoid';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=10825;
statSetup(i).dodgeRating=10825;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Av/Mas';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=7717;
statSetup(i).dodgeRating=7717;
statSetup(i).masteryRating=7716;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Mas/Av';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=4000;
statSetup(i).dodgeRating=4000;
statSetup(i).masteryRating=15150;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Ha/h';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=500;
statSetup(i).hasteRating=16600;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Ha/he';
statSetup(i).buffedStr=15000;
statSetup(i).stamina=28000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=2550;
statSetup(i).hasteRating=14550;
statSetup(i).armor=65000;

%% crank
% if matlabpool('size')>0
%     matlabpool close
% end
% gearsets=1:length(statSetup); %everything
gearsets=[1 14 13 9]; %C/Ha, Ha/he, Ha/h, Ha
% gearsets=[1 3 5 6 7 8 10 11 12]; %C/Ha C/Sg C/Ma C/Av C/Bal C/HM Av Av/M M/Av
% gearsets=[1 2 3 4 5]; %C/Ha C/St C/Sg C/Shm C/Ma

% matlabpool(3)
for j=gearsets
% parfor j=1:i
    config.plotNum=j;
    statblock(j)=pally_mc(config,statSetup(j));
%     toc
end


    
% matlabpool close

%% calculate stats
dmg=[statblock.dmg];

%moving averages
ma7=filter(ones(1,7)./7,1,dmg);
ma6=filter(ones(1,6)./6,1,dmg);
ma5=filter(ones(1,5)./5,1,dmg);
ma4=filter(ones(1,4)./4,1,dmg);
ma3=filter(ones(1,3)./3,1,dmg);
ma2=filter(ones(1,2)./2,1,dmg);

%what do we want to know?
MAmean=mean(ma5);
MAstd=std(ma5);
S=[statblock.S];
ma=[statblock.maDTPS];

n=length(statSetup);

%% save data
fbase=['.\pdata\pally_smooth_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
config.fileid=i;
config.filetype='smooth';
fname=[fbase '_' int2str(i) '.mat'];
save(fname)
disp(['data saved to ' fname])
% save(['pally_sw_data_' int2str(simMins) '_' int2str(numSims) '_' int2str(statAmount) '.mat'])


%% Table

li=pally_mc_table(statSetup,statblock,config,gearsets);

%% Gear sets

gl=DataTable();
gl{1,1+(1:n)}={statSetup.name};
gl{1:9,1}={'Set:';'Str';'Sta';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste'};
for i=1:length(statSetup)
    gl{2:9,1+i}={statSetup(i).buffedStr;...
        statSetup(i).stamina;...
        statSetup(i).parryRating;...
        statSetup(i).dodgeRating;...
        statSetup(i).masteryRating;...
        statSetup(i).hitRating;...
        statSetup(i).expRating;...
        statSetup(i).hasteRating};
end
disp('<pre>')
gl.toText()
disp('</pre>')