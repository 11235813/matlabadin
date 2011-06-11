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
talent=ddb.talentset{1}; %0/32/9, no HG
egs=ddb.gearset{4}; %3=T11H, 4=T12, 5=T12H
glyph=ddb.glyphset{6}; %No glyphs

%need to run these here so that the cfg structure can set hit and exp
gear_stats;
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
%redefine rotation queue so that we can make substitutions
queue.rot={'SotR>CS>AS>J>Cons>HW';      %#1 and #2 are the same as the
           'WoG>SotR>CS>AS>J>Cons>HW';  %defaults in [RM]
           'SotR>HotR>AS>J>Cons>HW';        %3&4 added for HotR subs
           'WoG>SotR>HotR>AS>J>Cons>HW'};
       
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats
%low hit, SotR talents, SoT
c=1;
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;

%low hit, W39/SoI
cfg(c).seal='SoI';
cfg(c).rot=2;
cfg(c).rlabel='W39';
%tsubs is substitutions for tables
cfg(c).tsubs={{'HotR',4}}; %format: ={{glyphname1,subsrot#},{gn2,sr#},...}
cfg(c).veng=1;

%low hit, 939/SoT
c=c+1;
cfg(c)=cfg(1);
cfg(c).seal='SoT';
cfg(c).rlabel='939';
cfg(c).rot=1;
cfg(c).tsubs={{'HotR',3}}; %format: ={{glyphname1,subsrot#},{gn2,sr#},...}

%hit-capped, 939/SoT
c=c+1;
cfg(c)=cfg(2);
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(c).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;

%low hit, W39/SoT
c=c+1;
cfg(c)=cfg(1); %import W39 from cfg 1
cfg(c).rlabel='W39';
cfg(c).seal='SoT';

%low-vengeance, low-hit, 939
c=c+1;
cfg(c)=cfg(2);
cfg(c).veng=0.3;

%% sim 
tabledps=zeros(length(gtree),length(rot),2);
for c=1:length(cfg);
    %set configuration variables
    exec=execution_model('seal',cfg(c).seal,'veng',cfg(c).veng);
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
               
        %store items in cfg for plots
        cfg(c).hit=player.phhit;
        cfg(c).exp=player.exp-mdf.glyphSoT;
        cfg(c).plabel=[cfg(c).rlabel ', ' cfg(c).seal ', ' int2str(cfg(c).hit) '% hit, ' int2str(cfg(c).exp) ' exp'];
        
        %store DPS
        totdps(m,:,c)=[rot.totdps];
        totdps0(m,:,c)=totdps(1,:,c);
        
    end
end
dpspgall=totdps0-totdps;



%% generate table data structure
for c=1:length(cfg)
    dpspg(:,c)=dpspgall(:,cfg(c).rot,c);

    %handle substitutions
    if ~isempty(cfg(c).tsubs)
        for mm=1:size(cfg(c).tsubs,2)
            subi=strmatch(cfg(c).tsubs{mm}(1),name);
            subr=cfg(c).tsubs{mm}{2};
            dpspg(subi,c)=dpspgall(subi,subr,c);
        end
    end
    
    tab.seal{c}=cfg(c).seal;
    tab.hitexp{c}=[int2str(cfg(c).hit) '%/' int2str(cfg(c).exp)];
    tab.veng{c}=[int2str(cfg(c).veng*100) '%'];
    tab.rot{c}=cfg(c).rlabel;
end



%% table output
%TODO: pick up here
spacer= repmat(' ',length(name)+4,3);

tabledps=[spacer char({'seal','rotation','hit/exp','Veng',char(name)})];
for icol=1:size(dpspg,2)
	tabledps=[tabledps spacer char({['  ' tab.seal{icol}],['  ' tab.rot{icol}], ...
        tab.hitexp{icol},[' ' tab.veng{icol}],num2str(dpspg(:,icol),'%2.1f')})];
end
tabledps



%% plots

dpspg_temp=dpspg;


%sorted
si=2; %939
[temp indd]=sort(dpspg_temp(:,si));
icols=[1 2 3 4];
dpspgplot=dpspg_temp(indd,icols);
    
N=size(dpspgplot,1);

figure(41)
bar41=barh(dpspgplot(2:N,:),'BarWidth',1,'BarLayout','grouped');
set(bar41(2),'FaceColor',[0.749 0.749 0]);
set(bar41(3),'FaceColor',[0.5 0 0]);
set(bar41(4),'FaceColor',[0.45 0.75 0.3]);
ylim([length(find(sum(dpspgplot,2)==0)) N]-0.5)
set(gca,'YTickLabel',name(indd(2:N)))
legend({cfg(icols).plabel},'Location','Best')
xlabel('DPS')
title('100% Veng, legend contains rotation/seal/hit/exp')
