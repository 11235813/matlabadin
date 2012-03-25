function [c]=ability_model(c)
%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates either the total damage done over the
%period of interest (i.e. Consecration) or the damage per tick (Censure)
%depending on how each ability is modeled (Cons is generally DPC, Censure
%is usually added in post-processing as a passive effect occuring with
%frequency 1/player.wswing).
%
%ability_model takes one input argument "c", which is the configuration
%structure for the simulation.  "c" contains the standard fields reurned by
%stat_model.  
%
%ability_model returns an updated "c" that includes an
%"abil" field containing the ability  values introduced in this module.


%TODO: check for redundancy of player.sp and player.hsp - hopefully we can
%remove player.hsp entirely.
%TODO: remove net structure; I think we don't need this going forward, and
%if we do, I want to implement it differently

%% Unpack
mdf=c.mdf;
player=c.player;
target=c.target;
gear=c.gear;
exec=c.exec;
base=c.base;


%% Holy Power
player.hopo=3;  %TODO: probably no reason to consider 1- or 2-HP SotR/WoG anymore

%% Seals
%TODO: Retest all hit conditions for seals

%Seal of Truth (fully stacked)
raw.SealofTruth=    0.14.*player.wdamage.*(1+0.2.*mdf.glyphIT).*mdf.spdmg;  %TODO: Check if this is 14% weapon damage or 14% of the attack's damage?
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofTruth=   0;
threat.SealofTruth= 0; %wowdb flag - generates no threat
mcost.SealofTruth=0;

%Censure (fully stacked)
%As we do not model interruptions, Cens is assumed to be perpetually
%refreshed (full uptime).
%TODO: possibly nullify if SoT not active
raw.Censure=        (0.018.*player.hsp+0.0350.*player.ap).*5 ...
                    ./(1+mdf.glyphIT).*mdf.spdmg; %per tick (for 5 stacks)
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./player.censTick;
heal.Censure=       0;
hps.Censure=        0;
threat.Censure=     dmg.Censure.*mdf.RFury;
tps.Censure=        threat.Censure./player.censTick;

%Seal of Righteousness - now seal of cleave
raw.SealofRighteousness=    0.05.*player.wdamage.*mdf.spdmg;
dmg.SealofRighteousness=    raw.SealofRighteousness.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofRighteousness=   0;
threat.SealofRighteousness= 0; %wowdb flag - generates no threat
mcost.SealofRighteousness=  0;

%Seal of Command - replaced by SoT
% raw.SealofCommand=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
%                             .*mdf.spdmg;
% dmg.SealofCommand=          raw.SealofCommand.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
% heal.SealofCommand=         0;
% threat.SealofCommand=       0;
% mcost.SealofCommand=        0;


%Seal of Insight (15 PPM, not haste-normalized)
raw.SealofInsight=          0.15.*(player.hsp+player.ap);
dmg.SealofInsight=          0;
heal.SealofInsight=         raw.SealofInsight.*(1+mdf.SoI).*(15.*gear.swing./60); %Check if this has changed to 15% proc or if it's still 15 PPM
threat.SealofInsight=       max(dmg.SealofInsight,heal.SealofInsight).*mdf.hthreat.*mdf.RFury./exec.npccount; %this is also flagged as generating no threat
mcost.SealofInsight=        -0.04.*base.mana;


%exhaustive listing of seal/Judgment damage
if isempty(exec.seal)
    raw.activeseal=0;
    dmg.activeseal=0;
    heal.activeseal=0;
    threat.activeseal=0;
    mcost.activeseal=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    raw.activeseal=raw.SealofInsight;
    dmg.activeseal=dmg.SealofInsight;
    heal.activeseal=heal.SealofInsight;
    threat.activeseal=threat.SealofInsight;
    mcost.activeseal=mcost.SealofInsight;
