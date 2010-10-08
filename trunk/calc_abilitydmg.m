clear;
gear_db;
def_db;

% lvl 85
base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base);
egs=ddb.gearset{2};  %85

% %spellpower weapoin/shield
% egs(15)=equip(56433);%main hand
% egs(16)=equip(55880);%off hand


%lvl 80
% base=player_model('lvl',80,'race','Human','prof','');
% npc=npc_model(base);
% egs=ddb.gearset{2};  %80


talent=ddb.talentset{1};  %85 and 80 (drop EG/GbtL @ 80)
% talent.ret(1,2)=3;
% talent.holy(1,3)=1;

%execution
exec=execution_model('npccount',1,'timein',0,'timeout',1,'seal','Truth');
%activate buffs
buff=buff_model('mode',1);
%invoke talents & glyphs
talents
%calculate relevant stats
gear_stats
%calculate final stats
stat_model


%Debugging for odd gear sets
% old.ap=player.ap;old.hsp=player.hsp;
% player.ap=5511;
% player.hsp=1683;
% gear.swing=2.6;
% player.wdamage=(1683+2250)/2;
% player.wdamage=gear.avgdmg+player.ap./14.*gear.swing;



%calculate ability damages - uncomment appropriate level model
% ability_model
ability_model_80

%generate a damage summary array
%% Summary
dmg_labels={'ShoR';'CS';'JoT';'AS';'HW';'HoW';'Exor';'SoT';'SoR';'SoJ';'Cens';'Cons';'HotR';'HaNova';'Melee'};


raw_vals=[round(raw.ShieldoftheRighteous); 
    round(raw.CrusaderStrike); 
    round(raw.Judgement); 
    round(raw.AvengersShield); 
    round(raw.HolyWrath); 
    round(raw.HammerofWrath); 
    round(raw.Exorcism); 
    round(raw.SealofTruth); 
    round(raw.SealofRighteousness); 
    round(raw.SealofJustice); 
    round(raw.Censure); 
    round(raw.Consecration); 
    round(raw.HammeroftheRighteous);
    round(raw.HammerNova);
    round(raw.Melee)];

dmg_vals=[round(dmg.ShieldoftheRighteous); 
    round(dmg.CrusaderStrike); 
    round(dmg.Judgement); 
    round(dmg.AvengersShield); 
    round(dmg.HolyWrath); 
    round(dmg.HammerofWrath); 
    round(dmg.Exorcism); 
    round(dmg.SealofTruth); 
    round(dmg.SealofRighteousness); 
    round(dmg.SealofJustice); 
    round(dmg.Censure); 
    round(dmg.Consecration); 
    round(dmg.HammeroftheRighteous);
    round(dmg.HammerNova);
    round(dmg.Melee)];

mdf.RF=3;
spacer=repmat(' ',size(raw_vals,1),2);
raw_summary=[char(dmg_labels) spacer int2str(raw_vals)];
dmg_summary=[char(dmg_labels) spacer int2str(dmg_vals)];
thr_summary=[char(dmg_labels) spacer int2str(dmg_vals.*mdf.RF)];
all_summary=[char(dmg_labels) spacer int2str(raw_vals) spacer int2str(dmg_vals) spacer int2str(dmg_vals.*mdf.RF)];


%ras' human data
data1=[1231 1476 520 3605 2601 0 1354 204 57 24 1005*5/6 1645 231 842 776]';

%kierly's human data, 2 sets, 3rd is combined
% data1=[627 215 1140 3764 1612 0 1527 22.5 95 41 216*5 210*10 26 1452 90.4]';
% data1=[0   218 1242 3854    0 0    0 22.7 95 41 223*5   0*10  0    0 92]';
% data1=[627 215 1242 3764 1612 0 1527 22.7 95 41 223*5 210*10 26 1452 90.4]';

%neziah's human data
% data1=[6325 3333 2950 6179 2126 0 0 362 0 0 931*5 426*10 635 1610 1503]';

%Arianne's lvl 80 Dwarf data (dal swd)
data1=[644 171 276 3093 3*790 0 1142 20.3 16.3 7 87.6*5 129*10 20.3 711 67.1]';

%towellie's lvl 80 human data
data1=[601 198 284 3102 1166 0 0 20.0 0 0 86*5 130*10 25.5 795 70.5]';
    
data2=[raw_summary spacer int2str(data1) spacer int2str(data1-raw_vals) spacer int2str(100.*(data1-raw_vals)./raw_vals)]
%% Put glyph section here


%% incorporate seal procs into damage

%liberal use of new "net.ability" structure



%% Code for plots

