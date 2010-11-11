%ABILITY_MODEL calculates the damage each ability does when used.  For
%DOT-like effects, it calculates the total damage done over the period of
%interest (i.e. Consecration) so that the total uptime and DPS can be
%modeled properly in different rotations

%% Holy Power
player.hopo=3;  %TODO move it

%% Seals

%Seal of Truth (fully stacked)
raw.SealofTruth=    0.15.*player.wdamage.*mdf.spdmg.*mdf.SotP; 
raw.JoT        =    (1+0.2229.*player.hsp+0.1421.*player.ap).*1.5; 
dmg.SealofTruth=    raw.SealofTruth.*mdf.phcrit.*target.resrdx; %automatical connect
dps.SealofTruth=    dmg.SealofTruth./player.wswing; %TODO : fix

%Censure (fully stacked, full duration)
mdf.Censcrit=1+(mdf.phcritmulti-1).*player.phcrit./100; %physical, 2.0 base multiplier
raw.Censure=        (0.050.*player.hsp+0.0965.*player.ap).*5.*mdf.SotP.*mdf.spdmg;
dmg.Censure=        raw.Censure.*mdf.Censcrit.*target.resrdx; %automatical connect
dps.Censure=        dmg.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.0115.*player.ap+0.0235.*player.hsp).* ...
                            mdf.spdmg.*mdf.SotP;
raw.JoR       =             (1+0.32.*player.hsp+0.2.*player.ap);
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx; %automatical connect

%Seal of Insight (15 PPM, not haste-normalized)
raw.SealofInsight=          0;
raw.JoI       =             (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofInsight=          raw.SealofInsight;

%Seal of Justice
raw.SealofJustice=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg.*mdf.SotP;
raw.JoJ       =             (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofJustice=          raw.SealofJustice.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit

%exhaustive listing of seal/judgement damage
if isempty(exec.seal)==1
    dmg.activeseal=0;
    raw.Judgement=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    dmg.activeseal=dmg.SealofInsight;
    raw.Judgement=raw.JoI;
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
    dmg.activeseal=dmg.SealofJustice;
    raw.Judgement=raw.JoJ;
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    dmg.activeseal=dmg.SealofRighteousness;
    raw.Judgement=raw.JoR;
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    dmg.activeseal=dmg.SealofTruth;
    raw.Judgement=raw.JoT;
end

%% Melee abilities

%Crusader Strike (can be blocked)
raw.CrusaderStrike= 1.15.*player.ndamage.*mdf.phdmg.*(mdf.Crus+2.*mdf.WotL).*mdf.t11x2;
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.CScrit;
net.CrusaderStrike= dmg.CrusaderStrike+dmg.activeseal.*mdf.mehit;

%Hammer of the Righteous
%physical (can be blocked)
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.phdmg.*(mdf.Crus+mdf.glyphHotR);
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.memodel.*mdf.HotRphcrit;
net.HammeroftheRighteous=   dmg.HammeroftheRighteous; %doesn't proc seals
%the aoe rolls only if physical connects
raw.HammerNova=   ((728+0.187.*player.ap).*mdf.spdmg.*mdf.Crus.*mdf.glyphHotR;
dmg.HammerNova=   raw.HammerNova.*(mdf.mehit.*mdf.sphit).*mdf.HotRspcrit.*target.resrdx; %spell hit/crit
net.HammerNova=   dmg.HammerNova;  %doesn't proc seals

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;
net.Melee=          dmg.Melee+dmg.activeseal.*mdf.mehit;

%Shield of the Righteous (can be blocked)
raw.ShieldoftheRighteous= player.hopo.*(1220+0.2.*player.ap).*mdf.spdmg.*mdf.glyphSotR;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit ...
                          .*target.resrdx; %melee hit
net.ShieldoftheRighteous= dmg.ShieldoftheRighteous+dmg.activeseal.*mdf.mehit;

%% Ranged abilities

%Avenger's Shield (can be blocked)
raw.AvengersShield= (3113+0.42.*player.ap+0.22.*player.hsp).*mdf.spdmg.*mdf.glyphAS;
raw.AvengersShield= raw.AvengersShield.*mdf.spellscale;
dmg.AvengersShield= raw.AvengersShield.*mdf.ramodel.*mdf.phcrit.*target.resrdx;              
net.AvengersShield= dmg.AvengersShield; %doesn't proc seals

%Judgement (the seal of choice is defined in execution_model) 
raw.Judgement=      raw.Judgement.*mdf.spdmg.*(mdf.glyphJ+2.*mdf.WotL);
dmg.Judgement=      raw.Judgement.*mdf.rahit.*mdf.Jcrit.*target.resrdx;
net.Judgement=      dmg.Judgement+dmg.activeseal.*mdf.rahit;

%Hammer of Wrath (can be blocked)
raw.HammerofWrath= (4015 + 0.14.*player.hsp + 0.515.*player.ap).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
net.HammerofWrath= dmg.HammerofWrath;  %doesn't proc seals

%% Spell abilities

%Consecration
raw.Consecration =  (810+0.26.*player.hsp+0.26.*player.ap).*mdf.spdmg.*mdf.HalGro.*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
net.Consecration =  dmg.Consecration;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritmulti.*(npc.type==1); %tracking npc type
raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])) ...
                    .*(mdf.spdmg.*mdf.BlazLi+mdf.glyphExo); %the glyph only boosts base damage
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
net.Exorcism=       dmg.Exorcism;

