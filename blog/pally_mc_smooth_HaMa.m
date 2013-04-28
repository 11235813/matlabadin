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
config.WoGfakeBubbleDuration=0;
config.WoGoverheal=1;
config.t152pcEquipped=0;
jMin=2;
jMax=7;
jStep=1;

%% set up stat configs
i=1;
statSetup(i).name='H12M1';
statSetup(i).buffedStr=15000;
statSetup(i).parryRating=1500;
statSetup(i).dodgeRating=1500;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=12000;
statSetup(i).armor=65000;
for i=2:13
    statSetup(i)=statSetup(i-1);
    statSetup(i).hasteRating=statSetup(i).hasteRating-1000;
    statSetup(i).masteryRating=statSetup(i).masteryRating+1000;
    statSetup(i).name=['H' int2str(13-i) 'M' int2str(i)];
end



%% crank
% if matlabpool('size')>0
%     matlabpool close
% end

% matlabpool(3)
for j=1:i
% parfor j=1:i
    config.plotNum=j;
    statblock(j)=pally_mc(config,statSetup(j));
%     toc
end


    
% matlabpool close

%% save data
fbase=['.\pdata\pally_smooth_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
fname=[fbase '_' int2str(i) '.mat'];
save(fname)
disp(['data saved to ' fname])
% save(['pally_sw_data_' int2str(simMins) '_' int2str(numSims) '_' int2str(statAmount) '.mat'])

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
    li{5+linePH,1:9}={'----','------',['--- ' int2str(j)],'Attack','Moving','Average','------','------','------'};
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
li.toText()
disp('</pre>')

gl=DataTable();
gl{1,1+(1:n)}={statSetup.name};
gl{1:8,1}={'Set:';'Str';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste'};
%% Gear sets
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