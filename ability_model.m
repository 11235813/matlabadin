%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations

%% Holy Power
player.hopo=3;  %placeholder for now, this may get moved elsewhere

%% Seals
%done first so Judgement can be properly defined

%Seal of Truth, using old SoVeng model, assumes a 5-stack
raw.SealofTruth=    0.16.*player.wdamage.*mdf.spdmg.*mdf.SotP; 
raw.SealJud(1)=    (1+0.22.*player.hsp+0.14.*player.ap).*1.5.*mdf.glyphJ; 
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx;
dps.SealofTruth=    dmg.SealofTruth./player.wswing;

%Censure (prev. Holy Vengeance), damage for a 5 stack over 15 seconds
mdf.Censcrit=1+(mdf.spcritmulti-1).*player.phcrit./100; %physical, 1.5 base multiplier
raw.Censure=        (0.013.*player.hsp+0.025.*player.ap).*5.*5.*mdf.spdmg;
dmg.Censure=        raw.Censure.*mdf.Censcrit.*target.resrdx;
dps.Censure=        dmg.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.011.*player.ap+0.022.*player.hsp).* ...
                            mdf.spdmg.*mdf.SotP;
raw.SealJud(2)=             (1+0.25.*player.hsp+0.16.*player.ap).*mdf.glyphJ;
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx;

%Seal of Insight
raw.SealofInsight=          0;
raw.SealJud(3)=             (1+0.25.*player.hsp+0.16.*player.ap).*mdf.glyphJ;
dmg.SealofInsight=          raw.SealofInsight.*target.resrdx;

%Seal of Justice
raw.SealofJustice=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg.*mdf.SotP;
raw.SealJud(4)=             (1+0.25.*player.hsp+0.16.*player.ap).*mdf.glyphJ;
dmg.SealofJustice=          raw.SealofJustice.*target.resrdx;

%% Melee abilities

%Crusader Strike
raw.CrusaderStrike= 1.2.*player.wdamage.*mdf.phdmg.*mdf.Crus.*(1+2.*mdf.WotL).*mdf.t11x2;
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.mehit.*mdf.CScrit;

%Hammer of the Righteous
%TODO check 2pt10 (both components) 
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.spdmg.*mdf.Crus.*mdf.t10x2.*mdf.glyphHotR;
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.mehit.*mdf.phcrit;
%placeholder for aoe portion
raw.HammerNova=   ((584+874)./2).*mdf.spdmg.*mdf.Crus.*mdf.t10x2.*mdf.glyphHotR; %523+783 base @ 80
dmg.HammerNova=   raw.HammerNova.*mdf.sphit.*mdf.spcrit.*target.resrdx; %assuming it's treated as spell

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;

%Shield of the Righteous
mdf.ShoR=   20.*(player.hopo==1)+60.*(player.hopo==2)+120.*(player.hopo==3);  %need to initialize this
raw.ShieldoftheRighteous= (mdf.ShoR./100.*player.ap).*mdf.spdmg.*mdf.glyphSotR;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.mehit.*mdf.phcrit.*target.resrdx;  %until we know if it can be dodged or parried
crit.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.mehit.*mdf.phcritmulti.*target.resrdx;

%% Ranged abilities

%Avenger's Shield
raw.AvengersShield= ((2802+3424)./2+0.42.*player.ap+0.22.*player.hsp).*mdf.spdmg.*mdf.glyphAS; %2512+3070 base @ 80
dmg.AvengersShield= raw.AvengersShield.*mdf.rahit.*mdf.phcrit.*target.resrdx;                

%Judgement - damage depends on seal.  raw.SealJud contains the Judgement
%damage values for each seal. The seal of choice is defined in execution_model. 
raw.Judgement=      raw.SealJud(exec.seal).*mdf.spdmg.*(1+2.*mdf.WotL);
dmg.Judgement=      raw.Judgement.*mdf.rahit.*mdf.Jcrit.*target.resrdx;
%for Sacred Duty handling, may implement this for every ability eventually
%/tlitp : don't like dedicated crit structures
crit.Judgement=     raw.Judgement.*mdf.rahit.*mdf.phcritmulti.*target.resrdx;  

%Hammer of Wrath
raw.HammerofWrath=  ((1254+1384)./2 + 0.15.*player.hsp + 0.15.*player.ap).*mdf.spdmg; %1124+1242 base @ 80
dmg.HammerofWrath= raw.HammerofWrath.*mdf.rahit.*mdf.HoWcrit.*target.resrdx;

%% Spell abilities

%Consecration
raw.Consecration =  (8.*(0+0.027.*player.hsp+0.027.*player.ap)).*mdf.spdmg.*mdf.HalGro.*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.spcrit.*target.resrdx;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(1-min([npc.type;1]))+mdf.spcritmulti.*min([npc.type;1]); %tracking npc type
raw.Exorcism=       ((1135+1267)./2 + 0.15.*max([player.hsp;player.ap])) ...   %1018+1136 base @ 80
                    .*mdf.spdmg.*mdf.BlazLi.*mdf.glyphExo;
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;

%Hand of Reckoning /TODO probably unnecessary
raw.HandofReckoning=0.*mdf.spdmg;
dmg.HandofReckoning=raw.HandofReckoning.*mdf.sphit.*mdf.spcrit.*target.resrdx;

%Holy Shield /TODO probably redundant
raw.HolyShield=     0.*mdf.spdmg; 
dmg.HolyShield=     raw.HolyShield.*mdf.sphit.*target.resrdx;

%Holy Wrath
raw.HolyWrath=      (2401+0.3.*player.hsp).*mdf.spdmg;  %2153 base @ 80
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;