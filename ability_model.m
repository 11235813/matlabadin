%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations

%% Holy Power
player.hopo=3;  %TODO move it

%% Seals

%Seal of Truth (fully stacked)
raw.SealofTruth=    0.15.*player.wdamage.*mdf.spdmg.*mdf.SotP; 
raw.JoT        =    (1+0.2229.*player.hsp+0.1421.*player.ap).*1.5; 
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofTruth=   0;
threat.SealofTruth= max(dmg.SealofTruth,heal.SealofTruth).*mdf.RF;

%Censure (fully stacked, full duration)
raw.Censure=        (0.050.*player.hsp+0.0965.*player.ap).*5.*mdf.SotP.*mdf.spdmg;
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./(5.*cens.NetTick);
heal.Censure=       0;
hps.Censure=        0;
threat.Censure=max(dmg.Censure,heal.Censure).*mdf.RF;
tps.Censure=threat.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.011.*player.ap+0.022.*player.hsp).* ...
                            mdf.spdmg.*mdf.SotP;
raw.JoR                =    (1+0.32.*player.hsp+0.2.*player.ap);
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx; %automatical connect
heal.SealofRighteousness=   0;
threat.SealofRighteousness=max(dmg.SealofRighteousness,heal.SealofRighteousness).*mdf.RF;

%Seal of Insight (15 PPM, not haste-normalized)
raw.SealofInsight=          0.15.*(player.hsp+player.ap).*mdf.Divin;
raw.JoI          =          (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofInsight=          0;
heal.SealofInsight=         raw.SealofInsight.*(15.*gear.swing./60);
threat.SealofInsight=       max(dmg.SealofInsight,heal.SealofInsight).*mdf.hthreat.*mdf.RF./exec.npccount;

%Seal of Justice
raw.SealofJustice=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg.*mdf.SotP;
raw.JoJ          =          (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofJustice=          raw.SealofJustice.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.SealofJustice=         0;
threat.SealofJustice=max(dmg.SealofJustice,heal.SealofJustice).*mdf.RF;

%exhaustive listing of seal/judgement damage
if isempty(exec.seal)
    dmg.activeseal=0;
    heal.activeseal=0;
    threat.activeseal=0;
    raw.Judgement=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    dmg.activeseal=dmg.SealofInsight;
    heal.activeseal=heal.SealofInsight;
    threat.activeseal=threat.SealofInsight;
    raw.Judgement=raw.JoI;
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
    dmg.activeseal=dmg.SealofJustice;
    heal.activeseal=heal.SealofJustice;
    threat.activeseal=threat.SealofJustice;
    raw.Judgement=raw.JoJ;
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    dmg.activeseal=dmg.SealofRighteousness;
    heal.activeseal=heal.SealofRighteousness;
    threat.activeseal=threat.SealofRighteousness;
    raw.Judgement=raw.JoR;
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    dmg.activeseal=dmg.SealofTruth;
    heal.activeseal=heal.SealofTruth;
    threat.activeseal=threat.SealofTruth;
    raw.Judgement=raw.JoT;
end

%% Melee abilities

%Crusader Strike (can be blocked)
raw.CrusaderStrike= 1.15.*player.ndamage.*mdf.phdmg.*(1+mdf.Crus+(10./3).*mdf.WotL+mdf.t11x2);
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.CScrit;
heal.CrusaderStrike=0;
threat.CrusaderStrike=max(dmg.CrusaderStrike,heal.CrusaderStrike).*mdf.RF;
net.CrusaderStrike{1}=dmg.CrusaderStrike+dmg.activeseal.*mdf.mehit;
net.CrusaderStrike{2}=heal.CrusaderStrike+heal.activeseal.*mdf.mehit;
net.CrusaderStrike{3}=threat.CrusaderStrike+threat.activeseal.*mdf.mehit;

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.phdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.HotRphcrit;
heal.HammeroftheRighteous=   0;
threat.HammeroftheRighteous=max(dmg.HammeroftheRighteous,heal.HammeroftheRighteous).*mdf.RF;
net.HammeroftheRighteous{1}=dmg.HammeroftheRighteous; %doesn't proc seals
net.HammeroftheRighteous{2}=heal.HammeroftheRighteous;
net.HammeroftheRighteous{3}=threat.HammeroftheRighteous;
%the nova rolls for hit only if physical connects
raw.HammerNova=   (728.8813374+0.18.*player.ap).*mdf.spdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammerNova=   raw.HammerNova.*mdf.mehit.*mdf.sphit.*mdf.HotRspcrit.*target.resrdx; %spell hit/crit
heal.HammerNova=   0;
threat.HammerNova=max(dmg.HammerNova,heal.HammerNova).*mdf.RF;
net.HammerNova{1}=dmg.HammerNova; %doesn't proc seals
net.HammerNova{2}=heal.HammerNova;
net.HammerNova{3}=threat.HammerNova;

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;
heal.Melee=         0;
hps.Melee=          0;
threat.Melee=       max(dmg.Melee,heal.Melee).*mdf.RF;
tps.Melee=          threat.Melee./player.wswing;
net.Melee{1}=       dmg.Melee+dmg.activeseal.*mdf.mehit;
net.Melee{2}=       heal.Melee+heal.activeseal.*mdf.mehit;
net.Melee{3}=       threat.Melee+threat.activeseal.*mdf.mehit;

%Shield of the Righteous (can be blocked)
mdf.hpscale=(player.hopo==1)+3.*(player.hopo==2)+6.*(player.hopo==3);
raw.ShieldoftheRighteous= ((610.2+0.1.*player.ap).*mdf.hpscale).*mdf.spdmg.*mdf.glyphSotR;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit ...
                          .*target.resrdx; %melee hit
heal.ShieldoftheRighteous=0;
threat.ShieldoftheRighteous{1}=raw.ShieldoftheRighteous.*mdf.RF;
threat.ShieldoftheRighteous{2}=dmg.ShieldoftheRighteous.*mdf.RF;
net.ShieldoftheRighteous{1}=dmg.ShieldoftheRighteous+dmg.activeseal.*mdf.mehit;
net.ShieldoftheRighteous{2}=heal.ShieldoftheRighteous+heal.activeseal.*mdf.mehit;
net.ShieldoftheRighteous{3}=threat.ShieldoftheRighteous{2}+threat.activeseal.*mdf.mehit;

%% Ranged abilities

%Avenger's Shield (can be blocked)
raw.AvengersShield= (3113.187994+0.419.*player.ap+0.21.*player.hsp).*mdf.spdmg.*mdf.glyphAS;
dmg.AvengersShield= raw.AvengersShield.*mdf.ramodel.*mdf.phcrit.*target.resrdx;
heal.AvengersShield=0;
threat.AvengersShield=max(dmg.AvengersShield,heal.AvengersShield).*mdf.RF;
net.AvengersShield{1}=dmg.AvengersShield; %doesn't proc seals
net.AvengersShield{2}=heal.AvengersShield;
net.AvengersShield{3}=threat.AvengersShield;

%Judgement (the seal of choice is defined in execution_model)
mdf.jseals=(mdf.JotJ>1)&&(strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal) ...
    ||strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)); %JotJ procs only R/T
