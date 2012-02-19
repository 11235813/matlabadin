function [c]=ability_model(c)
%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations


%TODO: check for redundancy of player.sp and player.hsp - hopefully we can
%remove player.hsp entirely.

%% Unpack
mdf=c.mdf;
player=c.player;
target=c.target;


%% Holy Power
player.hopo=3;  %TODO: probably no reason to consider 1- or 2-HP SotR/WoG anymore

%% Seals
%TODO: Retest all hit conditions for seals
%Seal of Truth (fully stacked)
raw.SealofTruth=    0.10.*player.wdamage.*mdf.spdmg; 
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofTruth=   0;
threat.SealofTruth= dmg.SealofTruth.*mdf.RFury;
mcost.SealofTruth=0;

%Censure (fully stacked)
%As we do not model interruptions, Cens is assumed to be perpetually
%refreshed (full uptime).
raw.Censure=        (0.014.*player.hsp+0.0270.*player.ap).*5 ...
                    .*mdf.spdmg; %per tick (for 5 stacks)
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./player.censTick;
heal.Censure=       0;
hps.Censure=        0;
threat.Censure=     dmg.Censure.*mdf.RFury;
tps.Censure=        threat.Censure./cens.NetTick;

%Seal of Righteousness - now seal of cleave
raw.SealofRighteousness=    gear.swing.*(0.011.*player.ap+0.022.*player.hsp) ...
                            .*mdf.spdmg;
dmg.SealofRighteousness=    raw.SealofRighteousness.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofRighteousness=   0;
threat.SealofRighteousness= dmg.SealofRighteousness.*mdf.RFury;
mcost.SealofRighteousness=  0;

%Seal of Command - possibly low-level seal
raw.SealofCommand=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg;
dmg.SealofCommand=          raw.SealofCommand.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.SealofCommand=         0;
threat.SealofCommand=       dmg.SealofCommand.*mdf.RFury;
mcost.SealofCommand=        0;


%Seal of Insight (15 PPM, not haste-normalized)
raw.SealofInsight=          0.15.*(player.hsp+player.ap);
dmg.SealofInsight=          0;
heal.SealofInsight=         raw.SealofInsight.*(15.*gear.swing./60);
threat.SealofInsight=       max(dmg.SealofInsight,heal.SealofInsight).*mdf.hthreat.*mdf.RFury./exec.npccount;
mcost.SealofInsight=        -0.04.*base.mana;


%exhaustive listing of seal/judgement damage
if isempty(exec.seal)
    dmg.activeseal=0;
    heal.activeseal=0;
    threat.activeseal=0;
    mcost.activeseal=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    dmg.activeseal=dmg.SealofInsight;
    heal.activeseal=heal.SealofInsight;
    threat.activeseal=threat.SealofInsight;
    mcost.activeseal=mcost.SealofInsight;
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
    dmg.activeseal=dmg.SealofJustice;
    heal.activeseal=heal.SealofJustice;
    threat.activeseal=threat.SealofJustice;
    mcost.activeseal=mcost.SealofJustice;
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    dmg.activeseal=dmg.SealofRighteousness;
    heal.activeseal=heal.SealofRighteousness;
    threat.activeseal=threat.SealofRighteousness;
    mcost.activeseal=mcost.SealofRighteousness;
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    dmg.activeseal=dmg.SealofTruth;
    heal.activeseal=heal.SealofTruth;
    threat.activeseal=threat.SealofTruth;
    mcost.activeseal=mcost.SealofTruth;
end

%% Melee abilities

