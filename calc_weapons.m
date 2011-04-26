%CALC_WEAPONS calculates the relative DPS output of different weapons

%% Setup tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1); 
base=player_model('race','Belf','prof','');
npc=npc_model(base);
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{1};  %placeholder, redefined in cfg
glyph=ddb.glyphset{1}; %placeholder, redefined in cfg
talents;
buff=buff_model;
stat_model;

%% List of weapons
weaplist1=[62457; %Ravening Slicer
           65173; %Thief''s Blade (Heroic)
           56346; %Elementium Fang (Heroic)
           67602; %Elementium Gutslicer
           56459; %Mace of Transformed Bone (Heroic)
           56364; %Axe of the Eclipse (Heroic)
           68740; %Darkheart Hacker
           56430; %Sun Strike (Heroic)
           65171; %Cookie''s Tenderizer (Heroic)
           69609; %Bloodlord's Protector
           63533; %Fang of Twilight
           59347; %Mace of Acrid Death
           59521; %Soul Blade
           65094; %Fang of Twilight (Heroic)
           65036; %Mace of Acrid Death (Heroic)
          ];

weaplist2=[56433; %Blade of the Burning Sun (Heroic)
           55065; %Elementium Hammer
           56312; %Torturer''s Mercy (Heroic)
           57872; %Scepter of Power (Heroic)
           62459; %Shimmering Morningstar
           69581; %Amani Scepter of Rites
           59463; %Maldo''s Sword Cane
           59459; %Andoros, Fist of the Dragon King
           63680; %Twilight''s Hammer
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
           65170; %Smite''s Reaver (Heroic)
           69575; %Mace of the Sacrificed
           69803; %Gurubashi Punisher
           69618; %Zulian Slasher
           69639; %Renataki's Soul Slicer
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


%% Configurations
%W39 rotation, low-hit set
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
c=1;
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(c).rot=2; %W39   
cfg(c).glyph=ddb.glyphset{2}; %WoG/SoI/HotR, AS/Cons
cfg(c).talent=ddb.talentset{1}; %0/32/9 no HG
cfg(c).seal='SoI';
cfg(c).label='W39/SoI build';

%W39 + SoI
c=c+1;
cfg(c)=cfg(c-1);
cfg(c).seal='SoT';
cfg(c).label='W39/SoT build';

%939 rotation, low-hit set
c=c+1;
cfg(c).helm=cfg(1).helm;
cfg(c).rot=1;
cfg(c).glyph=ddb.glyphset{1}; %SoT/SotR/HotR, AS/Cons
cfg(c).talent=ddb.talentset{1}; %0/32/9 no HG
cfg(c).seal='SoT';
cfg(c).label='939/SoT build';

%939 for 8% hit and exp soft-cap
c=c+1;
cfg(c)=cfg(c-1);
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(c).label='939/SoT build, hit/exp cap';

for m=1:M
    %equip the appropriate weapon
    egs(15)=equip(weaplist(m));
    
    %store useful info for plots
    pinfo.name{m}=egs(15).name;
    pinfo.ilvl(m)=egs(15).ilvl;


    for c=1:length(cfg)
        %calculate DPS below caps
        exec=execution_model('seal',cfg(c).seal,'veng',1);
        egs(1)=cfg(c).helm;
        glyph=cfg(c).glyph;
        talent=cfg(c).talent;
        talents;
        gear_stats;
        stat_model;
        ability_model;
        rotation_model;

%         wdps(m,c)=rot.totdps;
%         whps(m,c)=rot.tothps;
        wdps(m,c)=rot(cfg(c).rot).totdps;
        whps(m,c)=rot(cfg(c).rot).tothps;
%         wdps2(m,c)=rot(cfg(c).rot+3).totdps; %for 9H9 / hammer check
    end

end

pinfo.name=char(pinfo.name);
pinfo.labels=[pinfo.name repmat(' ',length(pinfo.ilvl),2) int2str(pinfo.ilvl')];

%HotR table
% dps=dps2;
% 'HotR table'
% [pinfo.labels repmat(' ',length(wdps2),3) int2str(round(wdps2(:,2:3)))]


% dps=dps1;
'CS table'
spacer3=repmat(' ',length(wdps),3);
spacer2=repmat(' ',length(wdps),2);
[pinfo.labels  spacer3 int2str(round(whps(:,1))) spacer2 int2str(round(wdps(:,1))) ...
               spacer2 int2str(round(whps(:,2))) spacer2 int2str(round(wdps(:,2:size(wdps,2))))]

i1=1:M1;
i2=M1+1:M2;
i3=M1+M2+[1:M3];

y1=1:M1;
y3=M1+1+[1:M3];
% y2=M1+1+[1:M2];
% y3=max(y2)+1+[1:M3];

y=[y1 y3];
i=[i1 i3];

dps1p=[wdps(i,3) diff(wdps(i,3:4)')']./1000;
pinfo.plotlabels=pinfo.labels(i,:);

figure(70)
% set(gcf,'Position',[2200 12 724 936])
bar70=barh(y,dps1p,'BarWidth',0.5,'BarLayout','stacked');
set(bar70(2),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(dps1p(:,1)) 1.01.*max(sum(dps1p,2))])
ylim(0.5+[0 max(y)])
set(gca,'YTick',y,'YTickLabel',pinfo.plotlabels)
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

% dps2p=[dps2(:,1) diff(dps2')'];
% 
% figure(72)
% % set(gcf,'Position',[2200 12 724 936])
% bar72=barh(y,dps2p,'BarWidth',0.5,'BarLayout','stacked');
% set(bar72(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.99.*min(min(dps2)) 1.01.*max(max(dps2))])
% ylim(0.5+[0 max(y)])
% set(gca,'YTick',y,'YTickLabel',pinfo.labels)
% xlabel('DPS (thousands)')
% title('All by ilvl & category - HotR rotation')
% legend('4% hit 18 exp','8% hit 26 exp','Location','Best')