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


%TODO: check for redundancy of player.sp and player.sp - hopefully we can
%remove player.sp entirely.
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
raw.SealofTruth=    0.14.*player.wdamage.*(1+0.2.*mdf.glyphIT).*mdf.spdmg;  
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofTruth=   0;
threat.SealofTruth= 0; %wowdb flag - generates no threat
mcost.SealofTruth=  0;

%Censure (fully stacked)
%As we do not model interruptions, Cens is assumed to be perpetually
%refreshed (full uptime).
%TODO: possibly nullify if SoT not active
raw.Censure=        (126 + 0.11.*player.sp).*5 ...
                    ./(1+mdf.glyphIT).*mdf.spdmg; %per tick (for 5 stacks)
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./player.censTick;
heal.Censure=       0;
hps.Censure=        0;
threat.Censure=     dmg.Censure.*mdf.RFury;
tps.Censure=        threat.Censure./player.censTick;

%Seal of Righteousness - now seal of cleave %TODO - verify tooltip
raw.SealofRighteousness=    0.05.*player.ndamage.*mdf.spdmg;
dmg.SealofRighteousness=    raw.SealofRighteousness.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofRighteousness=   0;
threat.SealofRighteousness= 0; %wowdb flag - generates no threat
mcost.SealofRighteousness=  0;

%Seal of Command - replaced by SoT
% raw.SealofCommand=          gear.swing.*(0.005.*player.ap+0.01.*player.sp) ...
%                             .*mdf.spdmg;
% dmg.SealofCommand=          raw.SealofCommand.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
% heal.SealofCommand=         0;
% threat.SealofCommand=       0;
% mcost.SealofCommand=        0;


%Seal of Insight (15 PPM, not haste-normalized) %TODO - verify tooltip
raw.SealofInsight=          0.15.*(player.sp+player.ap);
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
raw.CrusaderStrike= (1.30.*player.ndamage+913).*mdf.phdmg.*(1+mdf.pvphands); %todo: check this, new tooltip
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.phcrit;
heal.CrusaderStrike=0;
threat.CrusaderStrike=max(dmg.CrusaderStrike,heal.CrusaderStrike).*mdf.RFury;
mcost.CrusaderStrike=0.03.*mdf.glyphAC.*base.mana;

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.2.*player.wdamage.*mdf.phdmg;
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.phcrit;
heal.HammeroftheRighteous=   0;
threat.HammeroftheRighteous=max(dmg.HammeroftheRighteous,heal.HammeroftheRighteous).*mdf.RFury;
mcost.HammeroftheRighteous=0.117.*base.mana; %TODO: check this

%Nova connects automatically if HotR(phys) succeeds
raw.HammerNova=   (1050.5+0.234.*player.ap).*mdf.spdmg; %todo: check new nova damage scaling
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
raw.ShieldoftheRighteous= (617+0.54.*player.ap).*(1+mdf.glyphAS).*mdf.spdmg; %todo: check new AP/SP scaling
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit... 
                          .*target.resrdx; %melee hit
heal.ShieldoftheRighteous=0;
threat.ShieldoftheRighteous=dmg.ShieldoftheRighteous.*mdf.RFury;

%% Spell abilities

%Avenger's Shield (cannot be blocked)
raw.AvengersShield= (4488+0.21.*player.sp+0.545.*player.ap).*mdf.spdmg.*mdf.glyphFS;
dmg.AvengersShield= raw.AvengersShield.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.AvengersShield=0;
threat.AvengersShield=max(dmg.AvengersShield,heal.AvengersShield).*mdf.RFury;
mcost.AvengersShield=0.07.*base.mana;

%Judgment (the seal of choice is defined in execution_model)
raw.Judgment=       (702+0.397.*player.ap+0.635.*player.sp) ...
                    .*(1+mdf.glyphDJ).*mdf.spdmg; 
dmg.Judgment=      raw.Judgment.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.Judgment=     0;
threat.Judgment=   max(dmg.Judgment,heal.Judgment).*mdf.RFury;
mcost.Judgment=    0.059.*base.mana;

%Hammer of Wrath (can be blocked) - TODO: verify tooltip
raw.HammerofWrath= (1839.5+1.61.*player.sp).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HammerofWrath=0;
mcost.HammerofWrath=0.03.*base.mana;

