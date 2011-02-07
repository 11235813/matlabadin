%%CALC_GLYPHS calculates DPS output in a variety of different glyph
%%configurations to determine DPS per glyph

%% Setup tasks
clear;
gear_db;
def_db;
exec=execution_model('veng',1);
base=player_model('race','Human');
npc=npc_model(base);
buff=buff_model;
talent=ddb.talentset{4}; %0/33/8, no DG/HG/PoJ
egs=ddb.gearset{2};  %1=pre-raid , 2=raid

%need to run these here so that the cfg structure can set hit and exp
gear_stats;
glyph=ddb.glyphset{6}; %No glyphs
talents;
stat_model;
ability_model;
rotation_model;


%% set up our glyph configurations

%base - unpossible build, contains all relevant glyphs
tempglyph.prime=[1 1 1 1 1 1 1 1];
tempglyph.major=[0 1 0 0 1 0 0 1 0 0 1];

gtree(1)=tempglyph;
name{1}='Base';

%Crusader Strike
k=2;
gtree(k)=gtree(1);
gtree(k).prime(1)=0;
name{k}='CS';

%Hammer of the Righteous
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(3)=0;
name{k}='HotR';

%Judgement
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(4)=0;
name{k}='J';

%Seal of Truth
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(5)=0;
name{k}='SoT';

%Shield of the Righteous
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(6)=0;
name{k}='SotR';

%WoG
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(7)=0;
name{k}='WoG';

%SoI
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(8)=0;
name{k}='SoI';

%Cons
k=k+1;
gtree(k)=gtree(1);
gtree(k).major(2)=0;
name{k}='Cons';

%AS
k=k+1;
gtree(k)=gtree(1);
gtree(k).major(5)=0;
name{k}='AS';


%% Configurations
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
%low hit, SotR talents, SoT
c=1;
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(c).veng=1;
cfg(c).seal='Truth';
cfg(c).talent=ddb.talentset{1}; %0/31/10 w/o HG
cfg(c).tal='#1';
cfg(c).sea='SoT';
cfg(c).hitexp='2%/10';

%hit-capped, SotR talents, SoT
c=c+1;
cfg(c)=cfg(1);
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(c).hitexp='8%/26';

%low hit, WoG talents, SoI
c=c+1;
cfg(c)=cfg(1);
cfg(c).seal='Insight';
cfg(c).talent=ddb.talentset{2}; %0/31/10 WoG build
cfg(c).tal='#2';
cfg(c).sea='SoI';
cfg(c).hitexp='2%/10';

%low hit, WoG talents, Truth
c=c+1;
cfg(c)=cfg(1);
cfg(c).talent=ddb.talentset{2}; %0/31/10 WoG build
cfg(c).tal='#2';
cfg(c).hitexp='2%/10';

%low-vengeance, low-hit, 939
c=c+1;
cfg(c)=cfg(1);
cfg(c).veng=0.3;

%% sim 
tabledps=zeros(length(gtree),length(rot),2);
for c=1:length(cfg);
    %set configuration variables
    exec=execution_model('seal',cfg(c).seal,'veng',cfg(c).veng);
    talent=cfg(c).talent;
    glyph=ddb.glyphset{6}; %No glyphs, this is to fix the exp value in pretty-print
    egs(1)=cfg(c).helm;
    talents;gear_stats;
    
    for m=1:length(gtree) %everything

        clear glyph
        glyph=gtree(m);
        %invoke talents & glyphs
        talents;

        %calculate final stats
        stat_model;
        ability_model;
        rotation_model;
        
        totdps(m,:,c)=[rot.totdps];
        totdps0(m,:,c)=totdps(1,:,c);
        
        tottps(m,:,c)=[rot.tottps];
        tottps0(m,:,c)=tottps(1,:,c);


    end
end
dpspgall=totdps0-totdps;
tpspgall=tottps0-tottps;

%% generate table data structure

%relevant data indices for substitutions
h=strmatch('HotR',name);
w=strmatch('WoG',name);
i=strmatch('SoI',name);
s=strmatch('SotR',name);
t=strmatch('SoT',name);

