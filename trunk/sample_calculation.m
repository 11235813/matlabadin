clear;
%load gear database
gear_db;

%invoke player model.  1=human, 2=dwarf, 3=draenei, 4=belf
base=player_model('race',1);

%invoke npc model
npc=npc_model('lvl',83);

%invoke talents & glyphs
talents

%load gear set
gear_sample;

%calculate relevant stats
gear_stats

%activate buffs
buff_model

%calculate final stats
stat_model

%calculate ability damages
ability_model

warning('Success!')