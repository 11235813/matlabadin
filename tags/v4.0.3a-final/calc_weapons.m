clear;
gear_db;
def_db;

exec=execution_model('veng',0.6);
base=player_model('race','Belf','prof','');
npc=npc_model(base);
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{2};  %0/31/10 w/HG
glyph=ddb.glyphset{1}; %all relevant glyphs
talents;
buff=buff_model;
stat_model;

%adjustments to make sure that nothing is capped
%set melee hit to 4%, expertise to 18, mastery to 390 (16.5 mastery);
%do this by altering helm stats
egs(1).hit=max([egs(1).hit 0])-(player.phhit-4).*cnv.hit_phhit;
egs(1).exp=max([egs(1).exp 0])-(player.exp-18).*cnv.exp_exp;
egs(1).mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
helm1=egs(1);

%repeat for 8% hit and exp soft-cap
egs(1).hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
egs(1).exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
egs(1).mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
helm2=egs(1);

weaplist1=[62457; %Ravening Slicer
           65173; %Thief''s Blade (Heroic)
           56346; %Elementium Fang (Heroic)
           67602; %Elementium Gutslicer
           56459; %Mace of Transformed Bone (Heroic)
           56364; %Axe of the Eclipse (Heroic)
           56430; %Sun Strike (Heroic)
           65171; %Cookie''s Tenderizer (Heroic)
           63533; %Fang of Twilight
           59347; %Mace of Acrid Death
           59521; %Soul Blade
           65094; %Fang of Twilight (Heroic)
           65036; %Mace of Acrid Death (Heroic)
           65103; %Soul Blade (Heroic)
          ];

weaplist2=[56433; %Blade of the Burning Sun (Heroic)
           55065; %Elementium Hammer
           56312; %Torturer''s Mercy (Heroic)
           57872; %Scepter of Power (Heroic)
           62459; %Shimmering Morningstar
           59463; %Maldo''s Sword Cane
           59459; %Andoros, Fist of the Dragon King
           63680; %Twilight''s Hammer
           65013; %Maldo''s Sword Cane (Heroic)
           65017; %Andoros, Fist of the Dragon King (Heroic)
           65090; %Twilight''s Hammer (Heroic)
          ];
      
          
weaplist3=[65166; %Buzz Saw (Heroic)
           56266; %Lightning Whelk Axe (Heroic)
           56396; %Hammer of Sparks (Heroic)
           56384; %Resonant Kris (Heroic)
           65164; %Cruel Barb (Heroic)
           56353; %Heavy Geode Mace (Heroic)
           55067; %Elementium Bonesplitter
           67605; %Forged Elementium Mindcrusher
           65170; %Smite''s Reaver (Heroic)
           59443; %Crul''korak, the Lightning''s Arc
           68161; %Krol Decapitator
           59333; %Lava Spine
           64885; %Scimitar of the Sirocco
           65024; %Crul''korak, the Lightning''s Arc (Heroic)
           65047; %Lava Spine (Heroic)
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
    
    %calculate DPS below caps
    egs(1)=helm1;
    gear_stats;  
    stat_model;
    ability_model;
    rotation_model;

    dps1(m,1)=[sum(rot.coeff.*pridmg)]+rot.padps;
    dps2(m,1)=[sum(rot2.coeff.*pridmg)]+rot2.padps;    
    
    
    %calculate DPS at caps
    egs(1)=helm2;
    gear_stats; 
    stat_model;
    ability_model;
    rotation_model;

    dps1(m,2)=[sum(rot.coeff.*pridmg)]+rot.padps;
    dps2(m,2)=[sum(rot2.coeff.*pridmg)]+rot2.padps;    
end

pinfo.name=char(pinfo.name);
pinfo.labels=[pinfo.name repmat(' ',length(pinfo.ilvl),2) int2str(pinfo.ilvl')];

%HotR table
dps=dps2;
'HotR table'
[pinfo.labels repmat(' ',length(dps),3) int2str(round(dps))]


dps=dps1;
'CS table'
[pinfo.labels repmat(' ',length(dps),3) int2str(round(dps))]

y1=1:M1;y2=M1+1+[1:M2];y3=max(y2)+1+[1:M3];
y=[y1 y2 y3];

dps1p=[dps1(:,1) diff(dps1')']./1000;

figure(70)
% set(gcf,'Position',[2200 12 724 936])
bar70=barh(y,dps1p,'BarWidth',0.5,'BarLayout','stacked');
set(bar70(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(dps1p(:,1)) 1.01.*max(sum(dps1p,2))])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS (thousands)')
title('All by ilvl & category - CS rotation')
legend('4% hit 18 exp','8% hit 26 exp','Location','Best')


[x71 k71]=sort(dps1p(1:M1,1));y71=y1(k71);
figure(71)
% set(gcf,'Position',[2240 88 724 579])
bar71=barh(dps1p(k71,:),'BarWidth',0.5,'BarLayout','stacked');
set(bar71(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(dps1p(k71,1)) 1.01.*max(sum(dps1p(k71,:),2))])
ylim(0.5+[0 max(y1)])
set(gca,'YTick',y1,'YTickLabel',pinfo.labels(k71,:))
xlabel('DPS (thousands)')
title('Tank weapons, sorted by DPS')
legend('4% hit 18 exp','8% hit 26 exp','Location','Best')

dps2p=[dps2(:,1) diff(dps2')'];

figure(72)
% set(gcf,'Position',[2200 12 724 936])
bar72=barh(y,dps2p,'BarWidth',0.5,'BarLayout','stacked');
set(bar72(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(min(dps2)) 1.01.*max(max(dps2))])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.labels)
xlabel('DPS (thousands)')
title('All by ilvl & category - HotR rotation')
legend('4% hit 18 exp','8% hit 26 exp','Location','Best')
