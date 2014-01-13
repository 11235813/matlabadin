function [statblock]=pally_mc(config,statSetup)
%add path for "shift" function
addpath 'C:\Users\George\Documents\MATLAB\mop\helper_func\'

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
    config.simMins=10000;
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
    warning('T15 2-piece bonus defaulting to off')
end
t152pcEquipped=config.t152pcEquipped;

if ~isfield(config,'priority')
    config.priority='default';
    warning('Priority defaulted to basic CS>J>AS')
end
priority=config.priority;

if ~isfield(config,'enableSS')
    config.enableSS=1;
    warning('enableSS defaulted to 1 (enabled)')
end
enableSS=config.enableSS;

if ~isfield(config,'useDivineProtection')
    config.useDivineProtection=0;
    warning('Divine Protection defaulting to off')
end
useDivineProtection=config.useDivineProtection;

if ~isfield(config,'bossSwingDamage')
    config.bossSwingDamage=200000;
    warning('bossSwingDamage defaulting to 200k')
end
bossSwingDamage=config.bossSwingDamage;

if ~isfield(config,'soimodel')
    config.soimodel='fermi-1.55-0.15';
    warning('soimodel defaulting to fermi')
end
soimodel=regexp(config.soimodel,'(?<base>\w+)\-?(?<x0>\d+\.*\d*)?\-?(?<sigma>\d+\.*\d*)?','names');
if ~isnan(str2double(soimodel.x0)); soimodel.x0=str2double(soimodel.x0); elseif ~strcmp(soimodel.base,'nooverheal') soimodel.x0=1.5; warning('soimodel x0 defaulting to 1.5'); end;
if ~isnan(str2double(soimodel.sigma)); soimodel.sigma=str2double(soimodel.sigma); elseif strcmp(soimodel.base,'fermi'); soimodel.sigma=0.15; warning('soimodel sigma defaulting to 0.15'); end

if ~isfield(config,'soiDirection')
    config.soiDirection='back';
    warning('soiDirection defaulting to back')
end
soiDirection=config.soiDirection;

if ~isfield(config,'bossSpecial')
    config.bossSpecial='none';
end
bossSpecial=regexp(config.bossSpecial,'(?<type>\w+)\-?(?<damage>\d+\.*\d*)?\-?(?<baseCD>\d+\.*\d*)?\-?(?<randCD>\d+\.*\d*)?','names');

if ~isfield(config,'wogDirection')
    config.wogDirection='back';
    warning('wogDirection defaulting to back')
end
wogDirection=config.wogDirection;

%% Finisher priority Queue handling
finisher=config.finisher;
n=regexp(finisher,'(?<ftype>[a-zA-Z]+)(?<lockstr>\d*\.?\d*)-?(?<bleedstr>\d*)(?<ovrw>\**)','names');
ftype=n.ftype;
bleed=str2double(n.bleedstr);
lock=str2double(n.lockstr);
ovrw=~strcmpi(n.ovrw,'*');
%% Modify differential stat values based on config
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;
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
    statSetup.stamina=28000;
    statSetup.parryRating=4125;
    statSetup.dodgeRating=4125;
    statSetup.masteryRating=4125;
    statSetup.hitRating=2550;
    statSetup.expRating=5100;
    statSetup.hasteRating=4125;
    statSetup.armor=65000;
    statSetup.t15_4pc=0;    
end
buffedStr=statSetup.buffedStr;
stamina=statSetup.stamina;
parryRating=statSetup.parryRating;
dodgeRating=statSetup.dodgeRating;
masteryRating=statSetup.masteryRating;
hitRating=statSetup.hitRating;
expRating=statSetup.expRating;
hasteRating=statSetup.hasteRating;
armor=statSetup.armor;
if ~isfield(statSetup,'t15_4pc') || isempty(statSetup.t15_4pc);
    t154pcEquipped=0;
else
    t154pcEquipped=statSetup.t15_4pc;
end

%% Mitigation Factors
armorMit=1-armor./(armor+58370);
specMit=1-0.15;
wbMit=0.9;
dpMit=0.8;

%% Assorted Constants
gcAvoidProcRate=0.12;
gcCSProcRate=0.12;
gcBuffDuration=6.3;
% dpProcRate=0.25;
dpProcRate=0;
dpBuffDuration=8;
masteryRaidBuff=3000;

