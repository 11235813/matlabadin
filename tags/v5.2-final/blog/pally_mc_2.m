function [statblock]=pally_mc_2(config,statSetup)
%add path for "shift" function
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'
%set differential stat values to zero
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;

%% Input handling - config - stat,val,simMins,plotFlag,tocFlag
if ~exist('config','var')
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
    warning('simMins defaulting to %d', config.simMins) %#ok<*WNTAG>
end
simMins=config.simMins;

if ~isfield(config,'val')
    config.val=600;
    warning('stat value defaulting to %d',config.val)
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
    config.bossSwingTimer=1.500;
    warning(['boss swing timer factor defaulting to ' num2str(config.bossSwingTimer./1000,'%2.2f')])
end
bossSwingTimer=config.bossSwingTimer.*1000; %convert to ms

if ~isfield(config,'WoGoverheal')
    config.WoGoverheal=0.5;
    warning(['WoG overheal defaulting to ' int2str(config.WoGoverheal.*100) '%'])
end
WoGoverheal=config.WoGoverheal;

if ~isfield(config,'WoGfakeBubbleDuration')
    config.WoGfakeBubbleDuration=3000;
    warning(['WoG fake bubble duration defaulting to ' num2str(config.WoGfakeBubbleDuration./1000,'%2.2f') 's'])
end
WoGfakeBubbleDuration=config.WoGfakeBubbleDuration;

if ~isfield(config,'t152pcEquipped')
    config.t152pcEquipped=0;
    warning('T15 2-piece bonus defaulting to off')
end
t152pcEquipped=config.t152pcEquipped;

if ~isfield(config,'priority')
    config.priority='default';
    warning('Priority defaulted to basic CS>J>AS')
end
priority=config.priority;

if ~isfield(config,'enableSS')
    config.enableSS=0;
    warning('enableSS defaulted to 0 (disabled)')
end
enableSS=config.enableSS;

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
    statSetup.name='C/Bal';
    statSetup.buffedStr=15000;
    statSetup.parryRating=4125;
    statSetup.dodgeRating=4125;
    statSetup.masteryRating=4125;
    statSetup.hitRating=2550;
    statSetup.expRating=5100;
    statSetup.hasteRating=4125;
    statSetup.armor=65000;
end
buffedStr=statSetup.buffedStr;
parryRating=statSetup.parryRating;
dodgeRating=statSetup.dodgeRating;
masteryRating=statSetup.masteryRating;
hitRating=statSetup.hitRating;
expRating=statSetup.expRating;
hasteRating=statSetup.hasteRating;
armor=statSetup.armor;

armorMit=1-armor./(armor+58370);
specMit=1-0.15;
wbMit=0.9;


%% Define constants/variables
Cd=66.56745;
Cp=237.186;
Cb=150.3759;
k=0.886;
gcAvoidProcRate=0.12;
gcCSProcRate=0.12;
gcBuffDuration=6300;
% dpProcRate=0.25;
dpProcRate=0;
dpBuffDuration=8000;

%Vengeance info
bossRawDPS=310000;
bossRawSwingDamage=bossRawDPS.*bossSwingTimer;
bossSwingDamage=bossRawSwingDamage.*armorMit.*specMit.*wbMit;
avgVengAP=0.36*bossRawDPS;
AP=floor(1.1.*(avgVengAP+270+2.*(buffedStr-10)));
WoGHealBase=(5538+0.49.*AP./2).*1.05./bossSwingDamage.*(1-WoGoverheal);
WoGAmount=0; %initialize WoG absorb tracker

%% calculate stats
%defensive stats
mastery=8+(masteryRating+dmastery)./600;
blockCS=3+10+1./(1./Cb+k./mastery);
% miss=0;
dodgeCS=5.01+1./(1./Cd+k./((dodgeRating+ddodge)./885));
parryCS=3.19+1./(1./Cp+k./((buffedStr-178)./951.158596+(parryRating+dparry)./885));

avoidance=(dodgeCS+parryCS-9)./100;
block=(blockCS-4.5)./100;