elseif strcmpi('Command',exec.seal)||strcmpi('SoC',exec.seal)
    raw.activeseal=raw.SealofCommand;
    dmg.activeseal=dmg.SealofCommand;
    heal.activeseal=heal.SealofCommand;
    threat.activeseal=threat.SealofCommand;
    mcost.activeseal=mcost.SealofCommand;
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    raw.activeseal=raw.SealofRighteousness;
    dmg.activeseal=dmg.SealofRighteousness;
    heal.activeseal=heal.SealofRighteousness;
    threat.activeseal=threat.SealofRighteousness;
    mcost.activeseal=mcost.SealofRighteousness;
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    raw.activeseal=raw.SealofTruth;
    dmg.activeseal=dmg.SealofTruth;
    heal.activeseal=heal.SealofTruth;
    threat.activeseal=threat.SealofTruth;
    mcost.activeseal=mcost.SealofTruth;
end

%% Melee abilities

%Crusader Strike (can be blocked)
raw.CrusaderStrike= 1.00.*player.ndamage.*mdf.phdmg.*(1+mdf.pvphands);
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.phcrit;
heal.CrusaderStrike=0;
threat.CrusaderStrike=max(dmg.CrusaderStrike,heal.CrusaderStrike).*mdf.RFury;
mcost.CrusaderStrike=0.1.*mdf.glyphAC.*base.mana;

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.2.*player.wdamage.*mdf.phdmg;
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.phcrit;
heal.HammeroftheRighteous=   0;
threat.HammeroftheRighteous=max(dmg.HammeroftheRighteous,heal.HammeroftheRighteous).*mdf.RFury;
mcost.HammeroftheRighteous=0.11.*base.mana;

%Nova connects automatically if HotR(phys) succeeds
raw.HammerNova=   (728.8813374+0.18.*player.ap).*mdf.spdmg;
dmg.HammerNova=   raw.HammerNova.*mdf.mehit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.HammerNova=   0;
threat.HammerNova=max(dmg.HammerNova,heal.HammerNova).*mdf.RFury;

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing; %TODO: *ps redundant now
heal.Melee=         0;
hps.Melee=          0;
threat.Melee=       max(dmg.Melee,heal.Melee).*mdf.RFury;
tps.Melee=          threat.Melee./player.wswing;

%Shield of the Righteous (can be blocked)
raw.ShieldoftheRighteous= ((610.2+0.1.*player.ap).*6).*(1+mdf.glyphAS).*mdf.spdmg;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit... 
                          .*target.resrdx; %melee hit
heal.ShieldoftheRighteous=0;
% threat.ShieldoftheRighteous{1}=raw.ShieldoftheRighteous.*mdf.RFury;
threat.ShieldoftheRighteous=dmg.ShieldoftheRighteous.*mdf.RFury;
mcost.ShieldoftheRighteous=0;

%% Ranged abilities

%Avenger's Shield (cannot be blocked)
raw.AvengersShield= (3113.187994+0.419.*player.ap+0.21.*player.hsp).*mdf.spdmg.*mdf.glyphFS;
dmg.AvengersShield= raw.AvengersShield.*mdf.rahit.*mdf.phcrit.*target.resrdx;
heal.AvengersShield=0;
threat.AvengersShield=max(dmg.AvengersShield,heal.AvengersShield).*mdf.RFury;
mcost.AvengersShield=0.07.*base.mana;

%Judgment (the seal of choice is defined in execution_model)
raw.Judgment=       (1+0.2229.*player.hsp+0.1421.*player.ap) ...
                    .*(1+mdf.glyphDJ).*mdf.spdmg; 
dmg.Judgment=      raw.Judgment.*mdf.rahit.*target.resrdx;
heal.Judgment=     0.25.*dmg.Judgment.*mdf.t13x2P;
threat.Judgment=   max(dmg.Judgment,heal.Judgment).*mdf.RFury;
mcost.Judgment=    0.05.*base.mana;

%Ret-Only in MoP
% %Hammer of Wrath (can be blocked)
% raw.HammerofWrath= (4015.02439+0.117.*player.hsp+0.39.*player.ap).*mdf.spdmg;
% dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
% heal.HammerofWrath=0;
% threat.HammerofWrath=max(dmg.HammerofWrath,heal.HammerofWrath).*mdf.RFury;
% mcost.HammerofWrath=0.12.*mdf.glyphHammerofWrath.*base.mana;

%% Spell abilities

%Consecration
raw.Consecration =  (813.2998299+0.27.*player.hsp+0.27.*player.ap).*mdf.spdmg;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.Consecration=  0;
threat.Consecration=(max(dmg.Consecration,heal.Consecration)+12).*mdf.RFury;  %TODO: wowdb flags as generating no threat
mcost.Consecration = 0.07.*base.mana;

