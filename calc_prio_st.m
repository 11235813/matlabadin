%PRIO_CALC generates and stores the necessary data to compare different
%priority queues

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1);  %placeholder, set in cfg
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{1}; %placeholder, set in cfg
glyph=ddb.glyphset{4}; %placeholder, set in cfg
talents;
buff=buff_model;
stat_model;
ability_model;
prio_model;


%% Configurations
%low hit, SotR/SoT build
%set melee hit to 2%, expertise to 10
%do this by altering helm stats
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).label='939/SoT build';
cfg(1).seal='Truth';
cfg(1).glyph=ddb.glyphset{1}; %Default, HotR/SoT/ShoR, Cons/AS
cfg(1).talent=ddb.talentset{1}; %0/31/10 w/o HG

%low hit, WoG/SoI build
cfg(2).helm=cfg(1).helm;
cfg(2).label='W39/SoI build';
cfg(2).seal='Insight';
cfg(2).glyph=ddb.glyphset{2}; %WoG set
cfg(2).talent=ddb.talentset{2}; %0/31/10 WoG build


%hit-cap and exp soft-cap, SotR/SoT build
cfg(3)=cfg(1);
cfg(3).label='939/SoT build, hit-capped';
cfg(3).helm=egs(1);
cfg(3).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(3).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;


%% Generate coefficients for each priority queue
N=30000;  %# GCDs, set long enough to get stochastic data for each sim
dt=1.5;
N=1000;
for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;

    wb=waitbar(0,['Calculating CFG # ' int2str(c) ' / ' int2str(length(cfg))]);
    tic
    for k=1:k1

        waitbar(k/k1,wb)
        rdata(k,c)=prio_sim(k,'N',N,'dt',dt);

    end
    close(wb)
    toc


    %% construct coefficient matrix
    for m=1:length(rdata)
        cmat(m,:,c)=rdata(m,c).coeff;
    end


    %% save for later use (good for generic stuff, saves computation time)
    % save prio_data cmat rdata

    %% incorporate non-GCD damage sources
    %once at 100% vengeance
    exec=execution_model('seal',cfg(c).seal,'veng',1);
    stat_model
    ability_model
    for m=1:length(rdata)
        padps(m,1,c)=0;
        pathr(m,1,c)=0;
        
        %account for Inq
        Inqmod=sum(rdata(m,c).Inq>0)./length(rdata(m,c).Inq);

        %assume a 5-stack of SoT (if applicable).
        if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
            padps(m,1,c)=padps(m,1,c)+dps.Censure.*(1+0.3.*Inqmod);
            pathr(m,1,c)=pathr(m,1,c)+tps.Censure.*(1+0.3.*Inqmod);
        end

        %aa and seal damage
        padps(m,1,c)=padps(m,1,c)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        %aa and seal threat
        if strcmpi('Inisght',exec.seal)||strcmpi('SoI',exec.seal)
            pathr(m,1,c)=pathr(m,1,c)+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
        else
            pathr(m,1,c)=pathr(m,1,c)+tps.Melee+threat.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        end
    end
    acdps(:,1,c)=cmat(:,:,c)*val.pdmg;
    acthr(:,1,c)=cmat(:,:,c)*val.pthr;
    totdps(:,1,c)=acdps(:,1,c)+padps(:,1,c);
    totthr(:,1,c)=acthr(:,1,c)+pathr(:,1,c);
    

    %repeat for 30% vengeance
    exec=execution_model('seal',cfg(c).seal,'veng',0.3);
    stat_model
    ability_model
    for m=1:length(rdata)
        padps(m,2,c)=0;
        pathr(m,2,c)=0;
        
        %account for Inq
        Inqmod=sum(rdata(m,c).Inq>0)./length(rdata(m,c).Inq);

        %assume a 5-stack of SoT (if applicable).
        if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
            padps(m,2,c)=padps(m,2,c)+dps.Censure.*(1+0.3.*Inqmod);
            pathr(m,2,c)=pathr(m,2,c)+tps.Censure.*(1+0.3.*Inqmod);
        end

        %aa and seal damage
        padps(m,2,c)=padps(m,2,c)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        %aa and seal threat
        if strcmpi('Inisght',exec.seal)||strcmpi('SoI',exec.seal)
            pathr(m,2,c)=pathr(m,2,c)+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
        else
            pathr(m,2,c)=pathr(m,2,c)+tps.Melee+threat.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        end
    end
    acdps(:,2,c)=cmat(:,:,c)*val.pdmg;
    acthr(:,2,c)=cmat(:,:,c)*val.pthr;
    totdps(:,2,c)=acdps(:,2,c)+padps(:,2,c);
    totthr(:,2,c)=acthr(:,2,c)+pathr(:,2,c);
%% construct damage arrays

%build name array
for m=1:size(rdata,1);name{m,:}=rdata(m).name;end

spacer=repmat(' ',size(rdata,1)+2,3);
li{c} =    [spacer char({' ','Q#',int2str([1:length(rdata)]')}) ...
            spacer char({' ','Priority',char(name)}) ...
            spacer char({'DPS','V=100%',int2str(totdps(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(totdps(:,2,c))}) ...
            spacer char({'TPS','V=100%',int2str(totthr(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(totthr(:,2,c))}) ...
            spacer char({' E',' #',int2str([rdata(:,c).empties]')}) ...
            spacer char({' ',' %',num2str([rdata(:,c).emptypct]','%3.1f')}) ...
            spacer char({'SotR','miss',int2str([rdata(:,c).smiss]')}) ...
            spacer char({'AS','cast',int2str([rdata(:,c).ascast]')})];
        
cfg(c).label
li{c}

end