%quick-reference for args: dpspg(glyph,column), dpspgall(glyph,rot,cfg)
%column 1, low hit, 939
icol=1;icfg=1;
tab.tal{icol}=cfg(icfg).tal;
tab.seal{icol}=cfg(icfg).sea;
tab.hitexp{icol}=cfg(icfg).hitexp;
tab.veng{icol}=[int2str(cfg(icfg).veng*100) '%'];
tab.rot{icol}='939(W)';
dpspg(:,icol)=dpspgall(:,1,icfg);
dpspg(h,icol)=dpspgall(h,3,icfg); %s/SC9/SH9 for HotR glyph
dpspg(w,icol)=dpspgall(w,7,icfg); %s/SC9/WC9 for WoG glyph
dpspg(i,icol)=dpspgall(i,7,icfg); %s/SC9/W39 for WoG glyph
tpspg(:,icol)=tpspgall(:,1,icfg);
tpspg(h,icol)=tpspgall(h,3,icfg); %s/SC9/SH9 for HotR glyph
tpspg(w,icol)=tpspgall(w,7,icfg); %s/SC9/WC9 for WoG glyph
tpspg(i,icol)=tpspgall(i,7,icfg); %s/SC9/W39 for WoG glyph

%column 2, hit-capped, 939
icol=icol+1;icfg=2;
tab.tal{icol}=cfg(icfg).tal;
tab.seal{icol}=cfg(icfg).sea;
tab.hitexp{icol}=cfg(icfg).hitexp;
tab.veng{icol}=[int2str(cfg(icfg).veng*100) '%'];
tab.rot{icol}='939(W)';
dpspg(:,icol)=dpspgall(:,1,icfg);
dpspg(h,icol)=dpspgall(h,3,icfg); %s/SC9/SH9 for HotR glyph, 
dpspg(w,icol)=dpspgall(w,7,icfg); %s/SC9/WC9 for WoG glyph
dpspg(i,icol)=dpspgall(i,7,icfg); %s/SC9/WC9 for WoG glyph
tpspg(:,icol)=tpspgall(:,1,icfg);
tpspg(h,icol)=tpspgall(h,3,icfg); %s/SC9/SH9 for HotR glyph, 
tpspg(w,icol)=tpspgall(w,7,icfg); %s/SC9/WC9 for WoG glyph
tpspg(i,icol)=tpspgall(i,7,icfg); %s/SC9/WC9 for WoG glyph

%column 3, low hit, W39
icol=icol+1;icfg=3;
tab.tal{icol}=cfg(icfg).tal;
tab.seal{icol}=cfg(icfg).sea;
tab.hitexp{icol}=cfg(icfg).hitexp;
tab.veng{icol}=[int2str(cfg(icfg).veng*100) '%'];
tab.rot{icol}='W39(S)';
dpspg(:,icol)=dpspgall(:,7,icfg);
dpspg(h,icol)=dpspgall(h,8,icfg); %s/WC9/WH9 for HotR glyph
dpspg(s,icol)=dpspgall(s,1,icfg); %s/WC9/SC9 for SotR glyph
tpspg(:,icol)=tpspgall(:,7,icfg);
tpspg(h,icol)=tpspgall(h,8,icfg); %s/WC9/WH9 for HotR glyph
tpspg(s,icol)=tpspgall(s,1,icfg); %s/WC9/SC9 for SotR glyph

%column 4, low hit, W39
icol=icol+1;icfg=4;
tab.tal{icol}=cfg(icfg).tal;
tab.seal{icol}=cfg(icfg).sea;
tab.hitexp{icol}=cfg(icfg).hitexp;
tab.veng{icol}=[int2str(cfg(icfg).veng*100) '%'];
tab.rot{icol}='W39(S)';
dpspg(:,icol)=dpspgall(:,7,icfg);
dpspg(h,icol)=dpspgall(h,8,icfg); %s/WC9/WH9 for HotR glyph
dpspg(s,icol)=dpspgall(s,1,icfg); %s/WC9/SC9 for SotR glyph
tpspg(:,icol)=tpspgall(:,7,icfg);
tpspg(h,icol)=tpspgall(h,8,icfg); %s/WC9/WH9 for HotR glyph
tpspg(s,icol)=tpspgall(s,1,icfg); %s/WC9/SC9 for SotR glyph

