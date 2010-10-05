%PRIO_CALC generates and stores the necessary data to compare different
%priority queues

%% preload all appropriate variables - damage values don't matter
clear;
gear_db;
def_db;
base=player_model('lvl',80,'race','Human');
npc=npc_model(base);
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT');
buff=buff_model;
% egs=ddb.gearset{4}; % premade gear
gear_sample
talent=ddb.talentset{2}; %0/31/5 with all damage-relevant prot talents
gear_stats
talents

stat_model
ability_model_80
prio_model;

%% Generate coefficients for each priority queue
N=30000;  %set long enough to get stochastic data for each sim
wb=waitbar(0,'Calculating');
for k=1:length(prio)
    
    waitbar(k/length(prio),wb)
    rdata(k)=prio_sim(k,'N',N);
    
end
close(wb)

%% construct coefficient matrix
for m=1:length(rdata)
    cmat(m,:)=rdata(m).coeff;
end


%% save for later use (good for generic stuff, saves computation time)
save prio_data cmat rdata

%% incorporate non-GCD effects
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
    

    li(m,:)=[rdata(m).name repmat(' ',1,45-length(rdata(m).name))  ...
        int2str(int32(rdata(m).sumdps+rdata(m).padps)) ...
        repmat(' ',1,8-length(int2str(rdata(m).empties))) int2str(rdata(m).empties)];
end
li

