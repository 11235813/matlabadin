%CALC_ABILITYDMG calculates the damage of each ability (glyphed and
%un-glyphed) and generates plots

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1); %should default to 1 for npccount/timein/timeout, 0 behind, Truth
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{2}; %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{3}; %0/31/10 w/HG
glyph=ddb.glyphset{3}; %SoT glyph only
talents;
buff=buff_model;
stat_model;
ability_model;


%% Configurations

%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(1).veng=1;
cfg(1).seal='Truth';

%repeat for 8% hit and exp soft-cap
cfg(2).helm=egs(1);
cfg(2).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(2).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(2).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(2).veng=1;
cfg(2).seal='Truth';

%low veng, low hit
cfg(3).helm=cfg(1).helm;
cfg(3).veng=0.3;
cfg(3).seal='Truth';

%low veng, hit-cap
cfg(4).helm=cfg(2).helm;
cfg(4).veng=0.3;
cfg(4).seal='Truth';

%high veng, low hit, SoI
cfg(5).helm=cfg(1).helm;
cfg(5).veng=1;
cfg(5).seal='Insight';


%labels for pretty-print output
dmg_labels={'SotR';'CS';'Jud';'AS';'HW';'HoW';'Exor';'SoT';'SoR';'SoJ';'Cens';'Cons';'HotR';'HaNova';'Melee';'WoG'};

%% glyphed vals
tmpvar.raw=zeros(length(val.raw),length(cfg));
tmpvar.dmg=zeros(size(tmpvar.raw));tmpvar.net=zeros(size(tmpvar.raw));
tmpvar.glyph=zeros(length(val.raw),length(cfg));

for c=1:length(cfg)
    %set configuration variables
    exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
    egs(1)=cfg(c).helm;
    gear_stats;
    
    %values with only SoT glyph
    glyph=ddb.glyphset{3}; 
    talents;
    stat_model;
    ability_model;
    tmpvar.raw(:,c)=val.raw;  %raw damage
    tmpvar.dmg(:,c)=val.dmg;  %net damage after hit/crit
    tmpvar.heal(:,c)=val.heal;
    tmpvar.thr(:,c)=val.threat; %threat after hit/crit
    tmpvar.net(:,c)=val.net{1};  %seal procs included
    tmpvar.netthr(:,c)=val.net{2}; %net threat per cast
    
    %values with all glyphs active
    glyph.prime=ones(size(glyph.prime));glyph.major=ones(size(glyph.major));
    talents;
    stat_model;
    ability_model;
    tmpvar.glyphdmg(:,c)=val.dmg;
    tmpvar.glyphthr(:,c)=val.threat;
    tmpvar.glyphheal(:,c)=val.heal;
    tmpvar.glyphnet(:,c)=val.net{1};
    tmpvar.glyphnetthr(:,c)=val.net{2};
end


%% text arrays
spacer=repmat(' ',size(tmpvar.raw,1),3);
arr1=[tmpvar.raw(:,1) tmpvar.dmg(:,1) tmpvar.net(:,1) tmpvar.glyphdmg(:,1)];
arr2=[tmpvar.raw(:,5) tmpvar.dmg(:,5) tmpvar.net(:,5) tmpvar.glyphdmg(:,5)];
ii=find(strcmp(cellstr(dmg_labels),'WoG'));
arr1(ii,:)=[tmpvar.raw(ii,1) tmpvar.heal(ii,1) tmpvar.heal(ii,1) tmpvar.glyphheal(ii,1)];
arr2(ii,:)=[tmpvar.raw(ii,5) tmpvar.heal(ii,5) tmpvar.heal(ii,5) tmpvar.glyphheal(ii,5)];
dmgarray1=[char(dmg_labels) spacer int2str(arr1) spacer spacer int2str(arr2)]
arr3=tmpvar.glyphnet;
arr3(ii,:)=[tmpvar.heal(ii,:)];
dmgarray2=[char(dmg_labels) spacer int2str(arr3)]
thrarray1=[char(dmg_labels) spacer int2str(tmpvar.glyphthr)]


