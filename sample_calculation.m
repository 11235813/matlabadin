clear;
%load gear database
gear_db;
def_db;

%invoke player model
base=player_model('race','Human');

%invoke npc model
npc=npc_model(base);

%invoke execution_model
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT','veng',1.0);

%load gear set
egs=ddb.gearset{2}; %1=pre-raid , 2=raid

%calculate relevant stats
gear_stats;

%activate buffs and consumables
buff=buff_model;

%invoke talents & glyphs
talent=ddb.talentset{2};
glyph=ddb.glyphset{1};
talents;

%calculate final stats
stat_model;

%calculate ability damages
ability_model;

%rotation 
rotation_model;

warning('Success!')