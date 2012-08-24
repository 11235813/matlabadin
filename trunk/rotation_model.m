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
if isfield(c.exec,'queue')==0 || isempty(c.exec.queue)
    c.exec.queue='^WB>CS>J>AS>^SS>Cons>HW>SotR';
end

%repackage arguments for memoized_fsm and fsm_gen:
talentString=strrep(int2str(c.talent.short),' ','');
glyphString=c.glyph.string;
decimalHaste=c.player.phhaste./100;
pBuffs=',';
if c.buff.AW
    pBuffs=[pBuffs 'AW,'];
end
if c.buff.HA
    pBuffs=[pBuffs 'HA,'];
end
% if c.buff.BLust
%     pBuffs=[pBuffs 'BL,'];
% end


%% Crank

%generate FSM results
if length(c.mdf.mehit)==1 && length(c.mdf.jdhit)==1 && length(c.player.wswing)==1
       [c.rot.actionPr, ...
        c.rot.metadata, ...
        c.rot.uptime] = memoized_fsm(c.exec.queue, ...
                                        c.spec.name, ...
                                        talentString, ...
                                        glyphString, ...
                                        decimalHaste,...
                                        c.mdf.mehit, ...
                                        c.mdf.jdhit,...
                                        pBuffs); 
    %convert actionPr to CPS array
    [c.rot.cps c.rot.ecpsd c.rot.ecpsh c.rot.hpg]=action2cps(c);
    
%otherwise, we need some array handling, and may want to take advantage
%of parallelization

%mdf.mehit, mdf.sphit, and decimalHaste have one element, but player.wswing is 1xN -
%str scaling (via parry->parryhaste)
elseif length(c.mdf.mehit)==1 && length(c.mdf.jdhit)==1 && length(decimalHaste)==1 && length(c.player.wswing)>1
    %only need one fsm generation
       [c.rot.actionPr, ...
        c.rot.metadata, ...
        c.rot.uptime] = memoized_fsm(c.exec.queue, ...
                                        c.spec.name, ...
                                        talentString, ...
                                        glyphString, ...
                                        decimalHaste,...
                                        c.mdf.mehit, ...
                                        c.mdf.jdhit,...
                                        pBuffs); 
    %the conversion to a CPS array needs to be handled appropriately though
    for j=1:length(c.player.wswing)
        [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
    end

%mdf.mehit & mdf.sphit have one element, but decimalHaste is 1xN
%haste scaling
elseif length(c.mdf.mehit)==1 && length(c.mdf.jdhit)==1 && length(decimalHaste)>1 
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.spec.name, talentString, glyphString, decimalHaste, c.mdf.mehit, c.mdf.jdhit, pBuffs);
        for j=1:length(decimalHaste)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadata, ...
             c.rot.uptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.spec.name,...
                                                talentString,...
                                                glyphString, ...
                                                decimalHaste(j),...
                                                c.mdf.mehit, ...
                                                c.mdf.jdhit,...
                                                pBuffs);
            [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
        end
    else
        wb=waitbar(0,'Generating/Loading FSM data');
        for j=1:length(decimalHaste)
            waitbar(j/val.length,wb,['FSM gen/load for ' c.exec.queue])
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadataa, ...
             c.rot.uptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.spec.name,...
                                                talentString,...
                                                glyphString, ...
                                                decimalHaste(j),...
                                                c.mdf.mehit, ...
                                                c.mdf.jdhit,...
                                                pBuffs);
            [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
        end
        close(wb)
    end  
    
%both mdf.mehit and mdf.sphit have more than one element - assumed to
%be the same size
elseif length(c.mdf.mehit)>1 && length(c.mdf.jdhit)>1
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.spec.name, talentString, glyphString, decimalHaste, c.mdf.mehit, c.mdf.jdhit, pBuffs);
        for j=1:length(c.mdf.mehit)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadata, ...
             c.rot.uptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.spec.name,...
                                                talentString,...
                                                glyphString, ...
                                                decimalHaste,...
                                                c.mdf.mehit(j), ...
                                                c.mdf.jdhit(j),...
                                                pBuffs);
            [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
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
             c.rot.uptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.spec.name,...
                                                talentString,...
                                                glyphString, ...
                                                decimalHaste,...
                                                c.mdf.mehit(j), ...
                                                c.mdf.jdhit(j),...
                                                pBuffs);
            [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
        end
        close(wb)
    end
    
%only mdf.mehit has more than one element (can this even happen anymore?)
elseif length(c.mdf.mehit)>1 && length(c.mdf.jdhit)==1
    %use parallelization
    if useParallel
        fsm_gen(c.exec.queue, c.spec.name, talentString, glyphString, decimalHaste, c.mdf.mehit, c.mdf.jdhit, pBuffs);
        for j=1:length(c.mdf.mehit)
            %note that actionPr and metadata are overwritten on every
            %iteration.  This data is automatically stored in cps, and this
            %prevents us from having to do awkward multiple-indexed cell
            %operations within c.rot.actionPr.
            [c.rot.actionPr, ...
             c.rot.metadataa, ...
             c.rot.uptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.spec.name,...
                                                talentString,...
                                                glyphString, ...
                                                decimalHaste,...
                                                c.mdf.mehit(j), ...
                                                c.mdf.jdhit,...
                                                pBuffs);
            [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
            
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
             c.rot.uptime(j)] = memoized_fsm(c.exec.queue, ...
                                                c.spec.name,...
                                                talentString,...
                                                glyphString, ...
                                                decimalHaste,...
                                                c.mdf.mehit(j), ...
                                                c.mdf.jdhit,...
                                                pBuffs);
            [c.rot.cps(:,j) c.rot.ecpsd(:,j) c.rot.ecpsh(:,j) c.rot.hpg(j)]=action2cps(c,j);
        end
        close(wb)
    end
else
    error('unrecognized array configuration in rotation_model')
end

%% unpack uptimes
c.rot.ssuptime=[c.rot.uptime.ss];
c.rot.efuptime=[c.rot.uptime.ef];
c.rot.wbuptime=[c.rot.uptime.wb];
c.rot.sbuptime=[c.rot.uptime.sb];
c.rot.awuptime=[c.rot.uptime.aw];
% c.rot.gowoguptime=[c.rot.uptime.gowog];
c.rot.gcduptime=[c.rot.uptime.gcd];
%empties tracking - this is % empty gcds
c.rot.epct=1-[c.rot.uptime.gcd];


%% correct for cases where cps is Nx1 but val.* is NxM
if size(c.rot.cps,2)==1 && size(c.abil.val.dmg,2)>1
    c.rot.cps=repmat(c.rot.cps,1,size(c.abil.val.dmg,2));
    c.rot.efuptime=repmat(c.rot.efuptime,1,size(c.abil.val.dmg,2));
    c.rot.ssuptime=repmat(c.rot.ssuptime,1,size(c.abil.val.dmg,2));
end

%% dynamic model - effects that depend on rotation details

c=dynamic_model(c);

             
%% calculate total DPS and HPS
%note that a2cps includes all active and passive sources
c.rot.dps=sum(c.rot.ecpsd.*c.abil.val.dmg.*c.dyn.multdps)+c.dyn.flatdps;
c.rot.hps=sum(c.rot.ecpsh.*c.abil.val.heal);
c.rot.mps=c.player.mps-sum(c.rot.cps.*c.abil.val.mcost); 

%order fields alphabetically
c=orderfields(c);
end
