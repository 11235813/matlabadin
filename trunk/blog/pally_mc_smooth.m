clear
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'
%% simulation conditions
config.simMins=10000;
config.plotFlag='plot';
config.tocFlag='toc';
config.stat=' ';
config.val=0;
config.plotnum=1;
config.sF=5;


%% set up stat configs
i=1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=4834;
statSetup(i).dodgeRating=4892;
statSetup(i).masteryRating=6758;
statSetup(i).hitRating=1521;
statSetup(i).expRating=1777;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=6758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=2777;
statSetup(i).hasteRating=2000;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=5758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=2777;
statSetup(i).hasteRating=3000;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=7834;
statSetup(i).dodgeRating=6892;
statSetup(i).masteryRating=5758;
statSetup(i).hitRating=21;
statSetup(i).expRating=277;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=8758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=2777;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=2758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=2777;
statSetup(i).hasteRating=6000;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=2758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=5077;
statSetup(i).hasteRating=3700;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=6458;
statSetup(i).hitRating=2521;
statSetup(i).expRating=5077;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=6034;
statSetup(i).dodgeRating=6092;
statSetup(i).masteryRating=58;
statSetup(i).hitRating=2521;
statSetup(i).expRating=5077;
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
save([fbase '_' int2str(i) '.mat'])
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

%Mean & std spike damage intake
%events above 80 and 90%
for j=2:7
    disp(int2str(j))
   li=DataTable(); 
   li{1:6,1}={'Set:';'S%';'mean';'std';'80%';'90%'};
   li{1,2:10}={'#1','#2','#3','#4','#5','#6','#7','#8','#9'};
   li{2,2:10}=S;
   li{3,2:10}=eval(char(['mean(ma' int2str(j) ');']));
   li{4,2:10}=eval(char(['std(ma' int2str(j) ');']));
   li{5,2:10}=eval(char(['sum(ma' int2str(j) '>0.8)./length(ma5).*100;']));
   li{6,2:10}=eval(char(['sum(ma' int2str(j) '>0.9)./length(ma5).*100;']));
   li.setColumnFormat(2:10,'%1.4f')
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