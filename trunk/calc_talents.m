%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

%% Setup tasks
clear;
gear_db;
def_db;
base=player_model('race','Human');
npc=npc_model(base);
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth','veng',1);
buff=buff_model;
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS



%% set up our tree configurations

%base - unpossible build, contains a ridiculous # of points
temptree.holy=[2 0 3 0; 0 0 0 0];
temptree.prot=[3 2 2 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
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


%% sim 

%Calculate a sequence for this build, we'll use this sequence for all of
%the talents that don't have a direct effect on the rotation 
%(i.e. all but GC).
% clear talent
% talent=tree(1);
% %invoke talents & glyphs
% talents
% %calculate relevant stats
% gear_stats
% %calculate final stats
% stat_model
% ability_model
% rotation_model
% 
% %now calculate total DPS
% totdps(1)=rot.totdps;
% totdps1(1)=rot1.totdps;
% totdps

for m=1:length(tree) %everything
   

    clear talent
    talent=tree(m);
    %invoke talents & glyphs
    talents
    %calculate relevant stats
    gear_stats
    
    %artificially inflating hit and expertise to 8% and 26
%     stat_conversions;stat_model;
%     gear.hit=8*cnv.hit_phhit;
%     gear.exp=(26-10-base.exp)*cnv.exp_exp;

    %calculate final stats
    exec.npccount=1; %to reset from AoE
    stat_model
    ability_model
    rotation_model
    
    totdps(m)=rot.totdps;
    totdps1(m)=rot1.totdps;
    
    %calculate final stats
    exec.npccount=4; %to reset from AoE
    stat_model
    ability_model
    rotation_model
    totdpsa(m)=aoe.totdps;
    
end


dpsppt=(totdps(1)-totdps')./points';
dpsppt1=(totdps1(1)-totdps1')./points';
dpsppta=(totdpsa(1)-totdpsa')./points';

%% table output
spacer=repmat(' ',length(name),5);
[char(name)  spacer num2str(dpsppt,'%2.1f') spacer num2str(dpsppt1,'%2.1f') spacer num2str(dpsppta,'%2.1f')]


%% plots
dpsplot=[dpsppt dpsppt1 dpsppta];

figure(30)
set(gcf,'Position',[428 128 728 378])
bar30=barh(dpsplot(2:length(dpsplot),:),'BarWidth',1,'BarLayout','grouped');
set(bar30(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(2:length(name)))
legend('9C9','ISH9','AoE (IH9)','Location','Best')
xlabel('DPS per point')
title([ num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'])

%sorted
[dpspptsorted ind]=sort(dpsppt);
dpsplotsorted=dpsplot(ind,:);
figure(31)

set(gcf,'Position',[428 128 728 378])
bar31=barh(dpsplotsorted(2:length(dpsppt),:),'BarWidth',1,'BarLayout','grouped');
set(bar31(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
legend('9C9','ISH9','AoE (IH9)','Location','Best')
xlabel('DPS per point')
title([ num2str(exec.veng*100,'%2.1f') '% Veng, ' num2str(player.phhit,'%2.1f') '% hit, ' num2str(player.exp,'%2.1f') ' expertise'])

%for talent spec guide
figure(32)
set(gcf,'Position',[428 128 728 378])
bar31=barh(dpsplotsorted(2:length(dpsppt),1),'BarWidth',0.5,'BarLayout','grouped');
% set(bar31(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
legend('939','Location','Best')
xlabel('DPS per point')
title([ num2str(exec.veng*100,'%2.1f') '% Veng, ' num2str(player.phhit,'%2.1f') '% hit, ' ...
    num2str(player.exp,'%2.1f') ' expertise'])