function [statblock]=pally_mc(config,statSetup)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;

%% Input handling - config - stat,val,simMins,plotFlag,tocFlag
if ~exist('config')
    config=[];
end
if ~isfield(config,'tocFlag')
    config.tocFlag='toc';
end
tocFlag=config.tocFlag;

if ~isfield(config,'plotFlag')
    config.plotFlag='plot';
end
plotFlag=config.plotFlag;

if ~isfield(config,'simMins')
    config.simMins=500;
    warning(['simMins defaulting to ' int2str(config.simMins)])
end
simMins=config.simMins;

if ~isfield(config,'val')
    config.val=600;
    warning(['stat value defaulting to ' int2str(config.val)])
end
val=config.val;

if ~isfield(config,'sF')
    config.sF=5;
    warning(['smoothing factor defaulting to ' int2str(config.sF)])
end
sF=config.sF;

if ~isfield(config,'finisher')
    config.finisher='S';
end

if ~isfield(config,'bossSwingTimer')
    config.bossSwingTimer=1.5;
    warning(['boss swing timer factor defaulting to ' num2str(config.bossSwingTimer,'%2.2f')])
end
bossSwingTimer=config.bossSwingTimer;

if ~isfield(config,'WoGoverheal')
    config.WoGoverheal=0.5;
    warning(['WoG overheal defaulting to ' int2str(config.WoGoverheal.*100) '%'])
end
WoGoverheal=config.WoGoverheal;

if ~isfield(config,'WoGfakeBubbleDuration')
    config.WoGfakeBubbleDuration=3;
    warning(['WoG fake bubble duration defaulting to ' num2str(config.WoGfakeBubbleDuration,'%2.2f') 's'])
end
WoGfakeBubbleDuration=config.WoGfakeBubbleDuration;

if ~isfield(config,'t152pcEquipped')
    config.t152pcEquipped=0;
    warning(['T15 2-piece bonus defaulting to off'])
end
t152pcEquipped=config.t152pcEquipped;

%% Finisher priority Queue handling
finisher=config.finisher;
n=regexp(finisher,'(?<ftype>[a-zA-Z]+)(?<lockstr>\d*\.?\d*)-?(?<bleedstr>\d*)(?<ovrw>\**)','names');
ftype=n.ftype;
bleed=str2double(n.bleedstr);
lock=str2double(n.lockstr);
ovrw=~strcmpi(n.ovrw,'*');
%%
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

%% Initialize different random streams
RandStream.setDefaultStream ...
     (RandStream('mt19937ar','seed',sum(100*clock)));
 
%% Player stats
if nargin<2
    buffedStr=9208;
    parryRating=4834;
    dodgeRating=4892;
    masteryRating=6758;
    hitRating=900;
    expRating=1777;
    hasteRating=621;
    armor=60000;
else
    buffedStr=statSetup.buffedStr;
    parryRating=statSetup.parryRating;
    dodgeRating=statSetup.dodgeRating;
    masteryRating=statSetup.masteryRating;
    hitRating=statSetup.hitRating;
    expRating=statSetup.expRating;
    hasteRating=statSetup.hasteRating;
    armor=statSetup.armor;
end

%artificially set hit/exp to zero
% hitRating=0;
% expRating=0;
armorMit=1-armor./(armor+58370);
specMit=1-0.15;
wbMit=0.9;


%% Define constants/variables
Cd=66.56745;
Cp=237.186;
Cb=150.3759;
k=0.886;
gcProcRate=0.2;
gcBuffDuration=6.3;
% dpProcRate=0.25;
dpProcRate=0;
dpBuffDuration=8;

%Vengeance info
bossRawDPS=310000;
bossRawSwingDamage=bossRawDPS.*bossSwingTimer;
bossSwingDamage=bossRawSwingDamage.*armorMit.*specMit.*wbMit;
avgVengAP=0.36*bossRawDPS;
AP=floor(1.1.*(avgVengAP+270+2.*(buffedStr-10)));
WoGHealBase=(5538+0.49.*AP./2).*1.05./bossSwingDamage.*(1-WoGoverheal);


