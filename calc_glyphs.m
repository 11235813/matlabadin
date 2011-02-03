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
talent=ddb.talentset{1}; %0/31/10, no HG
egs=ddb.gearset{2};  %1=pre-raid , 2=raid

%need to run these here so that the cfg structure can set hit and exp
gear_stats;
glyph=ddb.glyphset{2}; %No glyphs
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
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(1).veng=1;

%repeat for 8% hit and exp soft-cap
cfg(2).helm=egs(1);
cfg(2).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(2).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(2).helm.mast=max([egs(1).mast 0])-(player.mast-16.5).*cnv.mast_mast;
cfg(2).veng=1;


%% sim 
tabledps=zeros(length(gtree),length(rot),2);
for c=1:length(cfg);
    %set configuration variables
    exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth','veng',cfg(c).veng);
    egs(1)=cfg(c).helm;
    gear_stats
    
    
    for m=1:length(gtree) %everything


        clear glyph
        glyph=gtree(m);
        %invoke talents & glyphs
        talents;

        %calculate final stats
        stat_model;
        ability_model;
        rotation_model;
        
        totdps(m,:)=[rot.totdps];
        tabledps(m,:,1)=totdps(m,:);
        tabledps(m,:,2)=totdps(1,:);


    end

    dpspgall=diff(tabledps,1,3);
    
    dpspg9=dpspgall(:,1);dpspg9(strmatch('HotR',name))=dpspgall(strmatch('HotR',name),3);
    dpspgi=dpspgall(:,2);
    dpspgw=dpspgall(:,7);dpspgw(strmatch('HotR',name))=dpspgall(strmatch('HotR',name),3);

    %% table output
    spacer= repmat(' ',length(name),5);    
    tmpvar.header=[ num2str(exec.veng*100,'%2.1f') '% Veng, ' num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'];
    tmpvar.data=[char(name) spacer num2str(dpspg9,'%2.1f') spacer num2str(dpspgi,'%2.1f') spacer num2str(dpspgw,'%2.1f')];
    spacer2=repmat(' ',size(tmpvar.data,1),length(tmpvar.header)-length(tmpvar.data));
    tmpvar.output=[tmpvar.header;[tmpvar.data spacer2]];
    tmpvar.output


    %% plots
    % figure(40)
    % set(gcf,'Position',[428 92 568 414])
    % bar20=barh(dpspgall(2:length(dpspg),:),'BarWidth',1,'BarLayout','grouped');
    % % set(bar20(2),'FaceColor',[0.749 0.749 0]);
    % ylim([0.5 7.5])
    % set(gca,'YTickLabel',name(2:length(name)))
    % legend('9C9','ISH9','AoE (IH9)','Location','Best')
    % xlabel('DPS')
    % title([ num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'])
    % % ylabel('Damage')

    %sorted
    [dpspgsorted ind]=sort(dpspg9);
    dpsplotsorted=[dpspgw(ind) dpspg9(ind) dpspgi(ind)];

    figure(40+c)

    set(gcf,'Position',[428 92 568 414])
    bar20=barh(dpsplotsorted(2:length(dpspg9),:),'BarWidth',1,'BarLayout','grouped');
    set(bar20(2),'FaceColor',[0.749 0.749 0]);
    ylim([0.5 7.5])
    set(gca,'YTickLabel',name(ind(2:length(name))))
    legend('W39','939','IHSH','Location','Best')
    xlabel('DPS')
    title([ num2str(exec.veng*100,'%2.1f') '% Veng, ' num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp-10,'%2.1f') ' expertise'])
end