raw.Judgement=      raw.Judgement.*mdf.spdmg.*(1+mdf.glyphJ+(10./3).*mdf.WotL);
dmg.Judgement=      raw.Judgement.*mdf.rahit.*mdf.Jcrit.*target.resrdx;
heal.Judgement=     0;
threat.Judgement=   max(dmg.Judgement,heal.Judgement).*mdf.RF;
net.Judgement{1}=   dmg.Judgement+mdf.jseals.*dmg.activeseal.*mdf.rahit;
net.Judgement{2}=   heal.Judgement+mdf.jseals.*heal.activeseal.*mdf.rahit;
net.Judgement{3}=   threat.Judgement+mdf.jseals.*threat.activeseal.*mdf.rahit;

%Hammer of Wrath (can be blocked)
raw.HammerofWrath= (4015.02439+0.117.*player.hsp+0.39.*player.ap).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
heal.HammerofWrath=0;
threat.HammerofWrath=max(dmg.HammerofWrath,heal.HammerofWrath).*mdf.RF;
net.HammerofWrath{1}=dmg.HammerofWrath; %doesn't proc seals
net.HammerofWrath{2}=heal.HammerofWrath;
net.HammerofWrath{3}=threat.HammerofWrath;

%% Spell abilities

%Consecration
raw.Consecration =  (813.2998299+0.27.*player.hsp+0.27.*player.ap).*mdf.spdmg.*(1+mdf.HalGro).*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.Consecration=  0;
threat.Consecration=max(dmg.Consecration,heal.Consecration).*mdf.RF;
net.Consecration{1}=dmg.Consecration;
net.Consecration{2}=heal.Consecration;
net.Consecration{3}=threat.Consecration;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])).*mdf.spdmg ...
                    .*(mdf.BlazLi+mdf.glyphExo); %DoT is based on base damage
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
heal.Exorcism=      0;
threat.Exorcism=    max(dmg.Exorcism,heal.Exorcism).*mdf.RF;
net.Exorcism{1}=    dmg.Exorcism;
net.Exorcism{2}=    heal.Exorcism;
net.Exorcism{3}=    threat.Exorcism;

%Holy Wrath
raw.HolyWrath=      ((2402.8+0.61.*player.hsp)./exec.npccount).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;
heal.HolyWrath=     0;
threat.HolyWrath=   max(dmg.HolyWrath,heal.HolyWrath).*mdf.RF;
net.HolyWrath{1}=   dmg.HolyWrath;
net.HolyWrath{2}=   heal.HolyWrath;
net.HolyWrath{3}=   threat.HolyWrath;

