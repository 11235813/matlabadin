clear;
%load gear database
gear_db;

%invoke player model
base=player_model;

%invoke npc model
npc=npc_model(base,'lvl',83);

%execution. seal : 1=truth, 2=righteousness, 3=insight, 4=justice.
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal',1);

%invoke talents & glyphs
talents

%load gear set
gear_sample;

%calculate relevant stats
gear_stats

%activate buffs and consumables
buff=buff_model;

%calculate final stats
stat_model

%calculate ability damages
ability_model

%rotation 
rotation_model

warning('Success!')