%% gear
statSetup.name='C/Ha';
statSetup.buffedStr=15000;
statSetup.stamina=28000;
statSetup.parryRating=1500;
statSetup.dodgeRating=1500;
statSetup.masteryRating=1500;
statSetup.hitRating=2550;
statSetup.expRating=5100;
statSetup.hasteRating=12000;
statSetup.armor=65000;

%% config base
config.simMins=1000;
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
config.finisher='S';
config.priority='default';
config.enableSS=0;
config.t154pcEquipped=0;
config.useDivineProtection=0;
config.bossSwingDamage=250000;
config.soimodel='nooverheal';
config.soiDirection='forward';


%% forward
fwdconfig=config;

a=pally_mc(fwdconfig,statSetup);


%% backward
backconfig=config;
backconfig.soiDirection='back';

b=pally_mc(backconfig,statSetup);


%% combine, stats

c=[a b];

li=DataTable();
i=1;

%title
li{i,1:3}={'Stat:','fwd','back'};

%Raw Heal
i=i+1;
li{i,1}='Raw Heal';
li{i,2:3}=cellstr([num2str([c.soiHealedRaw]'./1e3,'%2.2f') repmat('k',2,1)])';

%Raw Overheal
i=i+1;
li{i,1}='Raw OverHeal';
li{i,2:3}=cellstr([num2str([c.soiOverHealedRaw]'./1e3,'%2.2f') repmat('k',2,1)])';

%Heal %
i=i+1;
li{i,1}='Heal%';
li{i,2:3}=[c.soiHealed].*100;

%Overheal %
i=i+1;
li{i,1}='OverHeal%';
li{i,2:3}=[c.soiOverHealed].*100;


%show
li.setColumnFormat(2:3,'%2.2f')
li.toText()
