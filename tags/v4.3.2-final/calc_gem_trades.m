%CALC_GEM_TRADES calculates the efficiency ratio of certain gem trades

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1); %should default to 1 for npccount/timein/timeout, 0 behind, Truth
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{8}; %3=T11H, 4=T12, 5=T12H, 6=T13R, 7=T13N, 8=T13H
gear_stats;
talent=ddb.talentset{1}; %0/32/9 w/HG
glyph=ddb.glyphset{3}; %SoT glyph only
talents;
buff=buff_model;
stat_model;
ability_model;

%% configs
%no bonus
k=1;
cfg(k).name='Defender->Solid';
cfg(k).gem='Def->Sol';
cfg(k).bonus='';
cfg(k).mast=[0 0];
cfg(k).parry=[20 25];
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Puissant->Solid';
cfg(k).gem='Pui->Sol';
cfg(k).bonus='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0];
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fine->Defender';
cfg(k).gem='Fin->Def';
cfg(k).bonus='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0];
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fine->Solid';
cfg(k).gem='Fin->Sol';
cfg(k).bonus='';
cfg(k).mast=[20 25];
cfg(k).parry=[20 25];
cfg(k).sta=[60 75];

k=k+1;
cfg(k).name='Fractured->Puissant';
cfg(k).gem='Fra->Pui';
cfg(k).bonus='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0];
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fractured->Solid';
cfg(k).gem='Fra->Sol';
cfg(k).bonus='';
cfg(k).mast=[40 50];
cfg(k).parry=[0 0];
cfg(k).sta=[60 75];

%45 sta bonus (helm, yellow socket)
k=k+1;
cfg(k).name='Puissant->Solid, 45 STA bonus';
cfg(k).gem='Pui->Sol';
cfg(k).bonus='45 STA';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0];
cfg(k).sta=[30 37]-45;

k=k+1;
cfg(k).name='Fractured->Solid, 45 STA bonus';
cfg(k).gem='Fra->Sol';
cfg(k).bonus='45 STA';
cfg(k).mast=[40 50];
cfg(k).parry=[0 0];
cfg(k).sta=[60 75]-45;

%15 STA bonus (wrist, yellow socket)
k=k+1;
cfg(k).name='Puissant->Solid, 15 STA bonus';
cfg(k).gem='Pui->Sol';
cfg(k).bonus='15 STA';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0];
cfg(k).sta=[30 37]-15;

k=k+1;
cfg(k).name='Fractured->Solid, 15 STA bonus';
cfg(k).gem='Fra->Sol';
cfg(k).bonus='15 STA';
cfg(k).mast=[40 50];
cfg(k).parry=[0 0];
cfg(k).sta=[60 75]-15;

%20 mastery bonus (red)
k=k+1;
cfg(k).name='Defender->Solid, 20 Mastery bonus';
cfg(k).gem='Def->Sol';
cfg(k).bonus='20 Mast';
cfg(k).epic='';
cfg(k).mast=[0 0]+20;
cfg(k).parry=[20 25];
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fine->Defender, 20 Mastery bonus';
cfg(k).gem='Fin->Def';
cfg(k).bonus='20 Mast';
cfg(k).epic='';
cfg(k).mast=[20 25]+20;
cfg(k).parry=[0 0];
cfg(k).sta=[30 37];

%10 parry bonus (yellow)
k=k+1;
cfg(k).name='Puissant->Solid, 10 Parry bonus';
cfg(k).gem='Pui->Sol';
cfg(k).bonus='10 Parry';
cfg(k).epic='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0]+10;
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fractured->Solid, 10 Parry bonus';
cfg(k).gem='Fra->Sol';
cfg(k).bonus='10 Parry';
cfg(k).epic='';
cfg(k).mast=[40 50];
cfg(k).parry=[0 0]+10;
cfg(k).sta=[60 75];

%20 parry bonus (red)
k=k+1;
cfg(k).name='Puissant->Solid, 20 Parry bonus';
cfg(k).gem='Pui->Sol';
cfg(k).bonus='20 Parry';
cfg(k).epic='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0]+20;
cfg(k).sta=[30 37];

