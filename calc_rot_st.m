%CALC_ROT_ST uses the FSM formalism to calculate damage for a variety of
%different rotations under different conditions

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1);  %placeholder, set in cfg
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{7};  %6=T13R, 7=T13N, 8=T13H
gear_stats;
talent=ddb.talentset{1}; %placeholder, set in cfg
glyph=ddb.glyphset{4}; %placeholder, set in cfg
talents;
buff=buff_model;
stat_model;
ability_model;
queue_model; %lists the queues we're interested in

%% Configurations
%low hit, SotR/SoT build
%set melee hit to 2%, expertise to 10
%do this by altering helm stats
c=1;
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(c).label='939/SoT build';
cfg(c).seal='Truth';
cfg(c).glyph=ddb.glyphset{4}; %Modified Default, (CS+HotR)/SoT/ShoR, Cons/AS
cfg(c).talent=ddb.talentset{1}; %0/32/9 w/o HG

% %low hit, WoG/SoI build
c=c+1;
cfg(c).helm=cfg(1).helm;
cfg(c).label='W39/SoI build';
cfg(c).seal='Insight';
cfg(c).glyph=ddb.glyphset{5}; %Modified WoG (CS+HotR)/SoI/WoG, Cons/AS
cfg(c).talent=ddb.talentset{1}; %0/32/9 w/o HG


%hit-cap and exp soft-cap, SotR/SoT build
c=c+1;
cfg(c)=cfg(1);
cfg(c).label='939/SoT build, hit-capped';
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-56).*cnv.exp_exp;

%% Generate DPS for each config

%preallocate arrays for speed
cmat=zeros(length(queue.st),length(val.fsmlabel),length(cfg));
inqup=zeros(length(queue.st),1);mpsnet=inqup;
empties=inqup;

for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;
    ability_model;
    