%Crusader Strike (can be blocked)
raw.CrusaderStrike= 1.35.*player.ndamage.*mdf.phdmg.*(1+mdf.Crus+(10./3).*mdf.WotL+mdf.t11x2P+mdf.pvphands) ...
                    .*mdf.t12x2R;
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.CScrit;
heal.CrusaderStrike=0;
threat.CrusaderStrike=max(dmg.CrusaderStrike,heal.CrusaderStrike).*mdf.RFury;
net.CrusaderStrike{1}=dmg.CrusaderStrike+dmg.activeseal.*mdf.mehit;
net.CrusaderStrike{2}=heal.CrusaderStrike+heal.activeseal.*mdf.mehit;
net.CrusaderStrike{3}=threat.CrusaderStrike+threat.activeseal.*mdf.mehit;
mcost.CrusaderStrike=0.1.*mdf.glyphAscetic.*base.mana;

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.phdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.HotRphcrit;
heal.HammeroftheRighteous=   0;
threat.HammeroftheRighteous=max(dmg.HammeroftheRighteous,heal.HammeroftheRighteous).*mdf.RFury;
net.HammeroftheRighteous{1}=dmg.HammeroftheRighteous+dmg.activeseal.*mdf.mehit.*mdf.rseal;
net.HammeroftheRighteous{2}=heal.HammeroftheRighteous;
net.HammeroftheRighteous{3}=threat.HammeroftheRighteous+threat.activeseal.*mdf.mehit.*mdf.rseal;
mcost.HammeroftheRighteous=0.1.*base.mana;

%Nova connects automatically if HotR(phys) succeeds
raw.HammerNova=   (728.8813374+0.18.*player.ap).*mdf.spdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammerNova=   raw.HammerNova.*mdf.mehit.*mdf.HotRspcrit.*target.resrdx; %spell hit/crit
heal.HammerNova=   0;
threat.HammerNova=max(dmg.HammerNova,heal.HammerNova).*mdf.RFury;
net.HammerNova{1}=dmg.HammerNova; %doesn't proc seals
net.HammerNova{2}=heal.HammerNova;
net.HammerNova{3}=threat.HammerNova;

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;
heal.Melee=         0;
hps.Melee=          0;
threat.Melee=       max(dmg.Melee,heal.Melee).*mdf.RFury;
tps.Melee=          threat.Melee./player.wswing;
net.Melee{1}=       dmg.Melee+dmg.activeseal.*mdf.mehit;
net.Melee{2}=       heal.Melee+heal.activeseal.*mdf.mehit;
net.Melee{3}=       threat.Melee+threat.activeseal.*mdf.mehit;

%Shield of the Righteous (can be blocked)
mdf.hpscale=(player.hopo==1)+3.*(player.hopo==2)+6.*(player.hopo==3);
raw.ShieldoftheRighteous= ((610.2+0.1.*player.ap).*mdf.hpscale).*mdf.spdmg.*mdf.glyphSotR;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit.*mdf.t12x2P ... %t12x2 automatically hits
                          .*target.resrdx; %melee hit
heal.ShieldoftheRighteous=0;
% threat.ShieldoftheRighteous{1}=raw.ShieldoftheRighteous.*mdf.RFury;
threat.ShieldoftheRighteous=dmg.ShieldoftheRighteous.*mdf.RFury;
net.ShieldoftheRighteous{1}=dmg.ShieldoftheRighteous+dmg.activeseal;
net.ShieldoftheRighteous{2}=heal.ShieldoftheRighteous+heal.activeseal.*mdf.mehit;
net.ShieldoftheRighteous{3}=threat.ShieldoftheRighteous+threat.activeseal.*mdf.mehit;
mcost.ShieldoftheRighteous=0;

%% Ranged abilities

%Avenger's Shield (cannot be blocked)
raw.AvengersShield= (3113.187994+0.419.*player.ap+0.21.*player.hsp).*mdf.spdmg.*mdf.glyphAS;
dmg.AvengersShield= raw.AvengersShield.*mdf.rahit.*mdf.phcrit.*target.resrdx;
heal.AvengersShield=0;
threat.AvengersShield=max(dmg.AvengersShield,heal.AvengersShield).*mdf.RFury;
net.AvengersShield{1}=dmg.AvengersShield+dmg.activeseal.*mdf.rahit.*mdf.tseal;
net.AvengersShield{2}=heal.AvengersShield;
net.AvengersShield{3}=threat.AvengersShield+threat.activeseal.*mdf.rahit.*mdf.tseal;
mcost.AvengersShield=0.06.*base.mana;

%Judgement (the seal of choice is defined in execution_model)
raw.Judgment=       (1+0.2229.*player.hsp+0.1421.*player.ap) ...
                    .*(1+mdf.glyphJ).*mdf.spdmg; 
