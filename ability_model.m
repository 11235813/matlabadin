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
raw.SealofTruth=    0.025.*player.wdamage.*(1+0.3.*mdf.glyphIT).*mdf.spdmg;  
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofTruth=   0;
threat.SealofTruth= 0; %wowdb flag - generates no threat
mcost.SealofTruth=  0;
splash.SealofTruth= 0;
label.SealofTruth=  'SoT';

%Censure (fully stacked)
%As we do not model interruptions, Cens is assumed to be perpetually
%refreshed (full uptime).
%TODO: possibly nullify if SoT not active
raw.Censure=        (107 + 0.094.*player.sp) ... 
                    ./(1+mdf.glyphIT).*mdf.spdmg; %per tick (for 5 stacks)
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./player.censTick;
heal.Censure=       0;
hps.Censure=        0;
threat.Censure=     dmg.Censure.*mdf.RFury;
tps.Censure=        threat.Censure./player.censTick;
mcost.Censure=      0;
splash.Censure=     0;
label.Censure=      'Censure';

%Seal of Righteousness - now seal of cleave 
raw.SealofRighteousness=    0.06.*player.ndamage.*mdf.spdmg;
dmg.SealofRighteousness=    raw.SealofRighteousness.*mdf.phcrit.*target.resrdx; %automatical connect
heal.SealofRighteousness=   0;
threat.SealofRighteousness= 0; %wowdb flag - generates no threat
mcost.SealofRighteousness=  0;
splash.SealofRighteousness= exec.npccount-1;
label.SealofRighteousness=  'SoR';

%Seal of Insight (15 PPM, not haste-normalized) 
raw.SealofInsight=          0.15.*(player.sp+player.ap);
dmg.SealofInsight=          0;
heal.SealofInsight=         raw.SealofInsight.*(1+mdf.SoI).*(20.*gear.swing./60); 
threat.SealofInsight=       max(dmg.SealofInsight,heal.SealofInsight).*mdf.hthreat.*mdf.RFury./exec.npccount; %this is also flagged as generating no threat
mcost.SealofInsight=        0;
splash.SealofInsight=       0;
label.SealofInsight=        'SoI';


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
raw.CrusaderStrike=     (1.25.*player.ndamage+791).*mdf.phdmg.*(1+mdf.pvphands); %todo: check this, new tooltip
dmg.CrusaderStrike=     raw.CrusaderStrike.*mdf.memodel.*mdf.phcrit;
heal.CrusaderStrike=    0;
threat.CrusaderStrike=  max(dmg.CrusaderStrike,heal.CrusaderStrike).*mdf.RFury;
mcost.CrusaderStrike=   0.03.*base.mana;
splash.CrusaderStrike=  0;
label.CrusaderStrike=   'CS';

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.2.*player.ndamage.*mdf.phdmg;
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.phcrit;
heal.HammeroftheRighteous=  0;
threat.HammeroftheRighteous=max(dmg.HammeroftheRighteous,heal.HammeroftheRighteous).*mdf.RFury;
mcost.HammeroftheRighteous= 0.117.*base.mana; %TODO: check this
splash.HammeroftheRighteous=0;
label.HammeroftheRighteous= 'HotR';

%Nova connects automatically if HotR(phys) succeeds
raw.HammerNova=     0.35.*player.ndamage.*mdf.spdmg; %todo: check new nova damage scaling
dmg.HammerNova=     raw.HammerNova.*mdf.mehit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.HammerNova=    0;
threat.HammerNova=  max(dmg.HammerNova,heal.HammerNova).*mdf.RFury;
mcost.HammerNova=   0;
splash.HammerNova=  min([exec.npccount-1; 9]); %damage factor for secondary targets (multiples of dmg.*)
label.HammerNova=   'HaNova';

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing; %TODO: *ps redundant now
heal.Melee=         0;
hps.Melee=          0;
threat.Melee=       max(dmg.Melee,heal.Melee).*mdf.RFury;
tps.Melee=          threat.Melee./player.wswing;
mcost.Melee=        0;
splash.Melee=       0;
label.Melee=        'Melee';

%Shield of the Righteous (can be blocked)
raw.ShieldoftheRighteous= (836+0.617.*player.ap).*(1+mdf.glyphAS).*mdf.spdmg; 
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit... 
                          .*target.resrdx; %melee hit