%% Boss Damage Info
%bossSwingDamage is set in config 
bossDPS=bossSwingDamage./bossSwingTimer; %#ok<NASGU>
bossRawSwingDamage=bossSwingDamage./(armorMit.*specMit.*wbMit);
bossRawDPS=bossRawSwingDamage./bossSwingTimer;

%special attacks


%% Vengeance Calculations
avgVengAP=0.36*bossRawDPS;
AP=floor(1.1.*(avgVengAP+270+2.*(buffedStr-10)));

%% Defensive Stats
%diminishing returns coefficients
Cd=66.56745;
Cp=237.186;
Cb=150.3759;
kv=0.886;

%defensive stats, miss excluded because =0 for bosses
mastery=8+(masteryRating+dmastery+masteryRaidBuff)./600;
blockCS=3+10+1./(1./Cb+kv./mastery);
dodgeCS=5.01+1./(1./Cd+kv./((dodgeRating+ddodge)./885));
parryCS=3.19+1./(1./Cp+kv./((buffedStr-178)./951.158596+(parryRating+dparry)./885));

%avoidance and block in decimal format
avoidance=(max(dodgeCS-4.5,0)+max(parryCS-4.5,0))./100;
block=(blockCS-4.5)./100;

%chance for parry-hasting to occur on an avoid event
parryHasteChance=((parryCS-4.5)./100/avoidance);

%SotR DR modifier
DRmod=max([1-0.25-mastery./100 0.2]);

%% Offensive stats
haste=(hasteRating+dhaste)./425./100;
spellHaste=(1+haste).*1.05.*1.10-1;

hit=(hitRating+dhit)./340./100;
expt=(expRating+dexp)./340./100;

miss=max(0,0.075-hit);
dodge=max(0,(0.075-expt));
parry=max(0,(0.075-max((expt-0.075),0)));

%% WoG Heal Size
wogRaw=(5538+0.49.*AP./2).*1.05./bossSwingDamage;
WoGHealBase=wogRaw.*(1-WoGoverheal);
wogOHbase=wogRaw.*WoGoverheal;

%% Sacred Shield Ticks
ssAbsorbTickSize=(342 + 0.585.*AP)./bossSwingDamage;
ssAbsorbValue=enableSS.*ssAbsorbTickSize;
ssTickInterval=roundn(6./(1+spellHaste),-3);
numSSTicks=round2even(30./ssTickInterval);

%% melee swings and SoI
baseSwingTimer=2.6;
playerSwingTimer=roundn(baseSwingTimer./(1+haste)./1.1,-3); %1.1 for melee attack speed buff
SoIProcChance=20.*baseSwingTimer./60;
SoIHealSize=0.15*(AP+AP/2)./bossSwingDamage;

%% initialize Holy Power
hp=int8(0);

%% Stamina and Health
baseStamina=169;
baseHealth=146663;
stamModifier=1.25.*1.05.*1.1; %GbtL, plate spec, PW:F
buffedStamina=floor(baseStamina.*stamModifier)+floor((stamina+1950).*stamModifier);
totalHitPoints=baseHealth+(14.*buffedStamina-260);
health=totalHitPoints./bossSwingDamage; %normalized health
dpThreshold=0.2.*health;

