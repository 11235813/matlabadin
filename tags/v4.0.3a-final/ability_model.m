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
threat.SealofTruth=dmg.SealofTruth.*mdf.RF;

%Censure (fully stacked, full duration)
raw.Censure=        (0.050.*player.hsp+0.0965.*player.ap).*5.*mdf.SotP.*mdf.spdmg;
dmg.Censure=        raw.Censure.*mdf.phcrit.*target.resrdx; %automatical connect, phys crit/CM
dps.Censure=        dmg.Censure./(5.*cens.NetTick);
threat.Censure=dmg.Censure.*mdf.RF;
tps.Censure=threat.Censure./(5.*cens.NetTick);

%Seal of Righteousness
raw.SealofRighteousness=    gear.swing.*(0.011.*player.ap+0.022.*player.hsp).* ...
                            mdf.spdmg.*mdf.SotP;
raw.JoR       =             (1+0.32.*player.hsp+0.2.*player.ap);
dmg.SealofRighteousness=    raw.SealofRighteousness.*target.resrdx; %automatical connect
threat.SealofRighteousness=dmg.SealofRighteousness.*mdf.RF;

%Seal of Insight (15 PPM, not haste-normalized)
raw.SealofInsight=          0;
raw.JoI       =             (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofInsight=          raw.SealofInsight;
threat.SealofInsight=(15.*gear.swing./60).*0.15.*(player.hsp+player.ap).*mdf.Divin.*mdf.glyphSoI ...
                     .*mdf.hthreat.*mdf.RF;

%Seal of Justice
raw.SealofJustice=          gear.swing.*(0.005.*player.ap+0.01.*player.hsp) ...
                            .*mdf.spdmg.*mdf.SotP;
raw.JoJ       =             (1+0.25.*player.hsp+0.16.*player.ap);
dmg.SealofJustice=          raw.SealofJustice.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
threat.SealofJustice=dmg.SealofJustice.*mdf.RF;

%exhaustive listing of seal/judgement damage
if isempty(exec.seal)==1
    dmg.activeseal=0;
    threat.activeseal=0;
    raw.Judgement=0;
elseif strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
    dmg.activeseal=dmg.SealofInsight;
    threat.activeseal=threat.SealofInsight;
    raw.Judgement=raw.JoI;
elseif strcmpi('Justice',exec.seal)||strcmpi('SoJ',exec.seal)
    dmg.activeseal=dmg.SealofJustice;
    threat.activeseal=threat.SealofJustice;
    raw.Judgement=raw.JoJ;
elseif strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal)
    dmg.activeseal=dmg.SealofRighteousness;
    threat.activeseal=threat.SealofRighteousness;
    raw.Judgement=raw.JoR;
elseif strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    dmg.activeseal=dmg.SealofTruth;
    threat.activeseal=threat.SealofTruth;
    raw.Judgement=raw.JoT;
end

%% Melee abilities

%Crusader Strike (can be blocked)
raw.CrusaderStrike= 1.15.*player.ndamage.*mdf.phdmg.*(1+mdf.Crus+(10./3).*mdf.WotL+mdf.t11x2);
dmg.CrusaderStrike= raw.CrusaderStrike.*mdf.memodel.*mdf.CScrit;
net.CrusaderStrike= dmg.CrusaderStrike+dmg.activeseal.*mdf.mehit;
threat.CrusaderStrike=dmg.CrusaderStrike.*mdf.RF;

%Hammer of the Righteous
%physical (can be blocked)
mdf.HotRmodel=1+(mdf.blockrdx-1).*target.block./100;
raw.HammeroftheRighteous=   0.3.*player.wdamage.*mdf.phdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammeroftheRighteous=   raw.HammeroftheRighteous.*mdf.HotRmodel.*mdf.HotRphcrit;
net.HammeroftheRighteous=   dmg.HammeroftheRighteous; %doesn't proc seals
threat.HammeroftheRighteous=dmg.HammeroftheRighteous.*mdf.RF;
%the physical component always connects, the nova rolls for hit only once
raw.HammerNova=   (728.8813374+0.18.*player.ap).*mdf.spdmg.*(1+mdf.Crus+mdf.glyphHotR);
dmg.HammerNova=   raw.HammerNova.*mdf.sphit.*mdf.HotRspcrit.*target.resrdx; %spell hit/crit
net.HammerNova=   dmg.HammerNova;  %doesn't proc seals
threat.HammerNova=dmg.HammerNova.*mdf.RF;

%Melee attacks
raw.Melee=          player.wdamage.*mdf.phdmg;
dmg.Melee=          raw.Melee.*mdf.aamodel;
dps.Melee=          dmg.Melee./player.wswing;
net.Melee=          dmg.Melee+dmg.activeseal.*mdf.mehit;
threat.Melee=dmg.Melee.*mdf.RF;
tps.Melee=threat.Melee./player.wswing;

