clear
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'
%% simulation conditions
config.simMins=10;
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
finishers={'S';'SH1';'SH2';'TS';'ST'};
config.priority='default';
config.enableSS=1;
config.useDivineProtection=1;
config.bossSwingDamage=350000;
% config.soimodel='fermi-1.55-0.15';
config.soimodel='nooverheal';
config.soiDirection='back';
config.wogDirection='back';
% disp(['-----------------Finisher is ' config.finisher '----------------------------'])
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
statSetup(i).t15_4pc=0;
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
statSetup(i).t15_4pc=0;
i=i+1;
%based on http://www.sacredduty.net/2013/04/09/stamina-keeping-you-up-longer/#comment-2903
statSetup(i).name='C/Set';
statSetup(i).buffedStr=15000+686*1.05;
statSetup(i).stamina=28000-579*1.25*1.05;
statSetup(i).parryRating=1500+923;
statSetup(i).dodgeRating=1500+114;
statSetup(i).masteryRating=1500+637;
statSetup(i).hitRating=2550+1115-1089;
statSetup(i).expRating=5100-1089+1089;
statSetup(i).hasteRating=12000-1212;
statSetup(i).armor=65000-261;
statSetup(i).t15_4pc=1;

%% crank
for k=1:length(finishers)
    
    gearsets=1:length(statSetup);
    
    for j=gearsets
        config.finisher=finishers{k};
        statblock(k,j)=pally_mc(config,statSetup(j));
    end
    
    
%% calculate stats
dmg=[statblock.dmg];
% 
% %moving averages
% ma5=filter(ones(1,5)./5,1,dmg);
% 
% %what do we want to know?
% MAmean=mean(ma5);
% MAstd=std(ma5);
% S=[statblock.S];
% 
% n=length(finishers);


end


%% save data
config.filetype='setbonus';
fbase=['.\pdata\pally_' config.filetype '_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
config.fileid=i;
fname=[fbase '_' int2str(i) '.mat'];
save(fname)
disp(['data saved to ' fname])

%% Table

li=pally_mc_table(statSetup,statblock(k,:),config,gearsets);

%% Gear sets

gl=DataTable();
gl{1,1+(1:length(gearsets))}={statSetup(gearsets).name};
gl{1:9,1}={'Set:';'Str';'Sta';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste'};
for j=1:length(gearsets)
    i=gearsets(j);
    gl{2:9,1+j}={statSetup(i).buffedStr;...
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