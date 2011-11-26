%ROTATION_MODEL calculates the DPS/HPS output of a given rotation
clear cps inq

%parallelization flag
useParallel=1;

%define relevant queues if not done already
if exist('queue')==0 || isfield(queue,'rot')==0
    queue.rot={...
%         'SotR>CS>J>AS';
        'SotR>CS>AS+>J>AS>Cons>HW';
        'WoG>SotR>CS>AS+>J>AS>Cons>HW';
        'ISotR>SDSotR>Inq>CS>AS+>J>AS>Cons>HW';
%         'SotR>CS>AS>J';
%         'SotR>CS>HoW>AS>J';
%         'SotR>CS>HoW>AS>J>Cons>HW';
%         'WoG>HoW>SotR>CS>AS>J>Cons>HW';
        };
end

%initialize structure
%TODO: remove deprecated fields
rot=struct('tag','', ...
           'cps',[],...
           'inqup',[],...
           'inqmod',[],...
           'melee',[],...
           'sealdps',[],...
           'sealhps',[],...
           'acdps',[], ...
           'achps',[], ...
           'actps',[], ...
           'padps',[], ...
           'pahps',[], ...
           'patps',[], ...
           'totdps',[], ...
           'tothps',[], ...
           'tottps',[]);


%% Crank
for i=1:length(queue.rot);
    
    %tag
    rot(i).tag=queue.rot{i};
        
    %generate FSM results
    if length(mdf.mehit)==1 && length(mdf.rahit)==1
        [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{i}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
        %convert actionPr to CPS array
        inq = inqUptime;
        [cps]=action2cps(actionPr,metadata);
    
    %otherwise, we need some array handling, and may want to take advantage
    %of parallelization 
    
    %both mdf.mehit and mdf.rahit have more than one element - assumed to
    %be the same size
    elseif length(mdf.mehit)>1 && length(mdf.rahit)>1
        %use parallelization
        if useParallel
            fsm_gen(queue.rot{i}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
            for j=1:length(mdf.mehit)
                [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{i}, mdf.mehit(j), mdf.rahit(j), glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr,metadata,val.fsmlabel);
            end
        else
            wb=waitbar(0,'Generating/Loading FSM data');
            for j=1:length(mdf.mehit)
                waitbar(j/val.length,wb,['FSM gen/load for ' queue.rot{i}])
                [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{i}, mdf.mehit(j), mdf.rahit(j), glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr,metadata,val.fsmlabel);
            end
            close(wb)
        end
        
    %only mdf.mehit has more than one element (hit-capped but not xp capped)    
    elseif length(mdf.mehit)>1 && length(mdf.rahit)==1
        %use parallelization
        if useParallel
            fsm_gen(queue.rot{i}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
            for j=1:length(mdf.mehit)
                [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{i}, mdf.mehit(j), mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr, metadata,val.fsmlabel);
            end
        else
            wb=waitbar(0,'Generating/Loading FSM data');
            for j=1:length(mdf.mehit)
                waitbar(j/val.length,wb,['FSM gen/load for ' queue.rot{i}])
                [actionPr, metadata] = memoized_fsm(queue.rot{i}, mdf.mehit(j), mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr, metadata,val.fsmlabel);
            end
            close(wb)
        end
    else
        error('unrecognized array configuration in rotation_model')
    end  
    
    %store cps and inq
    rot(i).cps=cps;
    rot(i).inqup=inq;
    
    %correct for cases where cps is Nx1 but val.* is NxM
    if size(cps,2)==1 && size(val.fsmdmg,2)>1
        cps=repmat(cps,1,size(val.fsmdmg,2));
        inq=repmat(inq,1,size(val.fsmdmg,2));
    end
    
    %active sources
    rot(i).acdps=sum(cps.*val.fsmdmg);
    rot(i).achps=sum(cps.*val.fsmheal);
    rot(i).actps=sum(cps.*val.fsmthr);
    
    
    %passive sources (melee, seals, Censure)
    inqmod=1+0.3.*inq;
    rot(i).inqmod=inqmod;

    %melee and seals
    rot(i).melee=dps.Melee;
    rot(i).sealdps=dmg.activeseal.*mdf.mehit.*inqmod./player.wswing;
    rot(i).sealhps=heal.activeseal.*mdf.mehit./player.wswing;
    
        %Censure if applicable
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        rot(i).censdps=dps.Censure.*inqmod;
        rot(i).censtps=tps.Censure.*inqmod;
    else
        rot(i).censdps=0;
        rot(i).censtps=0;
    end
    
    %sum passive sources
    rot(i).padps=rot(i).melee+rot(i).sealdps+rot(i).censdps;
    rot(i).pahps=rot(i).sealhps;
    rot(i).patps=tps.Melee+mdf.RFury.*(rot(i).sealdps+rot(i).censdps+...
                                       mdf.hthreat.*rot(i).sealhps);
                                
    %sum active and passive
    rot(i).totdps=rot(i).padps+rot(i).acdps;
    rot(i).tothps=rot(i).pahps+rot(i).achps;
    rot(i).tottps=rot(i).patps+rot(i).actps;
    
    

end

clear i