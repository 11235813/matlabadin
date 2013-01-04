function [statblock]=warr_mc(config,statSetup,startCond)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;

%% Input handling
if ~exist('config')
    config=[];
end
if ~isfield(config,'tocFlag')
    tocFlag='toc';
else
    tocFlag=config.tocFlag;
end
if ~isfield(config,'plotFlag')
    plotFlag='plot';
else 
    plotFlag=config.plotFlag;
end
if ~isfield(config,'simMins')
    simMins=1000;
    warning(['simMins defaulting to ' int2str(simMins)])
else
    simMins=config.simMins;
end
if ~isfield(config,'val')
    val=1000;
    warning(['stat value defaulting to ' int2str(val)])
else
    val=config.val;
end
if ~isfield(config,'sF')
    sF=5;
    warning(['smoothing factor defaulting to ' int2str(sF)])
else
    sF=config.sF;
end
if ~isfield(config,'finisher')
    config.finisher='SBrBleed';
end
if ~isfield(config,'bossSwing')
    bossSwingTimer=1.5;
    warning(['boss swing timer factor defaulting to ' int2str(bossSwingTimer)])
else
    bossSwingTimer=config.bossSwing;
end

finisher=config.finisher;

if nargin>=1
    switch config.stat
        case 'hit'
            dhit=val;
        case 'exp'
            dexp=val;
        case 'haste'
            dhaste=val;
        case 'mastery'
            dmastery=val;
        case 'dodge'    
            ddodge=val;
        case 'parry'
            dparry=val;
    end
end

if nargin<3
    startCond.rage=0;
    startCond.prio='steadystate';
    startCond.stepspersecond=2;
end

%% Initialize different random streams
RandStream.setDefaultStream ...
     (RandStream('mt19937ar','seed',sum(100*clock)));
 
%% Player stats
if nargin<2 || isempty(statSetup)
    buffedStr=11000;
    parryRating=3000;
    dodgeRating=3000;
    masteryRating=3500;
    hitRating=2550;
    expRating=5100;
    armor=63500;
else
    buffedStr=statSetup.buffedStr;
    parryRating=statSetup.parryRating;
    dodgeRating=statSetup.dodgeRating;
    masteryRating=statSetup.masteryRating;
    hitRating=statSetup.hitRating;
    expRating=statSetup.expRating;
    armor=statSetup.armor;
end

%toggle off hit/exp
% hitRating=0;
% expRating=0;

%other
meta=1; %toggle for block meta, 1 is on, 0 is off
blockDmg=1-(0.3+meta./100);
critBlockDmg=1-2.*(0.3+meta./100);
armorMit=1-armor./(armor+58370);
% armorMit=1-0.57;
specMit=1-0.25;
wbMit=0.9;
%% Define constants/variables
bossRawDPS=310000;
bossRawSwingDamage=bossRawDPS.*bossSwingTimer;
Cd=90.6425;
Cp=237.1860;
Cb=150.3759;
k=0.956;
SnBProcRate=0.3;
SnBBuffDuration=5;

%Vengeance info
bossSwingDamage=bossRawSwingDamage.*armorMit.*specMit.*wbMit;
avgVengAP=0.4*bossRawDPS;
shieldBarrierAbsorb=2*(1.1.*avgVengAP+0.2.*buffedStr)./bossSwingDamage;

%% calculate stats
mastery=17.6+(masteryRating+dmastery).*2.2./600;
blockCS=3+10+meta+1./(1./Cb+k./(mastery.*0.5./2.2));
critBlock=double((meta+mastery)./100);
% miss=0;
dodgeCS=5.01+1./(1./Cd+k./((dodgeRating+ddodge)./885));
parryCS=3.21+1./(1./Cp+k./((buffedStr-203)./951.16+(parryRating+dparry)./885));

avoidance=double((dodgeCS+parryCS-9)./100);
block=double((blockCS-4.5)./100);

% haste=(hasteRating+dhaste)./425./100;

hit=(hitRating+dhit)./340./100;
exp=(expRating+dexp)./340./100;

miss=max(0,0.075-hit);
dodge=max(0,(0.075-exp));
parry=max(0,(0.075-max((exp-0.075),0)));


%initialize Rage
rage=startCond.rage;

%% Define events, cooldowns and buffs to track
events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;
%start boss swing timer at 0.5 seconds, just to de-synch from GCD
%not strictly necessary, I think, as rage generation should shuffle SB
%around significantly, but just to be safe...
tbe(1)=0.4;