%Ret-only in MoP
% %Exorcism
% mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
% raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])).*mdf.spdmg ...
%                     .*mdf.BlazLi.*(1+mdf.glyphExo);
% dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
% heal.Exorcism=      0;
% threat.Exorcism=    max(dmg.Exorcism,heal.Exorcism).*mdf.RFury;
% mcost.Exorcism = 0.3.*base.mana;
% 
%Holy Wrath
raw.HolyWrath=      (2402.8+0.61.*player.hsp)./(1+(exec.npccount-1).*mdf.glyphFW).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyWrath=     0;
threat.HolyWrath=   max(dmg.HolyWrath,heal.HolyWrath).*mdf.RFury;
mcost.HolyWrath =   0.2.*base.mana;

%Word of Glory
raw.WordofGlory=    (2133+0.2086.*player.hsp+0.1984.*player.ap).*player.hopo ...
                    .*(1-exec.overh).*(1+mdf.SoI);
dmg.WordofGlory=    0;
heal.WordofGlory=   raw.WordofGlory.*mdf.WoGcrit;
threat.WordofGlory= 11.*(exec.overh>0).*mdf.RFury./exec.npccount;
mcost.WordofGlory = 0;

%Eternal Flame
raw.EternalFlame=   (1 + 1.*player.hsp + 1.*player.ap).*player.hopo ... %PH
                    .*(1-exec.overh);
dmg.EternalFlame=   0;
heal.EternalFlame=  raw.EternalFlame.*mdf.spcrit;
threat.EternalFlame=1.*mdf.RFury./exec.npccount; %PH
mcost.EternalFlame= 0;

%Sacred Shield
raw.SacredShield=   (1 + 1.*player.hsp + 1.*player.ap).*player.hopo ... %PH
                    .*(1-exec.overh);
dmg.SacredShield=   0;
heal.SacredShield=  raw.SacredShield; %can absorbs crit?
threat.SacredShield=1.*mdf.RFury./exec.npccount; %PH
mcost.SacredShield= 0;


%% Consolidated arrays
%TODO: rename val to something more descriptive
val.length=max([length(dmg.CrusaderStrike) length(dmg.Consecration) length(dps.Melee) length(dps.Censure) length(mdf.mehit) length(mdf.rahit)]);
val.zeros=zeros(1,val.length);
val.ones=ones(1,val.length);
val.label={'CS';'HotR';'HammerNova';'J';'AS';'Cons';'HW';'SotR';'WoG';...
           'EF';'SS';'SoT';'SoR';'SoI';'Censure';'Melee';};

%TODO: add each seal and handle cps separately?        
val.raw=[...
          raw.CrusaderStrike.*val.ones;               %CS
          raw.HammeroftheRighteous.*val.ones;         %HotR
          raw.HammerNova.*val.ones;                   %HammerNova
          ...
          raw.Judgment.*val.ones;                     %J
          raw.AvengersShield.*val.ones;               %AS
          raw.Consecration.*val.ones;                 %Cons
          raw.HolyWrath.*val.ones;                    %HW
          ...
          raw.ShieldoftheRighteous.*val.ones;         %SotR
          raw.WordofGlory.*val.ones;                  %WoG
          raw.EternalFlame.*val.ones;                 %Eternal Flame
          raw.SacredShield.*val.ones;                 %SS
          ...
          raw.SealofTruth.*val.ones;                  %SoT
          raw.SealofRighteousness.*val.ones;          %SoR
%           raw.SealofCommand.*val.ones;                %SoC
          raw.SealofInsight.*val.ones;                %SoI
          ...
          raw.Censure.*val.ones;                      %Censure tick
          raw.Melee.*val.ones;                        %Melee Swing
          ];                                

