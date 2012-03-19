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
    c.exec.queue='SotR>CS>J>AS>Cons';
end


%% Crank

%generate FSM results
if length(c.mdf.mehit)==1 && length(c.mdf.rahit)==1 && length(c.player.wswing)==1
    [c.rot.actionPr, c.rot.metadata, c.rot.ssuptime, ...
        c.rot.efuptime, c.rot.wbuptime, c.rot.sbuptime] = ...
        memoized_fsm(c.exec.queue, c.mdf.mehit, c.mdf.rahit); 
    %convert actionPr to CPS array
    c.rot.cps=action2cps(c);
    %empties tracking - this is "dead time"; to get % empty GCDs multiply
    %by 3/2
    c.rot.eps=c.rot.cps(size(c.rot.cps,1));
    c.rot.epct=c.rot.eps.*3/2;
    
%otherwise, we need some array handling, and may want to take advantage
%of parallelization

%mdf.mehit and mdf.rahit have one element, but player.wswing is 1xN -
%haste, str scaling (via parry->parryhaste)
elseif length(c.mdf.mehit)==1 && length(c.mdf.rahit)==1 && length(c.player.wswing)>1
    %only need one fsm generation
    [c.rot.actionPr, c.rot.metadata, c.rot.ssuptime, ...
        c.rot.efuptime, c.rot.wbuptime, c.rot.sbuptime] = ...
        memoized_fsm(c.exec.queue, c.mdf.mehit, c.mdf.rahit);
    %the conversion to a CPS array needs to be handled appropriately though
    for j=1:length(c.player.wswing)
        [c.rot.cps(:,j)]=action2cps(c,j);
        %empties tracking
        c.rot.eps(j)=c.rot.cps(size(c.rot.cps,1),j);
        c.rot.epct(j)=c.rot.eps(j).*3/2;
    end
        
    
%both mdf.mehit and mdf.rahit have more than one element - assumed to
%be the same size
elseif length(c.mdf.mehit)>1 && length(c.mdf.rahit)>1
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.mdf.mehit, c.mdf.rahit);
        for j=1:length(c.mdf.mehit)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, c.rot.metadata, c.rot.ssuptime(j), ...
                c.rot.efuptime(j), c.rot.wbuptime(j), c.rot.sbuptime(j)] = ...
                memoized_fsm(c.exec.queue, c.mdf.mehit(j), c.mdf.rahit(j));
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.eps(j)=c.rot.cps(size(c.rot.cps,1),j);
            c.rot.epct(j)=c.rot.eps(j).*3/2;
        end
    else
        wb=waitbar(0,'Generating/Loading FSM data');
        for j=1:length(c.mdf.mehit)
            waitbar(j/val.length,wb,['FSM gen/load for ' c.exec.queue])
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, c.rot.metadataa, c.rot.ssuptime(j), ...
                c.rot.efuptime(j), c.rot.wbuptime(j), c.rot.sbuptime(j)] = ...
                memoized_fsm(c.exec.queue, c.mdf.mehit(j), c.mdf.rahit(j));
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.eps(j)=c.rot.cps(size(c.rot.cps,1),j);
            c.rot.epct(j)=c.rot.eps(j).*3/2;
        end
        close(wb)
    end
    
    %only mdf.mehit has more than one element (hit-capped but not xp capped)
elseif length(c.mdf.mehit)>1 && length(c.mdf.rahit)==1
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.mdf.mehit, c.mdf.rahit);
        for j=1:length(c.mdf.mehit)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, c.rot.metadataa, c.rot.ssuptime(j), ...
                c.rot.efuptime(j), c.rot.wbuptime(j), c.rot.sbuptime(j)] = ...
                memoized_fsm(c.exec.queue, c.mdf.mehit(j), c.mdf.rahit);
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.eps(j)=c.rot.cps(size(c.rot.cps,1),j);
            c.rot.epct(j)=c.rot.eps(j).*3/2;
            
        end
    else
        wb=waitbar(0,'Generating/Loading FSM data');
        for j=1:length(c.mdf.mehit)
            waitbar(j/val.length,wb,['FSM gen/load for ' c.exec.queue])
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [actionPr, metadataa, c.rot.ssuptime(j), ...
                c.rot.efuptime(j), c.rot.wbuptime(j), c.rot.sbuptime(j)] = ...
                memoized_fsm(c.exec.queue, c.mdf.mehit(j), c.mdf.rahit);
            [c.rot.cps(:,j)]=action2cps(c,j);
            %empties tracking
            c.rot.eps(j)=c.rot.cps(size(c.rot.cps,1),j);
            c.rot.epct(j)=c.rot.eps(j).*3/2;
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
%     rot(r).actps=sum(cps.*val.fsmthr);

%calculate HPG
c.rot.hpg=c.rot.cps(1,:).*c.mdf.mehit+... %CS
          c.rot.cps(2,:).*c.mdf.mehit+... %HotR
          c.rot.cps(4,:).*c.mdf.rahit+... %J
          c.rot.cps(5,:).*c.mdf.rahit;    %AS - need a way to differentiate between GrCr and non-GrCr casts

%order fields alphabetically
c=orderfields(c);
end