%Word of Glory //TODO
raw.WordofGlory=    (2133+0.2086.*player.hsp+0.1984.*player.ap).*player.hopo ...
                    .*(1-exec.overh).*mdf.Divin.*mdf.GbtL.*(1+mdf.glyphWoG+mdf.glyphSoI);
dmg.WordofGlory=    0;
heal.WordofGlory=   raw.WordofGlory.*mdf.WoGcrit;
threat.WordofGlory= (heal.WordofGlory.*mdf.hthreat+5.5.*(exec.overh>0)).*mdf.RF./exec.npccount;
net.WordofGlory{1}= dmg.WordofGlory;
net.WordofGlory{2}= heal.WordofGlory;
net.WordofGlory{3}= threat.WordofGlory;


%% Consolidated arrays
val.length=max([length(dmg.Consecration) length(dmg.CrusaderStrike)]);
val.zeros=zeros(1,val.length);
val.ones=ones(1,val.length);

val.raw=[...
    round(raw.ShieldoftheRighteous).*val.ones;
    round(raw.WordofGlory).*val.ones;
    ...
    round(raw.CrusaderStrike).*val.ones;
    round(raw.HammeroftheRighteous).*val.ones;
    ...
    round(raw.AvengersShield).*val.ones;
    round(raw.Consecration).*val.ones;
    round(raw.Exorcism).*val.ones;
    round(raw.HammerofWrath).*val.ones;
    round(raw.HolyWrath).*val.ones;
    round(raw.Judgement).*val.ones; 
    ...
    round(raw.HammerNova).*val.ones;
    round(raw.SealofInsight).*val.ones;
    round(raw.SealofJustice).*val.ones;
    round(raw.SealofRighteousness).*val.ones; 
    round(raw.SealofTruth).*val.ones; 
    ...
    round(raw.Melee).*val.ones;
    round(raw.Censure).*val.ones];

val.dmg=[...
    round(dmg.ShieldoftheRighteous).*val.ones;
    round(dmg.WordofGlory).*val.ones;
    ...
    round(dmg.CrusaderStrike).*val.ones;
    round(dmg.HammeroftheRighteous).*val.ones;
    ...
    round(dmg.AvengersShield).*val.ones;
    round(dmg.Consecration).*val.ones;
    round(dmg.Exorcism).*val.ones;
    round(dmg.HammerofWrath).*val.ones;
    round(dmg.HolyWrath).*val.ones;
    round(dmg.Judgement).*val.ones;
    ...
    round(dmg.HammerNova).*val.ones;
    round(dmg.SealofInsight).*val.ones;
    round(dmg.SealofJustice).*val.ones;
    round(dmg.SealofRighteousness).*val.ones; 
    round(dmg.SealofTruth).*val.ones; 
    ...
    round(dmg.Melee).*val.ones;
    round(dmg.Censure).*val.ones];

val.heal=[...
    round(heal.ShieldoftheRighteous).*val.ones;
    round(heal.WordofGlory).*val.ones;
    ...
    round(heal.CrusaderStrike).*val.ones;
    round(heal.HammeroftheRighteous).*val.ones;
    ...
    round(heal.AvengersShield).*val.ones;
    round(heal.Consecration).*val.ones;
    round(heal.Exorcism).*val.ones;
    round(heal.HammerofWrath).*val.ones;
    round(heal.HolyWrath).*val.ones;
    round(heal.Judgement).*val.ones;
    ...
    round(heal.HammerNova).*val.ones;
    round(heal.SealofInsight).*val.ones;
    round(heal.SealofJustice).*val.ones;
    round(heal.SealofRighteousness).*val.ones; 
    round(heal.SealofTruth).*val.ones; 
    ...
    round(heal.Melee).*val.ones;
    round(heal.Censure).*val.ones];

val.threat=[...
    round(threat.ShieldoftheRighteous{2}).*val.ones; 
    round(threat.WordofGlory).*val.ones;
    ...
    round(threat.CrusaderStrike).*val.ones;
    round(threat.HammeroftheRighteous).*val.ones;
    ...
    round(threat.AvengersShield).*val.ones;
    round(threat.Consecration).*val.ones;
    round(threat.Exorcism).*val.ones;
    round(threat.HammerofWrath).*val.ones;
    round(threat.HolyWrath).*val.ones;
    round(threat.Judgement).*val.ones;
    ...
    round(threat.HammerNova).*val.ones;
    round(threat.SealofInsight).*val.ones;
    round(threat.SealofJustice).*val.ones;
    round(threat.SealofRighteousness).*val.ones; 
    round(threat.SealofTruth).*val.ones; 
    ...
    round(threat.Melee).*val.ones;
    round(threat.Censure).*val.ones];