DRmod=max([1-0.3-mastery./100 0.2]);

%offensive stats
haste=(hasteRating+dhaste)./425./100;

hit=(hitRating+dhit)./340./100;
exp=(expRating+dexp)./340./100;

miss=max(0,0.075-hit);
dodge=max(0,(0.075-exp));
parry=max(0,(0.075-max((exp-0.075),0)));

%% Sacred Shield ticks
spellHaste=(1+haste).*1.05.*1.10-1;
ssAbsorbValue=enableSS.*(342 + 0.585.*AP)./bossSwingDamage;
ssTickInterval=roundn(6./(1+spellHaste),-3).*1000;
numSSTicks=round2even(30./(ssTickInterval./1000));
% ssDuration=numTicks.*ssTickInterval;
% ssAbsorbValue=0; %override for turning off SS

%% initialize Holy Power
hp=int8(0);

%% Define events, cooldowns and buffs to track
events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;
%start boss swing timer at 0.5 seconds, just to de-synch from GCD
%not strictly necessary, I think, as HP generation should shuffle SotR
%around significantly, but just to be safe...
tbe(1)=500;

buffs={'SotR duration','BoG Duration','CS cooldown','J cooldown','AS cooldown','SotR cooldown','Grand Crusader duration','Div Pupr duration','T152pc','WoG cd','WoG absorb','SS cd','SS absorb'};
tob = zeros(size(buffs));
idSotR=1;
idBoG=2;
idCScd=3;
idJcd=4;
idAScd=5;
idSotRcd=6;
idGCbuff=7;
idDPBuff=8;
idT152pc=9;
idWoGcd=10;
idWoGfakebubble=11;
idSScd=12;
idSSbubble=13;
% idSSbuff=14;

BoGstacks=0;
ssStacks=0;

simTime=simMins*60;
steps_per_sec=100;

%preallocate arrays
N=floor(simTime.*steps_per_sec);
dt=1000./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
SotRUptime=t;
debugHP=t;
debugHPG=t;
debugBoG=t;

%tracking
avoids=0;
blocks=0;
hits=0;
mits=0;
bMits=0;
hMits=0;
partialAbsorbs=0;
fullAbsorbs=0;
gcCSProcs=0;
gcAProcs=0;

%variables for conditional cast logic
bossSwingHistory=zeros(10,1); %store last 10 boss hits
% lbSH=length(bossSwingHistory);

% %make t array
t=(0:(N-1)).*dt;

%%for loop to do event handling
tic
for k=1:N
        
    %record time