buffs={'SB duration','SB charge 1','SB charge 2','SnB duration','WB duration','SS cooldown',...
       'Rev cooldown','BS cooldown','Tclap cooldown','CBE cd','Berserker Rage CD','SBr duration','SBr cd'};
tob = zeros(size(buffs));
idSB=1;
idSBcd1=2;
idSBcd2=3;
idSnB=4;
idWB=5;
idSScd=6;
idRcd=7;
idBScd=8;
idTCcd=9;
idCBEcd=10;
idBRcd=11;
idSBr=12;
idSBrcd=13;

simTime=simMins*60;
steps_per_sec=startCond.stepspersecond;

%preallocate arrays
N=floor(simTime.*steps_per_sec);
dt=1./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
SBUptime=t;
WBUptime=t;
SBCasts=0;
SBrCasts=0;
rageGain=0;
dsRage=0;
xsRage=0;
SBrAmount=0;
% SBrTrack(1)=0;
SBTrack=zeros(N,1);
SBrTrack=SBTrack;
SBrRage=SBTrack;

%tracking
avoids=0;
blocks=0;
critblocks=0;
hits=0;

cbFullAbsorbs=0;
cbPartialAbsorbs=0;
bFullAbsorbs=0;
bPartialAbsorbs=0;
hFullAbsorbs=0;
hPartialAbsorbs=0;

%%for loop to do event handling
tic
for k=1:N
    
    %record time
    t(k)=(k-1).*dt;
    
    %figure out if any of the event timers is 0 or less
    ids=find(tbe<=0);
    
    
    
    %event handling
    for j=1:length(ids)
                
        %Berserker Rage - use if available
        if tob(idBRcd)<=0 && rage<110
            %set BR cooldown
            tob(idBRcd)=30;
            %add rage
            rage=rage+10;
            rageGain=rageGain+10;
        end
        
        switch ids(j)
                %if the GCD timer is up, see if there's something to cast
            case idGCD
                
                %Defensive Stance
                dsRage=dsRage+0.5;
                if dsRage==1
                    rage=rage+1;
                    rageGain=rageGain+1;
                    dsRage=0;
                end
                
                %check for 60+ rage; if so cast SB
                finisherCast(finisher);
                
                gcdPriority(startCond.prio)
                                
                %enforce rage bounds - only need one to cover all of the
                %possible GCD cast choices
                if rage>120
                    xsRage=xsRage+(rage-120);
                    rage=min([rage 120]);
                end
            
            %boss swing
            case idBossSwing
                
                %update SBr
                if tob(idSBr)<=0
                    SBrAmount=0;
                end
                
                %check for 60+ rage; if so cast SB
                finisherCast(finisher);
                
                %reset boss swing timer
                tbe(idBossSwing)=bossSwingTimer;
                
                %check for avoid
                if rand < avoidance
                    damage(k)=0;
                    %reset Revenge CD
                    tob(idRcd)=0;
                    avoids=avoids+1;
                else
                    %figure out damage value.  If SB is up or we block,
                    %set to 0.7 or 0.4.  Otherwise, set to 1.
                    if tob(idSB)>0 || rand < block
                        %check for crit block
                        if rand < critBlock
                            critblocks=critblocks+1;
                            if SBrAmount>=critBlockDmg
                                damage(k)=0;
                                SBrAmount=SBrAmount-critBlockDmg;
                                cbFullAbsorbs=cbFullAbsorbs+1;
                            else
                                if SBrAmount>0
                                    cbPartialAbsorbs=cbPartialAbsorbs+1;
                                end
                                damage(k)=critBlockDmg-SBrAmount;
                                SBrAmount=0;
                            end
                            %gain rage
                            if tob(idCBEcd)<=0
                                rage=rage+10;
                                rageGain=rageGain+10;
                                tob(idCBEcd)=3;
                            end
                        %otherwise, normal block
                        else
                            blocks=blocks+1;
                            if SBrAmount>=blockDmg
                                damage(k)=0;
                                SBrAmount-SBrAmount-blockDmg;
                                bFullAbsorbs=bFullAbsorbs+1;
                            else
                                damage(k)=blockDmg-SBrAmount;
                                if SBrAmount>0
                                    bPartialAbsorbs=bPartialAbsorbs+1;
                                end
                                SBrAmount=0;
                            end
                        end
                    else
                        hits=hits+1;
                        if SBrAmount>1
                            damage(k)=0;
                            SBrAmount=SBrAmount-1;
                            hFullAbsorbs=hFullAbsorbs+1;
                        elseif SBrAmount>0
                            damage(k)=1-SBrAmount;
                            SBrAmount=0;
                            hPartialAbsorbs=hPartialAbsorbs+1;
                        else
                            damage(k)=1;                         
                        end
                    end
                    %enforce rage bounds
                    if rage>120
                        xsRage=xsRage+(rage-120);
                        rage=min([rage 120]);
                    end
                end
                
                %Debugging
