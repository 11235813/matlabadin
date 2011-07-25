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
egs=ddb.gearset{4}; %1=pre-raid , 2=T11, 3=T11H, 4=T12, 5=T12H

%calculate relevant stats
gear_stats;

%uncomment this to enable/disable tier bonuses
% t11_prot_2pc=0;
% t12_prot_2pc=1;
% t12_ret_2pc=1;
% gear.tierbonusP=[t11_prot_2pc t12_prot_2pc 0;0 0 0]; 
% gear.tierbonusR=[0 t12_ret_2pc 0;0 0 0];

%activate buffs and consumables
buff=buff_model;
% buff=buff_model('mode',0,'item','bok');
% buff=buff_model('mode',0,'item','UnRage');

%invoke talents & glyphs
talent=ddb.talentset{1};
glyph=ddb.glyphset{4};
talents;

%calculate final stats
stat_model;

%calculate ability damages
ability_model;

%rotation 
rotation_model;
disp('Success!')
disp(['Total dps for default 939 is ' num2str(rot(1).totdps,'%5.0f') ' DPS'])