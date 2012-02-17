clear;
%load gear database
gear_db;
%load defaults database
def_db;

%invoke player model
base=player_model('race','Human');  %possibly rename "char_model"

%invoke npc model
npc=npc_model(base);

%invoke execution_model
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT','veng',1.0);

%activate buffs and consumables
buff=buff_model;

%invoke spec, talents & glyphs
spec=spec_model();
talent=talent_model();
glyph=glyph_model();

%load gear set
egs=ddb.gearset{4}; %1=pre-raid , 2=T11, 3=T11H, 4=T12, 5=T12H

% %calculate relevant stats
gear_stats;


%% Everything up to here works; stat_model under reconstruction
%calculate final stats
[mdf player target]=stat_model(base,npc,exec,buff,spec,talent,glyph,gear); %in future, potentially package these somehow into one argument (maybe a "sim" or "player" structure)


%% ability_model and rotation_model still need to be reworked
%calculate ability damages
ability_model;

%rotation 
rotation_model;
disp('Success!')
disp(['Total dps for default 939 is ' num2str(rot(1).totdps,'%5.0f') ' DPS'])