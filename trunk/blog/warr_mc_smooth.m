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
config.bossSwing=1.5;
config.finisher='SBrWeave';
jMin=2;
jMax=7;
jStep=1;

startCond.rage=0;
startCond.stepspersecond=2;
startCond.prio='steadystate';
% startCond.finisher='SBrBleed';

%% set up stat configs
i=1;
statSetup(i).name='C/Ma';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=2000;
statSetup(i).dodgeRating=2000;
statSetup(i).masteryRating=5500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).name='C/Av';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=4000;
statSetup(i).dodgeRating=4000;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).name='C/Bal';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=3167;
statSetup(i).dodgeRating=3167;
statSetup(i).masteryRating=3166;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).name='C/Bal-NC';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=3167;
statSetup(i).dodgeRating=3167;
statSetup(i).masteryRating=3366;
statSetup(i).hitRating=2450;
statSetup(i).expRating=5000;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).name='Avoid';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=7325;
statSetup(i).dodgeRating=7325;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).name='Av/Mas';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=6000;
statSetup(i).dodgeRating=6000;
statSetup(i).masteryRating=4150;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).name='Mas/Av';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=4000;
statSetup(i).dodgeRating=4000;
statSetup(i).masteryRating=8150;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;

for j=1:i
    tic
    config.plotNum=j;
    statblock(j)=warr_mc(config,statSetup,startCond);
    toc
end


    
% matlabpool close
fbase=['warr_smooth_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
fname=[fbase '_' int2str(i) '.mat'];
save(fname)
disp(['data saved to ' fname])


%% calculate stats
dmg=[statblock.dmg];

%moving averages
ma5=filter(ones(1,5)./5,1,dmg);

%what do we want to know?
MAmean=mean(ma5);
MAstd=std(ma5);
S=[statblock.S];
ma=[statblock.maDTPS];

n=length(statSetup);

%% Table

%Mean & std spike damage intake
%events above 80 and 90%
li=DataTable();
li{1:4,1}={'Set:';'S%';'mean';'std'};
li{1,1+(1:n)}={statSetup.name};
li{2,1+(1:n)}=S;
matemp=filter(ones(1,5)./5,1,dmg);
li{3,1+(1:n)}=mean(matemp);
li{4,1+(1:n)}=std(matemp);
linePH=0;
for j=jMin:jStep:jMax
    matemp=filter(ones(1,j)./j,1,dmg);
    li{5+linePH,1:9}={'------','------',['--- ' int2str(j)],'Attack','Moving','Average','------','------','------'};
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
li.toText()
disp('</pre>')

%% Gear sets
gl=DataTable();
gl{1,1+(1:n)}={statSetup.name};
gl{1:8,1}={'Set:';'Str';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste'};

for i=1:length(statSetup)
    gl{2:8,1+i}={statSetup(i).buffedStr;...
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