%     t(k)=(k-1).*dt;
    
    %% event handling
    
     %upkeep stuff we'll want to do before every event
     
     %clear BoG stacks if the buff has expired
     if tob(idBoG)<=0
         BoGstacks=0;
     end
     
     %fix SotR at 0
     tob(idSotR)=max(tob(idSotR),0);
        
     
     %if the GCD timer is up, see if there's something to cast
     if tbe(idGCD)<=0
         
         %check for finisher cast
         finisherCast(ftype,lock,bleed,ovrw);
         
         %priority queue
         abilityCast(priority);
         
     end
     
     %SS refreshing mechanics
     if tob(idSSbubble)<=0 && ssStacks>0
        ssStacks=ssStacks-1;
        tob(idSSbubble)=ssTickInterval;
        ssAmount=ssAbsorbValue;
     end
     
     %boss swing
     if tbe(idBossSwing)<=0
         
         %update absorbs
         if tob(idWoGfakebubble)<=0
             WoGAmount=0;
         end
         if WoGAmount<=0
             tob(idWoGfakebubble)=0;
         end
         if tob(idSSbubble)<=0
             ssAmount=0;
         end
         if ssAmount<=0
             tob(idSSbubble)=0;
         end
         
         absorbAmount=WoGAmount+ssAmount;
         
         %check for finisher cast
         finisherCast(ftype,lock,bleed,ovrw);
         
         %reset boss swing timer
         tbe(idBossSwing)=bossSwingTimer;
         
         %check for avoid
         if rand < avoidance %#ok<*BDSCI>
             damage(k)=0;
             avoids=avoids+1;
             
             %Check for Grand Crusader proc
             if rand<gcAvoidProcRate
                 %set GC buff duration
                 tob(idGCbuff)=gcBuffDuration;
                 %reset AS cooldown
                 tob(idAScd)=0;
                 gcAProcs=gcAProcs+1;
             end
             
             %now check for block
         elseif rand < block+0.4*(tob(idT152pc)>0)
             blocks=blocks+1;
             if tob(idSotR)>0
                 mits=mits+1;
                 bMits=bMits+1;
                 %apply absorbs if applicable
                 if absorbAmount>0
                     damage(k)=manyAbsorbsHandleIt(0.7*DRmod);
                 else
                     damage(k)=0.7*DRmod;
                 end
             else
                 %absorbs
                 if absorbAmount>0
                     damage(k)=manyAbsorbsHandleIt(0.7);
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
                 %absorbs
                 if absorbAmount>0
                     damage(k)=manyAbsorbsHandleIt(DRmod);
                 else
                     damage(k)=DRmod;
                 end
             else
                 %absorbs
                 if absorbAmount>0
                     damage(k)=manyAbsorbsHandleIt(1);
                 else
                     damage(k)=1;
                 end
             end
         end
         
         %update bossSwingHistory
         bossSwingHistory=shift(bossSwingHistory,[1 0]);
         bossSwingHistory(1)=damage(k);
         
     end %close boss swing conditional
    
    %% Debugging
    SotRUptime(k)=tob(idSotR);
%     SotRUptimeotR(k,1)=tob(idSotRcd);
%     debugHP(k)=hp;
%     debugBoG(k)=BoGstacks;


    %increment time by decreasing tob and tbe
    %rounding to prevent floating point inaccuracies
    tbe=tbe-dt;
    tob=tob-dt;
%     tbe=round(tbe-dt);
%     tob=round(tob-dt);
       
end %close timestep for loop

%flash toc for timing/debugging if desired
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
statblock.gcAProcs=gcAProcs;
statb.ock.gcCSProcs=gcCSProcs;

statblock.Tsotr = simTime./sum(SotRUptime==3000);
statblock.Rsotr = 1/statblock.Tsotr;
statblock.Rhpg=sum(debugHPG>0)/simTime;
statblock.DRmod=DRmod;

