config.simMins=500;
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
config.bossSwingDamage=250000;
config.soimodel='fermi-1.55-0.15';

soimodel=regexp(config.soimodel,'(?<base>\w+)\-?(?<x0>\d+\.*\d*)?\-?(?<sigma>\d+\.*\d*)?','names');

x0=str2double(soimodel.x0);
sigma=str2double(soimodel.sigma);

% if exist('sb')~=1
    sb=pally_mc(config);
% end

%store boss swing history
BSH=sb.bshstore;

%sum the last 3 boss attacks
B=sum(sb.bshstore(1:3,:));
mB=mean(B);

%absorbs?

%% calculate histogram stats
[N x]=hist(B,40);

figure(1);hist(B,40);
xlabel('mean of last 3 boss attacks');
ylabel('Number of occurrences');
title([config.soimodel ',   ' int2str(config.bossSwingDamage/1000) 'k'])

figure(2);plot(x,cumsum(N)./sum(N));
xlabel('cumulative probability: last 3 boss attacks');
ylabel('Probability')
title([config.soimodel ',   ' int2str(config.bossSwingDamage/1000) 'k'])

b=1./(1+exp(-(B-x0)./sigma));
xx=linspace(0,3,1000);yy=1./(1+exp(-(xx-x0)./sigma));
figure(3);plot(xx,yy,B,b,'r.');xlabel('mean of last 3 boss attacks')
ylabel('SoI effectiveness (1-overheal)')
title([config.soimodel ',   ' int2str(config.bossSwingDamage/1000) 'k'])
text(0.2,0.5,['% overheal = ' num2str((1-mean(b)).*100,'%2.2f') '%'])

%histogram of healing values
[N2 x2]=hist(b,40);
figure(4);hist(b,40);
xlabel('SoI effectiveness (1-overheal)');
ylabel('Number of occurrences')
title([config.soimodel ',   ' int2str(config.bossSwingDamage/1000) 'k'])
text(0.3,max(N2)./2,['% overheal = ' num2str((1-mean(b)).*100,'%2.2f') '%'])

figure(5);plot(x2,cumsum(N2)./sum(N2));
title([config.soimodel ',   ' int2str(config.bossSwingDamage/1000) 'k'])
xlabel('SoI effectiveness (1-overheal)');
ylabel('Cumulative Probability')

soidist=sb.soiTracker(sb.soiTracker>=0);
[N3 x3]=hist(soidist,40);
figure(6);hist(soidist,40);
xlim([0 max(x3)])
xlabel('SoI heal size')
ylabel('Number of occurrences')
title([config.soimodel ',   ' int2str(config.bossSwingDamage/1000) 'k'])
text(max(x3)./4,max(N3).*2./3,['Avg Heal = ' num2str(mean(soidist).*100,'%2.1f') '% of boss attack'])
text(max(x3)./4,max(N3)./2,['Max Heal = ' num2str(max(soidist).*100,'%2.1f') '% of boss attack'])