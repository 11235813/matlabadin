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
raw.SealJud(1)=    (1+0.22.*player.hsp+0.14.*player.ap).*1.5.*mdf.glyphJ.*target.resrdx; 
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit; %automatical connect
dps.SealofTruth=    dmg.SealofTruth./player.wswing; %TODO : fix

%Censure (prev. Holy Vengeance), damage for a 5 stack over 15 seconds
mdf.Censcrit=1+(mdf.phcritmulti-1).*player.phcrit./100; %physical, 2.0 base multiplier
raw.Censure=        (0.013.*player.hsp+0.025.*player.ap).*5.*5.*mdf.SotP.*mdf.spdmg.*target.resrdx;
dmg.Censure=        raw.Censure.*mdf.Censcrit; %automatical connect
dps.Censure=        dmg.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.011.*player.ap+0.022.*player.hsp).* ...
                            mdf.spdmg.*mdf.SotP.*target.resrdx;
raw.SealJud(2)=             (1+0.25.*player.hsp+0.16.*player.ap).*mdf.glyphJ;
dmg.SealofRighteousness=    raw.SealofRighteousness; %automatical connect

%Seal of Insight
raw.SealofInsight=          0.*target.resrdx;
raw.SealJud(3)=             (1+0.25.*player.hsp+0.16.*player.ap).*mdf.glyphJ;
dmg.SealofInsight=          raw.SealofInsight;

%Seal of Justice
raw.SealofJustice=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg.*mdf.SotP.*target.resrdx;
raw.SealJud(4)=             (1+0.25.*player.hsp+0.16.*player.ap).*mdf.glyphJ;
dmg.SealofJustice=          raw.SealofJustice.*mdf.sphit.*mdf.spcrit; %spell hit/crit

%exhaustive listing of seal/judgement damage (for net calculations)
if isempty(exec.seal)==1
    dmg.seal=0;
    raw.Judgement=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    dmg.seal=dmg.SealofInsight;
    raw.Judgement=raw.SealJud(3);
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
    dmg.seal=dmg.SealofJustice;
    raw.Judgement=raw.SealJud(4);
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    dmg.seal=dmg.SealofRighteousness;
    raw.Judgement=raw.SealJud(2);
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    dmg.seal=dmg.SealofTruth;
    raw.Judgement=raw.SealJud(1);
end
%% Melee abilities

%Crusader Strike
raw.CrusaderStrike= 1.2.*player.wdamage.*mdf.phdmg.*mdf.Crus.*(1+2.*mdf.WotL).*mdf.t11x2;
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.mehit.*mdf.CScrit;
net.CrusaderStrike= dmg.CrusaderStrike+dmg.seal.*mdf.mehit;

%Hammer of the Righteous
%TODO check 2pt10 (both components) 
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.spdmg.*mdf.Crus.*mdf.t10x2.*mdf.glyphHotR;
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.mehit.*mdf.phcrit;
net.HammeroftheRighteous= dmg.HammeroftheRighteous+dmg.seal.*mdf.mehit;
%the aoe rolls only if physical connects
raw.HammerNova=   ((584+874)./2).*mdf.spdmg.*mdf.Crus.*mdf.t10x2.*mdf.glyphHotR.*target.resrdx; %523+783 base @ 80
dmg.HammerNova=   raw.HammerNova.*(mdf.mehit.*mdf.sphit).*mdf.spcrit; %spell hit/crit
net.HammerNova=   dmg.HammerNova;  %TODO: does this proc seals?

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;
net.Melee=          dmg.Melee+dmg.seal.*mdf.mehit;  %Assume seal procs from glances are full strength - TODO: Is this correct?

%Shield of the Righteous
mdf.ShoR=   20.*(player.hopo==1)+60.*(player.hopo==2)+120.*(player.hopo==3);  %need to initialize this
raw.ShieldoftheRighteous= (mdf.ShoR./100.*player.ap).*mdf.spdmg.*mdf.glyphSotR.*target.resrdx;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.mehit.*mdf.phcrit;  %melee hit
net.ShieldoftheRighteous= dmg.ShieldoftheRighteous + dmg.seal.*mdf.mehit;
% crit.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.mehit.*mdf.phcritmulti;

%% Ranged abilities

%Avenger's Shield
raw.AvengersShield= ((2802+3424)./2+0.42.*player.ap+0.22.*player.hsp).*mdf.spdmg.*mdf.glyphAS.*target.resrdx; %2512+3070 base @ 80
dmg.AvengersShield= raw.AvengersShield.*mdf.rahit.*mdf.phcrit;                
net.AvengersShield= dmg.AvengersShield; %doesn't proc seals

%Judgement - damage depends on seal.  raw.SealJud contains the Judgement
%damage values for each seal. The seal of choice is defined in execution_model. 
raw.Judgement=      raw.Judgement.*mdf.spdmg.*(1+2.*mdf.WotL).*target.resrdx;
dmg.Judgement=      raw.Judgement.*mdf.rahit.*mdf.Jcrit;
net.Judgement=      dmg.Judgement+dmg.seal.*mdf.rahit;

%Hammer of Wrath
raw.HammerofWrath=  ((1254+1384)./2 + 0.15.*player.hsp + 0.15.*player.ap).*mdf.spdmg.*target.resrdx; %1124+1242 base @ 80
dmg.HammerofWrath= raw.HammerofWrath.*mdf.rahit.*mdf.HoWcrit;
net.HammerofWrath=  dmg.HammerofWrath;  %doesnt' proc seals

%% Spell abilities

%Consecration
raw.Consecration =  (8.*(0+0.027.*player.hsp+0.027.*player.ap)).*mdf.spdmg.*mdf.HalGro.*mdf.glyphCons.*target.resrdx;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit; %spell hit/crit
net.Consecration =  dmg.Consecration;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(1-min([npc.type;1]))+mdf.spcritmulti.*min([npc.type;1]); %tracking npc type
raw.Exorcism=       ((1135+1267)./2 + 0.15.*max([player.hsp;player.ap])) ...   %1018+1136 base @ 80
                    .*mdf.spdmg.*mdf.BlazLi.*mdf.glyphExo.*target.resrdx;
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit;
net.Exorcism=       dmg.Exorcism;

%Hand of Reckoning /TODO probably unnecessary
raw.HandofReckoning=0.*mdf.spdmg.*target.resrdx;
dmg.HandofReckoning=raw.HandofReckoning.*mdf.sphit.*mdf.spcrit;

%Holy Shield /TODO probably redundant
raw.HolyShield=     0.*mdf.spdmg.*target.resrdx; 
dmg.HolyShield=     raw.HolyShield.*mdf.sphit;

%Holy Wrath
raw.HolyWrath=      (2401./exec.npccount+0.3.*player.hsp).*mdf.spdmg.*target.resrdx;  %2153 base @ 80
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit;
net.HolyWrath=      dmg.HolyWrath;