statblock.DTPS=sum(dmg)./simTime;
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
    function finisherCast(ftype,lock,bleed,~)
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
                
        elseif strcmpi(ftype,'shift') || strcmpi(ftype,'SH')
            %format: shiftX-Y, X=lock, Y=bleed - use SotR if the mean
            %damage of the last X attacks is > Y
            
            if ~isnan(lock); nHits=lock; else nHits=1; end %set lock if not defined
            if ~isnan(bleed); dThresh=bleed; else dThresh=0.8; end %set bleed if not defined
            %cast SotR if >= bleed holy power and a finisher is coming up
            %within lock seconds
            if hp>=5 && (tob(idCScd)<=1 || tob(idJcd)<=1 || (tob(idAScd)<=1 && tob(idGCbuff)>1))
                castSotRIfAble()
            %otherwise, cast SotR if we just took a full hit
            elseif hp>=3 && mean(bossSwingHistory(1:nHits))>=dThresh
                castSotRIfAble()
            end
        else
            error('invalid finisher specification')
        end
        
    end
    function castSotRIfAble()
        
        %check for 3+ HP, if so cast SotR
        if ( hp>=3 || tob(idDPBuff)>0 ) && tob(idSotRcd)<=0 
            %set SotR CD, give 3 seconds of DR, 20s of BoG
            tob(idSotRcd)=1500./(1+haste); %5.2
            tob(idSotR)=tob(idSotR)+3000;
            tob(idBoG)=20000;
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
            tob(idT152pc)=hpused.*5000.*t152pcEquipped;
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
                tob(idWoGcd)=1500; 
                %add a 3-second absorb shield
                tob(idWoGfakebubble)=WoGfakeBubbleDuration;
                %set the amount of the absorb shield based on HP spent, BoG
                WoGAmount=WoGHealBase.*double(hpused).*(1+BoGstacks.*(0.1+mastery/100));
                %consume BoG buff
                BoGstacks=0;
                tob(idBoG)=0;
            end
            
            
        end
    end

    function grantHP(amt)
        if nargin<1
            amt=1;
        end
        hp=hp+amt;
        hp=min([hp 5]);
        hp=max([hp 0]);        
    end
            
    function abilityCast(priority)
        
        if priority=='special'
            %placeholder for special generator priorities
            
        
        %default, no time-shifting
        else
            
            %CS is first priority
            if tob(idCScd)<=0
                %put CS on cooldown, start GCD
                tob(idCScd)=4500./(1+haste);
                tbe(idGCD)=1500./(1+haste);
                %Check for hit
                if rand<(1-miss-dodge-parry)
                    %success! grant HP, enforce bounds
                    grantHP;
                    debugHPG(k)=1; %debug flag
                    
                    %Check for Grand Crusader proc
                    if rand<gcCSProcRate
                        %set GC buff duration
                        tob(idGCbuff)=gcBuffDuration;
                        %reset AS cooldown
                        tob(idAScd)=0;
                        gcCSProcs=gcCSProcs+1;
                    end
                end
            %J is second priority, check for cooldown and don't use
            %if CS cd is almost up
            elseif tob(idJcd)<=0 && tob(idCScd)>=200
                %set J cooldown, start GCD
                tob(idJcd)=6000./(1+haste);
                tbe(idGCD)=1500./(1+haste);
                %check for hit
                if rand<(1-miss)
                    %success! grant HP, enforce bounds
                    grantHP;
                    debugHPG(k)=2; %debug flag
                end
            %Avenger's Shield
            elseif tob(idAScd)<=0 && tob(idCScd)>=200
                %set AS cooldown, Start GCD
                tob(idAScd)=15000./(1+haste);
                tbe(idGCD)=1500./(1+haste);
                %if Grand Crusader was active,
                if tob(idGCbuff)>0
                    %Consume GC buff, set GCD
                    tob(idGCbuff)=0;
                    %grant HP, enforce bounds
                    grantHP;
                    debugHPG(k)=3; %debug flag
                end
            %Sacred Shield
            elseif tob(idSScd)<=0
                %start SS cd, start GcD
                tob(idSScd)=6000;
                tbe(idGCD)=1500./(1+haste);
                %if SS isn't active, add stacks and create a 0-value bubble
                if ssStacks<=0
                    ssStacks=numSSTicks;
                    tob(idSSbubble)=ssTickInterval;
                    ssAmount=0;
                %otherwise add stacks to SS
                else
                    ssStacks=numSSTicks+1; %keep current stack and add N
                    %no need to add time to SSbubble, it's handled
                    %externally for refreshes
                end
                
                %for completeness, fill the GCD with a blank filler
            else
                tbe(idGCD)=1500./(1+haste);
            end
        end
    end

    function dmgTaken=manyAbsorbsHandleIt(damage)
        dmgTaken=damage;
        %apply WoG first if applicable
        if WoGAmount>0
            if dmgTaken>WoGAmount
                dmgTaken=dmgTaken-WoGAmount;
                WoGAmount=0;
            else
                WoGAmount=WoGAmount-dmgTaken;
                dmgTaken=0;
            end
        end
        %then apply sacred shield
        if ssAmount>0
            if dmgTaken>ssAmount
                dmgTaken=dmgTaken-ssAmount;
                ssAmount=0;
            else
                ssAmount=ssAmount-dmgTaken;
                dmgTaken=0;
            end
        end
        %register full and partial absorbs
        if dmgTaken==0
            fullAbsorbs=fullAbsorbs+1;
        elseif dmgTaken<damage
            partialAbsorbs=partialAbsorbs+1;
        end
    end

end