%% Code for plots
dmgplot=[tmpvar.dmg(:,1) max([tmpvar.glyphdmg(:,1)-tmpvar.dmg(:,1) zeros(size(tmpvar.glyphdmg(:,1)))],[],2)];
netplot=[tmpvar.net(:,1) max([tmpvar.glyphdmg(:,1)-tmpvar.dmg(:,1) zeros(size(tmpvar.glyphdmg(:,1)))],[],2)];
%fix for J (add raw.SotR)
netplot2=netplot;
jj=find(strcmp(cellstr(dmg_labels),'Jud'));ss=find(strcmp(cellstr(dmg_labels),'SotR'));
netplot2(jj,1)=netplot2(jj,1)+dmgplot(ss,1)*mdf.SacDut*mdf.rahit;
netplot2(jj,2)=netplot2(jj,2)+dmgplot(ss,2)*mdf.SacDut*mdf.rahit;
kk=[1:7 11:14 16];

figure(20)
set(gcf,'Position',[428 128 728 378])
bar20=bar(dmgplot(kk,:),'BarWidth',0.5,'BarLayout','stacked');
set(bar20(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 11.5])
maxy=ceil(max(sum(dmgplot,2))/5000)*5000;
ylim([0 maxy])
set(gca,'YTick',[0:5000:maxy],'YTickLabel',[int2str([0:5:maxy/1000]') repmat('k',1+maxy/5000,1)])
set(gca,'XTickLabel',dmg_labels(kk))
% set(gca,'YTick',[0:5
legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('Ability')
ylabel('Damage')
title('100% Vengeance, SoT')
% 
% 
figure(21)
set(gcf,'Position',[428 128 728 378])
bar40=bar(netplot(kk,:),'BarWidth',0.5,'BarLayout','stacked');
set(bar40(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 11.5])
maxy=ceil(max(sum(netplot,2))/5000)*5000;
ylim([0 maxy])
set(gca,'YTick',[0:5000:maxy],'YTickLabel',[int2str([0:5:maxy/1000]') repmat('k',1+maxy/5000,1)])
set(gca,'XTickLabel',dmg_labels(kk))
legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('Ability')
ylabel('Damage (including SoT procs)')
title('100% Vengeance')
% 
% 
figure(22)
set(gcf,'Position',[428 128 728 378])
bar40=bar(netplot2(kk,:),'BarWidth',0.5,'BarLayout','stacked');
set(bar40(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 11.5])
maxy=ceil(max(sum(netplot2,2))/5000)*5000;
ylim([0 maxy])
set(gca,'YTick',[0:5000:maxy],'YTickLabel',[int2str([0:5:maxy/1000]') repmat('k',1+maxy/5000,1)])
set(gca,'XTickLabel',dmg_labels(kk))
legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('Ability')
ylabel('Damage (including SoT procs and Sacred Duty)')
title('100% Vengeance')
% 
%% these two look psychadelically awful
% 
figure(23)
set(gcf,'Position',[428 128 728 378])
bar40=bar(tmpvar.glyphnet(kk,:),'BarWidth',1,'BarLayout','grouped');
set(bar40(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 12.5])
maxy=ceil(max(sum(netplot2,2))/5000)*5000;
ylim([0 maxy])
set(gca,'YTick',[0:5000:maxy],'YTickLabel',[int2str([0:5:maxy/1000]') repmat('k',1+maxy/5000,1)])
set(gca,'XTickLabel',dmg_labels(kk))
legend('Veng=100%','Veng=100%, 8% hit, 26 exp','Veng=30%','Veng=30%, 8% hit, 26 exp','Location','NorthEast')
xlabel('Ability')
ylabel('Damage (including SoT procs)')
title('Glyphed Damage, Varying Vengeance, Hit, Exp')
% 
% 
figure(24)
set(gcf,'Position',[428 128 728 378])
bar40=barh(arr3(kk,:),'BarWidth',1.5,'BarLayout','grouped');
set(bar40(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 12.5])
maxx=ceil(max(sum(netplot2,2))/5000)*5000;
xlim([0 maxy])
set(gca,'XTick',[0:5000:maxx],'XTickLabel',[int2str([0:5:maxx/1000]') repmat('k',1+maxx/5000,1)])
set(gca,'YTickLabel',dmg_labels(kk))
legend('Veng=100%','Veng=100%, 8% hit, 26 exp','Veng=30%','Veng=30%, 8% hit, 26 exp','Location','NorthEast')
ylabel('Ability')
xlabel('Damage (including SoT procs)')
title('Glyphed Damage, Varying Vengeance, Hit, Exp')