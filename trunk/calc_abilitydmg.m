clear;
disp('------------- CALC_ABILITYDMG -------------')
%% Load Databases
%load gear database
gear_db;
%load defaults database
def_db;

%% Configurations
%just use default for most
cfg(1)=build_config('glyph',[0 0 0]);
%second one for multi-target
cfg(2)=build_config('glyph',[0 0 0],'npccount',4);

%% Veng loop
for v=ddb.v
    
    
    %% Calculate stats and ability damages
    for i=1:length(cfg)
        cfg(i).exec.veng=0;
        cfg(i)=stat_model(cfg(i));
        cfg(i)=ability_model(cfg(i));
    end
    
    %shorthand
    c=cfg(1);d=cfg(2);
    
    %% Pretty-Print table
    L=length(c.abil.val.label);
    ldat=2+[1:L];
    
    li=DataTable();
    li{1:2,1}={'Ability';' '};
    li{ldat,1}=c.abil.val.label;
    li{1:2,2}={'Raw';' '};
    li{ldat,2}=round(c.abil.val.raw);
    li{1:2,3}={'Dmg';' '};
    li{ldat,3}=round(c.abil.val.dmg);
    li{1:2,4}={'AoE';'(4T)'};
    li{ldat,4}=round(d.abil.val.aoe./3);
    li{1:2,5}={'Heal';' '};
    li{ldat,5}=round(c.abil.val.heal);
    
    % li.setColumnTextAlignment(2,'left')
    % % li.setColumnTextAlignment(3:6,'center')
    % li.setColumnFormat(3:4,'%6.0f')
    % li.setColumnFormat(5:6,'%2.1f')
    disp(['[code]---' int2str(round(c.player.VengAP./1000)) 'k Vengeance ---'])
    li.toText()
    disp('[/code]')
    
    %% close Veng loop
end
%% Plots - high veng only

%% Plot #1 - Raw damage for basic rotational abilities
set1=[find(strcmp('CS',c.abil.val.label)); find(strcmp('HotR',c.abil.val.label));...
    find(strcmp('HaNova',c.abil.val.label)); find(strcmp('J',c.abil.val.label)); ...
    find(strcmp('AS',c.abil.val.label)); find(strcmp('Cons',c.abil.val.label)); ...
    find(strcmp('HW',c.abil.val.label)); find(strcmp('HoW',c.abil.val.label)); ...
    find(strcmp('SotR',c.abil.val.label)); find(strcmp('Melee',c.abil.val.label));];

figure(11)
bar11=bar(round(c.abil.val.raw(set1)./1e3),'BarWidth',0.5,'BarLayout','stacked');
% set(bar20(2),'FaceColor',[0.749 0.749 0]);
xlim(0.5+[0 length(set1)])
% maxy=ceil(max(sum(dmgplot,2))/5000)*5000;
% ylim([0 maxy])
% set(gca,'YTick',[0:5000:maxy],'YTickLabel',[int2str([0:5:maxy/1000]') repmat('k',1+maxy/5000,1)])
set(gca,'XTick',1:length(set1),'XTickLabel',{c.abil.val.label{set1}})
% legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('Ability')
ylabel('Raw Damage (thousands)')
title([int2str(round(c.player.VengAP./1000)) 'k Vengeance'])

%% Plot 2 - Raw damage for L90 talents (Cons/HW/HoW for comparison)
set2=[find(strcmp('Cons',c.abil.val.label)); find(strcmp('HW',c.abil.val.label));find(strcmp('HoW',c.abil.val.label));  find(strcmp('HPr',c.abil.val.label)); find(strcmp('LH',c.abil.val.label)); find(strcmp('ES',c.abil.val.label));];
figure(12)
bar12=bar(round(c.abil.val.raw(set2)./1e3),'BarWidth',0.5,'BarLayout','stacked');
xlim(0.5+[0 length(set2)])
set(gca,'XTick',1:length(set2),'XTickLabel',{c.abil.val.label{set2}})
xlabel('Ability')
ylabel('Raw Damage (thousands)')
title([int2str(round(c.player.VengAP./1000)) 'k Vengeance'])

%% Plot 3 - Raw damage for seals/censure
set3=[find(strcmp('SoT',c.abil.val.label));find(strcmp('SoR',c.abil.val.label));find(strcmp('SoI',c.abil.val.label));find(strcmp('Censure',c.abil.val.label));];
figure(13)
bar13=bar(round(c.abil.val.raw(set3)./1e3),'BarWidth',0.5);
xlim(0.5+[0 length(set3)])
set(gca,'XTick',1:length(set3),'XTickLabel',{c.abil.val.label{set3}})
xlabel('Ability')
ylabel('Raw Damage or Healing (thousands)')
title([int2str(round(c.player.VengAP./1000)) 'k Vengeance'])

%% Plot 4 - Raw healing 
set4=[find(strcmp('WoG',c.abil.val.label));find(strcmp('EF',c.abil.val.label));find(strcmp('EF(HoT)',c.abil.val.label));find(strcmp('SS',c.abil.val.label));find(strcmp('LH',c.abil.val.label));];
figure(14)
bar14=bar(round(c.abil.val.raw(set4)./1e3),'BarWidth',0.5);
xlim(0.5+[0 length(set4)])
set(gca,'XTick',1:length(set4),'XTickLabel',{c.abil.val.label{set4}})
xlabel('Ability')
ylabel('Raw Healing (thousands)')
title([int2str(round(c.player.VengAP./1000)) 'k Vengeance'])