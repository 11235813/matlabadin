%calc_enchant - used to calculate dps values of various enchants and buffs.
%current version is lacking a lot of features but it should provide correct
%results.

%% Setup Tasks
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
talent=ddb.talentset{4};  %0/33/8 w/o HG
glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS
talents;
stat_model;

%% Configurations
%W39 rotation, low-hit set
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(1).rot=3;   %W39

%939 rotation, low-hit set
cfg(2).helm=cfg(1).helm;
cfg(2).rot=2;

%repeat for 8% hit and exp soft-cap
cfg(3).helm=egs(1);
cfg(3).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(3).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(3).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(3).rot=2;   %9C9


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
    %set configuration variables
    egs(1)=cfg(c).helm;
    
    %clear food buff
    buff=buff_model('mode',0,'food',0);
    %clear weapon enchant
    egs(35)=equip(1,'s');

    %record baseline dps
    gear_stats
    stat_model
    ability_model
    rotation_model;
    dps0(c)=rot(cfg(c).rot).totdps;
    avo0(c)=player.avoid;

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
        
        %store avoidance
        avoe(m,c)=player.avoid-avo0(c);
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
        avof(m,c)=player.avoid-avo0(c);
    end

%% Dynamic enchants
    enchant_model
      
    %Landslide
    dpse(length(enchant)+1,c)=ls.dps;
    avoe(length(enchant)+1,c)=0;
    pinfo.ename{length(enchant)+1}='Landslide';
    
    %Avalanche
    dpse(length(enchant)+2,c)=av.dps;
    avoe(length(enchant)+2,c)=0;
    pinfo.ename{length(enchant)+2}='Avalanche';
    
    %Hurricane
    dpse(length(enchant)+3,c)=hu.dps;
    avoe(length(enchant)+3,c)=0;
    pinfo.ename{length(enchant)+3}='Hurricane';
    
    %Windwalk
    dpse(length(enchant)+4,c)=0;
    avoe(length(enchant)+4,c)=ww.dodge;
    pinfo.ename{length(enchant)+4}='Windwalk';

end

M1=size(dpse,1);
M2=size(dpsf,1);
% M=M1+M1;

%% Plotting 

%DPS sorting
dps1=[dpse;dpsf];
%set sorting index, config by which we're sorting
si=2; %1 for WoG, 2 for 939 low-hit, 3 for 939 capped

[temp temp2]=sort(dpse(:,si)); %sort enchants by dps
sorte=temp2((length(temp2)-length(find(sum(dpse,2)))+1):length(temp2)); %keep only nonzero entries

[temp temp2]=sort(dpsf(:,si)); %sort foods by dps
sortf=temp2((length(temp2)-length(find(sum(dpsf,2)))+1):length(temp2)); %keep only nonzero entries

sortall=[sorte;sortf+M1;]; %combine into one complete set of indices

%get names for the appropriate indices
pinfo.name=char([pinfo.ename pinfo.fname]);
pinfo.labels=[pinfo.name(sortall,:)];

%pretty-print table
[pinfo.labels repmat(' ',length(sortall),3) int2str(round(dps1(sortall,:)))]

%assemble plot parameters
dps1p=[dps1(sortall,:)];
y1=1:length(sorte);y2=length(sorte)+1+[1:length(sortf)];
y=[y1 y2];



%DPS plot
figure(80)
bar80=barh(y,dps1p,'BarWidth',1,'BarLayout','grouped');
set(bar80(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(min(dps1)) 1.01.*max(max(dps1))])
ylim(0.5+[length(find(sum(dps1p,2)==0)) max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS')
title('Food & Enchant analysis, sorted by capped DPS')
legend('W39, 2% hit 10 exp','939, 2% hit 10 exp','939, 8% hit 26 exp','Location','Best')


%Avoidance sorting, uses the same sorting index
avo1=[avoe;avof];
%sort by avoidance, keep only nonzero entries
[temp temp2]=sort(avoe(:,si));avsorte=temp2((length(temp2)-length(find(sum(avoe,2)))+1):length(temp2));
[temp temp2]=sort(avof(:,si));avsortf=temp2((length(temp2)-length(find(sum(avof,2)))+1):length(temp2));
%compile index list
avsortall=[avsorte;avsortf+M1;];
%get names
pinfo.avlabels=[pinfo.name(avsortall,:)];
%pretty-print table
[pinfo.avlabels repmat(' ',length(avsortall),3) num2str(avo1(avsortall,:),'%3.2f   %3.2f   %3.2f')]

%assemble plot parameters
avo1p=[avo1(avsortall,:)];
y1=1:length(avsorte);y2=length(avsorte)+1+(1:length(avsortf));
y=[y1 y2];

%Avoidance Plot
figure(81)
bar81=barh(y,avo1p,'BarWidth',1,'BarLayout','grouped');
set(bar81(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(min(avo1)) 1.01.*max(max(avo1))])
ylim(0.5+[length(find(sum(avo1p,2)==0)) max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.avlabels)
xlabel('Avoidance')
title('Food & Enchant analysis, sorted by 939 Avoidance')
legend('W39, 2% hit 10 exp','939, 2% hit 10 exp','939, 8% hit 26 exp','Location','Best')