%% calculate stats
mastery=8+(masteryRating+dmastery)./600;
blockCS=3+10+1./(1./Cb+k./mastery);
miss=0;
dodgeCS=5.01+1./(1./Cd+k./((dodgeRating+ddodge)./885));
parryCS=3.19+1./(1./Cp+k./((buffedStr-178)./951.158596+(parryRating+dparry)./885));

avoidance=(dodgeCS+parryCS-9)./100;
block=(blockCS-4.5)./100;

DRmod=1-0.3-mastery./100;

haste=(hasteRating+dhaste)./425./100;

hit=(hitRating+dhit)./340./100;
exp=(expRating+dexp)./340./100;

miss=max(0,0.075-hit);
dodge=max(0,(0.075-exp));
parry=max(0,(0.075-max((exp-0.075),0)));


%initialize Holy Power
hp=0;

%% Define events, cooldowns and buffs to track
events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;
%start boss swing timer at 0.5 seconds, just to de-synch from GCD
%not strictly necessary, I think, as HP generation should shuffle SotR
%around significantly, but just to be safe...
tbe(1)=0.5;

buffs={'SotR duration','BoG Duration','CS cooldown','J cooldown','SotR cooldown','Grand Crusader duration','Div Pupr duration','T152pc','WoG cd','WoG absorb'};
tob = zeros(size(buffs));
idSotR=1;
idBoG=2;
idCScd=3;
idJcd=4;
idSotRcd=5;
idGCbuff=6;
idDPBuff=7;
idT152pc=8;
idWoGcd=9;
idWoGfakebubble=10;

BoGstacks=0;

simTime=simMins*60;
steps_per_sec=100;

%preallocate arrays
N=floor(simTime.*steps_per_sec);
dt=1./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
SotRUptime=t;debugG=t;debugHP=t;SotRUptimeotR=t;debugHPG=t;debugBoG=t;

%tracking
avoids=0;
blocks=0;
hits=0;
mits=0;
bMits=0;
hMits=0;
partialAbsorbs=0;
fullAbsorbs=0;

%%for loop to do event handling
tic
for k=1:N
        
    %record time
    t(k)=(k-1).*dt;
    
    %figure out if any of the event timers is 0 or less
    ids=find(tbe<=0);
    
    %event handling
    for j=1:length(ids)
        
        switch ids(j)
            
            %if the GCD timer is up, see if there's something to cast
            case idGCD
                
                %check for finisher cast
                finisherCast(ftype,lock,bleed,ovrw);
                
                %CS is first priority
                if tob(idCScd)<=0
                    %put CS on cooldown, start GCD
                    tob(idCScd)=4.5./(1+haste);
                    tbe(idGCD)=1.5./(1+haste);
                    %Check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant HP, enforce bounds
                        hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                        debugHPG(k)=1; %debug flag
                        %Check for Grand Crusader proc
                        if rand<gcProcRate
                            %set GC buff duration
                            tob(idGCbuff)=gcBuffDuration;
                        end
                    end
                    %J is second priority, check for cooldown and don't use
                    %if CS cd is almost up
                elseif tob(idJcd)<=0 && tob(idCScd)>=0.2
                    %set J cooldown, start GCD
                    tob(idJcd)=6./(1+haste);
                    tbe(idGCD)=1.5./(1+haste);
                    %check for hit
                    if rand<(1-miss)
                        %success! grant HP, enforce bounds
                        hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                        debugHPG(k)=2; %debug flag
                    end
                    %Grand Crusader
                elseif tob(idGCbuff)>0 && tob(idCScd)>=0.2
                    %Consume GC buff, set GCD
                    tob(idGCbuff)=0;
                    tbe(idGCD)=1.5./(1+haste);
                    %grant HP, enforce bounds
                    hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                    debugHPG(k)=3; %debug flag
                end
                
                %boss swing
            case idBossSwing
                
                %update WoG fake absorb
                if tob(idWoGfakebubble)<=0
                    WoGAmount=0;
                end
                if WoGAmount<=0
                    tob(idWoGfakebubble)=0;
                end
                
                
                %check for finisher cast, do so
                finisherCast(ftype,lock,bleed,ovrw);
                
                %reset boss swing timer
                tbe(idBossSwing)=bossSwingTimer;
                
                %check for avoid
                if rand < avoidance
                    damage(k)=0;
                    avoids=avoids+1;
                    
                %now check for block
                elseif rand < block+0.4.*(tob(idT152pc)>0)
                    blocks=blocks+1;
                    if tob(idSotR)>0
                        mits=mits+1;
                        bMits=bMits+1;
                        if WoGAmount>=0.7.*DRmod
                            damage(k)=0;
                            WoGAmount=WoGAmount-0.7.*DRmod;
                            fullAbsorbs=fullAbsorbs+1;
                        elseif WoGAmount>0
                            damage(k)=0.7.*DRmod-WoGAmount;
                            WoGAmount=0;
                            partialAbsorbs=partialAbsorbs+1;
                        else
                            damage(k)=0.7.*DRmod;
                        end
                    else
                        if WoGAmount>=0.7
                            damage(k)=0;
                            WoGAmount=WoGAmount-0.7;
                            fullAbsorbs=fullAbsorbs+1;
                        elseif WoGAmount>0
                            damage(k)=0.7-WoGAmount;
                            WoGAmount=0;
                            partialAbsorbs=partialAbsorbs+1;
                        else
                            damage(k)=0.7;
                        end
                    end
                %and finally, normal hits
                else
                    hits=hits+1;
                    if tob(idSotR)>0
                        mits=mits+1;
                        hMits=hMits+1;
                        if WoGAmount>=DRmod
                            damage(k)=0;
                            WoGAmount=WoGAmount-DRmod;
                            fullAbsorbs=fullAbsorbs+1;
                        elseif WoGAmount>0
                            damage(k)=DRmod-WoGAmount;
                            WoGAmount=0;
                            partialAbsorbs=partialAbsorbs+1;
                        else
                            damage(k)=DRmod;
                        end
                    else
                        if WoGAmount>=1
                            damage(k)=0;
                            WoGAmount=WoGAmount-1;
                            fullAbsorbs=fullAbsorbs+1;
                        elseif WoGAmount>0
                            damage(k)=1-WoGAmount;
                            WoGAmount=0;
                            partialAbsorbs=partialAbsorbs+1;
                        else
                            damage(k)=1;
                        end
                    end
                end
                
        end %close switch
        
        
    end %close event for
    
    %     end %close event if
        
    
    %% Debugging
    SotRUptime(k,1)=tob(idSotR);
