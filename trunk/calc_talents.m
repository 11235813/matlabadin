%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

%% Setup tasks
clear;
gear_db;
def_db;


base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base);
gear_sample
exec=execution_model('npccount',1,'timein',0,'timeout',1,'seal','Truth');
buff=buff_model('mode',1);


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





%% sim
wb=waitbar(0,'Calculating');
for m=1:length(tree)
    
    clear talent
    talent=tree(m);
    %invoke talents & glyphs
    talents
    %calculate relevant stats
    gear_stats
    %calculate final stats
    stat_model
    ability_model_80
    prio_model

    seq(m)=prio_sim(8,'N',60000);
    waitbar(m/length(tree),wb)


    padps(m)=0;
    %account for Inq
    Inqmod=sum(seq(m).Inq>0)./length(seq(m).Inq);

    %assume a 5-stack of SoT (if applicable).
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps(m)=padps(m)+dps.Censure.*(1+0.3.*Inqmod);

    end

    %aa and seal damage
    padps(m)=padps(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;

    totdps(m)=seq(m).sumdps+padps(m);

end
close(wb)    

[char(name) repmat(' ',length(name),5) num2str((totdps(1)-totdps')./points','%2.1f')]