%Hand of Reckoning
raw.HandofReckoning=0;
dmg.HandofReckoning=raw.HandofReckoning.*mdf.sphit.*mdf.spcrit.*target.resrdx;

%Holy Shield
raw.HolyShield=     0; 
dmg.HolyShield=     raw.HolyShield.*mdf.sphit.*target.resrdx;

%Holy Wrath
raw.HolyWrath=      ((2402+0.305.*player.hsp)./exec.npccount+0.305.*player.hsp).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;
net.HolyWrath=      dmg.HolyWrath;


%% Consolidated arrays
val.length=max([length(dmg.Consecration) length(dmg.CrusaderStrike)]);
val.zero=zeros(1,val.length);
val.ones=ones(1,val.length);

val.raw=[round(raw.ShieldoftheRighteous).*val.ones; 
    round(raw.CrusaderStrike).*val.ones; 
    round(raw.Judgement).*val.ones; 
    round(raw.AvengersShield).*val.ones; 
    round(raw.HolyWrath).*val.ones; 
    round(raw.HammerofWrath).*val.ones; 
    round(raw.Exorcism).*val.ones; 
    round(raw.SealofTruth).*val.ones; 
    round(raw.SealofRighteousness).*val.ones; 
    round(raw.SealofJustice).*val.ones; 
    round(raw.Censure).*val.ones; 
    round(raw.Consecration).*val.ones; 
    round(raw.HammeroftheRighteous).*val.ones;
    round(raw.HammerNova).*val.ones;
    round(raw.Melee).*val.ones];

val.dmg=[round(dmg.ShieldoftheRighteous).*val.ones; 
    round(dmg.CrusaderStrike).*val.ones; 
    round(dmg.Judgement).*val.ones; 
    round(dmg.AvengersShield).*val.ones; 
    round(dmg.HolyWrath).*val.ones; 
    round(dmg.HammerofWrath).*val.ones; 
    round(dmg.Exorcism).*val.ones; 
    round(dmg.SealofTruth).*val.ones; 
    round(dmg.SealofRighteousness).*val.ones; 
    round(dmg.SealofJustice).*val.ones; 
    round(dmg.Censure).*val.ones; 
    round(dmg.Consecration).*val.ones; 
    round(dmg.HammeroftheRighteous).*val.ones;
    round(dmg.HammerNova).*val.ones;
    round(dmg.Melee).*val.ones];

val.net=[round(net.ShieldoftheRighteous).*val.ones; 
    round(net.CrusaderStrike).*val.ones; 
    round(net.Judgement).*val.ones; 
    round(net.AvengersShield).*val.ones; 
    round(net.HolyWrath).*val.ones; 
    round(net.HammerofWrath).*val.ones; 
    round(net.Exorcism).*val.ones; 
    val.zero; val.zero; val.zero;
    round(dmg.Censure).*val.ones; 
    round(net.Consecration).*val.ones; 
    round(net.HammeroftheRighteous).*val.ones;
    round(net.HammerNova).*val.ones;
    round(net.Melee).*val.ones];


%damage arrays for priority calculations
pridmg  =[raw.ShieldoftheRighteous.*val.ones;
          dmg.CrusaderStrike.*val.ones;
          dmg.Judgement.*val.ones;
          dmg.AvengersShield.*val.ones;
          dmg.HolyWrath.*val.ones;
          dmg.Consecration.*val.ones;
          dmg.HammeroftheRighteous.*val.ones;
          dmg.ShieldoftheRighteous./2.*val.ones;
          val.zero;
          dmg.HammerofWrath.*val.ones;
          dmg.activeseal.*val.ones;
          dmg.HammerNova.*val.ones];  

aoedmg  =[raw.ShieldoftheRighteous.*val.ones;
          dmg.CrusaderStrike.*val.ones;
          dmg.Judgement.*val.ones;
          dmg.AvengersShield.*min([exec.npccount; 1+2.*(mdf.glyphAS==1)]).*val.ones;
          dmg.HolyWrath.*exec.npccount.*val.ones;
          dmg.Consecration.*min([exec.npccount; 10]).*val.ones;  %hand-wavy AoE damage cap
          dmg.HammeroftheRighteous.*val.ones;
          dmg.ShieldoftheRighteous./2.*val.ones;
          val.zero;
          dmg.HammerofWrath.*val.ones;
          dmg.activeseal.*val.ones;
          dmg.HammerNova.*min([exec.npccount; 10]).*val.ones];   %and again