%     SotRUptimeotR(k,1)=tob(idSotRcd);
    debugHP(k,1)=hp;
    debugBoG(k,1)=BoGstacks;
    
    %increment time by decreasing tob and tbe
    tbe=tbe-dt;
    tob=tob-dt;
    
    %fix SotR at 0
    tob(idSotR)=max(tob(idSotR),0);
    %clear BoG stacks
    if tob(idBoG)<=0
        BoGstacks=0;
    end
end
if ~strcmp(tocFlag,'notoc')
    toc
end

%% compile for plots
dmg=damage(damage>=0);

%sanity check
if hits+blocks+avoids~=length(dmg)
    error('reporting error, length(dmg) doesn''t match number of events')
else
    numEvents=length(dmg);
end

statblock.S=sum(SotRUptime>0)./length(SotRUptime);
% avoids=sum(dmg==0);

statblock.avoidsPct=avoids./numEvents;
statblock.blocksPct=blocks./numEvents;
statblock.hitsPct=hits./numEvents;
statblock.mitsPct=mits./numEvents;
statblock.unmitsPct=(hits-hMits)./numEvents;
statblock.bMitsPct=bMits./numEvents;
statblock.hMitsPct=hMits./numEvents;

statblock.Tsotr = max(t)./sum(SotRUptime==3);
statblock.Rsotr = 1/statblock.Tsotr;
statblock.Rhpg=sum(debugHPG>0)/max(t);
statblock.DRmod=DRmod;

statblock.DTPS=sum(dmg)./max(t);
statblock.maDTPS=filter(ones(1,5)./5,1,dmg);
statblock.mean_ma=mean(statblock.maDTPS);
statblock.std_ma=std(statblock.maDTPS);

statblock.block=block;
statblock.avoidance=avoidance;
statblock.avoids=avoids;
statblock.blocks=blocks;
statblock.hits=hits;
statblock.mits=mits;
statblock.hMits=hMits;
statblock.bMits=bMits;
statblock.partialAbsorbs=partialAbsorbs;
statblock.fullAbsorbs=fullAbsorbs;

