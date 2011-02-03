%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

%% Setup tasks
clear;
gear_db;
def_db;
exec=execution_model('veng',1);
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{2}; %1=pre-raid , 2=raid
glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS
buff=buff_model;

%need to run these here so that the cfg structure can set hit and exp
gear_stats;
talents;
stat_model;
ability_model;
rotation_model;


%% set up our tree configurations
%base - unpossible build, contains a ridiculous # of points
temptree.holy=[2 0 3 0; 0 0 0 0];
temptree.prot=[3 2 2 2; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 3 0 2];
tree(1)=temptree;
points(1)=1;
name{1}='Base';

%SotP
k=2;
tree(k)=tree(1);
tree(k).prot(1,2)=0;
points(k)=tree(1).prot(1,2);
name{k}='SotP';

%Hallowed Ground
k=k+1;
tree(k)=tree(1);
tree(k).prot(3,1)=0;
points(k)=tree(1).prot(3,1);
name{k}='Hallowed Ground';

%WotL
k=k+1;
tree(k)=tree(1);
tree(k).prot(3,4)=0;
points(k)=tree(1).prot(3,4);
name{k}='WotL';

%Reck
k=k+1;
tree(k)=tree(1);
tree(k).prot(4,1)=0;
points(k)=tree(1).prot(4,1);
name{k}='Reck';

%Arbiter of the Light
k=k+1;
tree(k)=tree(1);
tree(k).holy(1,1)=0;
points(k)=tree(1).holy(1,1);
name{k}='Arbiter of the Light';

%JotP
k=k+1;
tree(k)=tree(1);
tree(k).holy(1,3)=0;
points(k)=tree(1).holy(1,3);
name{k}='JotP';

%Crusade
k=k+1;
tree(k)=tree(1);
tree(k).ret(1,2)=0;
points(k)=tree(1).ret(1,2);
name{k}='Crusade';

%RoL
k=k+1;
tree(k)=tree(1);
tree(k).ret(2,2)=0;
points(k)=tree(1).ret(2,2);
name{k}='RoL';

%Grand Crusader
k=k+1;
tree(k)=tree(1);
tree(k).prot(4,3)=0;
points(k)=tree(1).prot(4,3);
name{k}='Grand Crusader';

%Sacred duty
k=k+1;
tree(k)=tree(1);
tree(k).prot(6,2)=0;
points(k)=tree(1).prot(6,2);
name{k}='Sacred Duty';

%% Configurations
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(1).label='939/SoT';
cfg(1).veng=1;
cfg(1).seal='Truth';
cfg(1).rot=1;
cfg(1).glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS

%low hit, W39
cfg(2).helm=cfg(1).helm;
cfg(2).label='W39/SoI';
cfg(2).veng=1;
cfg(2).seal='Insight';
cfg(2).rot=7; %W39
cfg(2).glyph=ddb.glyphset{2}; %WoG set

%low hit, IHSH
cfg(3)=cfg(1);
cfg(3).label='IHSH/SoT';
cfg(3).rot=2;

%hit-cap and exp soft-cap, 939
cfg(4)=cfg(2);
cfg(4).label='939/SoT';
cfg(4).helm=egs(1);
cfg(4).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(4).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(4).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;

%% sim 
tabledps=zeros(length(tree),length(rot),2);
for c=1:length(cfg)
    
    for m=1:length(tree) %each talent
        %configuration variables
        exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
        egs(1)=cfg(c).helm;
        glyph=cfg(c).glyph;


        clear talent
        talent=tree(m);
        %invoke talents & glyphs
        talents;
        %calculate relevant stats
        gear_stats;

        %calculate final stats
        exec.npccount=1; %to reset from AoE
        stat_model;
        ability_model;
        rotation_model;
        
        %store items in cfg for plots
        cfg(c).hit=player.phhit;
        cfg(c).exp=player.exp;
        
        totdps(m,c)=rot(cfg(c).rot).totdps;
        totdps0(m,c)=totdps(1,c);

        %calculate aoe stats
        exec.npccount=4; 
        stat_model;
        ability_model;
        rotation_model;
        totdpsa(m,c)=rot(6).totdps;
        totdpsa0(m,c)=totdpsa(1,c);

    end
end


dpsppt=(totdps0-totdps)./repmat(points',1,size(totdps,2));
% dpsppt1=(totdps1(1)-totdps1')./points';
dpsppta=(totdpsa0-totdpsa)./repmat(points',1,size(totdpsa,2));

%% table output
spacer=repmat(' ',length(name),5);
table_st=char(name);
for c=1:length(cfg)
    table_st=[table_st spacer num2str(dpsppt(:,c),'%2.1f')];
end
table_st

table_aoe=char(name);
for c=2:length(cfg)
    table_aoe=[table_aoe spacer num2str(dpsppta(:,c),'%2.1f')];
end
table_aoe


%% plots
dpsplot=[dpsppt(:,1:3)];
aoeplot=[dpsppta(:,1:2)];

% figure(30)
% set(gcf,'Position',[428 128 728 378])
% bar30=barh(dpsplot(2:length(dpsplot),:),'BarWidth',1,'BarLayout','grouped');
% set(bar30(2),'FaceColor',[0.749 0.749 0]);
% ylim([0.5 10.5])
% set(gca,'YTickLabel',name(2:length(name)))
% legend('SCSC','IHSH','IHIH (AoE)','Location','Best')
% xlabel('DPS per point')
% title([ num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'])

%Sort
sortby=1; %sort by cfg(1)
[dpspptsorted ind]=sort(dpsppt(:,sortby));
dpsplotsorted=dpsplot(ind,:);

[aoesorted inda]=sort(dpsppta(:,sortby));
aoeplotsorted=aoeplot(inda,:);

figure(31)
set(gcf,'Position',[428 128 728 378])
bar31=barh(dpsplotsorted(2:length(dpsppt),:),'BarWidth',1,'BarLayout','grouped');
set(bar31(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
legend({cfg.label},'Location','Best')
xlabel('DPS per point')
title([ num2str(cfg(sortby).veng*100,'%2.1f') '% Veng, ' num2str(cfg(sortby).hit,'%2.1f') '% hit, ' num2str(cfg(sortby).exp,'%2.1f') ' expertise'])

%for talent spec guide
figure(32)
set(gcf,'Position',[428 128 728 378])
bar32=barh(dpspptsorted(2:length(dpspptsorted)),'BarWidth',0.5,'BarLayout','grouped');
% bar32=barh(dpsplotsorted(2:length(dpspptsorted),1:2),'BarWidth',1,'BarLayout','grouped');
% set(bar32(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
% legend({cfg.label},'Location','Best')
xlabel('DPS per point')
title([ num2str(cfg(sortby).veng*100,'%2.1f') '% Veng, ' num2str(cfg(sortby).hit,'%2.1f') '% hit, ' ...
    num2str(cfg(sortby).exp,'%2.1f') ' expertise'])

%aoe figure
figure(33)
set(gcf,'Position',[428 128 728 378])
bar33=barh(aoeplotsorted(2:length(dpsppt),:),'BarWidth',1,'BarLayout','grouped');
set(bar33(2),'FaceColor',[0.749 0.749 0]);
% set(bar33(2),'FaceColor',[ 0.078 0.169 0.549]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(inda(2:length(name))))
legend('IHSH/SoT','IHSH/SoI','Location','Best')
xlabel('DPS per point')
title(['4 targets, ' num2str(cfg(sortby).veng*100,'%2.1f') '% Veng, ' num2str(cfg(sortby).hit,'%2.1f') '% hit, ' num2str(cfg(sortby).exp,'%2.1f') ' expertise'])
