clear;
%% Load Databases
%load gear database
gear_db;
%load defaults database
def_db;

%% Build simulation configuration
%"c" is the default config structure name.  For sims which require multiple
%configurations, we'll use c(1), c(2), etc.

%Note that this entire section can be replaced with c=build_config

%invoke player model
c.base=player_model;  %possibly rename "char_model"

%invoke npc model
c.npc=npc_model(c.base);

%invoke execution_model
c.exec=execution_model;
c.exec.queue='^WB>CS>J>AS>HW>Cons'
c.exec.seal='SoI';

%activate buffs and consumables
c.buff=buff_model;

%invoke spec, talents & glyphs
c.spec=spec_model();
c.talent=talent_model();
c.glyph=glyph_model();

%load gear set
c.egs=ddb.gearset{5}; %1=i450 , 2=i463, 3=T14LFR (483), 4=T14N (496), 5=T14H (509)

%calculate relevant stats
%TODO: this could be built into stat_model
c.gear=gear_stats(c.egs);


%% Everything up to here works; stat_model under reconstruction
%calculate final stats
%in future, potentially package these somehow into one argument (maybe a "sim" or "player" structure)
c=stat_model(c); 


%% ability_model and rotation_model still need to be reworked
%calculate ability damages
c=ability_model(c);

%rotation 
c=rotation_model(c);

disp('Success!')
disp(['Total DPS for ' c.exec.queue ' is ' num2str(c.rot.dps,'%5.0f') ' DPS at ' num2str(c.player.mehit,'%1.2f') '% hit and ' num2str(c.player.exp,'%1.2f') '% exp'])
disp(['Total HPG for ' c.exec.queue ' is ' num2str(c.rot.hpg,'%1.4f') '/s at ' num2str(c.player.mehit,'%1.2f') '% hit and ' num2str(c.player.exp,'%1.2f') '% exp'])