statblock.dmg=dmg;

statblock.simMins=simMins;
statblock.simTime=simTime;
statblock.stepsPerSec=steps_per_sec;


%% plot
if ~strcmp(plotFlag,'noplot')
    pally_mc_plot(config,statblock,sF)
end

%% helper functions
    function finisherCast(ftype,lock,bleed,ovrw)
        if strcmpi(ftype,'S') %SotR spam
            castSotRIfAble()
        elseif strcmpi(ftype,'T') %maintain T152pc, bleed w/WoG
            if tob(idT152pc)<=0 || hp==5
                castWoGT15(0);
            end
        elseif strcmpi(ftype,'TS') %maintain T152pc, bleed w/SotR
            if tob(idT152pc)<=0 && (isnan(lock) || hp>=lock)
                castWoGT15(0);
            elseif hp==5
                castSotRIfAble()
            end
        elseif strcmpi(ftype,'ST') %SotR with T15 to bridge gaps
            if isnan(bleed) %no bleeding
                castSotRIfAble()
                if tob(idSotR)<=0 && tob(idT152pc)<=0 && (isnan(lock) || hp>=lock)
                    castWoGT15(0)
                end
            else %add a bleeding condition on BoG
                castSotRIfAble()
                if tob(idSotR)<=0 && tob(idT152pc)<=0 && (isnan(lock) || hp>=lock) && BoGstacks>=bleed;
                    castWoGT15(0)
                end
            end
                
        else
            error('invalid finisher specification')
        end
        
    end
    function castSotRIfAble()
        
        %check for 3+ HP and no SotR buff, if so cast SotR
        if ( hp>=3 || tob(idDPBuff)>0 ) && tob(idSotRcd)<=0 && tob(idSotR)<=0
            %set SotR CD, give 3 seconds of DR, 20s of BoG
            tob(idSotRcd)=1.5./(1+haste); %5.2
            tob(idSotR)=tob(idSotR)+3;
            tob(idBoG)=20;
            BoGstacks=min(BoGstacks+1,5);
            %Consume Divine Purpose proc if it exists
            if tob(idDPBuff)>0
                tob(idDPBuff)=0;
                %otherwise, consume 3 HP
            elseif hp>=3
                hp=hp-3;
                %Just in case - debugging
            else
                error('WTF')
            end
            %Divine Purpose procs
            if rand<dpProcRate
                tob(idDPBuff)=dpBuffDuration;
            end
        end
    end

    function castWoGT15(hpmin,strict)
        %input handling
        if nargin<1
            hpmin=0;
        end
        if nargin<2
            strict=0;
        end
        %first, try and cast WoG
        hpused=castWoG(hpmin,strict);
        %if we successfully cast, then hpused>0
        if hpused>0
            tob(idT152pc)=hpused.*5.*t152pcEquipped;
        end
    end

    function hpused=castWoG(hpmin,strict)
        %input handling
        if nargin<1
            hpmin=0;
        end
        if nargin<2
            strict=0;
        end
        %if WoG off cooldown
        if tob(idWoGcd)<=0
            %first, check for strict casts
            if nargin>1 && strict
                %if we've asked for strict and HP matches the target value
                if hp==hpmin
                    %set hp used to the target value
                    hpused=hpmin;
                end
            %else, we've not asked for strict casts
            elseif hp>=max(hpmin,1)
               %if we have hp>1 or hp>hpmin
               hpused=min(hp,3);
            elseif hp==0
                hpused=0;
                %oops, no holy power
            else
                %just in case, debugging
                error('WTF')
            end
            
            %if hpused is nonzero, cast WoG
            if hpused>0            
                %subtrat HP
                hp=hp-hpused;
                %set cooldown of WoG
                tob(idWoGcd)=1.5; 
                %add a 3-second absorb shield
                tob(idWoGfakebubble)=3;
                %set the amount of the absorb shield based on HP spent, BoG
                WoGAmount=WoGHealBase.*hpused.*(1+BoGstacks.*(0.1+mastery/100));
                %consume BoG buff
                BoGstacks=0;
                tob(idBoG)=0;
            end
            
            
        end
    end
            

end