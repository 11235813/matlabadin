%CALC_ROT_AOE uses the FSM formalism to calculate damage for a AoE
%situations

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1);  %placeholder, set in cfg
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{5};  %3=T11H, 4=T12, 5=T12H
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
cfg(1).helm=egs(1);
cfg(1).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(1).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(1).label='939/SoT build, Focused Shield glyphed';
cfg(1).seal='Truth';
cfg(1).glyph=ddb.glyphset{4}; %Modified Default, (CS+HotR)/SoT/ShoR, Cons/AS
cfg(1).talent=ddb.talentset{1}; %0/32/9 w/o HG

%second config, this time without the AS glyph
cfg(2)=cfg(1);
cfg(2).label='939/SoT build, Focused Shield unglyphed';
cfg(2).glyph=ddb.glyphset{7}; %Modified Default, (CS+HotR)/SoT/ShoR, Cons


%% Generate DPS for each config

%preallocate arrays for speed
cmat=zeros(length(queue.aoe),length(val.fsmlabel),length(cfg));
inqup=zeros(length(queue.aoe),1);mpsnet=inqup;
empties=inqup;



for c=1:length(cfg)
    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('seal',cfg(c).seal,'veng',1,'npccount',4);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    gear_stats;
    talents;
    stat_model;
    ability_model;

    wb=waitbar(0,['Calculating CFG # ' int2str(c) ' / ' int2str(length(cfg))]);
    tic
    for kk=1:size(queue.aoe,1)
        waitbar(kk/length(queue.aoe),wb)
        [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.aoe{kk}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
        
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
    end
    close(wb)
    toc
    

    %% Damage calculations
    
%     %preallocate arrays for speed
%     padps=zeros(size(queue.st,1),2,length(cfg));
%     patps=zeros(size(padps));pahps=zeros(size(padps));
%     acdps=zeros(size(padps));acthr=zeros(size(padps));achps=zeros(size(padps));
%     totdps=zeros(size(padps));tottps=zeros(size(padps));tothps=zeros(size(padps));
    
    
    %damage for primary target
    
    
    %active sources (GCD-based)
    acdps(:,c)=cmat(:,:,c)*val.fsmdmg;
    
    %passive sources (melee, seals, Censure)
    inqmod=1+0.3.*inqup;
    
    %melee + seal
    padps(:,c)=dps.Melee+dmg.activeseal.*mdf.mehit.*inqmod./player.wswing;
   
    %Censure if applicable
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps(:,c)=padps(:,c)+dps.Censure.*inqmod;
    end
    
    %sum active and passive
    dmgarray.target(:,c)=acdps(:,c)+padps(:,c);
    
    
    %damage for secondary targets
    for mm=1:5
        nmobs=mm+1;
        %re-run relevant modules for mm+1 mobs
        exec=execution_model('npccount',nmobs,'seal',cfg(c).seal,'veng',1);
        stat_model;ability_model;
        
        %store coefficients for "guaranteed" damage per mob -
        %HW/Cons/HotR/AS(<3)
        dmgarray.permob(:,mm,c)=cmat(:,:,c)*val.fsmaoe./mm;
        
        %mana efficiency per mob
        mpspermob(mm)=(nmobs-1)./nmobs.*mps.Sanc;
        
    end

        
        

%% construct output arrays

spacer=repmat(' ',length(queue.aoe)+2,2);
li{c} =    [spacer char({' ','Q#',int2str([1:length(queue.aoe)]')}) ...
            spacer char({' ','Priority',char(queue.aoe)}) ...
            spacer char({'Primary','DPS',int2str(dmgarray.target(:,c))}) ...
            spacer char({' ','  2  ',int2str(dmgarray.permob(:,1,c))}) ...
            spacer char({' ','  3  ',int2str(dmgarray.permob(:,2,c))}) ...
            spacer char({' ','  4  ',int2str(dmgarray.permob(:,3,c))}) ...
            spacer char({' ','  5  ',int2str(dmgarray.permob(:,4,c))}) ...
            spacer char({' ','  6  ',int2str(dmgarray.permob(:,5,c))}) ...
            spacer char({' E',' %',num2str(empties.*100,'%3.1f')}) ...
            spacer char({' I',' %',num2str(inqup.*100,'%3.1f')})...
            spacer char({'mps','  ',num2str(mpsnet,'%4.0f')})...
            spacer char({'mps','@6',num2str(mpsnet+mpspermob(length(mpspermob)),'%4.0f')})... 
            ];
        
cfg(c).label
li{c}

end


