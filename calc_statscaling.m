%CALC_STATSCALING calculates the scaling of our abilites with different
%stats

%% Setup tasks
clear;
gear_db;
def_db;
exec=execution_model('veng',1); %placeholder, redefined in cfg
base=player_model('race','Human');
npc=npc_model(base);
buff=buff_model;
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{1};  %placeholder, redefined in cfg
glyph=ddb.glyphset{1}; %placeholder, redefined in cfg
talents;
stat_model;

%% Stat components
stat={'exp';'hit';'str';'ap';'sta';'crit';'agi';'haste';'sp';'int';'mas'};
M=length(stat);  %number of "extra" stats

dstat=[10 10 20 10 10 10 10 10 10 10 10];

%% Configurations
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(1).label='939/SoT build';
cfg(1).veng=1;
cfg(1).seal='Truth';
cfg(1).rot=1;
cfg(1).glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS
cfg(1).talent=ddb.talentset{1}; %0/31/10 w/o HG

%low hit, W39
cfg(2).helm=cfg(1).helm;
cfg(2).label='W39/SoI build';
cfg(2).veng=1;
cfg(2).seal='Insight';
cfg(2).rot=7; %W39
cfg(2).glyph=ddb.glyphset{2}; %WoG set
cfg(2).talent=ddb.talentset{2}; %0/31/10 WoG build

% %low hit, IHSH
% cfg(3)=cfg(1);
% cfg(3).label='IHSH/SoT';
% cfg(3).rot=2;

%% Strength graphs
%reset extra structure
extra_init;
extra.val.str=-100+[1:2:1500];
sdps=zeros(M,length(extra.val.str),length(cfg));
sdps0=zeros(size(sdps));

for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;
        
    %store items in cfg for plots
    cfg(c).hit=player.phhit;
    cfg(c).exp=player.exp;

    for m=1:M
        %set each stat to dstat extra
        eval(char(['extra.itm.' stat{m} '=dstat(m);']))

        stat_model;ability_model;rotation_model;
        
        sdps(m,:,c)=rot(cfg(c).rot).totdps;

        %set each stat back to 0 extra
        eval(char(['extra.itm.' stat{m} '=0;']))

        stat_model;ability_model;rotation_model;
        
        sdps0(m,:,c)=rot(cfg(c).rot).totdps;

    end
end
sdiffdps=(sdps-sdps0).*10./repmat(dstat',[1 size(sdps,2) size(sdps,3)]);
xS=player.armorystr';
yS1=squeeze(sdiffdps(:,:,1))';
yS2=squeeze(sdiffdps(:,:,2))';

figure(50)
set(gcf,'Position',[290    92   706   414])
plot(xS,yS1)
xlim([min(player.armorystr) max(player.armorystr)])
legend(stat,'Location','NorthEast')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')
title([cfg(1).label ', '  num2str(cfg(1).veng*100,'%2.1f') '% Veng, ' num2str(cfg(1).hit,'%2.1f') '% hit, ' num2str(cfg(1).exp,'%2.1f') ' expertise'])

figure(60)
set(gcf,'Position',[290    92   706   414])
plot(xS,yS2)
xlim([min(xS) max(xS)])
legend(stat,'Location','NorthEast')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')
title([cfg(2).label ', ' num2str(cfg(2).veng*100,'%2.1f') '% Veng, ' num2str(cfg(2).hit,'%2.1f') '% hit, ' num2str(cfg(2).exp,'%2.1f') ' expertise'])
    
%% Hit graph
%reset extra structure
extra_init;
extra.val.hit=-max(gear.hit)+0:round(10.*cnv.hit_phhit);

for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;

    %store items in cfg for plots
    cfg(c).hit=player.phhit;
    cfg(c).exp=player.exp;

    for m=1:M
        %set each stat to dstat extra
        eval(char(['extra.itm.' stat{m} '=dstat(m);']))

        stat_model;ability_model;rotation_model;
        
        hdps(m,:,c)=rot(cfg(c).rot).totdps;

        %set each stat back to 0 extra
        eval(char(['extra.itm.' stat{m} '=0;']))

        stat_model;ability_model;rotation_model;

        hdps0(m,:,c)=rot(cfg(c).rot).totdps;
        
    end
end
hdiffdps=(hdps-hdps0).*10./repmat(dstat',[1 size(hdps,2) size(hdps,3)]);
xH=player.phhit';
yH1=squeeze(hdiffdps(:,:,1))';
yH2=squeeze(hdiffdps(:,:,2))';

figure(51)
set(gcf,'Position',[290    92   706   414])
plot(xH,yH1)
xlim([min(player.phhit) max(player.phhit)])
legend(stat,'Location','NorthEast')
xlabel('Melee hit % against lvl 80')
ylabel('DPS per 10 itemization points')
title([cfg(1).label ', '  num2str(cfg(1).veng*100,'%2.1f') '% Veng, ' num2str(cfg(1).exp(1),'%2.1f') ' expertise'])

figure(61)
set(gcf,'Position',[290    92   706   414])
plot(xH,yH2)
xlim([min(xH) max(xH)])
legend(stat,'Location','NorthEast')
xlabel('Melee hit % against lvl 80')
ylabel('DPS per 10 itemization points')
title([cfg(2).label ', '  num2str(cfg(2).veng*100,'%2.1f') '% Veng, '  num2str(cfg(2).exp(1),'%2.1f') ' expertise'])
    
%% Exp graph
%reset extra structure
extra_init;
extra.val.exp=-max(gear.exp)+0:round(45.*cnv.exp_exp);

for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;
    
    %store items in cfg for plots
    cfg(c).hit=player.phhit;
    cfg(c).exp=player.exp;

    for m=1:M
        %set each stat to dstat extra
        eval(char(['extra.itm.' stat{m} '=dstat(m);']))

        stat_model;ability_model;rotation_model;
        
        edps(m,:,c)=rot(cfg(c).rot).totdps;
        
        %set each stat back to 0 extra
        eval(char(['extra.itm.' stat{m} '=0;']))

        stat_model;ability_model;rotation_model;
        
        edps0(m,:,c)=rot(cfg(c).rot).totdps;

    end
end
ediffdps=(edps-edps0).*10./repmat(dstat',[1 size(edps,2) size(edps,3)]);
xE=player.exp';
yE1=squeeze(ediffdps(:,:,1))';
yE2=squeeze(ediffdps(:,:,2))';

figure(52)
set(gcf,'Position',[290    92   706   414])
plot(xE,yE1)
xlim([min(player.exp) max(player.exp)])
legend(stat,'Location','NorthEast')
xlabel('Expertise skill')
ylabel('DPS per 10 itemization points')
title([cfg(1).label ', '  num2str(cfg(1).veng*100,'%2.1f') '% Veng, ' num2str(cfg(1).hit(1),'%2.1f') '% hit'])


figure(62)
set(gcf,'Position',[290    92   706   414])
plot(xE,yE2)
xlim([min(xE) max(xE)])
legend(stat,'Location','NorthEast')
xlabel('Expertise skill')
ylabel('DPS per 10 itemization points')
title([cfg(2).label ', '  num2str(cfg(2).veng*100,'%2.1f') '% Veng, ' num2str(cfg(2).hit(1),'%2.1f') '% hit'])