%30 parry bonus (chest, legs, RYB)
k=k+1;
cfg(k).name='Puissant->Solid, 30 Parry bonus';
cfg(k).gem='Pui->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0]+30;
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Defender->Solid, 30 Parry bonus';
cfg(k).gem='Def->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[0 0];
cfg(k).parry=[20 25]+30;
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fine->Defender, 30 parry bonus';
cfg(k).gem='Fin->Def';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[20 25];
cfg(k).parry=[0 0]+30;
cfg(k).sta=[30 37];

k=k+1;
cfg(k).name='Fine->Solid, 30 parry bonus';
cfg(k).gem='Fin->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[20 25];
cfg(k).parry=[20 25]+30;
cfg(k).sta=[60 75];

k=k+1;
cfg(k).name='Fractured->Solid, 30 Parry bonus';
cfg(k).gem='Fra->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[40 50];
cfg(k).parry=[0 0]+30;
cfg(k).sta=[60 75];

%two-gem swaps, 30 parry only (RYB)
k=k+1;
cfg(k).name='Defender->Solid + Puissant->Solid, 30 Parry bonus';
cfg(k).gem='Def->Sol + Pui->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[20 25];
cfg(k).parry=[20 25]+30;
cfg(k).sta=[60 75];

k=k+1;
cfg(k).name='Defender->Solid + Fractured->Solid, 30 Parry bonus';
cfg(k).gem='Def->Sol + Fra->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[40 50];
cfg(k).parry=[20 25]+30;
cfg(k).sta=[30+60 37+75];

k=k+1;
cfg(k).name='Fine->Solid + Puissant->Solid, 30 parry bonus';
cfg(k).gem='Fin->Sol + Pui->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[20+20 25+25];
cfg(k).parry=[20 25]+30;
cfg(k).sta=[30+60 37+75];

k=k+1;
cfg(k).name='Fine->Solid + Fractured->Solid, 30 parry bonus';
cfg(k).gem='Fin->Sol + Fra->Sol';
cfg(k).bonus='30 Parry';
cfg(k).epic='';
cfg(k).mast=[20+40 25+50];
cfg(k).parry=[20 25]+30;
cfg(k).sta=[60+60 75+75];

%enchants
k=k+1;
cfg(k).name='50 Dodge->40 Stamina bracer enchant';
cfg(k).gem='50 Dodge->40 STA';
cfg(k).bonus='(bracer ench)';
cfg(k).epic='';
cfg(k).mast=[0 0];
cfg(k).parry=[50 0];
cfg(k).sta=[40 0];

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

a2m=(mean(ctrack0-atrack))/(ctrack0-ctrack);
a2m_warr=a2m.*2.25./1.5;

%% Calculate efficiency ratios (stam gain)/(ctc cost in units of mastery)

for j=1:length(cfg)
   eratio(j,:)=cfg(j).sta./(cfg(j).mast+cfg(j).parry.*a2m);
   eratio_warr(j,:)=cfg(j).sta./(cfg(j).mast+cfg(j).parry.*a2m_warr);
end
%% Display
spacer=repmat(' ',length(cfg),4);
% [char(cfg.name) spacer num2str(eratio,'%2.3f')];

%sorted
[temp ind]=sort(eratio(:,1),1,'descend');
esorted=eratio(ind,:);
esorted_warr=eratio_warr(ind,:);
% [char(cfg(ind).name) spacer num2str(esorted(:,1),'%2.3f') spacer num2str(esorted(:,2),'%2.3f')];


%sorted 4-column 
col1=char({'Gem trade',cfg(ind).gem});
col2=char({'Socket Bonus',cfg(ind).bonus});
col3=char({' Blue',num2str(esorted(:,1),'%2.3f')});
col4=char({' Epic',num2str(esorted(:,2),'%2.3f')});
col5=char({' Blue',num2str(esorted_warr(:,1),'%2.3f')});
col6=char({' Epic',num2str(esorted_warr(:,2),'%2.3f')});
spacer2=repmat(' ',size(col1,1),4);

%strip out NaN and 0 entries
for j=1:size(col4,1)
    col4(j,:)=regexprep(col4(j,:),'0.000','     ');
    col4(j,:)=regexprep(col4(j,:),'NaN','   ');
    col6(j,:)=regexprep(col6(j,:),'0.000','     ');
    col6(j,:)=regexprep(col6(j,:),'NaN','   ');
end

[col1 spacer2 col2 spacer2 col3 spacer2 col4 spacer2 col5 spacer2 col6]

1./[a2m a2m_warr]