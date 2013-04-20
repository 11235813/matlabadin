config.simMins=100;
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
config.enableSS=1;
config.t154pcEquipped=0;
config.useDivineProtection=0;
config.bossSwingDamage=250000;
config.soimodel='fermi';

x0=1.5;
sigma=0.15;

if exist('sb')~=1
    sb=pally_mc(config);
end

%store boss swing history
BSH=sb.bshstore;

%sum the last 3 boss attacks
B=sum(sb.bshstore(1:3,:));
mB=mean(B);

%absorbs?

%calculate histogram stats
[N x]=hist(temp,40);

figure(1);hist(temp,40);xlabel('mean of last 3 boss attacks');
ylabel('Number of occurrences');

figure(2);plot(x,cumsum(N)./sum(N));
xlabel('cumulative probability: last 3 boss attacks');
ylabel('Probability')

b=1./(1+exp(-(B-x0)./sigma));
xx=linspace(0,3,1000);yy=1./(1+exp(-(xx-x0)./sigma));
figure(3);plot(xx,yy,B,b,'r.');xlabel('mean of last 3 boss attacks')
ylabel('SoI effectiveness (1-overheal)')

%histogram of healing values
[N2 x2]=hist(b,40);
figure(4);hist(b,40);
xlabel('SoI effectiveness (1-overheal)');
ylabel('Number of occurrences')

figure(5);plot(x2,cumsum(N2)./sum(N2));xlabel('SoI effectiveness (1-overheal)');
ylabel('Cumulative Probability')

[N3 x3]=hist(sb.soiTracker(sb.soiTracker>=0),40);
figure(6);hist(sb.soiTracker(sb.soiTracker>=0),40);
xlim([0 max(x3)])
xlabel('SoI heal size')
ylabel('Number of occurrences')