%     arbitrarily turn on T13 ret 2-piece
%     mdf.t13x2R=1;

    wb=waitbar(0,['Calculating CFG # ' int2str(c) ' / ' int2str(length(cfg))]);
    tic
    for kk=1:length(queue.st)
        waitbar(kk/length(queue.st),wb)
        [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.st{kk}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
        
        %store stuff for debugging
        fsmdata(kk,c).meta=metadata;
        fsmdata(kk,c).action=actionPr;
        
        %convert actionPr to CPS array
        [cps] =action2cps(actionPr, metadata);
        
        %store in coefficient matrices
        cmat(kk,:,c)=cps';
        inqup(kk)=inqUptime;
        jotw.uptime(kk)=jotwUptime;
        if (jotw.BaseDur./jotw.uptime(kk))>jotw.NetDur
            mps.jotw(kk)=jotw.uptime(kk).*(jotw.PerTick./jotw.NetTick);
        else
            mps.jotw(kk)=jotw.PerTick./jotw.NetTick;
        end
        mpsgain=mps.jotw(kk)+mps.Repl+mps.Sanc+mps.BoM;
        mpscost=sum(cps.*val.fsmmana);
        mpsnet(kk)=mpsgain-mpscost;
        empties(kk)=sum(cps((length(cps)-1):length(cps)));
        %temporary fix for FSM change
        empties(kk)=1/1.5-sum([actionPr{2,:}]);
    end
    close(wb)
    toc
    

    %% Damage calculations
    
    %preallocate arrays for speed
    padps=zeros(size(queue.st,1),2,length(cfg));
    patps=zeros(size(padps));pahps=zeros(size(padps));
    acdps=zeros(size(padps));acthr=zeros(size(padps));achps=zeros(size(padps));
    totdps=zeros(size(padps));tottps=zeros(size(padps));tothps=zeros(size(padps));
    
    
    %once at 100% vengeance, once at 30%
    tmp.veng=[1 0.3];
    
    for m=1:2
        
        exec.veng=tmp.veng(m);
        stat_model
        ability_model
        
        %active sources (GCD-based)
        acdps(:,m,c)=cmat(:,:,c)*val.fsmdmg;
        acthr(:,m,c)=cmat(:,:,c)*val.fsmthr;
        achps(:,m,c)=cmat(:,:,c)*val.fsmheal;
        
        %passive sources (melee, seals, Censure)
        inqmod=1+0.3.*inqup;
        
        %melee + seal
        padps(:,m,c)=dps.Melee+dmg.activeseal.*mdf.mehit.*inqmod./player.wswing;
        pahps(:,m,c)=heal.activeseal.*mdf.mehit./player.wswing;
        patps(:,m,c)=tps.Melee+(dmg.activeseal.*inqmod+mdf.hthreat.*heal.activeseal).*mdf.RFury.*mdf.mehit./player.wswing;
        
        %Censure if applicable
        if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
            padps(:,m,c)=padps(:,m,c)+dps.Censure.*inqmod;
            patps(:,m,c)=patps(:,m,c)+tps.Censure.*inqmod;
        end
        
        %sum active and passive
        totdps(:,m,c)=acdps(:,m,c)+padps(:,m,c);
        tottps(:,m,c)=acthr(:,m,c)+patps(:,m,c);
        tothps(:,m,c)=achps(:,m,c)+pahps(:,m,c);
    end

%% construct output arrays

spacer=repmat(' ',length(queue.st)+2,2);
li{c} =    [spacer char({' ','Q#',int2str([1:length(queue.st)]')}) ...
            spacer char({' ','Priority',char(queue.st)}) ...
            spacer char({'DPS','V=100%',int2str(totdps(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(totdps(:,2,c))}) ...
            spacer char({'SHPS','V=100%',int2str(tothps(:,1,c))}) ...
            spacer char({' ','V=30%',int2str(tothps(:,2,c))}) ...
            spacer char({' E',' %',num2str(empties.*100,'%3.1f')}) ...
            spacer char({' I',' %',num2str(inqup.*100,'%3.1f')})...
            spacer char({'mps','  ',num2str(mpsnet,'%4.0f')})...
            ];
        
%             spacer char({'TPS','V=100%',int2str(tottps(:,1,c))}) ...
%             spacer char({' ','V=30%',int2str(tottps(:,2,c))}) ...
%             spacer char({' E',' #',int2str([rdata(:,c).empties]')}) ...
%             spacer char({'SotR','miss',int2str([rdata(:,c).smiss]')}) ...
%             spacer char({'AS','cast',int2str([rdata(:,c).ascast]')}) ...
%             spacer char({'GC','procs',int2str([rdata(:,c).gcproc]')})...
%             spacer char({'F2F','time',num2str([rdata(:,c).f2ftime]','%3.1f')}) ...
        
cfg(c).label
li{c}

end

%% pretty-print output array, this is only for the first set.
queue.stsubset={ ...
    'SotR>CS>J>AS'; ...
    'SotR>CS>AS>J'; ...
    'SotR>CS>AS+>J>AS'; ...
    'SotR>CS>AS+>J>AS>Cons>HW'; ...
    'SDSotR>ISotR>Inq>CS>AS+>J>AS'; ...
    'SDSotR>ISotR>Inq>CS>AS+>J>AS>Cons>HW'; ...
    'WoG>CS>AS+>J>AS'; ...
    'WoG>SotR>CS>AS+>J>AS'; ...
    'WoG>SotR>CS>AS+>J>AS>Cons>HW'; ...
    'SotR>CS>AS>HoW>J'; ...
    'SotR>CS>J>AS>HoW>Cons>HW'; ...
    'ISotR>SDSotR>Inq>CS>AS>HoW>J>Cons>HW'; ...
%     'WoG>SotR>CS>AS>HoW>J>Cons>HW'...
    };
    

for q=1:size(queue.stsubset,1)
    ind(q)=find(strcmp(queue.st,queue.stsubset{q}));
end

li{1}(ind+2,:)

%% save for later use (good for generic stuff, saves computation time)
% save prio_data.nv.mat cmat fsmdata