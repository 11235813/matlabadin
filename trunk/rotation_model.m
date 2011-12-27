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
for r=1:length(queue.rot);
    
    %tag
    rot(r).tag=queue.rot{r};
        
    %generate FSM results
    if length(mdf.mehit)==1 && length(mdf.rahit)==1
        [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{r}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
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
            fsm_gen(queue.rot{r}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
            for j=1:length(mdf.mehit)
                [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{r}, mdf.mehit(j), mdf.rahit(j), glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr,metadata,val.fsmlabel);
            end
        else
            wb=waitbar(0,'Generating/Loading FSM data');
            for j=1:length(mdf.mehit)
                waitbar(j/val.length,wb,['FSM gen/load for ' queue.rot{r}])
                [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{r}, mdf.mehit(j), mdf.rahit(j), glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr,metadata,val.fsmlabel);
            end
            close(wb)
        end
        
    %only mdf.mehit has more than one element (hit-capped but not xp capped)    
    elseif length(mdf.mehit)>1 && length(mdf.rahit)==1
        %use parallelization
        if useParallel
            fsm_gen(queue.rot{r}, mdf.mehit, mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
            for j=1:length(mdf.mehit)
                [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(queue.rot{r}, mdf.mehit(j), mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr, metadata,val.fsmlabel);
            end
        else
            wb=waitbar(0,'Generating/Loading FSM data');
            for j=1:length(mdf.mehit)
                waitbar(j/val.length,wb,['FSM gen/load for ' queue.rot{r}])
                [actionPr, metadata] = memoized_fsm(queue.rot{r}, mdf.mehit(j), mdf.rahit, glyph.Consecration, talent.EternalGlory, talent.SacredDuty, talent.GrandCrusader, mdf.t13x2R);
                inq(:,j) = inqUptime;
                [cps(:,j)]=action2cps(actionPr, metadata,val.fsmlabel);
            end
            close(wb)
        end
    else
        error('unrecognized array configuration in rotation_model')
    end  
    
    %store cps and inq
    rot(r).cps=cps;
    rot(r).inqup=inq;
    
    %correct for cases where cps is Nx1 but val.* is NxM
    if size(cps,2)==1 && size(val.fsmdmg,2)>1
        cps=repmat(cps,1,size(val.fsmdmg,2));
        inq=repmat(inq,1,size(val.fsmdmg,2));
    end
    
    %active sources
    rot(r).acdps=sum(cps.*val.fsmdmg);
    rot(r).achps=sum(cps.*val.fsmheal);
    rot(r).actps=sum(cps.*val.fsmthr);
    
    
    %passive sources (melee, seals, Censure)
    inqmod=1+0.3.*inq;
    rot(r).inqmod=inqmod;

    %melee and seals
    rot(r).melee=dps.Melee;
    rot(r).sealdps=dmg.activeseal.*mdf.mehit.*inqmod./player.wswing;
    rot(r).sealhps=heal.activeseal.*mdf.mehit./player.wswing;
    
    %Censure if applicable
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        rot(r).censdps=dps.Censure.*inqmod;
        rot(r).censtps=tps.Censure.*inqmod;
    else
        rot(r).censdps=0;
        rot(r).censtps=0;
    end
        
    %sum passive sources
    rot(r).padps=rot(r).melee+rot(r).sealdps+rot(r).censdps;
    rot(r).pahps=rot(r).sealhps;
    rot(r).patps=tps.Melee+mdf.RFury.*(rot(r).sealdps+rot(r).censdps+...
                                       mdf.hthreat.*rot(r).sealhps);
                                
    %sum active and passive
    rot(r).totdps=rot(r).padps+rot(r).acdps;
    rot(r).tothps=rot(r).pahps+rot(r).achps;
    rot(r).tottps=rot(r).patps+rot(r).actps;
    
    

end

clear r