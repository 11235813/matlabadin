clear;
%load gear database
gear_db;

%invoke player model
player_model

%invoke npc model
npc=npc_model('lvl',83);

%invoke talents & glyphs
talents

%load gear set
gear_sample;

%calculate relevant stats
gear_stats
stats_recalc