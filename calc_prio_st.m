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
cfg(1).glyph=ddb.glyphset{4}; %Modified Default, (CS+HotR)/SoT/ShoR, Cons/AS
cfg(1).talent=ddb.talentset{1}; %0/31/10 w/o HG

%low hit, WoG/SoI build
cfg(2).helm=cfg(1).helm;
cfg(2).label='W39/SoI build';
cfg(2).seal='Insight';
cfg(2).glyph=ddb.glyphset{5}; %Modified WoG (CS+HotR)/SoI/WoG, Cons/AS
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
N=10000;
for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;
    prio_model;

    wb=waitbar(0,['Calculating CFG # ' int2str(c) ' / ' int2str(length(cfg))]);
    tic
    for kk=1:k1
        waitbar(kk/k1,wb)
        rdata(kk,c)=prio_sim(kk,'N',N,'dt',dt);
    end
    close(wb)
    toc


    %% construct coefficient matrix
    cmat=zeros(size(rdata,1),length(rdata(1,1).coeff),length(cfg));
    for m=1:length(rdata)
        cmat(m,:,c)=rdata(m,c).coeff;
    end

    %% incorporate non-GCD damage sources
    %preallocate arrays for speed
    padps=zeros(size(rdata,1),2,length(cfg));
    patps=zeros(size(padps));pahps=zeros(size(padps));
    acdps=zeros(size(padps));acthr=zeros(size(padps));achps=zeros(size(padps));
    totdps=zeros(size(padps));tottps=zeros(size(padps));tothps=zeros(size(padps));
    %once at 100% vengeance
    exec=execution_model('seal',cfg(c).seal,'veng',1);
    stat_model
    ability_model
    for m=1:length(rdata)
        padps(m,1,c)=0;
        patps(m,1,c)=0;
        pahps(m,1,c)=0;
        
        %account for Inq
        Inqmod=sum(rdata(m,c).dur.Inq>0)./length(rdata(m,c).dur.Inq);

        %assume a 5-stack of SoT (if applicable).
        if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
            padps(m,1,c)=padps(m,1,c)+dps.Censure.*(1+0.3.*Inqmod);
            patps(m,1,c)=patps(m,1,c)+tps.Censure.*(1+0.3.*Inqmod);
        end

        %aa and seal damage
        padps(m,1,c)=padps(m,1,c)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        %aa and seal threat
        if strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
            patps(m,1,c)=patps(m,1,c)+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
            pahps(m,1,c)=pahps(m,1,c)+heal.activeseal.*mdf.mehit./player.wswing;
        else
            patps(m,1,c)=patps(m,1,c)+tps.Melee+threat.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        end
    end
    acdps(:,1,c)=cmat(:,:,c)*val.pdmg;
    acthr(:,1,c)=cmat(:,:,c)*val.pthr;
    achps(:,1,c)=cmat(:,:,c)*val.pheal;
    totdps(:,1,c)=acdps(:,1,c)+padps(:,1,c);
    tottps(:,1,c)=acthr(:,1,c)+patps(:,1,c);
    tothps(:,1,c)=achps(:,1,c)+pahps(:,1,c);
    

    %repeat for 30% vengeance
    exec=execution_model('seal',cfg(c).seal,'veng',0.3);
    stat_model
    ability_model
    for m=1:length(rdata)
        padps(m,2,c)=0;
        patps(m,2,c)=0;
        pahps(m,2,c)=0;
        
        %account for Inq
        Inqmod=sum(rdata(m,c).dur.Inq>0)./length(rdata(m,c).dur.Inq);

        %assume a 5-stack of SoT (if applicable).
        if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
            padps(m,2,c)=padps(m,2,c)+dps.Censure.*(1+0.3.*Inqmod);
            patps(m,2,c)=patps(m,2,c)+tps.Censure.*(1+0.3.*Inqmod);
        end

        %aa and seal damage
        padps(m,2,c)=padps(m,2,c)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        %aa and seal threat
        if strcmpi('Inisght',exec.seal)||strcmpi('SoI',exec.seal)
            patps(m,2,c)=patps(m,2,c)+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
            pahps(m,2,c)=pahps(m,2,c)+heal.activeseal.*mdf.mehit./player.wswing;
        else
            patps(m,2,c)=patps(m,2,c)+tps.Melee+threat.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
        end
    end
    acdps(:,2,c)=cmat(:,:,c)*val.pdmg;
    acthr(:,2,c)=cmat(:,:,c)*val.pthr;
    achps(:,2,c)=cmat(:,:,c)*val.pheal;
    totdps(:,2,c)=acdps(:,2,c)+padps(:,2,c);
    tottps(:,2,c)=acthr(:,2,c)+patps(:,2,c);
    tothps(:,2,c)=achps(:,2,c)+pahps(:,2,c);
%% construct damage arrays

%build name array
for m=1:size(rdata,1);name{m,:}=rdata(m).name;end

spacer=repmat(' ',size(rdata,1)+2,2);
li{c} =    [spacer char({' ','Q#',int2str([1:length(rdata)]')}) ...
            spacer char({' ','Priority',char(name)}) ...
            spacer char({'DPS','V=100%',int2str(totdps(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(totdps(:,2,c))}) ...
            spacer char({'TPS','V=100%',int2str(tottps(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(tottps(:,2,c))}) ...
            spacer char({'SHPS','V=100%',int2str(tothps(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(tothps(:,2,c))}) ...
            spacer char({' E',' #',int2str([rdata(:,c).empties]')}) ...
            spacer char({' E',' %',num2str([rdata(:,c).emptypct]','%3.1f')}) ...
            spacer char({'SotR','miss',int2str([rdata(:,c).smiss]')}) ...
            spacer char({'AS','cast',int2str([rdata(:,c).ascast]')}) ...
            spacer char({'GC','procs',int2str([rdata(:,c).gcproc]')})];
        
cfg(c).label
li{c}

end

%% store coefficients of important queues for later
% for c=1:3; coeffsum(:,:,c)=[rdata([3 18],c).coeff];end %939, W39

%% save for later use (good for generic stuff, saves computation time)
save prio_data.nv.mat cmat rdata