%Consecration
raw.Consecration =  (690+1.2.*player.sp).*mdf.spdmg; 
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.Consecration=  0;
threat.Consecration=(max(dmg.Consecration,heal.Consecration)+12).*mdf.RFury;  %TODO: wowdb flags as generating no threat
mcost.Consecration = 0.07.*base.mana;

%Holy Wrath
raw.HolyWrath=      (4300+0.91.*player.sp)./(1+(exec.npccount-1).*mdf.glyphFW).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyWrath=     0;
threat.HolyWrath=   max(dmg.HolyWrath,heal.HolyWrath).*mdf.RFury;
mcost.HolyWrath =   0.094.*base.mana;

%Word of Glory
raw.WordofGlory=    (4340+0.419*player.sp).*player.hopo ...
                    .*(1-exec.overh).*(1+mdf.SoI);
dmg.WordofGlory=    0;
heal.WordofGlory=   raw.WordofGlory.*mdf.spcrit; %TODO: handle BoG stacks
threat.WordofGlory= 11.*(exec.overh>0).*mdf.RFury./exec.npccount;

%Eternal Flame
raw.EternalFlame=   (1548 + 0.137.*player.sp).*player.hopo.*10 ... % 10 ticks
                    .*(1-exec.overh);
dmg.EternalFlame=   0;
heal.EternalFlame=  raw.EternalFlame.*mdf.spcrit;
threat.EternalFlame=1.*mdf.RFury./exec.npccount; %PH

%Sacred Shield
raw.SacredShield=   (5879 + 0.78.*player.sp).*5;  %total absorption per cast
dmg.SacredShield=   0;
heal.SacredShield=  raw.SacredShield; 
threat.SacredShield=1.*mdf.RFury./exec.npccount; %PH
mcost.SacredShield=0.27.*base.mana;

%Holy Prism
raw.HolyPrism=      (12412 + 1.098.*player.sp).*mdf.spdmg;
dmg.HolyPrism=      raw.HolyPrism.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyPrism=     (9304 + 0.823.*player.sp).*mdf.spcrit.*5; %5 targets
mcost.HolyPrism =   0;

%Holy Prism (cast on ally/self, damage is up to 5 nearby targets)
raw.HolyPrismAlt=      (9304 + 0.823.*player.sp).*mdf.spdmg;
dmg.HolyPrismAlt=      raw.HolyPrism.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyPrismAlt=     (12412 + 1.098.*player.sp).*mdf.spcrit.*5; %5 targets
mcost.HolyPrismAlt =   0;

%Execution Sentence
raw.ExecutionSentence = (10023 + 4.566.*player.sp).*mdf.spdmg;
dmg.ExecutionSentence = raw.ExecutionSentence.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.ExecutionSentence = 0;
mcost.ExecutionSentence = 0;

%Light's Hammer
raw.LightsHammer=   (2792 + 0.247.*player.sp).*8.*mdf.spdmg;
dmg.LightsHammer=   raw.LightsHammer.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.LightsHammer=  raw.LightsHammer.*mdf.spcrit;
mcost.LightsHammer= 0;

%Ret-only in MoP
% %Exorcism
% mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
% raw.Exorcism=       (2741+0.344.*max([player.sp;player.ap])).*mdf.spdmg ...
%                     .*mdf.BlazLi.*(1+mdf.glyphExo);
% dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
% heal.Exorcism=      0;
% threat.Exorcism=    max(dmg.Exorcism,heal.Exorcism).*mdf.RFury;
% mcost.Exorcism = 0.3.*base.mana;
% 

%% Consolidated arrays
%TODO: rename val to something more descriptive
val.length=max([length(dmg.CrusaderStrike) length(dmg.Consecration) length(dps.Melee) length(dps.Censure) length(mdf.mehit) length(mdf.sphit)]);
val.zeros=zeros(1,val.length);
val.ones=ones(1,val.length);
val.label={'CS';'HotR';'HammerNova';'J';'AS';'Cons';'HW';'HoW';'SotR';'WoG';...
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
          raw.HammerofWrath.*val.ones;                %HoW
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
          dmg.HammerofWrath.*val.ones;                %HoW
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
          heal.HammerofWrath.*val.ones;                %HoW
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
          val.zeros;                                            %HoW
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
          mcost.HammerofWrath.*val.ones;                %HoW
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

%% Sanity check
if size(val.label)~=size(val.dmg)
    error('val.label and val.dmg different sizes')
end
      
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