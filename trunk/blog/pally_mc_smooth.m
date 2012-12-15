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
config.bossSwing=0.25;


%% set up stat configs
i=1;
statSetup(i).name='C/Ha';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=2000;
statSetup(i).dodgeRating=2000;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=4000;
i=i+1;
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
statSetup(i).parryRating=2375;
statSetup(i).dodgeRating=2375;
statSetup(i).masteryRating=2375;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=2375;
i=i+1;
statSetup(i).name='C/Bal-NC';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=2375;
statSetup(i).dodgeRating=2375;
statSetup(i).masteryRating=2575;
statSetup(i).hitRating=2450;
statSetup(i).expRating=5000;
statSetup(i).hasteRating=2375;
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
fbase=['pally_smooth_data_' int2str(config.simMins)];
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

%Mean & std spike damage intake
%events above 80 and 90%
for j=15:5:30
   disp([int2str(j) ' Attack Moving Average'])
   li=DataTable(); 
   li{1:6,1}={'Set:';'S%';'mean';'std';'80%';'90%'};
   li{1,1+(1:n)}={statSetup.name};
   li{2,1+(1:n)}=S;
   matemp=filter(ones(1,j)./j,1,dmg);
%    li{3,1+(1:n)}=eval(char(['mean(ma' int2str(j) ');']));
   li{3,1+(1:n)}=mean(matemp);
%    li{4,1+(1:n)}=eval(char(['std(ma' int2str(j) ');']));
   li{4,1+(1:n)}=std(matemp);
%    li{5,1+(1:n)}=eval(char(['sum(ma' int2str(j) '>0.8)./length(ma5).*100;']));
   li{5,1+(1:n)}=sum(matemp>0.8)./size(matemp,1).*100;
%    li{6,1+(1:n)}=eval(char(['sum(ma' int2str(j) '>0.9)./length(ma5).*100;']));
   li{6,1+(1:n)}=sum(matemp>0.9)./size(matemp,1).*100;
   li.setColumnFormat(1+(1:n),'%1.4f')
   li.toText()
end
% 
% 
% disp('3')
% [mean(ma3);std(ma3); [sum(ma3>0.8);sum(ma3>0.9)]./length(ma3).*100]
% 
% %again for 4
% disp('4')
% [mean(ma4);std(ma4); [sum(ma4>0.8);sum(ma4>0.9)]./length(ma4).*100]
% 
% disp('5')
% [mean(ma5);std(ma5); [sum(ma5>0.8);sum(ma5>0.9)]./length(ma5).*100]
% 
% disp('6')
% [mean(ma6);std(ma6); [sum(ma6>0.8);sum(ma6>0.9)]./length(ma6).*100]
% 
% disp('7')
% [mean(ma7);std(ma7); [sum(ma7>0.8);sum(ma7>0.9)]./length(ma7).*100]