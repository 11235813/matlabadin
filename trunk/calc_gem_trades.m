%CALC_GEM_TRADES calculates the efficiency ratio of certain gem trades

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1); %should default to 1 for npccount/timein/timeout, 0 behind, Truth
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{7}; %3=T11H, 4=T12, 5=T12H, 6=T13R, 7=T13N, 8=T13H
gear_stats;
talent=ddb.talentset{1}; %0/32/9 w/HG
glyph=ddb.glyphset{3}; %SoT glyph only
talents;
buff=buff_model;
stat_model;
ability_model;

%% configs
k=1;
cfg(k).name='Puissant->Solid, no bonus';
cfg(k).mast=20;
cfg(k).parry=0;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Defender->Solid, no bonus';
cfg(k).mast=0;
cfg(k).parry=20;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Puissant->Solid, 45 STA bonus';
cfg(k).mast=20;
cfg(k).parry=0;
cfg(k).sta=30-45;

k=k+1;
cfg(k).name='Puissant->Solid, 45 STA bonus, EG';
cfg(k).mast=25;
cfg(k).parry=0;
cfg(k).sta=37-45;

k=k+1;
cfg(k).name='Puissant->Solid, 15 STA bonus';
cfg(k).mast=20;
cfg(k).parry=0;
cfg(k).sta=30-15;

k=k+1;
cfg(k).name='Puissant->Solid, 15 STA bonus, EG';
cfg(k).mast=25;
cfg(k).parry=0;
cfg(k).sta=37-15;

k=k+1;
cfg(k).name='Puissant->Solid, 10 Parry bonus';
cfg(k).mast=20;
cfg(k).parry=10;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Puissant->Solid, 10 Parry bonus, EG';
cfg(k).mast=25;
cfg(k).parry=10;
cfg(k).sta=37;

k=k+1;
cfg(k).name='Puissant->Solid, 30 Parry bonus';
cfg(k).mast=20;
cfg(k).parry=30;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Puissant->Solid, 30 Parry bonus, EG';
cfg(k).mast=25;
cfg(k).parry=30;
cfg(k).sta=37;

k=k+1;
cfg(k).name='Defender->Solid, 30 Parry bonus';
cfg(k).mast=0;
cfg(k).parry=50;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Defender->Solid, 30 Parry bonus, EG';
cfg(k).mast=0;
cfg(k).parry=55;
cfg(k).sta=37;

k=k+1;
cfg(k).name='Defender->Solid + Puissant->Solid, 30 Parry bonus';
cfg(k).mast=20;
cfg(k).parry=50;
cfg(k).sta=60;

k=k+1;
cfg(k).name='Defender->Solid + Puissant->Solid, 30 Parry bonus, EG';
cfg(k).mast=25;
cfg(k).parry=55;
cfg(k).sta=75;

k=k+1;
cfg(k).name='Defender->Solid, 20 Mastery bonus';
cfg(k).mast=20;
cfg(k).parry=20;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Defender->Solid, 20 Mastery bonus, EG';
cfg(k).mast=20;
cfg(k).parry=25;
cfg(k).sta=37;

k=k+1;
cfg(k).name='Puissant->Solid, 20 Parry bonus';
cfg(k).mast=20;
cfg(k).parry=20;
cfg(k).sta=30;

k=k+1;
cfg(k).name='Puissant->Solid, 20 Parry bonus, EG';
cfg(k).mast=25;
cfg(k).parry=20;
cfg(k).sta=37;



%% Calculate parry/mastery CTC ratio

extra.val.mas=0;
extra.val.dodge=0;
extra.val.parry=0;
stat_model
ctrack0=player.ctc;

extra.val.mas=-50;
extra.val.dodge=0;
extra.val.parry=0;
stat_model
ctrack=player.ctc;

extra.val.mas=0;
extra.val.dodge=-50;
extra.val.parry=0;
stat_model;
atrack(1)=player.ctc;

extra.val.mas=0;
extra.val.dodge=0;
extra.val.parry=-50;
stat_model;
atrack(2)=player.ctc;

avoid_to_mastery=(mean(ctrack0-atrack))/(ctrack0-ctrack);


%% Calculate efficiency ratios (stam gain)/(ctc cost in units of mastery)

for j=1:length(cfg)
   eratio(j,1)=cfg(j).sta./(cfg(j).mast+cfg(j).parry.*avoid_to_mastery);
end

%% Display
spacer=repmat(' ',length(cfg),5);
[char(cfg.name) spacer num2str(eratio,'%2.3f')]

%sorted
[esorted ind]=sort(eratio,1,'descend');
[char(cfg(ind).name) spacer num2str(esorted,'%2.3f')]

1/avoid_to_mastery