clear;
gear_db;def_db;

%player and dummy
base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base,'lvl',83);


%execution. seal : 1=truth, 2=righteousness, 3=insight, 4=justice.
exec=execution_model('npccount',3,'timein',0,'timeout',1,'seal',1);
buff=buff_model('mode',1);

%invoke talents & glyphs
talent=ddb.talentset{1}; 
talent.ret(1,2)=3; %3/3 crusade
talent.prot(3,1)=0; %Hallowed Ground
glyph.prime=[0 0 0 1 1 1 0]; %J/ShoR/SoT
glyph.prime=[0 0 1 0 1 1 0]; %HotR/ShoR/SoT
glyph.major=[0 0 0 0 0 0 0 0 0 0];

talents

%gear set
egs=ddb.gearset{2}; %naked with Dalaran Sword
gear_stats

%calculate final stats
stat_model


%% Insert appropriate character info

%Kierly
player.ap=522;
player.hsp=178;
gear.swing=1.4;
gear.avgdmg=(42+79)/2;

%rabs
% player.ap=3980;
% player.hsp=1216;
% gear.swing=1.6;
% gear.avgdmg=(296+551)/2;
% 
% %rabs Judgement only
% player.ap=3822;
% player.hsp=1168;

%recalculate wdmg and ndmg
player.wdamage=gear.avgdmg+player.ap./14.*gear.swing;
player.ndamage=gear.avgdmg+player.ap./14.*2.4;


%calculate ability output
ability_model

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
spacer=repmat(' ',size(raw_vals,1),2);
raw_summary=[char(dmg_labels) spacer int2str(raw_vals)];

%Kierly, 522 AP / 178 SP
data1=[713.5 257.4 372.5 3948.6 812.9 0 2209.6 27.2 16 7 119.2*5 92.6*10 28.2 977.4 66.5]';
%Kierly  522 AP / 978 SP
% data1=[695.7 250.7 901.7 4134.8 1226.4 0 2322.2 26.4 45.3 19.4 189.5*5 113.5*10 27.8 974.8 66.5]';
%Rabs  3980 AP / 1216 Sp
% data1=[5260.2 1852 2736.5 4692.4 1350.3 0 2984.8 207.2 134.2 0 851.2*5 213.2*10 203.6 1782.3 520.1]';
%Rabs J only   3822 / 1168
% data1=[0 0 2628.2 0 0 0 0 202.2 0 0 816.4*5 0 0 0 506.9]';
% data1=[0 0 2473.6 0 0 0 0 199.4 0 0 812.8*5 0 0 0 504.5]';
%[ShoR CS Jud AS HW HoW Exor SoT SoR SoJ Cens Cons HotR HaNova melee]
data2=[raw_summary spacer int2str(data1) spacer int2str(data1-raw_vals) spacer int2str(100.*(data1-raw_vals)./raw_vals)]
