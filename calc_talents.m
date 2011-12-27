%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

%% Setup tasks
clear;
gear_db;
def_db;
exec=execution_model('veng',1);
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{7};  %6=T13R, 7=T13N, 8=T13H
glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS
buff=buff_model;

%need to run these here so that the cfg structure can set hit and exp
gear_stats;
talents;
stat_model;
ability_model;
rotation_model;
% prio_model;


%% set up our tree configurations
%base - unpossible build, contains a ridiculous # of points
temptree.holy=[2 0 3 0; 0 0 0 0];
temptree.prot=[3 2 2 2; 2 3 2 0; 2 3 1 2; 1 1 1 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
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
name{k}='Reck (1st point)';

%Reck
k=k+1;
tree(k)=tree(1);
tree(k).prot(4,1)=2;
points(k)=tree(1).prot(4,1)-tree(k).prot(4,1);
name{k}='Reck (2nd point)';

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
name{k}='Grand Crusader (1st point)';

%Grand Crusader
k=k+1;
tree(k)=tree(1);
tree(k).prot(4,3)=2;
points(k)=tree(1).prot(4,3)-tree(k).prot(4,3);
name{k}='Grand Crusader (2nd point)';

%Sacred duty
k=k+1;
tree(k)=tree(1);
tree(k).prot(6,2)=0;
points(k)=tree(1).prot(6,2);
name{k}='Sacred Duty';

%Eternal Glory
k=k+1;
tree(k)=tree(1);
tree(k).prot(1,3)=0;
points(k)=tree(1).prot(1,3);
name{k}='Eternal Glory';

%% Configurations
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
c=1;
%low hit, W39
cfg(c).rot=2; %W39
cfg(c).rlabel='W39';
cfg(c).veng=1;
cfg(c).seal='SoI';
cfg(c).glyph=ddb.glyphset{2}; %WoG set

%low hit, 939
c=c+1;
cfg(c).helm=cfg(1).helm;
cfg(c).rot=1;
cfg(c).rlabel='939';
cfg(c).veng=1;
cfg(c).seal='SoT';
cfg(c).glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS

 
%hit-cap and exp soft-cap, 939
c=c+1;
cfg(c)=cfg(2);
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;

%repeat all three at 30% vengeance
c=c+1;cfg(c)=cfg(1);cfg(c).veng=0.3;
c=c+1;cfg(c)=cfg(2);cfg(c).veng=0.3;
c=c+1;cfg(c)=cfg(3);cfg(c).veng=0.3;

%% sim 
tabledps=zeros(length(tree),length(rot),2);
for c=1:length(cfg)
    
    wb=waitbar(0,['Calculating CFG # ' int2str(c) ' / ' int2str(length(cfg))]);
    tic
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
        stat_model;
        ability_model;
        rotation_model;
        tmprot.dps=rot(cfg(c).rot).totdps;
        tmprot.hps=rot(cfg(c).rot).tothps;
        dynamic_model
        
        %store items in cfg for plots
        cfg(c).hit=player.phhit;
        cfg(c).exp=player.exp;
        cfg(c).plabel=[cfg(c).rlabel ', ' cfg(c).seal ', ' int2str(cfg(c).hit) '% hit, ' int2str(cfg(c).exp) 'exp'];
        
        %store DPS
        totdps(m,c)=tmprot.dps+proc.dps;
        totdps0(m,c)=totdps(1,c);
        
        %store HPS
        tothps(m,c)=tmprot.hps+proc.hps;
        tothps0(m,c)=tothps(1,c);
        
        waitbar(m/length(tree),wb)

    end
    close(wb)
    toc
end



ct_temp=(totdps0-totdps)./repmat(points',1,size(totdps,2));
dpsppt=ct_temp;
%fix not needed anymore thanks to FSM accuracy
% dpsppt=max(ct_temp,zeros(size(ct_temp)));  %fix for anomalies caused by fitting (negative DPS when un-talenting SD)

ct_temp=(tothps0-tothps)./repmat(points',1,size(tothps,2));
hpsppt=ct_temp;

%% table output
spacer=repmat(' ',length(name)+1,3);

table_dps=[char({'Talent',name{:}}) spacer];
for c=1:length(cfg)
%     table_st=[table_st spacer char({['   ' cfg(c).label],num2str(dpsppt(:,c),'%2.1f')})];
    table_dps=[table_dps spacer char({[' ' cfg(c).rlabel],int2str(dpsppt(:,c))})];
end
table_dps


table_hps=[char({'Talent',name{:}}) spacer];
for c=1:length(cfg)
%     table_st=[table_st spacer char({['   ' cfg(c).label],num2str(dpsppt(:,c),'%2.1f')})];
    table_hps=[table_hps spacer char({[' ' cfg(c).rlabel],int2str(hpsppt(:,c))})];
end
table_hps


%% plots
dpsplot=[dpsppt(:,1:3)];

%Sort
sortby=2; %sort by cfg(1)
[dpspptsorted ind]=sort(dpsppt(:,sortby));
dpsplotsorted=dpsplot(ind,:);
dpsplotsorted=max(dpsplotsorted,zeros(size(dpsplotsorted)));

figure(31)
set(gcf,'Position',[428 128 728 378])
bar31=barh(dpsplotsorted(2:length(dpsppt),:),'BarWidth',1,'BarLayout','grouped');
set(bar31(2),'FaceColor',[0.749 0.749 0]);
set(bar31(3),'FaceColor',[0.5 0 0]);
ylim([0.5 k-0.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
legend({cfg.plabel},'Location','Best')
xlabel('DPS per point')
title([ num2str(cfg(sortby).veng*100,'%2.1f') '% Veng, legend contains rotation/seal/hit/expertise'])

%for talent spec guide
figure(32)
set(gcf,'Position',[428 128 728 378])
bar32=barh(dpspptsorted(2:length(dpspptsorted)),'BarWidth',0.5,'BarLayout','grouped');
ylim([0.5 k-0.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
xlabel('DPS per point')
title([ num2str(cfg(sortby).veng*100,'%2.1f') '% Veng, ' num2str(cfg(sortby).hit,'%2.1f') '% hit, ' ...
    num2str(cfg(sortby).exp,'%2.1f') ' expertise'])
