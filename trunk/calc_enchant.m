%calc_enchant - used to calculate dps values of various enchants and buffs.
%current version is lacking a lot of features but it should provide correct
%results.

%TODO
%instead of current static baseline, dynamic baseline
%pretty graphs

clear;
gear_db;
def_db;

%standard stuff
base=player_model('lvl',80,'race','Belf','prof','');
npc=npc_model(base);
gear_sample
talent=ddb.talentset{3};  %0/31/5
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth');
talents

%invoke all buffs except food
buff=buff_model('mode',0,'food',0);
%clear main hand enchant slot
egs(35)=equip(1,'s');

gear_stats
stat_model

%adjustments to make sure that nothing is capped
%set melee hit to 4%, expertise to 18, mastery to 390 (16.5 mastery);
%do this by altering helm stats
egs(1).hit=max([egs(1).hit 0])-(player.phhit-4).*cnv.hit_phhit;
egs(1).exp=max([egs(1).exp 0])-(player.exp-18).*cnv.exp_exp;
egs(1).mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
helm1=egs(1);

%record baseline dps
gear_stats
stat_model
ability_model
rotation_model;
dps10=rot.coeff'*pridmg+rot.padps;

%repeat for 8% hit and exp soft-cap
egs(1).hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
egs(1).exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
egs(1).mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
helm2=egs(1);

%record baseline dps
gear_stats
stat_model
ability_model
rotation_model;
dps20=rot.coeff'*pridmg+rot.padps;

enchant=[59619; %Accuracy
    60621; %Greater Potency
    27972; %Potency
    38995; %Exceptional Agility
    59621; %Berserking
    41976; %Titanium Weapon Chain
    ];

food=[43000; %40str
    42999; %40agi
    42994; %40exp
    42996; %40hit
    34766; %80ap
    43015; %fish feast
    34767; %46sp
    ];

list=[enchant;food];
          
M=length(list);  %all buffs and enchants
M1=length(enchant);M2=length(food);


for m=1:M
    
    %if enchant
    if m<=M1
        %enchant weapon
        egs(35)=equip(list(m),'s');
        %clear food buff
        buff=buff_model('mode',0,'food',0);
        %store useful info for plots
        pinfo.name{m}=egs(35).name;
        
	%otherwise it's food
    else
        %clear weapon enchant
        egs(35)=equip(1,'s');
        %apply food buff
        buff=buff_model('mode',0,'food',list(m));
        %store useful info for plots
        pinfo.name{m}=buff.food.name;
    end

    
    
    %calculate DPS below caps
    egs(1)=helm1;
    gear_stats    
    stat_model
    ability_model
    rotation_model;

    dps1(m,1)=rot.coeff'*pridmg+rot.padps-dps10;
        
    %calculate DPS at caps
    egs(1)=helm2;
    gear_stats    
    stat_model
    ability_model
    rotation_model;

    dps1(m,2)=rot.coeff'*pridmg+rot.padps-dps20;
end

%sorting for plots
[temp sorte]=sort(dps1(1:M1,2));
[temp sortf]=sort(dps1(M1+(1:M2),2));
sortall=[sorte;sortf+M1;];

pinfo.name=char(pinfo.name);
pinfo.labels=[pinfo.name(sortall,:)];
[pinfo.labels repmat(' ',length(dps1),3) int2str(round(dps1(sortall,:)))]

y1=1:M1;y2=M1+1+[1:M2];
y=[y1 y2];

dps1p=[dps1(sortall,:)];

figure(80)
bar80=barh(y,dps1p,'BarWidth',1.5,'BarLayout','grouped');
set(bar80(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(min(dps1)) 1.01.*max(max(dps1))])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS')
title('Food & Enchant analysis, sorted by capped DPS')
legend('4% hit 18 exp','8% hit 26 exp','Location','Best')
