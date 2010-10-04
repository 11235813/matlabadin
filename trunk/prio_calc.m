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


for m=1:length(rdata)
    li(m,:)=[rdata(m).name repmat(' ',1,30-length(rdata(m).name)) int2str(int32(rdata(m).sumdps))];
end
li

% [rdata.sumdps]./1e3