heal.ShieldoftheRighteous=0;
threat.ShieldoftheRighteous=dmg.ShieldoftheRighteous.*mdf.RFury;
mcost.ShieldoftheRighteous=0;
splash.ShieldoftheRighteous=0;
label.ShieldoftheRighteous='SotR';

%% 'Ranged' abilities

%J is a melee attack with 30y range that cannot be dodged/parried
raw.Judgment=       (623+0.328.*player.ap+0.546.*player.sp) ...
                    .*(1+mdf.glyphDJ).*mdf.spdmg; 
dmg.Judgment=      raw.Judgment.*mdf.jdhit.*mdf.phcrit.*target.resrdx;
heal.Judgment=     0;
threat.Judgment=   max(dmg.Judgment,heal.Judgment).*mdf.RFury;
mcost.Judgment=    0.059.*base.mana;
splash.Judgment=    0;
label.Judgment=     'J';

%Hammer of Wrath is a true "ranged" that can be dodged but not parried
raw.HammerofWrath= (1838+1.610.*player.sp).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.rahit.*mdf.phcrit.*target.resrdx;
heal.HammerofWrath=0;
mcost.HammerofWrath=0.03.*base.mana;
splash.HammerofWrath=0;
label.HammerofWrath='HoW';

%% Spell abilities

%Avenger's Shield (cannot be blocked)
raw.AvengersShield= (6732+0.315.*player.sp+0.8175.*player.ap).*mdf.spdmg.*mdf.glyphFS;
dmg.AvengersShield= raw.AvengersShield.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.AvengersShield=0;
threat.AvengersShield=max(dmg.AvengersShield,heal.AvengersShield).*mdf.RFury;
mcost.AvengersShield=0.07.*base.mana;
splash.AvengersShield=min([exec.npccount-1; 0+2.*(mdf.glyphFS==1)]);
label.AvengersShield='AS';

%Consecration (all 9 ticks)
raw.Consecration =  (102.7+0.18.*player.sp)*9.*mdf.spdmg; %789% buff to base, 11% nerf to AP in 5.2
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
heal.Consecration=  0;
threat.Consecration=(max(dmg.Consecration,heal.Consecration)+12).*mdf.RFury;  %TODO: wowdb flags as generating no threat
mcost.Consecration = 0.07.*base.mana;
splash.Consecration=min([exec.npccount-1; 9]);
label.Consecration= 'Cons';

%Holy Wrath
raw.HolyWrath=      (4300+0.91.*player.ap)./(1+(exec.npccount-1).*mdf.glyphFW).*mdf.spdmg.*(1+mdf.glyphFiWr);
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyWrath=     0;
threat.HolyWrath=   max(dmg.HolyWrath,heal.HolyWrath).*mdf.RFury;
mcost.HolyWrath =   0.094.*base.mana;
splash.HolyWrath=   mdf.glyphFW.*(exec.npccount-1);
label.HolyWrath=    'HW';

%Holy Prism (cast on enemy, healing is up to 5 nearby targets)
raw.HolyPrism=      (16136 + 1.428.*player.sp).*mdf.spdmg;
dmg.HolyPrism=      raw.HolyPrism.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyPrism=     (10882 + 0.962.*player.sp).*mdf.spcrit.*1; %1 out of 5 targets (i.e. self)
mcost.HolyPrism =   0;
splash.HolyPrism=   0;
label.HolyPrism=    'HPr';

%Holy Prism (cast on ally/self, damage is up to 5 nearby targets)
raw.HolyPrismAlt=      (10882 + 0.962.*player.sp).*mdf.spdmg;
dmg.HolyPrismAlt=      raw.HolyPrism.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.HolyPrismAlt=     (16136 + 1.428.*player.sp).*mdf.spcrit; %1 out of 5 targets
mcost.HolyPrismAlt =   0;
splash.HolyPrism=      min([exec.npccount-1; 4]);
label.HolyPrismAlt= 'HPrAlt'; %placeholder

%Execution Sentence
raw.ExecutionSentence = (12989 + 5.936.*player.sp).*mdf.spdmg;
dmg.ExecutionSentence = raw.ExecutionSentence.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.ExecutionSentence = 0;
mcost.ExecutionSentence = 0;
splash.ExecutionSentence=   0;
label.ExecutionSentence =   'ES';

%Light's Hammer (total damage from 8 ticks of Arcing Light)
raw.LightsHammer=   (3630 + 0.321.*player.sp).*8.*mdf.spdmg;
dmg.LightsHammer=   raw.LightsHammer.*mdf.sphit.*mdf.spcrit.*target.resrdx;
heal.LightsHammer=  (2512 + 0.222*player.sp).*8.*mdf.spcrit;
mcost.LightsHammer= 0;
splash.LightsHammer=min([exec.npccount-1; 9]); %TODO: confirm target cap for LH
label.LightsHammer= 'LH';

