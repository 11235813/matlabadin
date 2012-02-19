clear;
%load gear database
gear_db;
%load defaults database
def_db;

%Build simulation configuration
%"c" is the default config structure name.  For sims which require multiple
%configurations, we'll use c(1), c(2), etc.

%invoke player model
c.base=player_model('race','Human');  %possibly rename "char_model"

%invoke npc model
c.npc=npc_model(c.base);

%invoke execution_model
c.exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT','veng',1.0);

%activate buffs and consumables
c.buff=buff_model;

%invoke spec, talents & glyphs
c.spec=spec_model();
c.talent=talent_model();
c.glyph=glyph_model();

%load gear set
c.egs=ddb.gearset{1}; %1=pre-raid , 2=T14, 3=T14H, 4=T15, 5=T15H

%calculate relevant stats
%TODO: this could be built into stat_model
c.gear=gear_stats(c.egs);


%% Everything up to here works; stat_model under reconstruction
%calculate final stats
%in future, potentially package these somehow into one argument (maybe a "sim" or "player" structure)
c=stat_model(c); 


%% ability_model and rotation_model still need to be reworked
%calculate ability damages
ability_model(c);

%rotation 
rotation_model;
%dynamic_model;
disp('Success!')
disp(['Total dps for default 939 is ' num2str(rot(1).totdps,'%5.0f') ' DPS'])