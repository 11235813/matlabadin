clear;
gear_db;
def_db;

% lvl 85
base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base);
gear_sample
glyph=ddb.glyphset{1}; %no glyphs
talent=ddb.talentset{3};  %0/31/5

%execution
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth');
%activate buffs
buff=buff_model('mode',3);
%invoke talents & glyphs
talents
%calculate relevant stats
gear_stats
%calculate final stats
stat_model


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
ability_model

%generate a damage summary array
%% Summary
dmg_labels={'ShoR';'CS';'JoT';'AS';'HW';'HoW';'Exor';'SoT';'SoR';'SoJ';'Cens';'Cons';'HotR';'HaNova';'Melee'};


vals.raw=val.raw;  %raw damage
vals.dmg=val.dmg;  %net damage after hit/crit
vals.net=val.net;  %seal procs included

mdf.RF=3;
spacer=repmat(' ',size(vals.raw,1),2);
raw_summary=[char(dmg_labels) spacer int2str(vals.raw)];
dmg_summary=[char(dmg_labels) spacer int2str(vals.dmg)];
thr_summary=[char(dmg_labels) spacer int2str(vals.dmg.*mdf.RF)];
all_summary=[char(dmg_labels) spacer int2str(vals.raw) spacer int2str(vals.dmg) spacer int2str(vals.dmg.*mdf.RF)];

%% glyphed vals
vals.glyph=zeros(size(vals.raw));

for m=1:length(glyph.prime)
    glyph.prime=zeros(size(glyph.prime));glyph.major=zeros(size(glyph.major));
    glyph.prime(m)=1;
    talents
    stat_model
    ability_model
    tempvalp(:,m)=val.dmg;
end

% AS/cons glyphs
for m=1:length(glyph.major)
    glyph.prime=zeros(size(glyph.prime));glyph.major=zeros(size(glyph.major));
    glyph.major(m)=1;
    talents
    stat_model
    ability_model
    tempvalm(:,m)=val.dmg;
end

%now pick out ability damages and sort them into glyph_vals
vals.glyph(1)=tempvalp(1,6); %ShoR glyph
vals.glyph(2)=tempvalp(2,1); %CS
vals.glyph(3)=tempvalp(3,4); %Jud
vals.glyph(4)=tempvalm(4,5); %AS
vals.glyph(7)=tempvalp(7,2); %Exor
vals.glyph(12)=tempvalm(12,2); %Cons
vals.glyph(13)=tempvalp(13,3); %HotR
vals.glyph(14)=tempvalp(14,3); %HaNova

%% text arrays
spacer=repmat(' ',size(vals.raw,1),3);
dmgarray=[char(dmg_labels) spacer int2str([vals.raw vals.dmg vals.glyph])]



%% Code for plots
dmgplot=[vals.dmg max([vals.glyph-vals.dmg zeros(size(vals.glyph))],2)];
netplot=[vals.net max([vals.glyph-vals.dmg zeros(size(vals.glyph))],2)];
kk=[1:7 11:14];

figure(20)
set(gcf,'Position',[428 128 728 378])
bar20=bar(dmgplot(kk,:),'BarWidth',0.5,'BarLayout','stacked');
set(bar20(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 11.5])
set(gca,'XTickLabel',dmg_labels(kk))
legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('Ability')
ylabel('Damage')
% 
% 
figure(21)
set(gcf,'Position',[428 128 728 378])
bar40=bar(netplot(kk,:),'BarWidth',0.5,'BarLayout','stacked');
set(bar40(2),'FaceColor',[0.749 0.749 0]);
xlim([0.5 11.5])
set(gca,'XTickLabel',dmg_labels(kk))
legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('Ability')
ylabel('Damage (including SoV procs)')
% 