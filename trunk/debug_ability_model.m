clear;
gear_db;
%invoke player model. race : 1=human, 2=dwarf, 3=draenei, 4=belf, 5=tauren.
base=player_model('race',1);
%invoke npc model
npc=npc_model(base,'lvl',82);
%execution. seal : 1=truth, 2=righteousness, 3=insight, 4=justice.
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal',1);
%invoke talents & glyphs
talents
talent.RuleofLaw=0;
%load gear set
gear_sample;
%calculate relevant stats
gear_stats
%activate buffs
buff=buff_model('mode',1);
%calculate final stats
stat_model


%% Insert appropriate character info
player.ap=3562;
player.hsp=992;
gear.swing=1.7;
player.wdamage=(677+877)/2;


%calculate ability damages - uncomment appropriate level model
ability_model_80
% ability_model

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

spacer=repmat(' ',size(raw_vals,1),2);
raw_summary=[char(dmg_labels) spacer int2str(raw_vals)];
dmg_summary=[char(dmg_labels) spacer int2str(dmg_vals)];
thr_summary=[char(dmg_labels) spacer int2str(dmg_vals.*mdf.threat)];
all_summary=[char(dmg_labels) spacer int2str(raw_vals) spacer int2str(dmg_vals) spacer int2str(dmg_vals.*mdf.threat)]