%Column 5, low hit, IHSH9
icol=icol+1;icfg=1;
tab.tal{icol}=cfg(icfg).tal;
tab.seal{icol}=cfg(icfg).sea;
tab.hitexp{icol}=cfg(icfg).hitexp;
tab.veng{icol}=[int2str(cfg(icfg).veng*100) '%'];
tab.rot{icol}='IHSH9';
dpspg(:,icol)=dpspgall(:,2,icfg); %IHSH9, no need to adjsut for HotR
tpspg(:,icol)=tpspgall(:,2,icfg); %IHSH9, no need to adjsut for HotR

%column 6, low veng, 939
icol=icol+1;icfg=5;
tab.tal{icol}=cfg(icfg).tal;
tab.seal{icol}=cfg(icfg).sea;
tab.hitexp{icol}=cfg(icfg).hitexp;
tab.veng{icol}=[int2str(cfg(icfg).veng*100) '%'];
tab.rot{icol}='939(W)';
dpspg(:,icol)=dpspgall(:,1,icfg);
dpspg(h,icol)=dpspgall(h,3,icfg); %s/SC9/SH9 for HotR glyph
dpspg(w,icol)=dpspgall(w,7,icfg); %s/SC9/WC9 for WoG glyph
tpspg(:,icol)=tpspgall(:,1,icfg);
tpspg(h,icol)=tpspgall(h,3,icfg); %s/SC9/SH9 for HotR glyph
tpspg(w,icol)=tpspgall(w,7,icfg); %s/SC9/WC9 for WoG glyph


%% table output
%TODO: pick up here
spacer= repmat(' ',length(name)+5,3);

tabledps=[spacer char({'talents','seal','rotation','hit/exp','Veng',char(name)})];
for icol=1:size(dpspg,2)
	tabledps=[tabledps spacer char({tab.tal{icol},tab.seal{icol},tab.rot{icol},tab.hitexp{icol},tab.veng{icol},num2str(dpspg(:,icol),'%2.1f')})];
end
tabledps

tabletps=[spacer char({'talents','seal','rotation','hit/exp','Veng',char(name)})];
for icol=1:size(dpspg,2)
	tabletps=[tabletps spacer char({tab.tal{icol},tab.seal{icol},tab.rot{icol},tab.hitexp{icol},tab.veng{icol},num2str(tpspg(:,icol),'%2.1f')})];
end
tabletps


%% plots

%sorted
[temp indd]=sort(dpspg(:,1));
icols=[1 3 5];
dpspgplot=dpspg(indd,icols);

[temp indt]=sort(tpspg(:,1));
tpspgplot=tpspg(indt,icols);


    
N=size(dpspgplot,1);
for ll=1:length(icols)
legi{ll}=[tab.tal{icols(ll)} '-' tab.seal{icols(ll)} '-' tab.rot{icols(ll)}];
end
leg=char(legi);

figure(41)
bar20=barh(dpspgplot(2:N,:),'BarWidth',1,'BarLayout','grouped');
set(bar20(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 9.5])
set(gca,'YTickLabel',name(indd(2:N)))
legend(leg,'Location','Best')
xlabel('DPS')
title('100% Veng, 2%/10 hit/exp, (talents)-(seal)-(rotation)')

figure(42)
bar20=barh(tpspgplot(2:N,:),'BarWidth',1,'BarLayout','grouped');
set(bar20(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 9.5])
set(gca,'YTickLabel',name(indt(2:N)))
legend(leg,'Location','Best')
xlabel('TPS')
title('100% Veng, 2%/10 hit/exp, (talents)-(seal)-(rotation)')
    