dmg.Judgement=      raw.Judgement.*mdf.rahit.*target.resrdx;
heal.Judgement=     0.25.*dmg.Judgement.*mdf.t13x2P;
threat.Judgement=   max(dmg.Judgement,heal.Judgement).*mdf.RFury;
mcost.Judgement=0.05.*base.mana;
net.Judgement{1}=   dmg.Judgement+dmg.activeseal.*mdf.rahit;
net.Judgement{2}=   heal.Judgement+heal.activeseal.*mdf.rahit;
net.Judgement{3}=   threat.Judgement+threat.activeseal.*mdf.rahit;

%Hammer of Wrath (can be blocked)
raw.HammerofWrath= (4015.02439+0.117.*player.hsp+0.39.*player.ap).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
heal.HammerofWrath=0;
threat.HammerofWrath=max(dmg.HammerofWrath,heal.HammerofWrath).*mdf.RFury;
net.HammerofWrath{1}=dmg.HammerofWrath+dmg.activeseal.*mdf.rahit;
net.HammerofWrath{2}=heal.HammerofWrath+heal.activeseal.*mdf.rahit;
net.HammerofWrath{3}=threat.HammerofWrath+threat.activeseal.*mdf.rahit;
mcost.HammerofWrath=0.12.*mdf.glyphHammerofWrath.*base.mana;

%% Spell abilities

%Consecration
raw.Consecration =  (813.2998299+0.27.*player.hsp+0.27.*player.ap).*mdf.spdmg.*(1+mdf.HalGro).*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.Consecration=  0;
threat.Consecration=(max(dmg.Consecration,heal.Consecration)+12).*mdf.RFury;
net.Consecration{1}=dmg.Consecration;
net.Consecration{2}=heal.Consecration;
net.Consecration{3}=threat.Consecration;
mcost.Consecration = 0.55.*(1-2.*mdf.HalGro).*base.mana;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])).*mdf.spdmg ...
                    .*mdf.BlazLi.*(1+mdf.glyphExo);
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
heal.Exorcism=      0;
threat.Exorcism=    max(dmg.Exorcism,heal.Exorcism).*mdf.RFury;
net.Exorcism{1}=    dmg.Exorcism+dmg.activeseal.*mdf.sphit.*mdf.tseal;
net.Exorcism{2}=    heal.Exorcism;
net.Exorcism{3}=    threat.Exorcism+threat.activeseal.*mdf.sphit.*mdf.tseal;
mcost.Exorcism = 0.3.*base.mana;

%Holy Wrath
raw.HolyWrath=      ((2402.8+0.61.*player.hsp)./exec.npccount).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;
heal.HolyWrath=     0;
threat.HolyWrath=   max(dmg.HolyWrath,heal.HolyWrath).*mdf.RFury;
net.HolyWrath{1}=   dmg.HolyWrath;
net.HolyWrath{2}=   heal.HolyWrath;
net.HolyWrath{3}=   threat.HolyWrath;
mcost.HolyWrath = 0.2.*base.mana;

%Word of Glory
raw.WordofGlory=    (2133+0.2086.*player.hsp+0.1984.*player.ap).*player.hopo ...
                    .*(1-exec.overh).*mdf.Divin.*mdf.GbtL.*(1+mdf.glyphWoG+mdf.glyphSoI);
dmg.WordofGlory=    0;
heal.WordofGlory=   raw.WordofGlory.*mdf.WoGcrit;
threat.WordofGlory= 11.*(exec.overh>0).*mdf.RFury./exec.npccount;
net.WordofGlory{1}= dmg.WordofGlory;
net.WordofGlory{2}= heal.WordofGlory;
net.WordofGlory{3}= threat.WordofGlory;
mcost.WordofGlory = 0;


%% Consolidated arrays
val.length=max([length(dmg.CrusaderStrike) length(dmg.Consecration) length(dps.Melee) length(dps.Censure) length(mdf.mehit) length(mdf.rahit)]);
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
    round(threat.ShieldoftheRighteous).*val.ones; 
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
    round(net.Melee{i}).*val.ones;
    round(dmg.Censure).*val.ones];
end
clear i