val.dmg=[...
          dmg.CrusaderStrike.*val.ones;               %CS
          dmg.HammeroftheRighteous.*val.ones;         %HotR
          dmg.HammerNova.*val.ones;                   %HammerNova
          ...
          dmg.Judgment.*val.ones;                     %J
          dmg.AvengersShield.*val.ones;               %AS
          dmg.Consecration.*val.ones;                 %Cons
          dmg.HolyWrath.*val.ones;                    %HW
          ...
          dmg.ShieldoftheRighteous.*val.ones;         %SotR
          dmg.WordofGlory.*val.ones;                  %WoG
          dmg.EternalFlame.*val.ones;                 %Eternal Flame
          dmg.SacredShield.*val.ones;                 %SS
          ...
          dmg.SealofTruth.*val.ones;                  %SoT
          dmg.SealofRighteousness.*val.ones;          %SoR
%           dmg.SealofCommand.*val.ones;                %SoC
          dmg.SealofInsight.*val.ones;                %SoI
          ...
          dmg.Censure.*val.ones;                      %Censure tick
          dmg.Melee.*val.ones;                        %Melee Swing
          ];                                 

val.heal=[...
          heal.CrusaderStrike.*val.ones;               %CS
          heal.HammeroftheRighteous.*val.ones;         %HotR
          heal.HammerNova.*val.ones;                   %HammerNova
          ...
          heal.Judgment.*val.ones;                     %J
          heal.AvengersShield.*val.ones;               %AS
          heal.Consecration.*val.ones;                 %Cons
          heal.HolyWrath.*val.ones;                    %HW
          ...
          heal.ShieldoftheRighteous.*val.ones;         %SotR
          heal.WordofGlory.*val.ones;                  %WoG
          heal.EternalFlame.*val.ones;                 %Eternal Flame
          heal.SacredShield.*val.ones;                 %SS
          ...
          heal.SealofTruth.*val.ones;                  %SoT
          heal.SealofRighteousness.*val.ones;          %SoR
%           heal.SealofCommand.*val.ones;                %SoC
          heal.SealofInsight.*val.ones;                %SoI
          ...
          heal.Censure.*val.ones;                      %Censure tick
          heal.Melee.*val.ones;                        %Melee Swing
          ];                                 

val.aoe=[...
          val.zeros;                                            %CS
          val.zeros;                                            %HotR
          dmg.HammerNova.*min([exec.npccount-1; 9]).*val.ones;	%HammerNova
          ...
          val.zeros;                                            %J
          dmg.AvengersShield.*min([exec.npccount-1; 0+2.*(mdf.glyphFS==1)]).*val.ones; %AS
          dmg.Consecration.*min([exec.npccount-1; 9]).*val.ones; %Cons
          dmg.HolyWrath.*mdf.glyphFW.*(exec.npccount-1)./exec.npccount.*val.ones; %HW
          ...
          val.zeros;                                            %SotR
          val.zeros;                                            %WoG
          val.zeros;                                            %EF (TODO: heal threat)
          val.zeros;                                            %SS (TODO: buff threat)
          ...
          val.zeros;                                            %SoT (TODO: seal spreading?)
          dmg.SealofRighteousness.*min([exec.npccount-1; 9]).*val.ones; %SoR (TODO: check target limit)
%           val.zeros;                                            %SoC
          val.zeros;                                            %SoI (TODO: heal threat)
          ...
          val.zeros;                                            %Censure tick
          val.zeros;                                            %Melee Swing
          ];                                

val.mcost=[...
          mcost.CrusaderStrike.*val.ones;               %CS
          mcost.HammeroftheRighteous.*val.ones;         %HotR
          val.zeros;                                    %HammerNova
          ...
          mcost.Judgment.*val.ones;                     %J
          mcost.AvengersShield.*val.ones;               %AS
          mcost.Consecration.*val.ones;                 %Cons
          mcost.HolyWrath.*val.ones;                    %HW
          ...
          val.zeros;                                    %SotR
          val.zeros;                                    %WoG
          val.zeros;                                    %EF
          val.zeros;                                    %SS
          ...
          val.zeros;                                    %SoT
          val.zeros;                                    %SoR
%           val.zeros;                                    %SoC
          val.zeros;                                    %SoI
          ...
          val.zeros;                                    %Censure tick
          val.zeros;                                    %Melee Swing
          ];                                   
      
      
%% Repack
c.abil.raw=raw;
c.abil.dmg=dmg;
c.abil.heal=heal;
c.abil.threat=threat;
c.abil.mcost=mcost;
c.abil.val=val;

%order fields alphabetically
c=orderfields(c);
end