% kk=[1:4 7:9 12:13 15];
% % kk=1:15;
% dmgplot=dmg(kk,:);dmgplot([4 5],2)=dmg([kk(4) kk(5)],2)-dmg([kk(4) kk(5)],1);
% dmgs_plot=dmgs;dmgs_plot(4:5,2)=dmgs(4:5,2)-dmgs(4:5,1);
% thrs_plot=thrs;thrs_plot(4:5,2)=thrs(4:5,2)-thrs(4:5,1);
% %dps variable
% dps=dmg./cooldowns2;
% dpsplot=dmgplot./cooldowns2(kk,:);
% dmgs_dps=dmgs./cooldowns2(jj,:);
% thrs_tps=thrs./cooldowns2(jj,:);
% dmgs_dpsplot=dmgs_plot./cooldowns2(jj,:);
% thrs_tpsplot=thrs_plot./cooldowns2(jj,:);
% 
% %plot
% figure(20)
% set(gcf,'Position',[360 228 600 300])
% bar20=bar(dmgplot,'BarWidth',0.5,'BarLayout','stacked');
% set(bar20(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.5 10.5])
% set(gca,'XTickLabel',names(kk))
% legend('Unglyphed','Glyphed','Location','NorthWest')
% xlabel('Ability')
% ylabel('Damage')
% 
% 
% figure(21)
% set(gcf,'Position',[360 228 600 300])
% bar21=bar(dpsplot,'BarWidth',0.5,'BarLayout','stacked');
% set(bar21(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.5 10.5])
% set(gca,'XTickLabel',names(kk))
% leg1=legend('Unglyphed','Glyphed');
% set(leg1,'Position',[0.5608 0.7344 0.1983 0.14])
% xlabel('Ability')
% ylabel('DPS')
% 
% 
% %for threat, we just multiply the dmg or dps variable by the threat
% %modifier
% figure(30)
% set(gcf,'Position',[360 228 600 300])
% bar30=bar(dmgplot.*threatmod(kk,:),'BarWidth',0.5,'BarLayout','stacked');
% set(bar30(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.5 10.5])
% set(gca,'XTickLabel',names(kk))
% legend('Unglyphed','Glyphed','Location','NorthWest')
% xlabel('Ability')
% ylabel('Threat')
% 
% 
% figure(31)
% set(gcf,'Position',[360 228 600 300])
% bar31=bar(dpsplot.*threatmod(kk,:),'BarWidth',0.5,'BarLayout','stacked');
% set(bar31(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.5 10.5])
% set(gca,'XTickLabel',names(kk))
% leg1=legend('Unglyphed','Glyphed','Location','NorthEast');
% % set(leg1,'Position',[0.5608 0.7344 0.1983 0.14])
% xlabel('Ability')
% ylabel('TPS')
% 
% 
% figure(40)
% set(gcf,'Position',[360 228 600 300])
% bar40=bar(dmgs_plot,'BarWidth',0.5,'BarLayout','stacked');
% set(bar40(2),'FaceColor',[0.749 0.749 0]);
% % xlim([0.5 10.5])
% set(gca,'XTickLabel',names(jj))
% legend('Unglyphed','Glyphed','Location','NorthEast')
% xlabel('Ability')
% ylabel('Damage (including SoV procs)')
% 
% figure(41)
% set(gcf,'Position',[360 228 600 300])
% bar41=bar(thrs_tpsplot,'BarWidth',0.5,'BarLayout','stacked');
% set(bar41(2),'FaceColor',[0.749 0.749 0]);
% % xlim([0.5 10.5])
% set(gca,'XTickLabel',names(jj))
% legend('Unglyphed','Glyphed','Location','NorthEast')
% xlabel('Ability')
% ylabel('TPS (including SoV procs)')
% 
% 
% %generate pretty tables
% pad11=repmat('      ',length(names),1);
% pad12=repmat(' ',length(names),1);
% header1=['Ability  Raw Dmg.  Net Dmg.   Glyphed   Net Threat   Glyphed'];
% pt_dmg=[char(names) pad11 char(int2str(dmgr(:,1))) pad11 char(int2str(dmg(:,1))) pad11 char(int2str(dmg(:,2))) pad11 char(int2str(round(dmg(:,1).*threatmod(:,1)))) pad11 char(int2str(round(dmg(:,2).*threatmod(:,1)))) pad12];
% pt_dmg=[pt_dmg repmat(' ',length(names),length(header1)-length(pt_dmg))];
% pt_dmg=[header1; pt_dmg];
% 
% pad21=repmat('     ',length(names),1);
% pad22=repmat('  ',length(names),1);
% header2=['Ability   DPS   Glyphed    TPS   Glyphed'];
% pt_dps=[char(names) pad21 char(int2str(dps(:,1))) pad21 char(int2str(dps(:,2))) pad21 char(int2str(round(dps(:,1).*threatmod(:,1)))) pad21 char(int2str(round(dps(:,2).*threatmod(:,1)))) pad22];
% pt_dps=[header2; pt_dps];
% 
% pad31=repmat('     ',length(names(jj)),1);
% header3=['Ability  Damage    Glyphed   TPS    Glyphed  '];
% pt_dmgs=[char(names(jj)) pad31 char(int2str(dmgs(:,1))) pad31 char(int2str(dmgs(:,2))) pad31 char(int2str(round(thrs_tps(:,1)))) pad31 char(int2str(round(thrs_tps(:,2))))];
% pad32=repmat(' ',length(names(jj)),length(header3)-size(pt_dmgs,2));
% pt_dmgs=[pt_dmgs pad32];
% pt_dmgs=[header3; pt_dmgs];
% 
% 
% 
% pt_dmg
% 
% pt_dps
% 
% pt_dmgs