for i=1:3
val.net{i}=[...
    round(net.ShieldoftheRighteous{i}).*val.ones;
    round(net.WordofGlory{i}).*val.ones;
    ...
    round(net.CrusaderStrike{i}).*val.ones;
    round(net.HammeroftheRighteous{i}).*val.ones;
    ...
    round(net.AvengersShield{i}).*val.ones;
    round(net.Consecration{i}).*val.ones;
    round(net.Exorcism{i}).*val.ones;
    round(net.HammerofWrath{i}).*val.ones; 
    round(net.HolyWrath{i}).*val.ones;
    round(net.Judgement{i}).*val.ones; 
    ...
    round(net.HammerNova{i}).*val.ones;
    val.zeros; val.zeros; val.zeros; val.zeros;
    ...
    round(dmg.Censure).*val.ones;
    round(net.Melee{i}).*val.ones];
end
clear i

%output arrays for priority calculations
val.pdmg=[...
          val.zeros; %Inq
          raw.ShieldoftheRighteous./2.*val.ones; %2SotR
          raw.ShieldoftheRighteous.*val.ones;
          dmg.WordofGlory.*val.ones;
          ...
          dmg.CrusaderStrike.*val.ones;
          dmg.HammeroftheRighteous.*val.ones;
          ...
          dmg.AvengersShield.*val.ones;
          dmg.Consecration.*val.ones;
          dmg.HammerofWrath.*val.ones;
          dmg.HolyWrath.*val.ones;
          dmg.Judgement.*val.ones;
          ...
          dmg.HammerNova.*val.ones;
          dmg.activeseal.*val.ones];

val.admg=[...
          val.zeros;
          raw.ShieldoftheRighteous./2.*val.ones;
          raw.ShieldoftheRighteous.*val.ones;
          dmg.WordofGlory.*val.ones;
          ...
          dmg.CrusaderStrike.*val.ones;
          dmg.HammeroftheRighteous.*val.ones;
          ...
          dmg.AvengersShield./mdf.glyphAS.*min([exec.npccount;3]).*val.ones;
          dmg.Consecration.*min([exec.npccount;10]).*val.ones;
          dmg.HammerofWrath.*val.ones;
          dmg.HolyWrath.*exec.npccount.*val.ones;
          dmg.Judgement.*val.ones;
          ...
          dmg.HammerNova.*min([exec.npccount;10]).*val.ones;
          dmg.activeseal.*val.ones];

val.pheal=[...
          val.zeros; %Inq
          heal.ShieldoftheRighteous.*val.ones; %2SotR
          heal.ShieldoftheRighteous.*val.ones;
          heal.WordofGlory.*val.ones;
          ...
          heal.CrusaderStrike.*val.ones;
          heal.HammeroftheRighteous.*val.ones;
          ...
          heal.AvengersShield.*val.ones;
          heal.Consecration.*val.ones;
          heal.HammerofWrath.*val.ones;
          heal.HolyWrath.*val.ones;
          heal.Judgement.*val.ones;
          ...
          heal.HammerNova.*val.ones;
          heal.activeseal.*val.ones];

val.pthr=[...
          val.zeros;
          threat.ShieldoftheRighteous{1}./2.*val.ones;
          threat.ShieldoftheRighteous{1}.*val.ones;
          threat.WordofGlory.*val.ones;
          ...
          threat.CrusaderStrike.*val.ones;
          threat.HammeroftheRighteous.*val.ones;
          ...
          threat.AvengersShield.*val.ones;
          threat.Consecration.*val.ones;
          threat.HammerofWrath.*val.ones;
          threat.HolyWrath.*val.ones;
          threat.Judgement.*val.ones;
          ...
          threat.HammerNova.*val.ones;
          threat.activeseal.*val.ones];

if (strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)) mdf.iseal=min([exec.npccount;10]); else mdf.iseal=1; end;
val.athr=[...
          val.zeros;
          threat.ShieldoftheRighteous{1}./2.*val.ones;
          threat.ShieldoftheRighteous{1}.*val.ones;
          threat.WordofGlory.*min([exec.npccount;10]).*val.ones
          ...
          threat.CrusaderStrike.*val.ones;
          threat.HammeroftheRighteous.*val.ones;
          ...
          threat.AvengersShield./mdf.glyphAS.*min([exec.npccount;3]).*val.ones;
          threat.Consecration.*min([exec.npccount;10]).*val.ones;
          threat.HammerofWrath.*val.ones;
          threat.HolyWrath.*exec.npccount.*val.ones;
          threat.Judgement.*val.ones;
          ...
          threat.HammerNova.*min([exec.npccount;10]).*val.ones;
          threat.activeseal.*mdf.iseal.*val.ones];