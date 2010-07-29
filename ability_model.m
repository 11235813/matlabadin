%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations

%Holy Damage modifier
mod.holydmg=CoE.*talent.example.*buff.example;
%mod structure, eventually all modifier values will be lumped under this
%structure (i.e. mod.BoK, mod.CoE, and so forth).  Also, this should
%probably go in stat_model instead of here.

%% Melee Attacks 
%can be dodged, parried, blocked, or miss.  2x crit damage
mod.mehit=1-(boss.miss+boss.dodge+boss.parry)./100;
mod.mecrit=1+(phcrit_multiplier-1).*player.phcrit./100;

%Crusader Strike
raw.CrusaderStrike= weapon.damage.*mod.physdmg;
dmg.CrusaderStrike= raw.CrusaderStrike.*mod.mehit.*mod.mecrit;

%% Ranged
%cannot be dodged or parried, 2x crit damage
mod.rahit=1-boss.miss./100;
mod.racrit=mod.mecrit;  %identical to melee crits

%Avenger's Shield
raw.AvengersShield= ((1219-1489)/2 + 0.07.*hsp + 0.07.*ap).* ...
                    mod.holydmg;
dmg.AvengersShield= raw.AvengersShield.*mod.rahit.*mod.racrit.*boss.resrdx;                

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
                    mod.holydmg;
dmg.HammerofWrath= raw.HammerofWrath.*mod.rahit.*mod.racrit.*boss.resrdx;    


%% Seals
%cannot miss/dodge/parry, melee crit mechanics

%Seal of Truth, using old SoVeng model, assumes a 5-stack
raw.SealofTruth=    0.33.*weapon.damage.*mod.holydmg; 
dmg.SealofTruth=    raw.SealofTruth.*mod.mecrit.*boss.resrdx;

%Holy Vengeance, damage for a 5 stack over 15 seconds
raw.HolyVengeance=  (0.013.*hsp+0.025.*ap).*5.*5.*mod.holydmg;
dmg.Holyvengeance=  raw.HolyVengeance.*boss.resrdx;

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.022.*ap+0.044.*hsp).*mod.holydmg;
dmg.SealofRighteousness=    raw.SealofRighteousness.*boss.resrdx;


%% Spell Attacks
%can only miss, 1.5x crit damage
mod.sphit=1-boss.spmiss./100;
mod.spcrit=1+(spcrit_multiplier-1).*player.spcrit./100;

%Consecration
raw.Consecration =  (8+0.04.*hsp+0.04.*ap).*mod.holydmg;
dmg.Consecration =  raw.Consecration.*boss.resrdx;

%Exorcism
raw.Exorcism=       ((1135-1267)/2 + 0.15.*hsp + 0.15.*ap).*mod.holydmg;
dmg.Exorcism=       raw.Exorcism.*mod.sphit.*mod.spcrit.*boss.resrdx;

%Holy Wrath
raw.HolyWrath=      (2401 + 0.3.*hsp).*mod.holydmg;
dmg.HolyWrath=      raw.HolyWrath.*mod.sphit.*mod.spcrit.*boss.resrdx;

