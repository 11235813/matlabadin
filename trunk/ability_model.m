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
threat.SealofTruth=dmg.SealofTruth.*mdf.RF;

%Censure (fully stacked, full duration)
raw.Censure=        (0.050.*player.hsp+0.0965.*player.ap).*5.*mdf.SotP.*mdf.spdmg;
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./(5.*cens.NetTick);
threat.Censure=dmg.Censure.*mdf.RF;
tps.Censure=threat.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.011.*player.ap+0.022.*player.hsp).* ...
                            mdf.spdmg.*mdf.SotP;
raw.JoR                =    (1+0.32.*player.hsp+0.2.*player.ap);
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx; %automatical connect
threat.SealofRighteousness=dmg.SealofRighteousness.*mdf.RF;

%Seal of Insight (15 PPM, not haste-normalized)
raw.SealofInsight=          0;
raw.JoI          =          (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofInsight=          raw.SealofInsight;
threat.SealofInsight=(15.*gear.swing./60).*0.15.*(player.hsp+player.ap).*mdf.Divin ...
                     .*mdf.hthreat.*mdf.RF;

%Seal of Justice
raw.SealofJustice=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg.*mdf.SotP;
raw.JoJ          =          (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofJustice=          raw.SealofJustice.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
threat.SealofJustice=dmg.SealofJustice.*mdf.RF;

%exhaustive listing of seal/judgement damage
if isempty(exec.seal)==1
    dmg.activeseal=0;
    threat.activeseal=0;
    raw.Judgement=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    dmg.activeseal=dmg.SealofInsight;
    threat.activeseal=threat.SealofInsight;
    raw.Judgement=raw.JoI;
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
    dmg.activeseal=dmg.SealofJustice;
    threat.activeseal=threat.SealofJustice;
    raw.Judgement=raw.JoJ;
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    dmg.activeseal=dmg.SealofRighteousness;
    threat.activeseal=threat.SealofRighteousness;
    raw.Judgement=raw.JoR;
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    dmg.activeseal=dmg.SealofTruth;
    threat.activeseal=threat.SealofTruth;
    raw.Judgement=raw.JoT;
end

%% Melee abilities

%Crusader Strike (can be blocked)
raw.CrusaderStrike= 1.15.*player.ndamage.*mdf.phdmg.*(1+mdf.Crus+(10./3).*mdf.WotL+mdf.t11x2);
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.CScrit;
threat.CrusaderStrike=dmg.CrusaderStrike.*mdf.RF;
net.CrusaderStrike{1}=dmg.CrusaderStrike+dmg.activeseal.*mdf.mehit;
net.CrusaderStrike{2}=threat.CrusaderStrike+threat.activeseal.*mdf.mehit;

%Hammer of the Righteous
%physical (can be blocked)
mdf.HotRmodel=1+(mdf.blockrdx-1).*target.block./100;
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.phdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.HotRmodel.*mdf.HotRphcrit;
threat.HammeroftheRighteous=dmg.HammeroftheRighteous.*mdf.RF;
net.HammeroftheRighteous{1}=dmg.HammeroftheRighteous; %doesn't proc seals
net.HammeroftheRighteous{2}=threat.HammeroftheRighteous;
%the physical component always connects, the nova rolls for hit only once
raw.HammerNova=   (728.8813374+0.18.*player.ap).*mdf.spdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammerNova=   raw.HammerNova.*mdf.sphit.*mdf.HotRspcrit.*target.resrdx; %spell hit/crit
threat.HammerNova=dmg.HammerNova.*mdf.RF;
net.HammerNova{1}=dmg.HammerNova; %doesn't proc seals
net.HammerNova{2}=threat.HammerNova;

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;
threat.Melee=       dmg.Melee.*mdf.RF;
tps.Melee=          threat.Melee./player.wswing;
net.Melee{1}=       dmg.Melee+dmg.activeseal.*mdf.mehit;
net.Melee{2}=       threat.Melee+threat.activeseal.*mdf.mehit;

%Shield of the Righteous (can be blocked)
mdf.hpscale=(player.hopo==1)+3.*(player.hopo==2)+6.*(player.hopo==3);
raw.ShieldoftheRighteous= ((610.2+0.1.*player.ap).*mdf.hpscale).*mdf.spdmg.*mdf.glyphSotR;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit ...
                          .*target.resrdx; %melee hit
threat.ShieldoftheRighteous{1}=raw.ShieldoftheRighteous.*mdf.RF;
threat.ShieldoftheRighteous{2}=dmg.ShieldoftheRighteous.*mdf.RF;
net.ShieldoftheRighteous{1}=dmg.ShieldoftheRighteous+dmg.activeseal.*mdf.mehit;
net.ShieldoftheRighteous{2}=threat.ShieldoftheRighteous{2}+threat.activeseal.*mdf.mehit;

%% Ranged abilities

%Avenger's Shield (can be blocked)
raw.AvengersShield= (3113.187994+0.419.*player.ap+0.21.*player.hsp).*mdf.spdmg.*mdf.glyphAS;
dmg.AvengersShield= raw.AvengersShield.*mdf.ramodel.*mdf.phcrit.*target.resrdx;
threat.AvengersShield=dmg.AvengersShield.*mdf.RF;
net.AvengersShield{1}=dmg.AvengersShield; %doesn't proc seals
net.AvengersShield{2}=threat.AvengersShield;

%Judgement (the seal of choice is defined in execution_model)
mdf.jseals=(mdf.JotJ>0)&&(strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal) ...
    ||strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)); %JotJ procs only R/T
