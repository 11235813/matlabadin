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
% config.soimodel='fermi-1.55-0.15';
config.soimodel='nooverheal';
config.soiDirection='back';
config.wogDirection='back';
disp(['-----------------Finisher is ' config.finisher '----------------------------'])
jMin=2;
jMax=7;
jStep=1;
config.jbounds=[jMin jStep jMax];

%% set up stat configs
dstat=2000;

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
statSetup(i)=statSetup(1);
statSetup(i).name=' Stam';
statSetup(i).stamina = statSetup(i).stamina + dstat;
i=i+1;
statSetup(i)=statSetup(1);
statSetup(i).name='Hit';
statSetup(i).hitRating = statSetup(i).hitRating - dstat;
i=i+1;
statSetup(i)=statSetup(1);
statSetup(i).name='Exp';
statSetup(i).expRating = statSetup(i).expRating - dstat;
i=i+1;
statSetup(i)=statSetup(1);
statSetup(i).name='Haste';
statSetup(i).hasteRating = statSetup(i).hasteRating + dstat;
i=i+1;
statSetup(i)=statSetup(1);
statSetup(i).name=' Mast';
statSetup(i).masteryRating = statSetup(i).masteryRating + dstat;
i=i+1;
statSetup(i)=statSetup(1);
statSetup(i).name='Dodge';
statSetup(i).dodgeRating = statSetup(i).dodgeRating + dstat;
i=i+1;
statSetup(i)=statSetup(1);
statSetup(i).name='Parry';
statSetup(i).parryRating = statSetup(i).parryRating + dstat;

%% crank
% if matlabpool('size')>0
%     matlabpool close
% end
gearsets=1:length(statSetup); %everything
% gearsets=[1 14 13 9]; %C/Ha, Ha/he, Ha/h, Ha
% gearsets=[1 3 5 6 7 8 10 11 12]; %C/Ha C/Sg C/Ma C/Av C/Bal C/HM Av Av/M M/Av
% gearsets=[1 2 3 4 5]; %C/Ha C/St C/Sg C/Shm C/Ma
% gearsets=[1 3 5 6 15 10]; %C/Ha C/Sg C/Ma C/Av C/Str Av];

% matlabpool(3)
for j=gearsets
% parfor j=1:i
    config.plotNum=j;
    statblock(j)=pally_mc(config,statSetup(j));
%     toc
end


    
% matlabpool close

%% calculate stats
dmg=[statblock(gearsets).dmg];

%moving averages
ma7=filter(ones(1,7),1,dmg);
ma6=filter(ones(1,6),1,dmg);
ma5=filter(ones(1,5),1,dmg);
ma4=filter(ones(1,4),1,dmg);
ma3=filter(ones(1,3),1,dmg);
ma2=filter(ones(1,2),1,dmg);

%what do we want to know?
MAmean=mean(ma5);
MAstd=std(ma5);
S=[statblock.S];
% ma=[statblock.maDTPS];

n=length(statSetup);

%% save data
config.filetype='metric';
fbase=['.\pdata\pally_' config.filetype '_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
config.fileid=i;
fname=[fbase '_' int2str(i) '.mat'];
save(fname,'-v7.3')
disp(['data saved to ' fname])
% save(['pally_sw_data_' int2str(simMins) '_' int2str(numSims) '_' int2str(statAmount) '.mat'])


%% Table

li=pally_mc_table(statSetup,statblock,config,gearsets);

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


%% Test new metric
ma=zeros([size(ma2,1) size(ma2,2) 7]);
ma(:,:,2)=ma2;ma(:,:,3)=ma3;ma(:,:,4)=ma4;ma(:,:,5)=ma5;ma(:,:,6)=ma6;ma(:,:,7)=ma7;
hsf=repmat([statblock.health],[size(ma,1) 1 size(ma,3)]);
ma=ma./hsf;

i=4;
N=200;
bins=linspace(0,199,N)/100+0.5*N/100/100;
baseline=hist(ma(:,1,i),bins);
stam=hist(ma(:,2,i),bins);
haste=hist(ma(:,3,i),bins);
mast=hist(ma(:,4,i),bins);
dodge=hist(ma(:,5,i),bins);
parry=hist(ma(:,6,i),bins);
totalevents=sum(baseline);

%find 25% of data cutoff
j=length(baseline);
accumulator=0;
while accumulator<0.1
   accumulator=accumulator+baseline(j)./totalevents;
   j=j-1;
end
cutoff=bins(j);
cutoffj=j;
% 
% figure(1)
% bar(bins',[baseline; stam]','stacked')
% legend('baseline','stam')
% 
% figure(2)
% bar(bins,stam-baseline)
% xlim([cutoff 1.1*max(ma(:,1,i))])