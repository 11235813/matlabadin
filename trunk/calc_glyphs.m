%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

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


%% sim 

%Calculate a sequence for this build, we'll use this sequence for all of
%the talents that don't have a direct effect on the rotation 

tmpvar.vengap=[1 1 0.3 0.3];
tmpvar.hitcap=[0 1   0   1];

for n=1:length(tmpvar.vengap);

    exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth','veng',tmpvar.vengap(n));


    for m=1:length(gtree) %everything


        clear glyph
        glyph=gtree(m);
        %invoke talents & glyphs
        talents;
        %calculate relevant stats
        gear_stats;

        %artificially inflating hit and expertise to 8% and 36
        if tmpvar.hitcap(n)==1
            stat_conversions;stat_model;
            gear.hit=8*cnv.hit_phhit;
            gear.exp=(26-base.exp)*cnv.exp_exp;
        end
        %calculate final stats
        stat_model;
        ability_model;
        rotation_model;

        totdps(m)=rot(1).totdps;
        totdps1(m)=rot(2).totdps;
        totdps2(m)=rot(3).totdps;
        totdpsa(m)=rot(6).totdps;

        if strcmp(name(m),'HotR')
            tabledps(m,:)=[totdps2(m) totdps2(1)];
            tabledps1(m,:)=[totdps1(m) totdps1(1)];
            tabledpsa(m,:)=[totdpsa(m) totdpsa(1)];
        else
            tabledps(m,:)=[totdps(m) totdps(1)];
            tabledps1(m,:)=[totdps1(m) totdps1(1)];
            tabledpsa(m,:)=[totdpsa(m) totdpsa(1)];
        end

    end


    dpspg=diff(tabledps,1,2);
    dpspg1=diff(tabledps1,1,2);
    dpspga=diff(tabledpsa,1,2);

    dpspgall=[dpspg dpspg1];

    %% table output
    spacer= repmat(' ',length(name),5);    
    tmpvar.header=[ num2str(exec.veng*100,'%2.1f') '% Veng, ' num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'];
    tmpvar.data=[char(name) spacer num2str(dpspg,'%2.1f') spacer num2str(dpspg1,'%2.1f')];
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
    [dpspgsorted ind]=sort(dpspg);
    dpsplotsorted=dpspgall(ind,:);

    figure(40+n)

    set(gcf,'Position',[428 92 568 414])
    bar20=barh(dpsplotsorted(2:length(dpspg),:),'BarWidth',1,'BarLayout','grouped');
    set(bar20(2),'FaceColor',[0.749 0.749 0]);
    ylim([0.5 7.5])
    set(gca,'YTickLabel',name(ind(2:length(name))))
    legend('SCSC','IHSH','Location','Best')
    xlabel('DPS')
    title([ num2str(exec.veng*100,'%2.1f') '% Veng, ' num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'])
end