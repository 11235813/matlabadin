clear
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'
%% simulation conditions
config.simMins=10000;
config.plotFlag='2only';
config.tocFlag='toc';
config.stat=' ';
config.val=0;
config.plotnum=1;
config.sF=5;
config.bossSwingTimer=1.5;
config.WoGfakeBubbleDuration=3;
config.WoGoverheal=0.5;
config.t152pcEquipped=1;
finishers={'S','SH1','SH2','T','TS','ST'};
config.enableSS=0;
jMin=2;
jMax=7;
jStep=1;

%% set up stat configs
i=1;
statSetup(i).name='C/Ha';
statSetup(i).buffedStr=15000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=12000;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='C/Ma';
statSetup(i).buffedStr=15000;
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
statSetup(i).parryRating=4125;
statSetup(i).dodgeRating=4125;
statSetup(i).masteryRating=4125;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=4125;
statSetup(i).armor=65000;
i=i+1;
statSetup(i).name='Ha';
statSetup(i).buffedStr=15000;
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
statSetup(i).parryRating=4000;
statSetup(i).dodgeRating=4000;
statSetup(i).masteryRating=15150;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=65000;


%% Calculate each of these for 3 different valuesof WoG overheal
for i=[1 0.5 0]

    config.WoGoverheal=i;
%% Finisher testing w/ C/Ha gear set

for j=1:length(finishers)
    tic
    config.plotNum=j;
    config.finisher=finishers{j};
    statblock(j)=pally_mc(config,statSetup(2));
    toc
end
   
% %parallel version
% matlabpool close
% matlabpool(3)
% % for j=1:length(finishers)
% tic
% parfor j=1:length(finishers)
%     config.plotFlag='noplot';
%     config.finisher=finishers{j};
%     statblock(j)=pally_mc(config,statSetup(1));
%     toc
% end
% toc
% matlabpool close

%% calculate stats
dmg=[statblock.dmg];

%moving averages
ma5=filter(ones(1,5)./5,1,dmg);

%what do we want to know?
MAmean=mean(ma5);
MAstd=std(ma5);
S=[statblock.S];
ma=[statblock.maDTPS];

n=length(finishers);


%% Save data
fbase=['.\pdata\pally_setbonus_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
fname=[fbase '_' int2str(i) '.mat'];
save(fname)
disp(['data saved to ' fname])

%% Table
%Mean & std spike damage intake
%events above 80 and 90%
li=DataTable();
li{1:4,1}={'Queue:';'S%';'mean';'std'};
li{1,1+(1:n)}=finishers;
li{2,1+(1:n)}=S;
matemp=filter(ones(1,5)./5,1,dmg);
li{3,1+(1:n)}=mean(matemp);
li{4,1+(1:n)}=std(matemp);
linePH=0;
for j=jMin:jStep:jMax
    matemp=filter(ones(1,j)./j,1,dmg);
    li{5+linePH,1:(n+1)}=cat(2,{'------',['--- ' int2str(j)],'Attack','Moving','Average'},repmat({'------'},1,n-4));
    linePH=linePH+1;
    li{5+linePH,1}='60%';
    li{5+linePH,1+(1:n)}=sum(matemp>0.6)./size(matemp,1).*100;
    linePH=linePH+1;
    li{5+linePH,1}='70%';
    li{5+linePH,1+(1:n)}=sum(matemp>0.7)./size(matemp,1).*100;
    linePH=linePH+1;
    li{5+linePH,1}='80%';
    li{5+linePH,1+(1:n)}=sum(matemp>0.8)./size(matemp,1).*100;
    linePH=linePH+1;
    li{5+linePH,1}='90%';
    li{5+linePH,1+(1:n)}=sum(matemp>0.9)./size(matemp,1).*100;
    linePH=linePH+1;
end
li.setColumnFormat(1+(1:n),'%1.4f')
disp('<pre>')
disp(['WoG overheal factor: ' int2str(config.WoGoverheal.*100) '%'])
li.toText()
disp('</pre>')


end
%% Gear sets
m=length(statSetup);

gl=DataTable();
gl{1,1+(1:m)}={statSetup.name};
gl{1:9,1}={'Set:';'Str';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste';'Armor'};

for i=1:length(statSetup)
    gl{2:9,1+i}={statSetup(i).buffedStr;...
        statSetup(i).parryRating;...
        statSetup(i).dodgeRating;...
        statSetup(i).masteryRating;...
        statSetup(i).hitRating;...
        statSetup(i).expRating;...
        statSetup(i).hasteRating;...
        statSetup(i).armor};
end
disp('<pre>')
gl.toText()
disp('</pre>')