%% Define events to track
events={'Boss Swing Timer','GCD','melee','Boss Special'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;
idMelee=3;
idBSpec=4;

%start boss swing timer at 0.5 seconds, just to de-synch from GCD
%not strictly necessary, I think, as HP generation should shuffle SotR
%around significantly, but just to be safe...
tbe(idBossSwing)=0.5;
tbe(idMelee)=playerSwingTimer;

%% Define buffs to track
buffs={'SotR duration','BoG Duration','CS cooldown','J cooldown','AS cooldown','SotR cooldown','Grand Crusader duration','Div Pupr duration','T152pc','WoG cd','WoG absorb','SS cd','SS absorb','DivProt','DivProt cd'};
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
idDivProt=14;
idDivProtcd=15;

%% Simulation parameters
simTime=simMins*60;
steps_per_sec=100;
dt=1./steps_per_sec;
ulp=0.001; %unit of least precision (1ms) - for dealing with float errors
backSteps=floor(bossSwingTimer./dt); %number of timesteps to look back for healing

%% pre-calculate cooldowns and buff times for speed
tGCD=1.5./(1+haste);
tCScd=4.5./(1+haste);
tJcd=6./(1+haste);
tAScd=15./(1+haste);
tDivProt=10;
tDivProtCD=60;
tSotR=3;
tBoG=20;

%% Dynamic Scalar Trackers
BoGstacks=0;
ssStacks=0;
WoGAmount=0; %initialize WoG absorb tracker
soiAmount=0;
parries=0;
dodges=0;
blocks=0;
hits=0;
mits=0;
bMits=0;
hMits=0;
dpMits=0;
partialAbsorbs=0;
fullAbsorbs=0;
gcCSProcs=0;
gcAProcs=0;
t154pcHPGains=0;
melees=0;
SotRcasts=0;
divProtCasts=0;
soiHealed=0;
soiOHbase=0;
soiOHexpire=0;
soiOHbackExcess=0;
soiOHbackFull=0;
wogHealed=0;
wogOHexpire=0;
wogOHbackExcess=0;
wogOHbackFull=0;

%variables for conditional cast logic
bossSwingHistory=zeros(10,1); %store last 10 boss hits

%% Preallocate Vector Trackers
N=floor(simTime.*steps_per_sec);
t=zeros(N,1);
damage=-1.*ones(N,1);
soiTracker=damage;
hpgTracker=t;
hpgGained=t;
%make t array
t=(0:(N-1)).*dt;

%% For loop to do event handling
tic
k=1;

while k<=N
     %event handling
    
     %upkeep stuff we'll want to do before every event
     
     %clear BoG stacks if the buff has expired
     if tob(idBoG)<=ulp
         BoGstacks=0;
     end
     
     %% GCD
     %if the GCD timer is up, see if there's something to cast
     if tbe(idGCD)<=ulp
         
         %check for finisher cast
         finisherCast(ftype,lock,bleed,ovrw);
         
         %priority queue
         abilityCast(priority);
         
     end
     
     %% Player Melee
     %if the swing timer is up, make a melee attack
     if tbe(idMelee)<=ulp
         
         %melee attack, roll for miss/dodge/parry (block/glance irrelevant)
         if rand>(miss+dodge+parry)
         
            %check for SoI proc
             if rand<SoIProcChance
                 %handle SoI proc mechanics
                 handleSoI;
                 
             end
         end
         
         %reset swing timer
         tbe(idMelee)=playerSwingTimer;
         
         %log melee
         melees=melees+1;
     end
     
     %% SS refreshing mechanics
     if tob(idSSbubble)<=ulp && ssStacks>0
        ssStacks=ssStacks-1;
        tob(idSSbubble)=ssTickInterval;
        ssAmount=ssAbsorbValue;
     end
     
     %% Boss Swing
     if tbe(idBossSwing)<=ulp
                  
         %invoke Divine Protection 
         if (t154pcEquipped>0 || useDivineProtection>0) && tob(idDivProtcd)<=ulp
            %cast Divine Protection
            tob(idDivProt)=tDivProt;
            tob(idDivProtcd)=tDivProtCD;
            divProtCasts=divProtCasts+1;
         end
                  
         %check for finisher cast
         finisherCast(ftype,lock,bleed,ovrw);
         
         %reset boss swing timer
         tbe(idBossSwing)=bossSwingTimer;
         
         %check for avoid
         if rand < avoidance %#ok<*BDSCI>
             damage(k)=0;
             
             %Check for Grand Crusader proc
             if rand<gcAvoidProcRate
                 %set GC buff duration
                 tob(idGCbuff)=gcBuffDuration;
                 %reset AS cooldown
                 tob(idAScd)=0;
                 gcAProcs=gcAProcs+1;
             end
             
             %check for parry-hasting
             if rand<parryHasteChance
                 tbe(idMelee)=max(tbe(idMelee)-0.4.*playerSwingTimer,0.2.*playerSwingTimer);
                 parries=parries+1;
             else
                 dodges=dodges+1;
             end
                             
         %now check for block
         elseif rand < block+0.4*(tob(idT152pc)>0)
             blocks=blocks+1;
             
             %base block damage value
             dmgVal=0.7;
             
             %sotr
             if tob(idSotR)>ulp
                 mits=mits+1;
                 bMits=bMits+1;
                 %damage value
                 dmgVal=dmgVal*DRmod;
             end
             
             %divine protection
             if tob(idDivProt)>ulp
                 dmgVal=dmgVal.*dpMit;
                 dpMits=dpMits+1;
             end
             
             %apply absorbs if applicable
             updateAbsorbs;
             absorbAmount=WoGAmount+ssAmount+soiAmount;
             if absorbAmount>0
                 damage(k)=manyAbsorbsHandleIt(dmgVal);
             else
                 damage(k)=dmgVal;
             end
             
             %handle T15 4-piece
             if t154pcEquipped>0 && tob(idDivProt)>ulp
                 t154pcIncrementHP(dmgVal);
             end
             
         %and finally, normal hits
         else
             hits=hits+1;
             dmgVal=1;
             %sotr
             if tob(idSotR)>ulp
                 mits=mits+1;
                 hMits=hMits+1;
                 %damage value
                 dmgVal=dmgVal*DRmod;
             end             
             %divine protection
             if tob(idDivProt)>ulp
                 dmgVal=dmgVal.*dpMit;
                 dpMits=dpMits+1;
             end
             %absorbs
             updateAbsorbs;
             absorbAmount=WoGAmount+ssAmount+soiAmount;
             if absorbAmount>0
                 damage(k)=manyAbsorbsHandleIt(dmgVal);
             else
                 damage(k)=dmgVal;
             end
             
             %handle T15 4-piece
             if t154pcEquipped>0 && tob(idDivProt)>ulp
                 t154pcIncrementHP(dmgVal);
             end
         end
         
         %update bossSwingHistory
         bossSwingHistory=shift(bossSwingHistory,[1 0]);
         bossSwingHistory(1)=damage(k);
         
         %clear any SoI procs - only applicable to next boss attack anyway
         %note that this only has an effect if we're using absorb version
         if soiAmount>0
             soiOHexpire=soiOHexpire+soiAmount;
             soiAmount=0;
         end
         
     end %close boss swing conditional
    
     % Boss Special attacks
     if tbe(idBSpec)<ulp
         %placeholders
         tbe(idBSpec)=10000*60; %10k minutes
         
         %determine type (physical or magical)
         
         %handle physical - need SotR mitigation, block, armor, etc.
         
         %else handle magical - need passive magical mitigation
         
     end

    %% Skip to next event
    
    dk=round(min(tbe)./dt);
    dk=max(dk,1);
    k=k+dk;
    
    tbe=tbe-dk.*dt;
    tob=tob-dk.*dt;
    
       
end %close while loop

%flash toc for timing/debugging if desired
if ~strcmp(tocFlag,'notoc')
    toc
end

%% Construct statblock for output
dmg=damage(damage>=0);

%sanity check
avoids=dodges+parries;
if hits+blocks+avoids~=length(dmg)
    error('reporting error, length(dmg) doesn''t match number of events')
else
    bossAttacks=length(dmg);
end

statblock.block=block;
statblock.avoidance=avoidance;
statblock.dmg=dmg;
statblock.damage=damage;

statblock.bossAttacks=bossAttacks;
statblock.avoidsPct=avoids./bossAttacks;
statblock.parryPct=parries./bossAttacks;
statblock.dodgePct=dodges./bossAttacks;
statblock.blocksPct=blocks./bossAttacks;
statblock.hitsPct=hits./bossAttacks;
statblock.mitsPct=mits./bossAttacks;
statblock.unmitsPct=(hits-hMits)./bossAttacks;
statblock.bMitsPct=bMits./bossAttacks;
statblock.hMitsPct=hMits./bossAttacks;
statblock.gcAProcs=gcAProcs;
statblock.gcCSProcs=gcCSProcs;
statblock.avoids=avoids;
statblock.blocks=blocks;
statblock.hits=hits;
statblock.mits=mits;
statblock.hMits=hMits;
statblock.bMits=bMits;
statblock.partialAbsorbs=partialAbsorbs;
statblock.fullAbsorbs=fullAbsorbs;
statblock.melees=melees;
statblock.parries=parries;
statblock.dodges=dodges;

statblock.Tsotr = simTime./SotRcasts;
statblock.Rsotr = 1/statblock.Tsotr;
statblock.S=statblock.Rsotr.*3;
statblock.Rhpg=sum(hpgGained(hpgGained>0))/simTime;
statblock.DRmod=DRmod;

statblock.DTPS=sum(dmg)./simTime;

statblock.simMins=simMins;
statblock.simTime=simTime;
statblock.stepsPerSec=steps_per_sec;

statblock.health=health;
statblock.totalHitPoints=totalHitPoints;
statblock.bossSwingDamage=bossSwingDamage;
statblock.bossRawSwingDamage=bossRawSwingDamage;
statblock.playerSwingTimer=playerSwingTimer;

statblock.t154pcHPGains=t154pcHPGains;
statblock.t154pcHPG=t154pcHPGains./simTime;
statblock.divProtcasts=divProtCasts;

soiOverHealed=soiOHbase+soiOHexpire+soiOHbackExcess+soiOHbackFull;
statblock.soiHealedRaw=soiHealed;
statblock.soiOverHealedRaw=soiOverHealed;
statblock.soiHealed=soiHealed./(soiHealed+soiOverHealed);
statblock.soiOverHealed=soiOverHealed./(soiHealed+soiOverHealed);
statblock.soiHealSize=SoIHealSize;
statblock.soiOHbase=soiOHbase;
statblock.soiOHexpire=soiOHexpire;
statblock.soiOHbackExcess=soiOHbackExcess;
statblock.soiOHbackFull=soiOHbackFull;
wogOverHealed=wogOHbase+wogOHexpire+wogOHbackExcess+wogOHbackFull;
statblock.wogHealedRaw=wogHealed;
statblock.wogOverHealedRaw=wogOverHealed;
statblock.wogOverHealedRaw=wogOverHealed;
statblock.wogHealed=wogHealed./(wogHealed+wogOverHealed);
statblock.wogOverHealed=wogOverHealed./(wogHealed+wogOverHealed);
statblock.wogHealSize=WoGHealBase;
statblock.wogOHbase=wogOHbase;
statblock.wogOHexpire=wogOHexpire;
statblock.wogOHbackExcess=wogOHbackExcess;
statblock.wogOHbackFull=wogOHbackFull;

% %commented out for memory reasons, mostly useful as debugging anyhow
% statblock.hpgTracker=hpgTracker;
% statblock.hpgGained=hpgGained;
% statblock.soiTracker=soiTracker;

%% plot
if ~strcmp(plotFlag,'noplot')
    pally_mc_plot(config,statblock,sF)
end

%% helper functions
    function finisherCast(ftype,lock,bleed,~)
        if strcmpi(ftype,'S') %SotR spam
            castSotRIfAble()
        elseif strcmpi(ftype,'T') %maintain T152pc, bleed w/WoG
            if tob(idT152pc)<=ulp || hp==5
                castWoGT15(0);
            end
        elseif strcmpi(ftype,'TS') %maintain T152pc, bleed w/SotR
            if tob(idT152pc)<=ulp && (isnan(lock) || hp>=lock)
                castWoGT15(0);
            elseif hp==5
                castSotRIfAble()
            end
        elseif strcmpi(ftype,'ST') %SotR with T15 to bridge gaps
            if isnan(bleed) %no bleeding
                castSotRIfAble()
                if tob(idSotR)<=ulp && tob(idT152pc)<=ulp && (isnan(lock) || hp>=lock)
                    castWoGT15(0)
                end
            else %add a bleeding condition on BoG
                castSotRIfAble()
                if tob(idSotR)<=ulp && tob(idT152pc)<=ulp && (isnan(lock) || hp>=lock) && BoGstacks>=bleed;
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
        elseif strcmpi(ftype,'none')
            %nothing goes here
        else
            error('invalid finisher specification')
        end
        
    end

    function castSotRIfAble()
        
        %check for 3+ HP, if so cast SotR
        if ( hp>=3 || tob(idDPBuff)>0 ) && tob(idSotRcd)<=ulp 
            %check for negative SotR duration - if so fix at zero
            tob(idSotR)=max(tob(idSotR),0);
            
            %roll for hit
            if rand<(1-miss-dodge-parry)  
                
                %check for SoI proc                
                if rand<SoIProcChance
                    handleSoI;
                end
            end
            
            %set SotR CD, give 3 seconds of DR, 20s of BoG
            tob(idSotRcd)=tGCD; %5.2
            tob(idSotR)=tob(idSotR)+tSotR;
            tob(idBoG)=tBoG;
            BoGstacks=min(BoGstacks+1,5);
            SotRcasts=SotRcasts+1;
            
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
        if tob(idWoGcd)<=ulp
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
                handleWoG(hpused);
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
        if hp>5; hp=5; end
        if hp<0; hp=0; end
    end
            
    function abilityCast(priority)
        
        if strcmp(priority,'special')
        %placeholder for special generator priorities
                    
        %default, no time-shifting
        else
            
            %CS is first priority
            if tob(idCScd)<=ulp
                %put CS on cooldown, start GCD
                tob(idCScd)=tCScd;
                tbe(idGCD)=tGCD;
                %Check for hit
                if rand<(1-miss-dodge-parry)
                    %success! grant HP, enforce bounds
                    grantHP;
                    hpgTracker(k)=1; %debug flag
                    hpgGained(k)=1;
                    
                    %Check for Grand Crusader proc
                    if rand<gcCSProcRate
                        %set GC buff duration
                        tob(idGCbuff)=gcBuffDuration;
                        %reset AS cooldown
                        tob(idAScd)=0;
                        gcCSProcs=gcCSProcs+1;
                    end
                    
                    %check for SoI proc
                    if rand<SoIProcChance    
                        handleSoI;                     
                    end
                end
            %J is second priority, check for cooldown and don't use
            %if CS cd is almost up
            elseif tob(idJcd)<=ulp && tob(idCScd)>=0.2
                %set J cooldown, start GCD
                tob(idJcd)=tJcd;
                tbe(idGCD)=tGCD;
                %check for hit
                if rand<(1-miss)
                    %success! grant HP, enforce bounds
                    grantHP;
                    hpgTracker(k)=2; %debug flag
                    hpgGained(k)=1;
                end
            %Avenger's Shield
            elseif tob(idAScd)<=ulp && tob(idCScd)>=0.2
                %set AS cooldown, Start GCD
                tob(idAScd)=tAScd;
                tbe(idGCD)=tGCD;
                %if Grand Crusader was active,
                if tob(idGCbuff)>0
                    %Consume GC buff, set GCD
                    tob(idGCbuff)=0;
                    %grant HP, enforce bounds
                    grantHP;
                    hpgTracker(k)=3; %debug flag
                    hpgGained(k)=1;
                end
            %Sacred Shield
            elseif tob(idSScd)<=ulp
                %start SS cd, start GcD
                tob(idSScd)=6;
                tbe(idGCD)=tGCD;
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
                tbe(idGCD)=tGCD;
            end
        end
    end

    function dmgTaken=manyAbsorbsHandleIt(d)
        %initialize damage taken
        dmgTaken=d;
        
        % apply sacred shield first
        if ssAmount>0
            if dmgTaken>ssAmount
                dmgTaken=dmgTaken-ssAmount;
                ssAmount=0;
            else
                ssAmount=ssAmount-dmgTaken;
                dmgTaken=0;
            end
        end
        %then apply WoG if applicable
        if WoGAmount>0
            if dmgTaken>WoGAmount
                dmgTaken=dmgTaken-WoGAmount;
                WoGAmount=0;
            else
                WoGAmount=WoGAmount-dmgTaken;
                dmgTaken=0;
            end
        end
        %register full and partial absorbs
        if dmgTaken==0
            fullAbsorbs=fullAbsorbs+1;
        elseif dmgTaken<d
            partialAbsorbs=partialAbsorbs+1;
        end
        %then apply SoI
        if soiAmount>0
            if dmgTaken>=soiAmount
                dmgTaken=dmgTaken-soiAmount;
                soiHealed=soiHealed+soiAmount;
                soiAmount=0;
            else
                soiAmount=soiAmount-dmgTaken;
                soiHealed=soiHealed+dmgTaken;
                dmgTaken=0;
            end
        end
    end

    function updateAbsorbs()       
         
         %update absorbs
         if tob(idWoGfakebubble)<=ulp
             wogOHexpire=wogOHexpire+WoGAmount;
             WoGAmount=0;
         end
         if WoGAmount<=0
             tob(idWoGfakebubble)=0;
         end
         if tob(idSSbubble)<=ulp
             ssAmount=0;
         end
         if ssAmount<=0
             ssAmount=0; %cap at 0 just in case
         end
    end

    function t154pcIncrementHP(d)
    	grantHP(floor(d./dpThreshold)); 
        hpgTracker(k)=4;
        hpgGained(k)=floor(d./dpThreshold);
        t154pcHPGains=t154pcHPGains+floor(d./dpThreshold);
    end

    function SoiAmt=soiAbsorbValue(bossSwingHistory,soimodel)
        
        %create SoI bubble     
        if strcmp(soimodel.base,'nooverheal') %equiv. to flat-1
            SoiAmt=SoIHealSize;           
        elseif strcmp(soimodel.base,'flat') %flat-X0 for X0% effectiveness
            SoiAmt=SoIHealSize.*soimodel.x0;   
        elseif strcmp(soimodel.base,'fermi') %fermi-X0-SIGMA
            x=sum(bossSwingHistory(1:3));
            SoiAmt=SoIHealSize./(1+exp(-(x-soimodel.x0)/soimodel.sigma));             
        elseif strcmp(soimodel.base,'off') %equivalent to flat-0
            SoiAmt=0;
        else
            error('soi model not defined, this shouldn''t happen...')
        end
        soiOHbase=soiOHbase+(SoIHealSize-SoiAmt);
    end

    function handleSoI()
               
        %calculate size of SoI proc
        soiTemp=soiAbsorbValue(bossSwingHistory,soimodel);
        
        %apply either forward or backward
        if strcmp(soiDirection,'back')
            %back-application algorithm
            backApplySoI(soiTemp)
        else
            %add to current absorb bubble
            soiAmount=soiAmount+soiTemp;
        end
        
        %track SoI for debugging/post-processing
        soiTracker(k)=soiTemp;
                 
    end

    function handleWoG(hpused)
        
        %amount of WoG is flat
       
        %apply either forward or backward
        if strcmp(wogDirection,'back')
            %back-application algorithm
            backApplyWoG(WoGHealBase.*double(hpused));
        else
            %add to current absorb bubble
            %set cooldown of WoG
            tob(idWoGcd)=tGCD;
            %add a 3-second absorb shield
            tob(idWoGfakebubble)=WoGfakeBubbleDuration;
            %set the amount of the absorb shield based on HP spent, BoG
            WoGAmount=WoGHealBase.*double(hpused).*(1+BoGstacks.*(0.1+mastery/100));
        end
    end

    function backApplySoI(x)
        %if the previous boss swing is nonzero
        if bossSwingHistory(1)>0
            %find this entry in damage
            kk=find(damage(max(k-backSteps,0):k)==bossSwingHistory(1));
            id=max(k-backSteps,1)-1+kk;
            %adjust by subtracting SoI
            if x>=damage(id)
                soiHealed=soiHealed+damage(id);
                soiOHbackExcess=soiOHbackExcess+(x-damage(id));
                damage(id)=0;
                bossSwingHistory(1)=damage(id);
            else
                damage(id)=damage(id)-x;
                soiHealed=soiHealed+x;
                bossSwingHistory(1)=damage(id);
            end       
        else
            soiOHbackFull=soiOHbackFull+x;
        end
    end

    function backApplyWoG(x)
        %if the previous boss swing is nonzero
        if bossSwingHistory(1)>0
            %find this entry in damage
            kk=find(damage(max(k-backSteps,1):k)==bossSwingHistory(1));
            id=max(k-backSteps,1)-1+kk;
            %adjust by subtracting SoI
            if x>damage(id)
                wogHealed=wogHealed+damage(id);
                wogOHbackExcess=wogOHbackExcess+(x-damage(id));
                damage(id)=0;
                bossSwingHistory(1)=damage(id);
            else
                damage(id)=damage(id)-x;
                wogHealed=wogHealed+x;
                bossSwingHistory(1)=damage(id);
            end
        else
            wogOHbackFull=wogOHbackFull+x;
        end
    end
end