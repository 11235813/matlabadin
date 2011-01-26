%calc_enchant - used to calculate dps values of various enchants and buffs.
%current version is lacking a lot of features but it should provide correct
%results.

clear;
gear_db;
def_db;
exec=execution_model('veng',0.6);
base=player_model('race','Belf','prof','');
npc=npc_model(base);
%invoke all buffs except food
buff=buff_model('mode',0,'food',0);
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
%clear main hand enchant slot
egs(35)=equip(1,'s');
gear_stats;
talent=ddb.talentset{1};  %0/31/10 w/o HG
glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS
talents;
stat_model;

%% Configurations
%In the future, this section will define "configurations," which will
%include fixing hit/expertise/mastery values and choosing rotation logic

%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(1).rot=7;   %W39

%939 rotation, low-hit set
cfg(2).helm=cfg(1).helm;
cfg(2).rot=1;

%repeat for 8% hit and exp soft-cap
cfg(3).helm=egs(1);
cfg(3).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(3).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(3).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(3).rot=1;   %9C9


%% List of passive effects to calculate


enchant=[55057; %Pyrium Weapon Chain
         59619; %Accuracy
         60621; %Greater Potency
         27972; %Potency
         38995; %Exceptional Agility
         41976; %Titanium Weapon Chain
         ];

food=[87584; %90 str
      87637; %90 exp
      87595; %90 hit
      62669; %90 agi
      87597; %90 crit
      62665; %90 haste
      87594; %90 mast
      ];

  
  
for c=1:3
%% Passive enchants and foods
    %clear food buff
    buff=buff_model('mode',0,'food',0);
    %clear weapon enchant
    egs(35)=equip(1,'s');

    %record baseline dps
    egs(1)=cfg(c).helm;
    gear_stats
    stat_model
    ability_model
    rotation_model;
    dps0(c)=rot(cfg(c).rot).totdps;

    %enchants
    
    %clear food buff
    buff=buff_model('mode',0,'food',0);
    
    for m=1:length(enchant)

        %enchant weapon
        egs(35)=equip(enchant(m),'s');
        %store useful info for plots
        pinfo.ename{m}=egs(35).name;
        
        %calculate DPS 
        gear_stats
        stat_model
        ability_model
        rotation_model;
        seq=rot;
        
        %store DPS
        dpse(m,c)=rot(cfg(c).rot).totdps-dps0(c);
    end

    %foods
    
    %clear weapon enchant
    egs(35)=equip(1,'s');

    for m=1:length(food)
        %apply food buff
        buff=buff_model('mode',0,'food',food(m));
        %store useful info for plots
        pinfo.fname{m}=buff.food.name;

        %calculate DPS
        gear_stats
        stat_model
        ability_model
        rotation_model;
        seq=rot;

        %store DPS
        dpsf(m,c)=rot(cfg(c).rot).totdps-dps0(c);
    end

%% Dynamic enchants
    enchant_model
      
    %Landslide
    dpse(length(enchant)+1,c)=ls.dps;
    pinfo.ename{length(enchant)+1}='Landslide';
    
    %Avalanche
    dpse(length(enchant)+2,c)=av.dps;
    pinfo.ename{length(enchant)+2}='Avalanche';
    
    %Hurricane
    dpse(length(enchant)+3,c)=hu.dps;
    pinfo.ename{length(enchant)+3}='Hurricane';
    

end

M1=size(dpse,1);
M2=size(dpsf,1);
% M=M1+M1;

%% Plotting 
dps1=[dpse;dpsf];
%sorting for plots
si=2; %1 for WoG, 2 for 939 low-hit, 3 for 939 capped
[temp sorte]=sort(dpse(:,si));
[temp sortf]=sort(dpsf(:,si));
sortall=[sorte;sortf+M1;];

pinfo.name=char([pinfo.ename pinfo.fname]);
pinfo.labels=[pinfo.name(sortall,:)];
[pinfo.labels repmat(' ',length(dps1),3) int2str(round(dps1(sortall,:)))]

y1=1:M1;y2=M1+1+[1:M2];
y=[y1 y2];

dps1p=[dps1(sortall,:)];

figure(80)
bar80=barh(y,dps1p,'BarWidth',1,'BarLayout','grouped');
set(bar80(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(min(dps1)) 1.01.*max(max(dps1))])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS')
title('Food & Enchant analysis, sorted by capped DPS')
legend('W39, 2% hit 10 exp','939, 2% hit 10 exp','939, 8% hit 26 exp','Location','Best')
