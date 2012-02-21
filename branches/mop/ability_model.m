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
gear=c.gear;
exec=c.exec;
base=c.base;


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
%TODO: possibly nullify if SoT not active
raw.Censure=        (0.014.*player.hsp+0.0270.*player.ap).*5 ...
                    .*mdf.spdmg; %per tick (for 5 stacks)
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./player.censTick;
heal.Censure=       0;
hps.Censure=        0;
threat.Censure=     dmg.Censure.*mdf.RFury;
tps.Censure=        threat.Censure./player.censTick;

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
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
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
raw.CrusaderStrike= 1.00.*player.ndamage.*mdf.phdmg.*mdf.pvphands;
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.CScrit;
heal.CrusaderStrike=0;
threat.CrusaderStrike=max(dmg.CrusaderStrike,heal.CrusaderStrike).*mdf.RFury;
net.CrusaderStrike{1}=dmg.CrusaderStrike+dmg.activeseal.*mdf.mehit;
net.CrusaderStrike{2}=heal.CrusaderStrike+heal.activeseal.*mdf.mehit;
net.CrusaderStrike{3}=threat.CrusaderStrike+threat.activeseal.*mdf.mehit;
mcost.CrusaderStrike=0.1.*mdf.glyphAscetic.*base.mana;

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.2.*player.wdamage.*mdf.phdmg.*(1+mdf.glyphHotR);
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.phcrit;
heal.HammeroftheRighteous=   0;
threat.HammeroftheRighteous=max(dmg.HammeroftheRighteous,heal.HammeroftheRighteous).*mdf.RFury;
net.HammeroftheRighteous{1}=dmg.HammeroftheRighteous+dmg.activeseal.*mdf.mehit.*mdf.rseal;
net.HammeroftheRighteous{2}=heal.HammeroftheRighteous;
net.HammeroftheRighteous{3}=threat.HammeroftheRighteous+threat.activeseal.*mdf.mehit.*mdf.rseal;
mcost.HammeroftheRighteous=0.11.*base.mana;

%Nova connects automatically if HotR(phys) succeeds
raw.HammerNova=   (728.8813374+0.18.*player.ap).*mdf.spdmg.*(1+mdf.glyphHotR);
dmg.HammerNova=   raw.HammerNova.*mdf.mehit.*mdf.spcrit.*target.resrdx; %spell hit/crit
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
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit... 
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
raw.AvengersShield= (3113.187994+0.419.*player.ap+0.21.*player.hsp).*mdf.spdmg.*mdf.glyphFS;
dmg.AvengersShield= raw.AvengersShield.*mdf.rahit.*mdf.phcrit.*target.resrdx;
heal.AvengersShield=0;
threat.AvengersShield=max(dmg.AvengersShield,heal.AvengersShield).*mdf.RFury;
net.AvengersShield{1}=dmg.AvengersShield+dmg.activeseal.*mdf.rahit.*mdf.tseal;
net.AvengersShield{2}=heal.AvengersShield;
net.AvengersShield{3}=threat.AvengersShield+threat.activeseal.*mdf.rahit.*mdf.tseal;
mcost.AvengersShield=0.07.*base.mana;

%Judgment (the seal of choice is defined in execution_model)
raw.Judgment=       (1+0.2229.*player.hsp+0.1421.*player.ap) ...
                    .*(1+mdf.glyphJ).*mdf.spdmg; 
dmg.Judgment=      raw.Judgment.*mdf.rahit.*target.resrdx;
heal.Judgment=     0.25.*dmg.Judgment.*mdf.t13x2P;
threat.Judgment=   max(dmg.Judgment,heal.Judgment).*mdf.RFury;
mcost.Judgment=    0.05.*base.mana;
net.Judgment{1}=   dmg.Judgment+dmg.activeseal.*mdf.rahit;
net.Judgment{2}=   heal.Judgment+heal.activeseal.*mdf.rahit;
net.Judgment{3}=   threat.Judgment+threat.activeseal.*mdf.rahit;

%Ret-Only in MoP
% %Hammer of Wrath (can be blocked)
% raw.HammerofWrath= (4015.02439+0.117.*player.hsp+0.39.*player.ap).*mdf.spdmg;
% dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
% heal.HammerofWrath=0;
% threat.HammerofWrath=max(dmg.HammerofWrath,heal.HammerofWrath).*mdf.RFury;
% net.HammerofWrath{1}=dmg.HammerofWrath+dmg.activeseal.*mdf.rahit;
% net.HammerofWrath{2}=heal.HammerofWrath+heal.activeseal.*mdf.rahit;
% net.HammerofWrath{3}=threat.HammerofWrath+threat.activeseal.*mdf.rahit;
% mcost.HammerofWrath=0.12.*mdf.glyphHammerofWrath.*base.mana;

