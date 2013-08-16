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
config.bossSwing=1.5;

finishers={'SB','SBr*','F-110'};

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
statSetup(i).armor=63500;
i=i+1;
statSetup(i).name='C/Av';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=4000;
statSetup(i).dodgeRating=4000;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
statSetup(i).armor=63500;
i=i+1;
statSetup(i).name='C/Bal';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=3167;
statSetup(i).dodgeRating=3167;
statSetup(i).masteryRating=3166;
statSetup(i).hitRating=2550;
statSetup(i).expRating=5100;
statSetup(i).hasteRating=0;
statSetup(i).armor=63500;
i=i+1;
statSetup(i).name='C/Bal-NC';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=3167;
statSetup(i).dodgeRating=3167;
statSetup(i).masteryRating=3366;
statSetup(i).hitRating=2450;
statSetup(i).expRating=5000;
statSetup(i).hasteRating=0;
statSetup(i).armor=63500;
i=i+1;
statSetup(i).name='Avoid';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=7325;
statSetup(i).dodgeRating=7325;
statSetup(i).masteryRating=1500;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=63500;
i=i+1;
statSetup(i).name='Av/Mas';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=6000;
statSetup(i).dodgeRating=6000;
statSetup(i).masteryRating=4150;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=63500;
i=i+1;
statSetup(i).name='Mas/Av';
statSetup(i).buffedStr=11000;
statSetup(i).parryRating=4000;
statSetup(i).dodgeRating=4000;
statSetup(i).masteryRating=8150;
statSetup(i).hitRating=500;
statSetup(i).expRating=500;
statSetup(i).hasteRating=0;
statSetup(i).armor=63500;
    n=length(statSetup);

% %% Crank
% for k=1:length(finishers)
%     config.finisher=finishers{k};
%     
%     
%     for j=1:i
%         tic
%         config.plotNum=j;
%         statblock(j)=warr_mc(config,statSetup(j),startCond);
%         toc
%     end
%     
%     
%     
%     
%     %% Table
%     
%     %Mean & std spike damage intake
%     %events above 80 and 90%
%     li=DataTable();
%     li{1:8,1}={'Set:';'S%';'mean';'std';'SBr(k)';'SBr<60(k)';'RPS';'xsR(k)'};
%     li{1,1+(1:n)}={statSetup.name};
%     li{2,1+(1:n)}=S;
%     matemp=filter(ones(1,5)./5,1,dmg);
%     li{3,1+(1:n)}=mean(matemp);
%     li{4,1+(1:n)}=std(matemp);
%     li{5,1+(1:n)}=sum([statblock.SBrTrack]>0)./1e3;
%     li{6,1+(1:n)}=(sum([statblock.SBrTrack]>0)-sum([statblock.SBrTrack]>40))./1e3;
%     li{7,1+(1:n)}=[statblock.Rrage];
%     li{8,1+(1:n)}=[statblock.xsRage]./1e3;
%     linePH=0;
%     for j=jMin:jStep:jMax
%         matemp=filter(ones(1,j)./j,1,dmg);
%         li{9+linePH,1:(n+1)}=cat(2,{'------',['--- ' int2str(j)],'Attack','Moving','Average'},repmat({'------'},1,n-4));
%         linePH=linePH+1;
%         li{9+linePH,1}='80%';
%         li{9+linePH,1+(1:n)}=sum(matemp>0.8)./size(matemp,1).*100;
%         linePH=linePH+1;
%         li{9+linePH,1}='90%';
%         li{9+linePH,1+(1:n)}=sum(matemp>0.9)./size(matemp,1).*100;
%         linePH=linePH+1;
%     end
%     li.setColumnFormat(1+(1:n),'%1.4f')
%     disp(config.finisher)
%     disp('<pre>')
%     li.toText()
%     disp('</pre>')
%     
% end

%% Gear sets
gl=DataTable();
gl{1,1+(1:n)}={statSetup.name};
gl{1:8,1}={'Set:';'Str';'Armor';'Parry';'Dodge';'Mastery';'Hit';'Exp'};

for i=1:length(statSetup)
    gl{2:8,1+i}={statSetup(i).buffedStr;...
        statSetup(i).armor;...
        statSetup(i).parryRating;...
        statSetup(i).dodgeRating;...
        statSetup(i).masteryRating;...
        statSetup(i).hitRating;...
        statSetup(i).expRating};
end
disp('<pre>')
gl.toText()
disp('</pre>')

%% Hit/exp scaling sim

config.finisher='SB';
heStatSetup=statSetup(3);
j=0;
NumDataPoints=255;  %51, 102, 170, 255 all evenly divisible
stepVal=heStatSetup.hitRating./NumDataPoints;
W=waitbar(0,['Generating (step ' int2str(j) ' of ' int2str(NumDataPoints) ')']);
while heStatSetup.hitRating>=0 && heStatSetup.expRating>=0
    j=j+1;
    waitbar(j./NumDataPoints,W,['Generating (step ' int2str(j) ' of ' int2str(NumDataPoints) ')'])
    tic
    statblock(j)=warr_mc(config,heStatSetup,startCond);
    hitexp(j,:)=[heStatSetup.hitRating heStatSetup.expRating];
    toc
    heStatSetup.hitRating=heStatSetup.hitRating-stepVal;
    heStatSetup.expRating=heStatSetup.expRating-2.*stepVal;
end
close(W)
%% calculate stats
dmg=[statblock.dmg];

%moving averages
ma5=filter(ones(1,5)./5,1,dmg);

%what do we want to know?
MAmean=mean(ma5);
MAstd=std(ma5);
S=[statblock.S];
ma=[statblock.maDTPS];



fbase=['.\wdata\warr_stat2_data_' int2str(config.simMins)];
f=0;
while exist([fbase '_' int2str(f) '.mat'])==2
    f=f+1;
end
fname=[fbase '_' int2str(f) '.mat'];
save(fname)
disp(['data saved to ' fname])

%% Post-processing
matemp=filter(ones(1,4)./4,1,dmg);
spike490=sum(matemp>0.9)./size(matemp,1).*100;
hitpct=hitexp(:,1)./340;
exppct=hitexp(:,2)./340;


%% Plots
x1=hitpct+exppct;
x2=hitpct+exppct;

figure(1)
plot(x1,spike490,'.-',x1,ones(size(spike490)).*1e-3,'k--')
xlim([0 max(x1)])
xlabel('Hit+Expertise (%)')
ylabel('Percentage of spikes exceeding 90% max throughput')
title('Spike presence vs. hit percentage, 4-attack moving average')
% set(gca,'YScale','log')

figure(2)
plot(x1,spike490,'.-',x1,ones(size(spike490)).*1e-3,'k--')
xlim([15 max(x1)])
xlabel('Hit+Expertise (%)')
ylabel('Percentage of spikes exceeding 90% max throughput')
title('Spike presence vs. hit percentage, 4-attack moving average')


figure(3)
plot(x2,spike490,'.-',x2,ones(size(spike490)).*1e-3,'k--')
xlim([0 max(x2)])
set(gca,'YScale','log')
xlabel('Hit+Expertise (%)')
ylabel('Percentage of spikes exceeding 90% max throughput')
title('Spike presence vs. hit percentage, 4-attack moving average')