%Shield of the Righteous (can be blocked)
mdf.hpscale=(player.hopo==1)+3.*(player.hopo==2)+6.*(player.hopo==3);
raw.ShieldoftheRighteous= ((610.2+0.1.*player.ap).*mdf.hpscale).*mdf.spdmg.*mdf.glyphSotR;
dmg.ShieldoftheRighteous= raw.ShieldoftheRighteous.*mdf.memodel.*mdf.phcrit ...
                          .*target.resrdx; %melee hit
net.ShieldoftheRighteous= dmg.ShieldoftheRighteous+dmg.activeseal.*mdf.mehit;
threat.ShieldoftheRighteous=dmg.ShieldoftheRighteous.*mdf.RF;

%% Ranged abilities

%Avenger's Shield (can be blocked)
raw.AvengersShield= (3113.187994+0.419.*player.ap+0.21.*player.hsp).*mdf.spdmg.*mdf.glyphAS;
dmg.AvengersShield= raw.AvengersShield.*mdf.ramodel.*mdf.phcrit.*target.resrdx;              
net.AvengersShield= dmg.AvengersShield; %doesn't proc seals
threat.AvengersShield=dmg.AvengersShield.*mdf.RF;

%Judgement (the seal of choice is defined in execution_model)
mdf.jseals=(mdf.JotJ>0)&&(strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal) ...
    ||strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)); %JotJ procs only R/T
raw.Judgement=      raw.Judgement.*mdf.spdmg.*(1+mdf.glyphJ+(10./3).*mdf.WotL);
dmg.Judgement=      raw.Judgement.*mdf.rahit.*mdf.Jcrit.*target.resrdx;
net.Judgement=      dmg.Judgement+mdf.jseals.*dmg.activeseal.*mdf.rahit;
threat.Judgement=dmg.Judgement.*mdf.RF;

%Hammer of Wrath (can be blocked)
raw.HammerofWrath= (4015.02439+0.117.*player.hsp+0.39.*player.ap).*mdf.spdmg;
dmg.HammerofWrath= raw.HammerofWrath.*mdf.ramodel.*mdf.HoWcrit.*target.resrdx;
net.HammerofWrath= dmg.HammerofWrath;  %doesn't proc seals
threat.HammerofWrath=dmg.HammerofWrath.*mdf.RF;

%% Spell abilities

%Consecration
raw.Consecration =  (813.2998299+0.27.*player.hsp+0.27.*player.ap).*mdf.spdmg.*(1+mdf.HalGro).*mdf.glyphCons;
dmg.Consecration =  raw.Consecration.*mdf.sphit.*mdf.spcrit.*target.resrdx; %spell hit/crit
net.Consecration =  dmg.Consecration;
threat.Consecration=dmg.Consecration.*mdf.RF;

%Exorcism
mdf.Exorcrit=mdf.spcrit.*(npc.type==0)+mdf.spcritm.*(npc.type==1); %tracking npc type
raw.Exorcism=       (2741+0.344.*max([player.hsp;player.ap])).*mdf.spdmg ...
                    .*(mdf.BlazLi+mdf.glyphExo); %DoT is based on base damage
dmg.Exorcism=       raw.Exorcism.*mdf.sphit.*mdf.Exorcrit.*target.resrdx;
net.Exorcism=       dmg.Exorcism;
threat.Exorcism=dmg.Exorcism.*mdf.RF;

%Holy Wrath
raw.HolyWrath=      ((2402.8+0.61.*player.hsp)./exec.npccount).*mdf.spdmg;
dmg.HolyWrath=      raw.HolyWrath.*mdf.sphit.*mdf.HWcrit.*target.resrdx;
net.HolyWrath=      dmg.HolyWrath;
threat.HolyWrath=dmg.HolyWrath.*mdf.RF;

%Word of Glory //TODO
raw.WordofGlory=    0;
dmg.WordofGlory=    raw.WordofGlory;
threat.WordofGlory= (2133+0.21.*player.hsp+0.17.*player.ap).*player.hopo.*mdf.WoGcrit ...
                    .*(1-exec.overh).*mdf.Divin.*mdf.glyphSoI.*mdf.glyphWoG.*mdf.GbtL.*mdf.hthreat ...
                    +5.5.*(exec.overh>0);
threat.WordofGlory= threat.WordofGlory.*mdf.RF;


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
          dmg.AvengersShield./mdf.glyphAS.*min([exec.npccount; 3]).*val.ones;
          dmg.HolyWrath.*exec.npccount.*val.ones;
          dmg.Consecration.*min([exec.npccount; 10]).*val.ones;  %hand-wavy AoE damage cap
          dmg.HammeroftheRighteous.*val.ones;
          dmg.ShieldoftheRighteous./2.*val.ones;
          val.zero;
          dmg.HammerofWrath.*val.ones;
          dmg.activeseal.*val.ones;
          dmg.HammerNova.*min([exec.npccount; 10]).*val.ones];   %and again