%% Spell abilities

%Consecration
raw.Consecration =  (813.2998299+0.27.*player.hsp+0.27.*player.ap).*mdf.spdmg.*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.Consecration=  0;
threat.Consecration=(max(dmg.Consecration,heal.Consecration)+12).*mdf.RFury;
net.Consecration{1}=dmg.Consecration;
net.Consecration{2}=heal.Consecration;
net.Consecration{3}=threat.Consecration;
mcost.Consecration = 0.07.*base.mana;

%Ret-only in MoP
% %Exorcism
% mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
% raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])).*mdf.spdmg ...
%                     .*mdf.BlazLi.*(1+mdf.glyphExo);
% dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
% heal.Exorcism=      0;
% threat.Exorcism=    max(dmg.Exorcism,heal.Exorcism).*mdf.RFury;
% net.Exorcism{1}=    dmg.Exorcism+dmg.activeseal.*mdf.sphit.*mdf.tseal;
% net.Exorcism{2}=    heal.Exorcism;
% net.Exorcism{3}=    threat.Exorcism+threat.activeseal.*mdf.sphit.*mdf.tseal;
% mcost.Exorcism = 0.3.*base.mana;
% 
% %Holy Wrath
% raw.HolyWrath=      ((2402.8+0.61.*player.hsp)./exec.npccount).*mdf.spdmg;
% dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;
% heal.HolyWrath=     0;
% threat.HolyWrath=   max(dmg.HolyWrath,heal.HolyWrath).*mdf.RFury;
% net.HolyWrath{1}=   dmg.HolyWrath;
% net.HolyWrath{2}=   heal.HolyWrath;
% net.HolyWrath{3}=   threat.HolyWrath;
% mcost.HolyWrath = 0.2.*base.mana;

%Word of Glory
raw.WordofGlory=    (2133+0.2086.*player.hsp+0.1984.*player.ap).*player.hopo ...
                    .*(1-exec.overh).*(1+mdf.glyphWoG+mdf.glyphSoI);
dmg.WordofGlory=    0;
heal.WordofGlory=   raw.WordofGlory.*mdf.WoGcrit;
threat.WordofGlory= 11.*(exec.overh>0).*mdf.RFury./exec.npccount;
net.WordofGlory{1}= dmg.WordofGlory;
net.WordofGlory{2}= heal.WordofGlory;
net.WordofGlory{3}= threat.WordofGlory;
mcost.WordofGlory = 0;


%% Consolidated arrays
%TODO: rename val to something more descriptive
val.length=max([length(dmg.CrusaderStrike) length(dmg.Consecration) length(dps.Melee) length(dps.Censure) length(mdf.mehit) length(mdf.rahit)]);
val.zeros=zeros(1,val.length);
val.ones=ones(1,val.length);
val.label={'CS';'HotR';'HammerNova';'J';'AS';'Cons';'SotR';'WoG';...
            'seal';'Censure';'Melee';'Nothing';};

%TODO: add each seal and handle cps separately?        
val.raw=[...
          raw.CrusaderStrike.*val.ones;               %CS
          raw.HammeroftheRighteous.*val.ones;         %HotR
          raw.HammerNova.*val.ones;                   %HammerNova
          ...
          raw.Judgment.*val.ones;                     %J
          raw.AvengersShield.*val.ones;               %AS
          raw.Consecration.*val.ones;                 %Cons
          ...
          raw.ShieldoftheRighteous.*val.ones;         %SotR
          raw.WordofGlory.*val.ones;                  %WoG
          ...
          raw.activeseal.*val.ones;                   %seal
          raw.Censure.*val.ones;                      %Censure tick
          raw.Melee.*val.ones;                        %Melee Swing
          val.zeros];                                 %Nothing

val.dmg=[...
          dmg.CrusaderStrike.*val.ones;               %CS
          dmg.HammeroftheRighteous.*val.ones;         %HotR
          dmg.HammerNova.*val.ones;                   %HammerNova
          ...
          dmg.Judgment.*val.ones;                     %J
          dmg.AvengersShield.*val.ones;               %AS
          dmg.Consecration.*val.ones;                 %Cons
          ...
          dmg.ShieldoftheRighteous.*val.ones;         %SotR
          dmg.WordofGlory.*val.ones;                  %WoG
          ...
          dmg.activeseal.*val.ones;                   %seal
          dmg.Censure.*val.ones;                      %Censure tick
          dmg.Melee.*val.ones;                        %Melee Swing
          val.zeros];                                 %Nothing

