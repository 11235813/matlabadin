%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations

%% Seals
%done first so Judgement can be properly defined

%Seal of Truth, using old SoVeng model, assumes a 5-stack
raw.SealofTruth=    0.33.*player.wdamage.*mod.spdmg.*mod.SotP; 
raw.SealJud(1)=    (1+0.22.*player.hsp+0.14.*player.ap).*1.5; 
dmg.SealofTruth=    raw.SealofTruth.*mod.phcrit.*target.resrdx;
dps.SealofTruth=    dmg.SealofTruth./player.wswing;

%Censure (prev. Holy Vengeance), damage for a 5 stack over 15 seconds
mod.Censcrit=1+(mod.spcritmulti-1).*player.phcrit./100; %physical, 1.5 base multiplier
raw.Censure=        (0.013.*player.hsp+0.025.*player.ap).*5.*5.*mod.spdmg;
dmg.Censure=        raw.Censure.*mod.Censcrit.*target.resrdx;
dps.Censure=        dmg.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.022.*player.ap+0.044.*player.hsp).* ...
                            mod.spdmg.*mod.SotP;
raw.SealJud(2)=             (0);    %Not yet on wowhead?
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx;

%Seal of Insight
raw.SealofInsight=          0;
raw.SealJud(3)=             (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofInsight=          raw.SealofInsight.*target.resrdx;

%Seal of Justice
raw.SealofJustice=          0;
raw.SealJud(4)=             (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofJustice=          raw.SealofJustice.*target.resrdx;

%% Melee abilities

%Crusader Strike
raw.CrusaderStrike= player.wdamage.*mod.phdmg.*mod.Crus;
dmg.CrusaderStrike= raw.CrusaderStrike.*mod.mehit.*mod.CScrit;

%Hammer of the Righteous
raw.HammeroftheRighteous=   3.*player.wdamage.*mod.spdmg.*mod.Crus;
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mod.mehit.*mod.HRcrit;

%Melee attacks
raw.Melee=          player.wdamage.*mod.phdmg;
dmg.Melee=          raw.Melee.*mod.aahitcrit;
dps.Melee=          dmg.Melee./player.wswing;

%% Ranged abilities

%Avenger's Shield
raw.AvengersShield= ((1219+1489)/2 + 0.07.*player.hsp + 0.07.*player.ap).*mod.spdmg;
dmg.AvengersShield= raw.AvengersShield.*mod.rahit.*mod.phcrit.*target.resrdx;                

%Judgement - damage depends on seal.  raw.SealJud contains the Judgement
%damage values for each seal. The seal of choice is defined in execution_model. 
raw.Judgement=      raw.SealJud(exec.seal).*mod.spdmg.*mod.ImpJud;
dmg.Judgement=      raw.Judgement.*mod.rahit.*mod.Jcrit.*target.resrdx;
%for Sacred Duty handling, may implement this for every ability eventually
%/tlitp : don't like dedicated crit structures
crit.Judgement=     raw.Judgement.*mod.rahit.*mod.phcritmulti.*target.resrdx;  

%Hammer of Wrath
raw.HammerofWrath=  ((1254+1384)/2 + 0.15.*player.hsp + 0.15.*player.ap).*mod.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mod.rahit.*mod.phcrit.*target.resrdx;    


%% Spell abilities

%Consecration
raw.Consecration =  (8+0.04.*player.hsp+0.04.*player.ap).*mod.spdmg.*mod.HalGro;
dmg.Consecration =  raw.Consecration.*mod.spcrit.*target.resrdx;

%Exorcism
mod.Exorcrit=mod.spcrit.*(1-min([npc.type;1]))+mod.spcritmulti.*min([npc.type;1]); %tracking npc type
raw.Exorcism=       ((1135-1267)/2 + 0.15.*player.hsp + 0.15.*player.ap).*mod.spdmg;
dmg.Exorcism=       raw.Exorcism.*mod.sphit.*mod.Exorcrit.*target.resrdx;

%Hand of Reckoning
raw.HandofReckoning=(1+0.5.*player.ap).*mod.spdmg;
dmg.HandofReckoning=raw.HandofReckoning.*mod.sphit.*mod.spcrit.*target.resrdx;

%Holy Shield
raw.HolyShield=     97.*mod.spdmg; %tooltip might be wrong, "Effect #2" says 79.  Also I assume they'll implement ap/sp scaling.
dmg.HolyShield=     raw.HolyShield.*mod.sphit.*target.resrdx;

%Holy Wrath
raw.HolyWrath=      (2401 + 0.3.*player.hsp).*mod.spdmg.*(1+mod.WotL);
dmg.HolyWrath=      raw.HolyWrath.*mod.sphit.*mod.HWcrit.*target.resrdx;