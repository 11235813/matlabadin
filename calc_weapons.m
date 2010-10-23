clear;
gear_db;
def_db;


base=player_model('lvl',80,'race','Belf','prof','');
npc=npc_model(base);
gear_sample
talent=ddb.talentset{3};  %0/31/5
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth');
buff=buff_model('mode',3);
%invoke talents & default glyphs
talents

gear_stats
stat_model

%adjustments to make sure that nothing is capped
%set melee hit to 4%, expertise to 18, mastery to 390 (16.5 mastery);
%do this by altering helm stats
egs(1).hit=max([egs(1).hit 0])-(player.phhit-4).*cnv.hit_phhit;
egs(1).exp=max([egs(1).exp 0])-(player.exp-18).*cnv.exp_exp;
egs(1).mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;

%calculate final stats
% ability_model
% rotation_model


weaplist1=[40345; %Broken Promise
          47810; %CG
          50290; %Falric
          50268; %Rimefang
          45110; %Titanguard
          45876; %Shiver          
          45442; %Sorthalis
          47967; %CG (H)
          48714; %Honor of the Fallen
          51010; %Facelifter
          50760; %Bonebreaker
          51795; %Troggbane
          47506; %Silverwing Defender 
          51869; %Facelifter (H)
          50179; %Last Word
          51937; %Bonebreaker (H)
          51947; %Troggbane (H)
          49997; %Mithrios
          50708; %Last Word (heroic)
          50738; %Mithrios (H)
          ];

weaplist2=[50771; %Frost Needle
           51932; %Frost Needle (H)
          ];
      
          
weaplist3=[49296; %Singed Viskag
          50191; %Nighttime
          47808; %The Lion's Maw
          47816; %The Grinder
          50303; %Black Icicle
          45947; %Serilas
          45463; %Vulmir
          49501; %Tempered Viskag
          47973; %The Grinder (H)
          47966; %Lion's Maw (H)
          47148; %Stormpike Cleaver
          51021; %Soulbreaker
          50787; %FGC
          50050; %Cudgel of Furious Justice
          50810; %Gutbuster
          47526; %Remorseless (H)
          47156; %STormpike Cleaver (H)
          51858; %Soulbreaker (H)
          51916; %FGC (H)
          51521; %Wrathful Slicer
          51893; %Gutbuster(H)
          50412; %BvB
          50012; %Havoc's Call 
          51522; %Wrathful Longblade
          50672; %BvB (H)   
          50737; %Havoc's Call (heroic)
          ];
weaplist=[weaplist1;weaplist2;weaplist3];
          
M=length(weaplist);  %total number of weapons
M1=length(weaplist1);M2=length(weaplist2);M3=length(weaplist3);



for m=1:M
    %equip the appropriate weapon
    egs(15)=equip(weaplist(m));
    %store useful info for plots
    pinfo.name{m}=egs(15).name;
    pinfo.ilvl(m)=egs(15).ilvl;
    %calculate DPS
    gear_stats    
    stat_model
    ability_model
    rotation_model;

    dps1(m)=rot.coeff'*pridmg+rot.padps;
    dps2(m)=rot2.coeff'*pridmg+rot2.padps;    
end


pinfo.name=char(pinfo.name);
pinfo.labels=[pinfo.name repmat(' ',length(pinfo.ilvl),2) int2str(pinfo.ilvl')];

%HotR table
dps=dps2;
'HotR table'
[pinfo.labels repmat(' ',length(dps),3) int2str(round(dps'))]


dps=dps1;
'CS table'
[pinfo.labels repmat(' ',length(dps),3) int2str(round(dps'))]

y1=1:M1;y2=M1+1+[1:M2];y3=max(y2)+1+[1:M3];
y=[y1 y2 y3];

figure(70)
set(gcf,'Position',[2240 88 724 860])
bar70=barh(y,dps,'BarWidth',0.5,'BarLayout','stacked');
xlim([0.99.*min(dps) 1.01.*max(dps)])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS')
title('All by ilvl & category - CS rotation')


[x71 k71]=sort(dps(1:M1));y71=y1(k71);
figure(71)
set(gcf,'Position',[2240 88 724 579])
bar71=barh(x71,'BarWidth',0.5,'BarLayout','stacked');
xlim([0.99.*min(x71) 1.01.*max(x71)])
ylim(0.5+[0 max(y1)])
set(gca,'YTick',y1,'YTickLabel',pinfo.labels(k71,:))
xlabel('DPS')
title('Tank weapons, sorted by DPS')

figure(72)
set(gcf,'Position',[2240 88 724 860])
bar72=barh(y,dps2,'BarWidth',0.5,'BarLayout','stacked');
xlim([0.99.*min(dps2) 1.01.*max(dps2)])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS')
title('All by ilvl & category - HotR rotation')