if (strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)) mdf.iseal=min([exec.npccount;10]); else mdf.iseal=1; end;

      
 val.fsmdmg=[...
          val.zeros;                                                            %Inq
          val.zeros;                                                            %Inq(Inq)
          dmg.ShieldoftheRighteous./2.*val.ones;                                %SotR2
          dmg.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit./2.*val.ones;       %SotR2(SD)
          dmg.ShieldoftheRighteous.*mdf.Inq./2.*val.ones;                       %SotR2(Inq)
          dmg.ShieldoftheRighteous.*mdf.Inq.*mdf.phcritm./mdf.phcrit./2.*val.ones; %SotR2(SD)(Inq)
          dmg.ShieldoftheRighteous.*val.ones;                                   %SotR
          dmg.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit.*val.ones;          %SotR(SD)
          dmg.ShieldoftheRighteous.*mdf.Inq.*val.ones;                          %SotR(Inq)
          dmg.ShieldoftheRighteous.*mdf.Inq.*mdf.phcritm./mdf.phcrit.*val.ones; %SotR(SD)(Inq)
          dmg.WordofGlory.*val.ones;                                            %WoG
          dmg.WordofGlory.*mdf.Inq.*val.ones;                                   %WoG(Inq)
          ...
          dmg.CrusaderStrike.*val.ones;                                         %CS
          dmg.CrusaderStrike.*val.ones;                                         %CS(Inq)
          dmg.HammeroftheRighteous.*val.ones;                                   %HotR
          dmg.HammerNova.*val.ones;                                             %HammerNova
          dmg.HammeroftheRighteous.*val.ones;                                   %HotR(Inq)
          dmg.HammerNova.*mdf.Inq.*val.ones;                                    %HammerNova(Inq)
          ...
          dmg.AvengersShield.*val.ones;                                         %AS
          dmg.AvengersShield.*mdf.Inq.*val.ones;                                %AS(Inq)
          dmg.Consecration.*val.ones;                                           %Cons
          dmg.Consecration.*mdf.Inq.*val.ones;                                  %Cons(Inq)
          dmg.HammerofWrath.*val.ones;                                          %HoW
          dmg.HammerofWrath.*mdf.Inq.*val.ones;                                 %HoW(Inq)
          dmg.HolyWrath.*val.ones;                                              %HW
          dmg.HolyWrath.*mdf.Inq.*val.ones;                                     %HW(Inq)
          dmg.Judgement.*val.ones;                                              %J
          dmg.Judgement.*mdf.Inq.*val.ones;                                     %J(Inq)
          ...
          dmg.activeseal.*val.ones;                                             %seal
          dmg.activeseal.*mdf.Inq.*val.ones;                                   %seal(Inq)
          val.zeros;                                                               %Nothing
          val.zeros];                                                              %Nothing(Inq)
      
 val.fsmheal=[...
          val.zeros;                                                               %Inq
          val.zeros;                                                               %Inq(Inq)
          heal.ShieldoftheRighteous./2.*val.ones;                                %SotR2
          heal.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit./2.*val.ones;       %SotR2(SD)
          heal.ShieldoftheRighteous./2.*val.ones;                               %SotR2(Inq)
          heal.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit./2.*val.ones;      %SotR2(SD)(Inq)
          heal.ShieldoftheRighteous.*val.ones;                                   %SotR
          heal.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit.*val.ones;          %SotR(SD)
          heal.ShieldoftheRighteous.*val.ones;                          %SotR(Inq)
          heal.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit.*val.ones; %SotR(SD)(Inq)
          heal.WordofGlory.*val.ones;                                            %WoG
          heal.WordofGlory.*val.ones;                                   %WoG(Inq)
          ...
          heal.CrusaderStrike.*val.ones;                                         %CS
          heal.CrusaderStrike.*val.ones;                                         %CS(Inq)
          heal.HammeroftheRighteous.*val.ones;                                   %HotR
          heal.HammerNova.*val.ones;                                             %HammerNova
          heal.HammeroftheRighteous.*val.ones;                                   %HotR(Inq)
          heal.HammerNova.*val.ones;                                    %HammerNova(Inq)
          ...
          heal.AvengersShield.*val.ones;                                         %AS
          heal.AvengersShield.*val.ones;                                %AS(Inq)
          heal.Consecration.*val.ones;                                           %Cons
          heal.Consecration.*val.ones;                                  %Cons(Inq)
          heal.HammerofWrath.*val.ones;                                          %HoW
          heal.HammerofWrath.*val.ones;                                 %HoW(Inq)
          heal.HolyWrath.*val.ones;                                              %HW
          heal.HolyWrath.*val.ones;                                     %HW(Inq)
          heal.Judgement.*val.ones;                                              %J
          heal.Judgement.*mdf.Inq.*val.ones;                                     %J(Inq)
          ...
          heal.activeseal.*val.ones;                                             %seal
          heal.activeseal.*val.ones;                                   %seal(Inq)
          val.zeros;                                                               %Nothing
          val.zeros];                                                              %Nothing(Inq)
      
 val.fsmthr=[...
          val.zeros;                                                            %Inq
          val.zeros;                                                            %Inq(Inq)
          threat.ShieldoftheRighteous./2.*val.ones;                                %SotR2
          threat.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit./2.*val.ones;       %SotR2(SD)
          threat.ShieldoftheRighteous.*mdf.Inq./2.*val.ones;                       %SotR2(Inq)
          threat.ShieldoftheRighteous.*mdf.Inq.*mdf.phcritm./mdf.phcrit./2.*val.ones; %SotR2(SD)(Inq)
          threat.ShieldoftheRighteous.*val.ones;                                   %SotR
          threat.ShieldoftheRighteous.*mdf.phcritm./mdf.phcrit.*val.ones;          %SotR(SD)
          threat.ShieldoftheRighteous.*mdf.Inq.*val.ones;                          %SotR(Inq)
          threat.ShieldoftheRighteous.*mdf.Inq.*mdf.phcritm./mdf.phcrit.*val.ones; %SotR(SD)(Inq)
          threat.WordofGlory.*val.ones;                                            %WoG
          threat.WordofGlory.*mdf.Inq.*val.ones;                                   %WoG(Inq)
          ...
          threat.CrusaderStrike.*val.ones;                                         %CS
          threat.CrusaderStrike.*val.ones;                                         %CS(Inq)
          threat.HammeroftheRighteous.*val.ones;                                   %HotR
          threat.HammerNova.*val.ones;                                             %HammerNova
          threat.HammeroftheRighteous.*val.ones;                                   %HotR(Inq)
          threat.HammerNova.*mdf.Inq.*val.ones;                                    %HammerNova(Inq)
          ...
          threat.AvengersShield.*val.ones;                                         %AS
          threat.AvengersShield.*mdf.Inq.*val.ones;                                %AS(Inq)
          threat.Consecration.*val.ones;                                           %Cons
          threat.Consecration.*mdf.Inq.*val.ones;                                  %Cons(Inq)
          threat.HammerofWrath.*val.ones;                                          %HoW
          threat.HammerofWrath.*mdf.Inq.*val.ones;                                 %HoW(Inq)
          threat.HolyWrath.*val.ones;                                              %HW
          threat.HolyWrath.*mdf.Inq.*val.ones;                                     %HW(Inq)
          threat.Judgement.*val.ones;                                              %J
          threat.Judgement.*mdf.Inq.*val.ones;                                     %J(Inq)
          ...
          threat.activeseal.*val.ones;                                             %seal
          threat.activeseal.*mdf.Inq.*val.ones;                                   %seal(Inq)
          val.zeros;                                                               %Nothing
          val.zeros];                                                              %Nothing(Inq)v
      
 val.fsmaoe=[...
          val.zeros;                                                            %Inq
          val.zeros;                                                            %Inq(Inq)
          val.zeros;                                                            %SotR2
          val.zeros;                                                            %SotR2(SD)
          val.zeros;                                                            %SotR2(Inq)
          val.zeros;                                                            %SotR2(SD)(Inq)
          val.zeros;                                                            %SotR
          val.zeros;                                                            %SotR(SD)
          val.zeros;                                                            %SotR(Inq)
          val.zeros;                                                            %SotR(SD)(Inq)
          val.zeros;                                                            %WoG
          val.zeros;                                                            %WoG(Inq)
          ...
          val.zeros;                                                            %CS
          val.zeros;                                                            %CS(Inq)
          val.zeros;                                                            %HotR
          dmg.HammerNova.*min([exec.npccount-1; 9]).*val.ones;                   %HammerNova
          val.zeros;                                                            %HotR(Inq)
          dmg.HammerNova.*min([exec.npccount-1; 9]).*mdf.Inq.*val.ones;          %HammerNova(Inq)
          ...
          dmg.AvengersShield.*min([exec.npccount-1; 0+2.*(mdf.glyphAS==1)]).*val.ones; %AS
          dmg.AvengersShield.*min([exec.npccount-1; 0+2.*(mdf.glyphAS==1)]).*mdf.Inq.*val.ones; %AS(Inq)
          dmg.Consecration.*min([exec.npccount-1; 9]).*val.ones;                 %Cons
          dmg.Consecration.*min([exec.npccount-1; 9]).*mdf.Inq.*val.ones;        %Cons(Inq)
          val.zeros;                                                            %HoW
          val.zeros;                                                            %HoW(Inq)
          dmg.HolyWrath.*(exec.npccount-1)./exec.npccount.*val.ones;            %HW
          dmg.HolyWrath.*(exec.npccount-1)./exec.npccount.*mdf.Inq.*val.ones;	%HW(Inq)
          val.zeros;                                                            %J
          val.zeros;                                                            %J(Inq)
          ...
          val.zeros;                                                            %seal
          val.zeros;                                                            %seal(Inq)
          val.zeros;                                                               %Nothing
          val.zeros];                                                              %Nothing(Inq)
      
 val.fsmmana=[...
          val.zeros;                                                            %Inq
          val.zeros;                                                            %Inq(Inq)
          val.zeros;                                %SotR2
          val.zeros;                                %SotR2(SD)
          val.zeros;                                %SotR2(Inq)
          val.zeros;                                %SotR2(SD)(Inq)
          val.zeros;                                %SotR
          val.zeros;                                %SotR(SD)
          val.zeros;                                %SotR(Inq)
          val.zeros;                                %SotR(SD)(Inq)
          val.zeros;                                %WoG
          val.zeros;                                %WoG(Inq)
          ...
          mcost.CrusaderStrike.*val.ones;         	%CS
          mcost.CrusaderStrike.*val.ones;         	%CS(Inq)
          mcost.HammeroftheRighteous.*val.ones;  	%HotR
          val.zeros;                                %HammerNova
          mcost.HammeroftheRighteous.*val.ones;    	%HotR(Inq)
          val.zeros;                                %HammerNova(Inq)
          ...
          mcost.AvengersShield.*val.ones;          	%AS
          mcost.AvengersShield.*val.ones;          	%AS(Inq)
          mcost.Consecration.*val.ones;            	%Cons
          mcost.Consecration.*val.ones;           	%Cons(Inq)
          mcost.HammerofWrath.*val.ones;        	%HoW
          mcost.HammerofWrath.*val.ones;        	%HoW(Inq)
          mcost.HolyWrath.*val.ones;              	%HW
          mcost.HolyWrath.*val.ones;              	%HW(Inq)
          mcost.Judgement.*val.ones;             	%J
          mcost.Judgement.*val.ones;            	%J(Inq)
          ...
          mcost.activeseal.*val.ones;               %seal
          mcost.activeseal.*val.ones;               %seal(Inq)
          val.zeros;                                %Nothing
          val.zeros];    
      
 val.fsmlabel={'Inq';'Inq(Inq)';'SotR2';'SotR2(SD)';'SotR2(Inq)';'SotR2(SD)(Inq)';'SotR';'SotR(SD)';'SotR(Inq)';'SotR(SD)(Inq)';'WoG';'WoG(Inq)';...
               'CS';'CS(Inq)';'HotR';'HammerNova';'HotR(Inq)';'HammerNova(Inq)';...
               'AS';'AS(Inq)';'Cons';'Cons(Inq)';'HoW';'HoW(Inq)';'HW';'HW(Inq)';'J';'J(Inq)';...
               'seal';'seal(Inq)';...
               'Nothing';'Nothing(Inq)'};