%                 if rage==120
%                     warning('Rage overflow')
%                 end
                
        end %close switch
        
    end %close event for
    
    
    
    %% Debugging
    SBUptime(k,1)=tob(idSB);
    WBUptime(k,1)=tob(idWB);
%     SotRUptimeotR(k,1)=tob(idSotRcd);
%     debugHP(k,1)=hp;
    
    %increment time by decreasing tob and tbe
    tbe=tbe-dt;
    tob=tob-dt;
    
    %fix SotR at 0
    tob(idSB)=max(tob(idSB),0);
end
if ~strcmp(tocFlag,'notoc')
    toc
end

%% compile for plots
dmg=damage(damage>=0);
statblock.dmg=dmg;

%sanity check
if hits+blocks+critblocks+avoids~=length(dmg)
    error('reporting error, length(dmg) doesn''t match number of events')
else
    numEvents=length(dmg);
end

statblock.S=sum(SBUptime>0)./length(SBUptime);
statblock.avoidsPct=avoids./numEvents;
statblock.blocksPct=blocks./numEvents;
statblock.critblocksPct=critblocks./numEvents;
statblock.hitsPct=hits./numEvents;

statblock.hFullAbsorbsPct=hFullAbsorbs./numEvents;
statblock.hPartialAbsorbsPct=hPartialAbsorbs./numEvents;
statblock.cbFullAbsorbsPct=cbFullAbsorbs./numEvents;
statblock.cbPartialAbsorbsPct=cbPartialAbsorbs./numEvents;
statblock.bFullAbsorbsPct=bFullAbsorbs./numEvents;
statblock.bPartialAbsorbsPct=bPartialAbsorbs./numEvents;

statblock.allFullAbsorbs=hFullAbsorbs+cbFullAbsorbs+bFullAbsorbs;
statblock.allFullAbsorbsPct=statblock.allFullAbsorbs./numEvents;
% partialAbsorbsPct=partialAbsorbs./numEvents;
% fullHitsPct=fullHits./numEvents;
% fullHitAbsorbsPct=fullHitAbsorbs./numEvents;
% cbPartialAbsorbsPct=cbPartialAbsorbs./numEvents;


statblock.block=block;
statblock.avoidance=avoidance;

statblock.rageGain=rageGain;
statblock.xsRage=xsRage;
statblock.Rrage=rageGain./simTime;
statblock.SBCasts=SBCasts;
statblock.SBrCasts=SBrCasts;
statblock.Tsb = simTime./SBCasts;
statblock.Rsb = 1/statblock.Tsb;
statblock.Tsbr= simTime./SBrCasts;
statblock.Rsbr= 1/statblock.Tsbr;
statblock.SBrTrack=SBrTrack;
statblock.SBTrack=SBTrack;
statblock.SBrRage=SBrRage;

statblock.DTPS=sum(dmg)./simTime;
statblock.maDTPS=filter(ones(1,5)./5,1,dmg);
statblock.mean_ma=mean(statblock.maDTPS);
statblock.std_ma=std(statblock.maDTPS);


statblock.simMins=simMins;
statblock.simTime=simTime;
statblock.stepsPerSec=steps_per_sec;
statblock.bossSwingTimer=bossSwingTimer;

statblock.critBlockDmg=critBlockDmg;
statblock.blockDmg=blockDmg;

%% plot

if ~strcmp(plotFlag,'noplot')
    warr_mc_plot(config,statblock,sF)
end

