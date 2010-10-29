%CALC_PRIO_AOE simulates AoE priority queues and calculates DPS

%% preload all appropriate variables - damage values don't matter
clear;
gear_db;
def_db;
base=player_model('lvl',80,'race','Human');
npc=npc_model(base);
exec=execution_model('npccount',4,'timein',1,'timeout',1,'seal','SoT');
buff=buff_model;
% egs=ddb.gearset{4}; % premade gear
gear_sample
talent=ddb.talentset{2}; %0/31/5 with all damage-relevant prot talents
glyph.major=[0 1 0 0 0 0 0 0 0 0];
gear_stats
talents

stat_model
ability_model
prio_model;

%% Generate coefficients for each priority queue
N=90000;  %set long enough to get stochastic data for each sim
dt=0.5;
wb=waitbar(0,'Calculating');
tic
for k=1:(k2-k1)
    
    waitbar(k/(k2-k1),wb)
    rdata(k)=prio_sim(k1+k,'N',N,'dt',dt);
    
end
close(wb)
toc

%% construct coefficient matrix
for m=1:(k2-k1)
    cmat(m,:)=rdata(m).coeff;
end


%% save for later use (good for generic stuff, saves computation time)
save prio_data_aoe cmat rdata

%% Create damage array for different mob numbers
for mm=1:5
    %re-run relevant modules for mm+1 mobs
    exec=execution_model('npccount',mm+1,'timein',1,'timeout',1,'seal','SoT');
    stat_model;ability_model;
    
    %store coefficients for total damage done
    dmgarray.total(:,mm)=aoedmg;
    
    %store coefficients for "guaranteed" damage per mob - HW/Cons/HotR
    dmgarray.permob(:,mm)=aoedmg.*[zeros(4,1); 1; 1; zeros(5,1); 1]./exec.npccount; 
end

%% incorporate non-GCD damage sources
clear li padmg
for m=1:length(rdata)
    padps(m)=0;
    %account for Inq
    Inqmod=sum(rdata(m).Inq>0)./length(rdata(m).Inq);
    
    %assume a 5-stack of SoT (if applicable).
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps(m)=padps(m)+dps.Censure.*(1+0.3.*Inqmod);
    
    end
    
    %aa and seal damage
	padps(m)=padps(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
end

%% construct damage arrays
dmgarray.tabletot=cmat*dmgarray.total;
dmgarray.tableaoe=cmat*dmgarray.permob;
dmgarray.padps=repmat(padps',1,size(dmgarray.tabletot,2));

%build name array
for m=1:length(rdata);name{m,:}=rdata(m).name;end

%% total damage (sum of all damage done to all mobs)
spacer=repmat(' ',length(rdata),3);
li=[spacer int2str([1:length(rdata)]') spacer char(name) spacer int2str(dmgarray.tabletot+dmgarray.padps) spacer int2str([rdata.empties]') spacer num2str([rdata.emptypct]','%3.1f')];
li

%% "guaranteed" damage per mob - only counts HW, HaNova, Consecration
li2=[spacer int2str([1:length(rdata)]') spacer char(name) spacer int2str(dmgarray.tableaoe) spacer int2str([rdata.empties]') spacer num2str([rdata.emptypct]','%3.1f')];
li2