raw.Judgement=      raw.Judgement.*mdf.spdmg.*(1+mdf.glyphJ+(10./3).*mdf.WotL);
dmg.Judgement=      raw.Judgement.*mdf.rahit.*mdf.Jcrit.*target.resrdx;
threat.Judgement=   dmg.Judgement.*mdf.RF;
net.Judgement{1}=   dmg.Judgement+mdf.jseals.*dmg.activeseal.*mdf.rahit;
net.Judgement{2}=   threat.Judgement+mdf.jseals.*threat.activeseal.*mdf.rahit;

%Hammer of Wrath (can be blocked)
raw.HammerofWrath= (4015.02439+0.117.*player.hsp+0.39.*player.ap).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
threat.HammerofWrath=dmg.HammerofWrath.*mdf.RF;
net.HammerofWrath{1}=dmg.HammerofWrath; %doesn't proc seals
net.HammerofWrath{2}=threat.HammerofWrath;

%% Spell abilities

%Consecration
raw.Consecration =  (813.2998299+0.27.*player.hsp+0.27.*player.ap).*mdf.spdmg.*(1+mdf.HalGro).*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
threat.Consecration=dmg.Consecration.*mdf.RF;
net.Consecration{1}=dmg.Consecration;
net.Consecration{2}=threat.Consecration;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])).*mdf.spdmg ...
                    .*(mdf.BlazLi+mdf.glyphExo); %DoT is based on base damage
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
threat.Exorcism=    dmg.Exorcism.*mdf.RF;
net.Exorcism{1}=    dmg.Exorcism;
net.Exorcism{2}=    threat.Exorcism;

%Holy Wrath
raw.HolyWrath=      ((2402.8+0.61.*player.hsp)./exec.npccount).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;
threat.HolyWrath=   dmg.HolyWrath.*mdf.RF;
net.HolyWrath{1}=   dmg.HolyWrath;
net.HolyWrath{2}=   threat.HolyWrath;

%Word of Glory //TODO
raw.WordofGlory=    0;
dmg.WordofGlory=    raw.WordofGlory;
threat.WordofGlory= (2133+0.21.*player.hsp+0.17.*player.ap).*player.hopo.*mdf.WoGcrit ...
                    .*(1-exec.overh).*mdf.Divin.*mdf.glyphSoI.*mdf.glyphWoG.*mdf.GbtL.*mdf.hthreat ...
                    +5.5.*(exec.overh>0);
threat.WordofGlory= threat.WordofGlory.*mdf.RF;
net.WordofGlory{1}= dmg.WordofGlory;
net.WordofGlory{2}= threat.WordofGlory;


%% Consolidated arrays
val.length=max([length(dmg.Consecration) length(dmg.CrusaderStrike)]);
val.zeros=zeros(1,val.length);
val.ones=ones(1,val.length);

val.raw=[round(raw.ShieldoftheRighteous).*val.ones; 
    round(raw.CrusaderStrike).*val.ones; 
    round(raw.Judgement).*val.ones; 
    round(raw.AvengersShield).*val.ones; 
    round(raw.HolyWrath).*val.ones; 
    round(raw.HammerofWrath).*val.ones; 
    round(raw.Exorcism).*val.ones; 
    round(raw.SealofTruth).*val.ones; 
    round(raw.SealofRighteousness).*val.ones; 
    round(raw.SealofJustice).*val.ones; 
    round(raw.Censure).*val.ones; 
    round(raw.Consecration).*val.ones; 
    round(raw.HammeroftheRighteous).*val.ones;
    round(raw.HammerNova).*val.ones;
    round(raw.Melee).*val.ones;
    round(raw.WordofGlory).*val.ones];

val.dmg=[round(dmg.ShieldoftheRighteous).*val.ones; 
    round(dmg.CrusaderStrike).*val.ones; 
    round(dmg.Judgement).*val.ones; 
    round(dmg.AvengersShield).*val.ones; 
    round(dmg.HolyWrath).*val.ones; 
    round(dmg.HammerofWrath).*val.ones; 
    round(dmg.Exorcism).*val.ones; 
    round(dmg.SealofTruth).*val.ones; 
    round(dmg.SealofRighteousness).*val.ones; 
    round(dmg.SealofJustice).*val.ones; 
    round(dmg.Censure).*val.ones; 
    round(dmg.Consecration).*val.ones; 
    round(dmg.HammeroftheRighteous).*val.ones;
    round(dmg.HammerNova).*val.ones;
    round(dmg.Melee).*val.ones;
    round(dmg.WordofGlory).*val.ones];