%% helper functions

    function shieldBlockCast()
        
        
        %check for 60+ rage; if so cast SB
        if ( rage>=60 ) && (tob(idSBcd1)<=0  || tob(idSBcd2)<=0)
            %give 6 seconds of SB
            tob(idSB)=tob(idSB)+6;
            %handle charges.  If both available, use #1
            if tob(idSBcd1)<=0 && tob(idSBcd2)<=0
                tob(idSBcd1)=9;
                %if only #1 is available, use it
            elseif tob(idSBcd1)<=0 && tob(idSBcd2)>0
                tob(idSBcd1)=9+tob(idSBcd2);
                %if only #2 is available, use it
            elseif tob(idSBcd2)<=0 && tob(idSBcd1)>0
                tob(idSBcd2)=9+tob(idSBcd1);
                %just in case - debugging
            else
                error('WTF')
            end
            %Consume rage
            rage=rage-60;
            %enforce minimum rage (shouldn't be necessary, but..)
            rage=max([rage;0]);
            %track for cast rate
            SBCasts=SBCasts+1;
            SBTrack(k)=1;
        end
    end

    function shieldBarrierCast()
        if (rage>=20) && tob(idSBrcd)<=0
            %give 6 seconds of SBr
            tob(idSBr)=6;
            %set cooldown
            tob(idSBrcd)=1.5;
            %determine amount of rage to use
            stacks=min(floor(rage./20),3);
            %set absorb value
            SBrAmount=shieldBarrierAbsorb.*stacks./3;
            %consume rage
            SBrRage(k)=rage;
            rage=rage-stacks.*20;
            %track for cast rate
            SBrCasts=SBrCasts+1;
            SBrTrack(k)=stacks.*20;
        end
    end

    function finisherCast(finisher)                
        
        if strcmpi(finisher,'SB')
            shieldBlockCast()
        elseif strcmpi(finisher,'SBr')
            shieldBarrierCast()
        elseif strcmpi(finisher,'SBr*')
            if tob(idSBr)<=0
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'SBr60')
            %if we have 6 rage, pop barrier
            if rage>=60
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'SBr60*')
            %if we have 6 rage, pop barrier
            if rage>=60 && tob(idSBr)<=0
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'B-100') %use SBarr to bleed rage >100
            %first, try and use Shield Block
            shieldBlockCast();
            %if we still have excess rage, pop barrier
            if rage>=100
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'B-105') %use SBarr to bleed rage >100
            %first, try and use Shield Block
            shieldBlockCast();
            %if we still have excess rage, pop barrier
            if rage>=105
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'B-110') %use SBarr to bleed rage >100
            %first, try and use Shield Block
            shieldBlockCast();
            %if we still have excess rage, pop barrier
            if rage>=110
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'B-115') %use SBarr to bleed rage >100
            %first, try and use Shield Block
            shieldBlockCast();
            %if we still have excess rage, pop barrier
            if rage>=115
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'B-120') %use SBarr to bleed rage >100
            %first, try and use Shield Block
            shieldBlockCast();
            %if we still have excess rage, pop barrier
            if rage>=120
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W3-105')
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon, pop barrier
            if (rage>=20 && tob(idSBcd1)>3 && tob(idSBcd2)>3 && tob(idSB)<=0 && tob(idSBr)<=0) || (rage>=105)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W3-110')
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon, pop barrier
            if (rage>=20 && tob(idSBcd1)>3 && tob(idSBcd2)>3 && tob(idSB)<=0 && tob(idSBr)<=0) || (rage>=110)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W3-115')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>3 && tob(idSBcd2)>3 && tob(idSB)<=0 && tob(idSBr)<=0) || (rage>=115)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W3-120')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>3 && tob(idSBcd2)>3 && tob(idSB)<=0 && tob(idSBr)<=0) || (rage>=120)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W4')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>=4 && tob(idSBcd2)>=4 && tob(idSB)<=0 && tob(idSBr)<=0) 
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W3')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>=3 && tob(idSBcd2)>=3 && tob(idSB)<=0 && tob(idSBr)<=0)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W3.5')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>=3.5 && tob(idSBcd2)>=3.5 && tob(idSB)<=0 && tob(idSBr)<=0)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W2')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>=2 && tob(idSBcd2)>=2 && tob(idSB)<=0 && tob(idSBr)<=0)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W2.5')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>=2.5 && tob(idSBcd2)>=2.5 && tob(idSB)<=0 && tob(idSBr)<=0)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'W1')            
            %first, try and use Shield Block
            shieldBlockCast();
            %if we have excess rage AND SB isn't available soon and SB
            %isn't up
            if (rage>=20 && tob(idSBcd1)>=1 && tob(idSBcd2)>=1 && tob(idSB)<=0 && tob(idSBr)<=0)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'F0-120')            
            %first, try and use Shield Block - only if neither SBr or SB
            %are up
            if tob(idSB)<=0 && tob(idSBr)<=0
                shieldBlockCast();
            end
            %if we have rage and SB/SBr not up OR bleed
            %isn't up
            if (rage>=20 && tob(idSB)<=0 && tob(idSBr)<=0) || (rage>=120)
                shieldBarrierCast()
            end
        elseif strcmpi(finisher,'F1-120')            
            %first, try and use Shield Block - only if neither SBr or SB
            %are up
            if tob(idSB)<=0 && tob(idSBr)<=0
                shieldBlockCast();
            end
            %if we have excess rage AND SB/SBr isn't up
            if (rage>=20 && tob(idSBcd1)>1 && tob(idSBcd2)>1 && tob(idSB)<=0 && tob(idSBr)<=0) || (rage>=120)
                shieldBarrierCast()
            end
        else
            error('invalid finisher specification')
        end
        
    end

    function gcdPriority(prio)
        if strcmp(prio,'short') %30-second priority, SS>Rev>BS>Dev
            
             %SS is first priority
                if tob(idSScd)<=0
                    %put SS on cooldown, start GCD
                    tob(idSScd)=6;
                    tbe(idGCD)=1.5;
                    %Check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant rage
                        rage=rage+20;
                        rageGain=rageGain+20;
                        %consume Sword and Board
                        if tob(idSnB)>0
                            rage=rage+5;
                            rageGain=rageGain+5;
                            tob(idSnB)=0;
                        end
                    end
                %Rev is second priority, check for cooldown and don't use
                %if SS cd is almost up
                elseif tob(idRcd)<=0 && tob(idSScd)>=0.2
                    %set R cooldown, start GCD
                    tob(idRcd)=9;
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant rage, enforce bounds
                        rage=rage+15;
                        rageGain=rageGain+15;
                    end
                %Battle Shout - use on cooldown if it won't cap rage
                elseif tob(idBScd)<=0 && rage<=100;
                    %set BS cooldown, start GCD
                    tob(idBScd)=60;
                    tbe(idGCD)=1.5;
                    %add rage
                    rage=rage+20;
                    rageGain=rageGain+20;
                %Dev - use if empty and nothing else was used. Hold if we
                %somehow caused a near-clash with SS
                elseif tob(idSScd)>=0.2
                    %start GCD
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! check for Sword and Board
                        if rand<SnBProcRate
                            %success! grant SnB buff
                            tob(idSnB)=SnBBuffDuration;
                        end
                    end
                end
                
                %enforce rage bounds - only need one to cover all of the
                %possible GCD cast choices
                if rage>120
                    xsRage=xsRage+(rage-120);
                    rage=min([rage 120]);
                end
    
        else %default priority, SS>Rev>BS>TC>Dev
            
                %SS is first priority
                if tob(idSScd)<=0
                    %put SS on cooldown, start GCD
                    tob(idSScd)=6;
                    tbe(idGCD)=1.5;
                    %Check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant rage
                        rage=rage+20;
                        rageGain=rageGain+20;
                        %consume Sword and Board
                        if tob(idSnB)>0
                            rage=rage+5;
                            rageGain=rageGain+5;
                            tob(idSnB)=0;
                        end
                    end
                %Rev is second priority, check for cooldown and don't use
                %if SS cd is almost up
                elseif tob(idRcd)<=0 && tob(idSScd)>=0.2
                    %set R cooldown, start GCD
                    tob(idRcd)=9;
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant rage, enforce bounds
                        rage=rage+15;
                        rageGain=rageGain+15;
                    end
                %Battle Shout - use on cooldown if it won't cap rage
                elseif tob(idBScd)<=0 && rage<=100 && tob(idSScd)>=0.2;
                    %set BS cooldown, start GCD
                    tob(idBScd)=60;
                    tbe(idGCD)=1.5;
                    %add rage
                    rage=rage+20;
                    rageGain=rageGain+20;            
                %Thunder Clap - use if WB isn't up
                elseif tob(idWB)<=0 && tob(idTCcd)<=0 && tob(idSScd)>=0.2
                    %set TC cooldown, start GCD
                    tob(idTCcd)=6;
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge)
                        %apply WB
                        tob(idWB)=30;
                    end
                %Dev - use if empty and nothing else was used. Hold if we
                %somehow caused a near-clash with SS
                elseif tob(idSScd)>=0.2
                    %start GCD
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! check for Sword and Board
                        if rand<SnBProcRate
                            %success! grant SnB buff
                            tob(idSnB)=SnBBuffDuration;
                        end
                    end
                end
        end
       
        
    end

end