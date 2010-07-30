%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations

%Crusader Strike
raw.CrusaderStrike= player.wdamage.*mod.phdmg;
dmg.CrusaderStrike= raw.CrusaderStrike.*mod.mehit.*mod.phcrit;

%Avenger's Shield
raw.AvengersShield= ((1219-1489)/2 + 0.07.*hsp + 0.07.*ap).* ...
                    mod.spdmg;
dmg.AvengersShield= raw.AvengersShield.*mod.rahit.*mod.phcrit.*target.resrdx;                

%Judgement - have to decide how to handle this since it's seal-dependent.
%I dislike the old "JudgementofTruth/JudgementofRighteousness" system.
%Thinking about using the old "seal" variable here so that the damage is
%automatically reflected in the base Judgement cast.  In other words,
%raw.Judgement = sealdmgarray(seal).*mod.holydmg;
%sealdmgarray (or whatever we call it) would be defined down in the Seal
%section.
raw.Judgement=      0.*mod.holydmg;
dmg.Judgement=      raw.Judgement.*mod.rahit.*mod.racrit.*boss.resrdx;

%Hammer of Wrath
raw.HammerofWrath=  ((1254-1384)/2 + 0.15.*hsp + 0.15.*ap).* ...
                    mod.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mod.rahit.*mod.phcrit.*target.resrdx;    


%% Seals
%cannot miss/dodge/parry, melee crit mechanics

%Seal of Truth, using old SoVeng model, assumes a 5-stack
raw.SealofTruth=    0.33.*player.wdamage.*mod.spdmg; 
dmg.SealofTruth=    raw.SealofTruth.*mod.phcrit.*target.resrdx;

%Holy Vengeance, damage for a 5 stack over 15 seconds
raw.HolyVengeance=  (0.013.*hsp+0.025.*ap).*5.*5.*mod.spdmg;
dmg.Holyvengeance=  raw.HolyVengeance.*target.resrdx;

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.022.*ap+0.044.*hsp).*mod.spdmg;
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx;

%Consecration
raw.Consecration =  (8+0.04.*hsp+0.04.*ap).*mod.spdmg;
dmg.Consecration =  raw.Consecration.*target.resrdx;

%Exorcism
%tracking demons/undead
mod.Exorcism=mod.spcrit.*(1-min([npc.type;1]))+mod.spcritmulti.*min([npc.type;1];

raw.Exorcism=       ((1135-1267)/2 + 0.15.*hsp + 0.15.*ap).*mod.spdmg;
dmg.Exorcism=       raw.Exorcism.*mod.sphit.*mod.Exorcism.*target.resrdx;

%Holy Wrath
raw.HolyWrath=      (2401 + 0.3.*hsp).*mod.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mod.sphit.*mod.spcrit.*target.resrdx;