%% Heals / Absorbs

%Word of Glory
raw.WordofGlory=    (5538+0.49.*player.sp).*player.hopo.*(1+mdf.SoI).*mdf.t14x4P;
dmg.WordofGlory=    0.7691.*raw.WordofGlory.*mdf.glyphHaWo.*mdf.sphit.*mdf.spcrit./(1+mdf.SoI); %Harsh Words glyph, TODO: test SoI interaction
heal.WordofGlory=   raw.WordofGlory.*(1-mdf.glyphHaWo).*(1-exec.overh).*mdf.spcrit; 
threat.WordofGlory= 11.*(exec.overh>0).*mdf.RFury./exec.npccount;
mcost.WordofGlory=  0;
splash.WordofGlory=	0;
label.WordofGlory=  'WoG';

%Eternal Flame direct heal
raw.EternalFlame=   (5538+0.49.*player.sp).*player.hopo.*(1+mdf.SoI).*mdf.t14x4P; %Base Heal
dmg.EternalFlame=   0;
heal.EternalFlame=  raw.EternalFlame.*(1-exec.overh).*mdf.spcrit;
threat.EternalFlame=1.*mdf.RFury./exec.npccount; %PH
mcost.EternalFlame= 0;
splash.EternalFlame=0;
label.EternalFlame= 'EF';

%Eternal Flame HoT
raw.EternalFlameHoT=   (508+0.0585.*player.sp).*player.hopo.*(1+mdf.SoI); %heal for 1 tick
dmg.EternalFlameHoT=   0;
heal.EternalFlameHoT=  raw.EternalFlameHoT.*(1-exec.overh).*mdf.spcrit;
threat.EternalFlameHoT=1.*mdf.RFury./exec.npccount;
mcost.EternalFlameHoT= 0;
splash.EternalFlameHoT=0;
label.EternalFlameHoT= 'EF(HoT)';

%Sacred Shield
raw.SacredShield=   (5879 + 0.78.*player.sp);  %absorption per 1 tick
dmg.SacredShield=   0;
heal.SacredShield=  raw.SacredShield; 
threat.SacredShield=1.*mdf.RFury./exec.npccount; %PH
mcost.SacredShield= 0.0.*base.mana;
splash.SacredShield=0;
label.SacredShield= 'SS';

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
val.name={'CrusaderStrike';'HammeroftheRighteous';'HammerNova'; ... %HP gen
          'Judgment';'AvengersShield';'Consecration';'HolyWrath';'HammerofWrath';... %Rotational
          'ShieldoftheRighteous';'WordofGlory';'EternalFlame';'EternalFlameHoT';... %HP sinks
          'SacredShield'; 'HolyPrism';'LightsHammer';'ExecutionSentence'; ... %Talents (except EF)
          'SealofTruth';'SealofRighteousness';'SealofInsight';... %Seals
          'Censure';'Melee'}; %passive 
    
%automatic generation of val.raw, .dmg, .heal, .aoe, .mcost and .label arrays
rawstr='val.raw=[';
dmgstr='val.dmg=[';
healstr='val.heal=[';
mcoststr='val.mcost=[';
aoestr='val.aoe=[';
labelstr='val.label={';
for i=1:length(val.name);
    rawstr=[rawstr 'raw.' val.name{i} '.*val.ones;'];
    dmgstr=[dmgstr 'dmg.' val.name{i} '.*val.ones;'];
    healstr=[healstr 'heal.' val.name{i} '.*val.ones;'];
    mcoststr=[mcoststr 'mcost.' val.name{i} '.*val.ones;'];
    aoestr=[aoestr 'splash.' val.name{i} '.*val.ones;'];
    labelstr=[labelstr 'label.' val.name{i} ';'];
end
eval([rawstr '];']);
eval([dmgstr '];']);
eval([healstr '];']);
eval([mcoststr '];']);
eval([aoestr '].*val.dmg;']);
eval([labelstr '};']);
      
%% Repack
c.abil.raw=raw;
c.abil.dmg=dmg;
c.abil.heal=heal;
c.abil.threat=threat;
c.abil.mcost=mcost;
c.abil.splash=splash;
c.abil.val=val;

%order fields alphabetically
c=orderfields(c);
end