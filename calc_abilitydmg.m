clear;
gear_db;
def_db;

exec=execution_model('veng',1); %should default to 1 for npccount/timein/timeout, 0 behind, Truth
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{2}; %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{2}; %0/31/10 w/HG
glyph=ddb.glyphset{3}; %SoT glyph only
talents;
buff=buff_model;
stat_model;

%artificially inflating hit and expertise to 8% and 26
% gear.hit=8*cnv.hit_phhit;
% gear.exp=(26-10-base.exp)*cnv.exp_exp;
% stat_model

%Debugging for odd gear sets
% old.ap=player.ap;old.hsp=player.hsp;
% player.ap=1010;
% player.hsp=421;
% player.ap=3179;
% player.hsp=889;
% gear.swing=1.6;
% gear.avgdmg=(200+373)/2;
% player.wdamage=(690+921)/2;
% gear.avgdmg=player.wdamage-player.ap./14.*gear.swing;
% player.wdamage=gear.avgdmg+player.ap./14.*gear.swing;
% player.ndamage=gear.avgdmg+player.ap./14.*2.4;


%calculate ability output
ability_model;
% rotation_model

%generate a damage summary array
%% Summary
dmg_labels={'ShoR';'CS';'JoT';'AS';'HW';'HoW';'Exor';'SoT';'SoR';'SoJ';'Cens';'Cons';'HotR';'HaNova';'Melee';'WoG'};


vals.raw=val.raw;  %raw damage
vals.dmg=val.dmg;  %net damage after hit/crit
vals.net=val.net{1};  %seal procs included

spacer=repmat(' ',size(vals.raw,1),2);
raw_summary=[char(dmg_labels) spacer int2str(vals.raw)];
dmg_summary=[char(dmg_labels) spacer int2str(vals.dmg)];
thr_summary=[char(dmg_labels) spacer int2str(vals.dmg.*mdf.RF)];
all_summary=[char(dmg_labels) spacer int2str(vals.raw) spacer int2str(vals.dmg) spacer int2str(vals.dmg.*mdf.RF)];

%% glyphed vals
vals.glyph=zeros(length(vals.raw),4);
%invoke all glyphs
glyph.prime=ones(size(glyph.prime));glyph.major=ones(size(glyph.major));
temp.vap=[1 1 0.3 0.3];
%artificially inflating hit and expertise to 8% and 26 for the last set
temp.hit=[gear.hit 8*cnv.hit_phhit gear.hit 8*cnv.hit_phhit];
temp.exp=[gear.exp (26-10-base.exp)*cnv.exp_exp gear.exp (26-10-base.exp)*cnv.exp_exp];

for m=1:size(vals.glyph,2)
    exec=execution_model('veng',temp.vap(m));
    gear.hit=temp.hit(m);
    gear.exp=temp.exp(m);
    talents;
    stat_model;
    ability_model;
    vals.glyph1(:,m)=val.dmg;
    vals.glyph2(:,m)=val.net(1);
end
vals.glyph2=cell2mat(vals.glyph2);

% %now pick out ability damages and sort them into glyph_vals
% vals.glyph(1)=tempvalp(1,6); %ShoR glyph
% vals.glyph(2)=tempvalp(2,1); %CS
% vals.glyph(3)=tempvalp(3,4); %Jud
% vals.glyph(4)=tempvalm(4,5); %AS
% vals.glyph(7)=tempvalp(7,2); %Exor
% vals.glyph(12)=tempvalm(12,2); %Cons
% vals.glyph(13)=tempvalp(13,3); %HotR
% vals.glyph(14)=tempvalp(14,3); %HaNova

%% text arrays
spacer=repmat(' ',size(vals.raw,1),3);
dmgarray1=[char(dmg_labels) spacer int2str([vals.raw vals.dmg vals.net vals.glyph1(:,1)])]
dmgarray2=[char(dmg_labels) spacer int2str(vals.glyph2)]



%% Code for plots
dmgplot=[vals.dmg max([vals.glyph1(:,1)-vals.dmg zeros(size(vals.glyph1(:,1)))],[],2)];
netplot=[vals.net max([vals.glyph1(:,1)-vals.dmg zeros(size(vals.glyph1(:,1)))],[],2)];
%fix for J (add raw.SotR)
netplot2=netplot;
netplot2(3,1)=netplot2(3,1)+raw.ShieldoftheRighteous*mdf.SacDut*mdf.rahit;
kk=[1:7 11:14];

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
title('100% Vengeance')
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
% 
figure(23)
set(gcf,'Position',[428 128 728 378])
bar40=bar(vals.glyph2(kk,:),'BarWidth',1,'BarLayout','grouped');
set(bar40(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 11.5])
maxy=ceil(max(sum(netplot2,2))/5000)*5000;
ylim([0 maxy])
set(gca,'YTick',[0:5000:maxy],'YTickLabel',[int2str([0:5:maxy/1000]') repmat('k',1+maxy/5000,1)])
set(gca,'XTickLabel',dmg_labels(kk))
legend('Veng=100%','Veng=100%, 8% hit, 26 exp','Veng=30%','Veng=30%, 8% hit, 26 exp','Location','NorthEast')
xlabel('Ability')
ylabel('Damage (including SoT procs)')
title('Glyphed Damage, Varying Vengeance, Hit, Exp')