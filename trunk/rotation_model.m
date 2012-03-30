function [c]=rotation_model(c)
%ROTATION_MODEL calculates the DPS/HPS output of a given rotation, as
%defined in the configuration structure.
%
%rotation_model takes one input argument "c", which is the configuration
%structure for the simulation.  "c" contains the standard fields reurned by
%stat_model.  If c.exec.queue has not been defined, it will be defaulted to
%SotR.CS>J>AS>Cons.
%
%rotation_model returns an updated "c" that includes an
%"rot" field containing the new values introduced in this module.

%helper functions
addpath ./helper_func/
%parallelization flag
useParallel=1;

%define relevant queues if not done already
%TODO: maybe this makes more sense in c.rot?
if isfield(c.exec,'queue')==0
    c.exec.queue='^WB>^SS>SotR>CS>J>AS>Cons>HW';
end


%% Crank

%generate FSM results
if length(c.mdf.mehit)==1 && length(c.mdf.sphit)==1 && length(c.player.wswing)==1
       [c.rot.actionPr, ...
        c.rot.metadata, ...
        c.rot.ssuptime, ...
        c.rot.efuptime, ...
        c.rot.wbuptime, ...
        c.rot.sbuptime, ...
        c.rot.gcduptime] = memoized_fsm(c.exec.queue, ...
                                        c.mdf.mehit, ...
                                        c.mdf.sphit, ...
                                        c.talent.SelflessHealer); 
    %convert actionPr to CPS array
    c.rot.cps=action2cps(c);
    %empties tracking - this is % empty gcds
    c.rot.epct=1-c.rot.gcduptime;
    
%otherwise, we need some array handling, and may want to take advantage
%of parallelization

%mdf.mehit and mdf.sphit have one element, but player.wswing is 1xN -
%haste, str scaling (via parry->parryhaste)
elseif length(c.mdf.mehit)==1 && length(c.mdf.sphit)==1 && length(c.player.wswing)>1
    %only need one fsm generation
       [c.rot.actionPr, ...
        c.rot.metadata, ...
        c.rot.ssuptime, ...
        c.rot.efuptime, ...
        c.rot.wbuptime, ...
        c.rot.sbuptime, ...
        c.rot.gcduptime] = memoized_fsm(c.exec.queue, ...
                                        c.mdf.mehit, ...
                                        c.mdf.sphit, ...
                                        c.talent.SelflessHealer);
    %the conversion to a CPS array needs to be handled appropriately though
    for j=1:length(c.player.wswing)
        [c.rot.cps(:,j)]=action2cps(c,j);
        %empties tracking
        c.rot.epct(j)=1-c.rot.gcduptime;
    end
        
    
%both mdf.mehit and mdf.sphit have more than one element - assumed to
%be the same size
elseif length(c.mdf.mehit)>1 && length(c.mdf.sphit)>1
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.mdf.mehit, c.mdf.sphit);
        for j=1:length(c.mdf.mehit)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadata, ...
             c.rot.ssuptime(j), ...
             c.rot.efuptime(j), ...
             c.rot.wbuptime(j), ...
             c.rot.sbuptime(j), ...
             c.rot.gcduptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.mdf.mehit(j), ...
                                                c.mdf.sphit(j),...
                                                c.talent.SelflessHealer);
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.epct(j)=1-c.rot.gcduptime(j);
        end
    else
        wb=waitbar(0,'Generating/Loading FSM data');
        for j=1:length(c.mdf.mehit)
            waitbar(j/val.length,wb,['FSM gen/load for ' c.exec.queue])
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadataa, ...
             c.rot.ssuptime(j), ...
             c.rot.efuptime(j), ...
             c.rot.wbuptime(j), ...
             c.rot.sbuptime(j), ...
             c.rot.gcduptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.mdf.mehit(j), ...
                                                c.mdf.sphit(j),...
                                                c.talent.SelflessHealer);
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.epct(j)=1-c.rot.gcduptime(j);
        end
        close(wb)
    end
    
%only mdf.mehit has more than one element (can this even happen anymore?)
elseif length(c.mdf.mehit)>1 && length(c.mdf.sphit)==1
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.mdf.mehit, c.mdf.sphit);
        for j=1:length(c.mdf.mehit)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadataa, ...
             c.rot.ssuptime(j), ...
             c.rot.efuptime(j), ...
             c.rot.wbuptime(j), ...
             c.rot.sbuptime(j), ...
             c.rot.gcduptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.mdf.mehit(j), ...
                                                c.mdf.sphit,...
                                                c.talent.SelflessHealer);
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.epct(j)=1-c.rot.gcduptime(j);
            
        end
    else
        wb=waitbar(0,'Generating/Loading FSM data');
        for j=1:length(c.mdf.mehit)
            waitbar(j/val.length,wb,['FSM gen/load for ' c.exec.queue])
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadataa, ...
             c.rot.ssuptime(j), ...
             c.rot.efuptime(j), ...
             c.rot.wbuptime(j), ...
             c.rot.sbuptime(j), ...
             c.rot.gcduptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.mdf.mehit(j), ...
                                                c.mdf.sphit,...
                                                c.talent.SelflessHealer);
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.epct(j)=1-c.rot.gcduptime(j);
        end
        close(wb)
    end
else
    error('unrecognized array configuration in rotation_model')
end


%% correct for cases where cps is Nx1 but val.* is NxM
if size(c.rot.cps,2)==1 && size(c.abil.val.dmg,2)>1
    c.rot.cps=repmat(c.rot.cps,1,size(c.abil.val.dmg,2));
    c.rot.efuptime=repmat(c.rot.efuptime,1,size(c.abil.val.dmg,2));
    c.rot.ssuptime=repmat(c.rot.ssuptime,1,size(c.abil.val.dmg,2));
end

%% TODO: put dynamic_model here?

%% calculate total DPS and HPS
%note that a2cps includes all active and passive sources
c.rot.dps=sum(c.rot.cps.*c.abil.val.dmg);
c.rot.hps=sum(c.rot.cps.*c.abil.val.heal);
c.rot.mps=c.player.mps-sum(c.rot.cps.*c.abil.val.mcost); 

%calculate HPG
c.rot.hpg=c.rot.cps(1,:).*c.mdf.mehit+... %CS
          c.rot.cps(2,:).*c.mdf.mehit+... %HotR
          c.rot.cps(4,:).*c.mdf.sphit+... %J
          c.rot.cps(5,:).*c.mdf.sphit;    %AS - need a way to differentiate between GrCr and non-GrCr casts

%order fields alphabetically
c=orderfields(c);
end
