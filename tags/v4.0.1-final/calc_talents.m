%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

%% Setup tasks
clear;
gear_db;
def_db;


base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base);
gear_sample
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth');
buff=buff_model('mode',3);


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
clear talent
talent=tree(1);
%invoke talents & glyphs
talents
%calculate relevant stats
gear_stats
%calculate final stats
stat_model
ability_model
prio_model
rot.consflag=1;
rotation_model

%now calculate total DPS
totdps(1)=rot.totdps;
totdps1(1)=rot1.totdps;

% for m=2:length(tree)-2  %everything except GC & SD
for m=2:length(tree) %everything
   

    clear talent
    talent=tree(m);
    %invoke talents & glyphs
    talents
    %calculate relevant stats
    gear_stats
    %calculate final stats
    stat_model
    ability_model
    rotation_model
    
    totdps(m)=rot.totdps;
    totdps1(m)=rot1.totdps;
    
end


%% Grand Crusader & Sacred Duty
%These are more annoying, we need to sim out another version with GC
%inactive and compare DPS.  This is a bit of a pain since GC can come out
%negative if we're unlucky. 

%TODO: fix prio_sim to make it possible to do Sacred Duty without
%re-simming
% 
% wb=waitbar(0,'Calculating GC');
% for m=length(tree)-1:length(tree)
%     
%     clear talent
%     talent=tree(m);
%     %invoke talents & glyphs
%     talents
%     %calculate relevant stats
%     gear_stats
%     %calculate final stats
%     stat_model
%     ability_model
% 
%     seq2(m)=prio_sim(10,'N',90000);
%     waitbar(m/length(tree),wb)
%     
%     acdps(m)=sum(pridmg.*seq2(m).coeff)
% 
%     padps(m)=0;
%     %account for Inq
%     Inqmod=sum(seq2(m).Inq>0)./length(seq2(m).Inq);
% 
%     %assume a 5-stack of SoT (if applicable).
%     if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
%         padps(m)=padps(m)+dps.Censure.*(1+0.3.*Inqmod);
% 
%     end
% 
%     %aa and seal damage
%     padps(m)=padps(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
% 
%     totdps(m)=acdps(m)+padps(m);
% 
% end
% close(wb)

dpsppt=(totdps(1)-totdps')./points';
dpsppt1=(totdps1(1)-totdps1')./points';

%% table output
spacer=repmat(' ',length(name),5);
[char(name)  spacer num2str(dpsppt,'%2.1f') spacer num2str(dpsppt1,'%2.1f')]


%% plots
dpsplot=[dpsppt dpsppt1-dpsppt];

figure(30)
set(gcf,'Position',[428 128 728 378])
bar30=barh(dpsplot(2:length(dpsplot),:),'BarWidth',0.5,'BarLayout','stacked');
set(bar30(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(2:length(name)))
% legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('DPS per point')
% ylabel('Damage')

%sorted
[dpspptsorted ind]=sort(dpsppt);
dpsplotsorted=dpsplot(ind,:);
figure(31)

set(gcf,'Position',[428 128 728 378])
bar31=barh(dpsplotsorted(2:length(dpsppt),:),'BarWidth',0.5,'BarLayout','stacked');
set(bar31(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 10.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
% legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('DPS per point')