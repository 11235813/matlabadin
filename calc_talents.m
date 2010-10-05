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
tree(2)=tree(1);
tree(2).prot(1,2)=0;
points(2)=tree(1).prot(1,2);
name{2}='SotP';

%Hallowed Ground
tree(3)=tree(1);
tree(3).prot(3,1)=0;
points(3)=tree(1).prot(3,1);
name{3}='Hallowed Ground';

%WotL
tree(4)=tree(1);
tree(4).prot(3,4)=0;
points(4)=tree(1).prot(3,4);
name{4}='WotL';

%Reck
tree(5)=tree(1);
tree(5).prot(4,1)=0;
points(5)=tree(1).prot(4,1);
name{5}='Reck';

%Grand Crusader
tree(6)=tree(1);
tree(6).prot(4,3)=0;
points(6)=tree(1).prot(4,3);
name{6}='Grand Crusader';

%Arbiter of the Light
tree(7)=tree(1);
tree(7).holy(1,1)=0;
points(7)=tree(1).holy(1,1);
name{7}='Arbiter of the Light';

%JotP
tree(8)=tree(1);
tree(8).holy(1,3)=0;
points(8)=tree(1).holy(1,3);
name{8}='JotP';

%Crusade
tree(9)=tree(1);
tree(9).ret(1,2)=0;
points(9)=tree(1).ret(1,2);
name{9}='Crusade';

%RoL
tree(10)=tree(1);
tree(10).ret(2,2)=0;
points(10)=tree(1).ret(2,2);
name{10}='RoL';





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