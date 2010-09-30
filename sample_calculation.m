clear;
%load gear database
gear_db;
def_db;

%invoke player model
base=player_model('race','Human');

%invoke npc model
npc=npc_model(base);

%invoke execution_model
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT');


%load gear set
gear_sample;

%calculate relevant stats
gear_stats

%activate buffs and consumables
buff=buff_model;

%invoke talents & glyphs
talents

%calculate final stats
stat_model

%calculate ability damages
ability_model

%rotation 
rotation_model

warning('Success!')