val.heal=[...
          heal.CrusaderStrike.*val.ones;               %CS
          heal.HammeroftheRighteous.*val.ones;         %HotR
          heal.HammerNova.*val.ones;                   %HammerNova
          ...
          heal.Judgment.*val.ones;                     %J
          heal.AvengersShield.*val.ones;               %AS
          heal.Consecration.*val.ones;                 %Cons
          ...
          heal.ShieldoftheRighteous.*val.ones;         %SotR
          heal.WordofGlory.*val.ones;                  %WoG
          ...
          heal.activeseal.*val.ones;                   %seal
          heal.Censure.*val.ones;                      %Censure tick
          heal.Melee.*val.ones;                        %Melee Swing
          val.zeros];                                  %Nothing

val.aoe=[...
          val.zeros;                                            %CS
          val.zeros;                                            %HotR
          dmg.HammerNova.*min([exec.npccount-1; 9]).*val.ones;	%HammerNova
          ...
          val.zeros;                                            %J
          dmg.AvengersShield.*min([exec.npccount-1; 0+2.*(mdf.glyphFS==1)]).*val.ones; %AS
          dmg.Consecration.*min([exec.npccount-1; 9]).*val.ones; %Cons
          ...
          val.zeros;                                            %SotR
          val.zeros;                                            %WoG
          ...
          val.zeros;                                            %seal TODO: SoRight Cleave
          val.zeros;                                            %Censure tick
          val.zeros;                                            %Melee Swing
          val.zeros];                                  %Nothing

val.mcost=[...
          mcost.CrusaderStrike.*val.ones;               %CS
          mcost.HammeroftheRighteous.*val.ones;         %HotR
          val.zeros;                                    %HammerNova
          ...
          mcost.Judgment.*val.ones;                     %J
          mcost.AvengersShield.*val.ones;               %AS
          mcost.Consecration.*val.ones;                 %Cons
          ...
          val.zeros;                                    %SotR
          val.zeros;                                    %WoG
          ...
          val.zeros;                                    %seal
          val.zeros;                                    %Censure tick
          val.zeros;                                    %Melee Swing
          val.zeros];                                   %Nothing
      
      
      
      
%Old Code, for reference      
% 
% val.raw=[...
%     round(raw.ShieldoftheRighteous).*val.ones;
%     round(raw.WordofGlory).*val.ones;
%     ...
%     round(raw.CrusaderStrike).*val.ones;
%     round(raw.HammeroftheRighteous).*val.ones;
%     ...
%     round(raw.AvengersShield).*val.ones;
%     round(raw.Consecration).*val.ones;
%     round(raw.Exorcism).*val.ones;
%     round(raw.HammerofWrath).*val.ones;
%     round(raw.HolyWrath).*val.ones;
%     round(raw.Judgment).*val.ones; 
%     ...
%     round(raw.HammerNova).*val.ones;
%     round(raw.SealofInsight).*val.ones;
%     round(raw.SealofCommand).*val.ones;
%     round(raw.SealofRighteousness).*val.ones; 
%     round(raw.SealofTruth).*val.ones; 
%     ...
%     round(raw.Melee).*val.ones;
%     round(raw.Censure).*val.ones];
% 
% for i=1:3
% val.net{i}=[...
%     round(net.ShieldoftheRighteous{i}).*val.ones;
%     round(net.WordofGlory{i}).*val.ones;
%     ...
%     round(net.CrusaderStrike{i}).*val.ones;
%     round(net.HammeroftheRighteous{i}).*val.ones;
%     ...
%     round(net.AvengersShield{i}).*val.ones;
%     round(net.Consecration{i}).*val.ones;
%     round(net.Exorcism{i}).*val.ones;
%     round(net.HammerofWrath{i}).*val.ones; 
%     round(net.HolyWrath{i}).*val.ones;
%     round(net.Judgment{i}).*val.ones; 
%     ...
%     round(net.HammerNova{i}).*val.ones;
%     val.zeros; val.zeros; val.zeros; val.zeros;
%     ...
%     round(net.Melee{i}).*val.ones;
%     round(dmg.Censure).*val.ones];
% end

%% Repack
c.abil.raw=raw;
c.abil.dmg=dmg;
c.abil.heal=heal;
c.abil.threat=threat;
c.abil.mcost=mcost;
c.abil.val=val;

end