val.threat=[round(threat.ShieldoftheRighteous{2}).*val.ones; 
    round(threat.CrusaderStrike).*val.ones; 
    round(threat.Judgement).*val.ones; 
    round(threat.AvengersShield).*val.ones; 
    round(threat.HolyWrath).*val.ones; 
    round(threat.HammerofWrath).*val.ones; 
    round(threat.Exorcism).*val.ones; 
    round(threat.SealofTruth).*val.ones; 
    round(threat.SealofRighteousness).*val.ones; 
    round(threat.SealofJustice).*val.ones; 
    round(threat.Censure).*val.ones; 
    round(threat.Consecration).*val.ones; 
    round(threat.HammeroftheRighteous).*val.ones;
    round(threat.HammerNova).*val.ones;
    round(threat.Melee).*val.ones;
    round(threat.WordofGlory).*val.ones];

for i=1:2
val.net{i}=[round(net.ShieldoftheRighteous{i}).*val.ones; 
    round(net.CrusaderStrike{i}).*val.ones; 
    round(net.Judgement{i}).*val.ones; 
    round(net.AvengersShield{i}).*val.ones; 
    round(net.HolyWrath{i}).*val.ones; 
    round(net.HammerofWrath{i}).*val.ones; 
    round(net.Exorcism{i}).*val.ones; 
    val.zeros; val.zeros; val.zeros;
    round(dmg.Censure).*val.ones; 
    round(net.Consecration{i}).*val.ones; 
    round(net.HammeroftheRighteous{i}).*val.ones;
    round(net.HammerNova{i}).*val.ones;
    round(net.Melee{i}).*val.ones;
    round(net.WordofGlory{i}).*val.ones];
end
clear i

%damage/threat arrays for priority calculations
val.pdmg=[raw.ShieldoftheRighteous.*val.ones;
          dmg.CrusaderStrike.*val.ones;
          dmg.Judgement.*val.ones;
          dmg.AvengersShield.*val.ones;
          dmg.HolyWrath.*val.ones;
          dmg.Consecration.*val.ones;
          dmg.HammeroftheRighteous.*val.ones;
          dmg.ShieldoftheRighteous./2.*val.ones;
          val.zeros;
          dmg.HammerofWrath.*val.ones;
          dmg.activeseal.*val.ones;
          dmg.HammerNova.*val.ones;
          dmg.WordofGlory.*val.ones];  

val.admg=[raw.ShieldoftheRighteous.*val.ones;
          dmg.CrusaderStrike.*val.ones;
          dmg.Judgement.*val.ones;
          dmg.AvengersShield./mdf.glyphAS.*min([exec.npccount;3]).*val.ones;
          dmg.HolyWrath.*exec.npccount.*val.ones;
          dmg.Consecration.*min([exec.npccount;10]).*val.ones; %hand-wavy AoE damage cap
          dmg.HammeroftheRighteous.*val.ones;
          dmg.ShieldoftheRighteous./2.*val.ones;
          val.zeros;
          dmg.HammerofWrath.*val.ones;
          dmg.activeseal.*val.ones;
          dmg.HammerNova.*min([exec.npccount;10]).*val.ones;   %and again
          dmg.WordofGlory.*val.ones];

val.pthr=[threat.ShieldoftheRighteous{1}.*val.ones;
          threat.CrusaderStrike.*val.ones;
          threat.Judgement.*val.ones;
          threat.AvengersShield.*val.ones;
          threat.HolyWrath.*val.ones;
          threat.Consecration.*val.ones;
          threat.HammeroftheRighteous.*val.ones;
          threat.ShieldoftheRighteous{2}./2.*val.ones;
          val.zeros;
          threat.HammerofWrath.*val.ones;
          threat.activeseal.*val.ones;
          threat.HammerNova.*val.ones;
          threat.WordofGlory.*val.ones];

val.athr=[threat.ShieldoftheRighteous{1}.*val.ones;
          threat.CrusaderStrike.*val.ones;
          threat.Judgement.*val.ones;
          threat.AvengersShield./mdf.glyphAS.*min([exec.npccount;3]).*val.ones;
          threat.HolyWrath.*exec.npccount.*val.ones;
          threat.Consecration.*min([exec.npccount;10]).*val.ones;
          threat.HammeroftheRighteous.*val.ones;
          threat.ShieldoftheRighteous{2}./2.*val.ones;
          val.zeros;
          threat.HammerofWrath.*val.ones;
          threat.activeseal.*val.ones;
          threat.HammerNova.*min([exec.npccount;10]).*val.ones;
          threat.WordofGlory.*val.ones];