clear
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'
% finishers={'SBrBleed','SBrBleed20','SBrWeave4','SBrWeave3','SBrWeave2','SBonly'}; %,'SBronly','SBronly60'};
finishers={'SB','SBr','SBr*','SBr60','B-100','B-110','B-120','W4-110','W4-115','W4-120','W4','W3','W2','F0-120','F1-120'};
finishers={'SB','SBr','SBr*','SBr60','SBr60*'};
finishers={'SB','SBr*','B-100','B-105','B-110','B-115','B-120'};
finishers={'SB','SBr*','W3-105','W3-110','W3-115','W3-120'};
finishers={'SB','SBr*','W3.1-105','W3.1-110','W3.1-115','W3.1-120'};
finishers={'SB','SBr*','W4','W3','W2','W1'};
finishers={'SB','SBr*','F0-120','F1-120','F-120'};
finishers={'SB','SBr*','F-100','F-110','F-120'};
% finishers={'SB','SBr'};
% finishers={'SB','SBr*','W3.5','W3','W2.5','W2'};
statSetup='';
config.simMins=10000; %10000
config.plotFlag='2only';
config.tocFlag='toc';
config.stat=' ';
config.val=0;
config.plotnum=1;
config.sF=5;
config.bossSwingTimer=1.5;
jMin=2;
jMax=7;
jStep=1;

startCond.rage=0;
startCond.stepspersecond=2;
startCond.prio='steadystate';
% startCond.prio='short';
% startCond.finisher='SBrBleed';

tic
for k=1:length(finishers)
    
    config.plotNum=k;
    config.finisher=finishers{k};
    statblock(k)=warr_mc(config,statSetup,startCond);

end
toc


%% calculate stats
dmg=[statblock.dmg];

ma5=filter(ones(1,5)./5,1,dmg);

%what do we want to know
MAmean=mean(ma5);
MAstd=std(ma5);
S=[statblock.S];
ma=[statblock.maDTPS];

%% Save data
fbase=['.\wdata\warr_finish_data_' int2str(config.simMins)];
i=0;
while exist([fbase '_' int2str(i) '.mat'])==2
    i=i+1;
end
fname=[fbase '_' int2str(i) '.mat'];
save(fname)
disp(['data saved to ' fname])


%% Table
clear li
%Mean & std spike damage intake
%events above 80 and 90%
li=DataTable();
li{1:8,1}={'Set:';'S%';'mean';'std';'SBr(k)';'SBr<60(k)';'RPS';'xsR(k)'};
n=length(finishers);
li{1,1+(1:n)}=finishers;
li{2,1+(1:n)}=S;
matemp=filter(ones(1,5)./5,1,dmg);
li{3,1+(1:n)}=mean(matemp);
li{4,1+(1:n)}=std(matemp);
li{5,1+(1:n)}=sum([statblock.SBrTrack]>0)./1e3;
li{6,1+(1:n)}=(sum([statblock.SBrTrack]>0)-sum([statblock.SBrTrack]>40))./1e3;
li{7,1+(1:n)}=[statblock.Rrage];
li{8,1+(1:n)}=[statblock.xsRage]./1e3;
linePH=0;
for j=jMin:jStep:jMax
    matemp=filter(ones(1,j)./j,1,dmg);
    li{9+linePH,1:(n+1)}=cat(2,{'------',['--- ' int2str(j)],'Attack','Moving','Average'},repmat({'------'},1,n-4));
    linePH=linePH+1;
    li{9+linePH,1}='80%';
    li{9+linePH,1+(1:n)}=sum(matemp>0.8)./size(matemp,1).*100;
    linePH=linePH+1;
    li{9+linePH,1}='90%';
    li{9+linePH,1+(1:n)}=sum(matemp>0.9)./size(matemp,1).*100;
    linePH=linePH+1;
end
li.setColumnFormat(1+(1:n),'%1.4f')
disp('<pre>')
li.toText()
disp('</pre>')
