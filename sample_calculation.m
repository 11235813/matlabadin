clear;
%load gear database
gear_db;

%invoke player model
base=player_model('race','Human');

%invoke npc model
npc=npc_model(base,'lvl',83);

%invoke execution_model
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT');

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