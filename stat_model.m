%% stat_model
%this m-file recalculates the final stats of the player, taking into
%account all sources.  It's divided into sections according to topic.

%% Rating/Stat conversions 
%have been moved to a separate file so that they
%can be called independently by other functions/simulations.  We'll call
%that file here
stat_conversions
mdf.threat=1.43.*1.8;

%% Talents & Glyphs
%I'm going to try and minimize the number of duplicate variables we have.
%Thus, whenever possible I'm going to bake the talent variable into the
%relevant stat calculation.  Ideally, this section will end up empty?
mdf.VengAP=0.05.*talent.Vengeance;
mdf.TbtL=6.*talent.TouchedbytheLight; %incorporates all effects
mdf.AotL=6.*talent.ArbiteroftheLight;
mdf.JotP=1+0.03.*talent.JudgementsofthePure;
mdf.PotI=1+0.2.*talent.ProtectoroftheInnocent; %RA output
mdf.SotP=1+0.05.*talent.SealsofthePure;
mdf.JotJ=1+0.1.*talent.JudgementsoftheJust;
mdf.Tough=1+floor(3.4.*talent.Toughness)./100;
mdf.HalGro=1+0.2.*talent.HallowedGround; %Cons output
mdf.Sanct=2.*talent.Sanctuary; %crit reduction for now
mdf.WotL=0.1.*talent.WrathoftheLightbringer; %incorporates both effects
mdf.Reck=0.1.*talent.Reckoning;  %this will probably end up in the parryhaste module
mdf.GC=0.1.*talent.GrandCrusader;
mdf.Vind=1-0.05.*talent.Vindication; %damage reduction
mdf.HolySh=15.*talent.HolyShield;
% mdf.GbtL %NYI
mdf.SacDut=0.25.*talent.SacredDuty; 
mdf.EfaE=0.2.*talent.EyeforanEye; %proc chance
mdf.Crus=1+0.1.*talent.Crusade;
mdf.RoL=5.*talent.RuleofLaw;
% mdf.EG %NYI

%% Meta Gems, Enchants, Plate Spec
%Similar to talents, I'd like to incorporate these directly into the
%calculations.  I'm leaving the section here to remind myself to check for
%Armsman implementation down the line
mdf.ameta=1+0.02.*gear.armormeta;
mdf.cmeta=1+0.03.*gear.critmeta;
mdf.plate=1+0.05.*gear.isplate;

%%Standard Professions
%(passive bonuses, independent of gearing choices)
if (base.prof1==1 || base.prof2==1) mdf.mining=120; else mdf.mining=0; end;
if (base.prof1==2 || base.prof2==2) mdf.skinning=80; else mdf.skinning=0; end;

%% Raid Buffs
mdf.BoK=1+0.05.*buff.BoK;
mdf.SoE=100.*buff.SoE;
mdf.PWF=100.*buff.PWF;
mdf.ArcInt=100.*buff.ArcInt;
mdf.UnRage=1+0.1.*buff.UnRage;
mdf.FMT=6.*buff.FMT; %does it stack with ToW?
mdf.ToW=10.*buff.ToW; %does it stack with FMT?
mdf.HePr=buff.HePr;
mdf.ArcTac=1+0.03.*buff.ArcTac;
mdf.LotP=5.*buff.LotP;
mdf.WF=1+0.2.*buff.WF;
mdf.WoA=1+0.05.*buff.WoA;
mdf.BL=1+0.3.*buff.BL;
mdf.Devo=1000.*buff.Devo;
mdf.Focus=3.*buff.Focus;
%% Raid Debufs
mdf.SavCom=1+0.04.*buff.SavCom;
mdf.Hemo=1.3.*buff.Hemo;
mdf.CoE=1+0.08.*buff.CoE;
mdf.ISB=5.*buff.ISB;
mdf.Sund=1-0.12.*buff.Sund;
mdf.ST=1-0.2.*buff.ST;

%% Extras
%this section is a way to incorporate extra amounts of different stats to
%compare itemization benefits
%extra is a struct array with fields shown below.  The "extra.val.x" and
%"extra.itm.x" contain the contributions to stat x in terms of raw stats
%(val) and ipoints (itm)
%the ipoint conversion factors are defined in stat_conversions
if exist('extra')==0
    extra_init
end;
extra.str=extra.itm.str.*ipconv.str   	+ extra.val.str;
extra.sta=extra.itm.sta.*ipconv.sta     + extra.val.sta;
extra.agi=extra.itm.agi.*ipconv.agi   	+ extra.val.agi;
extra.int=extra.itm.int.*ipconv.int     + extra.val.int;
extra.hit=extra.itm.hit.*ipconv.hit  	+ extra.val.hit;
extra.crit=extra.itm.crit.*ipconv.crit	+ extra.val.crit;
extra.exp=extra.itm.exp.*ipconv.exp  	+ extra.val.exp;
extra.ap=extra.itm.ap.*ipconv.ap        + extra.val.ap;
extra.sp=extra.itm.sp.*ipconv.sp        + extra.val.sp;
extra.has=extra.itm.has.*ipconv.has     + extra.val.has;
extra.mas=extra.itm.mas.*ipconv.mas     + extra.val.mas;
extra.blo=extra.itm.blo.*ipconv.blo     + extra.val.blo;

%% Primary stats
player.str=floor(base.stats.str.*mdf.BoK)+floor((gear.str+mdf.SoE+extra.str).*mdf.BoK);
player.sta=floor((base.stats.sta+mdf.mining).*(1+(mdf.TbtL./40)).*mdf.BoK.*mdf.plate)+ ...
    floor((gear.sta+mdf.PWF+extra.sta).*(1+(mdf.TbtL./40)).*mdf.BoK.*mdf.plate);
player.agi=floor(base.stats.agi.*mdf.BoK)+floor((gear.agi+mdf.SoE+extra.agi).*mdf.BoK);
player.int=floor(base.stats.int.*mdf.BoK)+floor((gear.int+extra.int).*mdf.BoK);
% player.spi=floor(base.stats.spi.*mdf.BoK)+floor((gear.spi+extra.spi).*mdf.BoK);

%armory strength
player.armorystr=base.stats.str+gear.str; %TODO fix/delete

%hit points
player.hitpoints=base.health+10.*(player.sta-18)+gear.health;

%armor and physical damage reduction
player.armor=gear.barmor.*mdf.Tough.*mdf.ameta ...
    +gear.earmor+player.agi.*2+mdf.Devo;
player.armor_c=400+85*npc.lvl+4.5*85*(npc.lvl-59);
player.phdr=player.armor./(player.armor+player.armor_c);

%resistance and spell damage reduction
player.resistance=0; %TODO : fix it (buff etc.)
player.resist_c=400;
player.spdr=player.resistance./(player.resistance+player.resist_c);


%% Hit Rating (TODO check HePr later on)
player.phhit=(gear.hit+extra.hit)./cnv.hit_phhit+mdf.HePr;
player.sphit=(gear.hit+extra.hit)./cnv.hit_sphit+mdf.TbtL+mdf.HePr;


%% Expertise
if (base.race==1 && (strcmp(egs(15).wtype,'swo') || strcmp(egs(15).wtype,'mac')))
        base.exp=3;
elseif (base.race==2 && strcmp(egs(15).wtype,'mac'))
        base.exp=5;
end

player.exp=(base.exp + (gear.exp+extra.exp)./cnv.exp_exp);

%% Haste 
player.phhaste=100.*( ...
    (1 + (gear.haste+extra.haste)./cnv.haste_phhaste./100).* ...
    mdf.JotP.*mdf.WF ...
    -1);
player.sphaste=100.*(...
    (1+(gear.haste+extra.haste)./cnv.haste_sphaste./100).* ...
    mdf.JotP.*mdf.WoA ...
    -1);
player.spgcd=max([1.5./(1+player.sphaste./100);ones(size(player.sphaste))]);

mdf.phhaste=(1+player.phhaste./100);
mdf.sphaste=(1+player.sphaste./100);

%alternate values under Bloodlust-type effects
bl.phhaste=100.*((1+player.phhaste./100).*mdf.BL-1);
bl.sphaste=100.*((1+player.sphaste./100).*mdf.BL-1);
bl.spgcd=max([1.5./(1+bl.sphaste./100);ones(size(player.sphaste))]); 

mdf.blphhaste=(1+bl.phhaste./100);
mdf.blsphaste=(1+bl.sphaste./100);

%haste scaling for DoT effects
cens.BaseTick=3; %seconds
cens.BaseDur=15; %seconds
cens.NetTick=cens.BaseTick./mdf.sphaste; %confirmed to scale only with spell haste (b12644)
cens.NumTicks=round(cens.BaseDur./cens.BaseTick.*mdf.sphaste); 
cens.NetDur=cens.NumTicks.*cens.NetTick;


%% Crit
%multipliers
mdf.phcritmulti=2.*mdf.cmeta;   %for physical attacks
mdf.spcritmulti=1.5.*mdf.cmeta; %for spells


%melee abilities ("physical crit")
player.phcrit=base.phcrit + ...                                %base physical crit
    player.agi./cnv.agi_phcrit + ...                           %AGI
    (gear.crit+mdf.skinning+extra.crit)./cnv.crit_phcrit + ... %crit rating
    mdf.LotP ...                                               %buffs
    -npc.phcritsupp;                                           %crit suppression

%spell abilities ("spell crit")
player.spcrit=base.spcrit + ...                                %base spell crit
    player.int./cnv.int_spcrit + ...                           %INT
    (gear.crit+mdf.skinning+extra.crit)./cnv.crit_spcrit + ... %crit rating
    mdf.LotP+mdf.ISB+mdf.Focus ...                             %buffs
    -npc.spcritsupp;                                           %crit suppression

%regular melee attacks (one-roll system)
%this gets modified again after boss stats to enforce crit cap
player.aacrit=base.phcrit + ...                                %base physical crit
    player.agi./cnv.agi_phcrit + ...                           %AGI
    (gear.crit+mdf.skinning+extra.crit)./cnv.crit_phcrit + ... %crit rating
    mdf.LotP ...                                               %buffs
    -npc.phcritsupp;                                           %crit suppression

%explicit crit for non-standard abilities
player.HWcrit=player.spcrit+mdf.WotL.*100;          %WotL
player.HoWcrit=player.phcrit+mdf.WotL.*100;         %WotL
player.CScrit=player.phcrit+mdf.RoL;                %RoL
player.Jcrit=player.phcrit+mdf.AotL+100.*mdf.WotL;  %AotL, WotL
player.WoGcrit=player.spcrit+mdf.RoL;               %RoL

%enforce crit caps for two-roll
player.phcrit=max([min([player.phcrit;100.*ones(size(player.phcrit))]); ...
    zeros(size(player.phcrit))]);
player.spcrit=max([min([player.spcrit;100.*ones(size(player.spcrit))]); ...
    zeros(size(player.spcrit))]);

player.HWcrit=max([min([player.HWcrit;100.*ones(size(player.HWcrit))]); ...
    zeros(size(player.HWcrit))]);
player.HoWcrit=max([min([player.HoWcrit;100.*ones(size(player.HoWcrit))]); ...
    zeros(size(player.HoWcrit))]);
player.CScrit=max([min([player.CScrit;100.*ones(size(player.CScrit))]); ...
    zeros(size(player.CScrit))]);
player.Jcrit=max([min([player.Jcrit;100.*ones(size(player.Jcrit))]); ...
    zeros(size(player.Jcrit))]);
player.WoGcrit=max([min([player.WoGcrit;100.*ones(size(player.WoGcrit))]); ...
    zeros(size(player.WoGcrit))]);


%Crit modifier values
mdf.phcrit=1+(mdf.phcritmulti-1).*player.phcrit./100;
mdf.spcrit=1+(mdf.spcritmulti-1).*player.spcrit./100;

mdf.HWcrit=1+(mdf.spcritmulti-1).*player.HWcrit./100;
mdf.HoWcrit=1+(mdf.phcritmulti-1).*player.HoWcrit./100;
mdf.CScrit=1+(mdf.phcritmulti-1).*player.CScrit./100;
mdf.Jcrit=1+(mdf.phcritmulti-1).*player.Jcrit./100;
mdf.WoGcrit=1+(mdf.spcritmulti-1).*player.WoGcrit./100;

%% SP and AP
%AP gets computed later on, in the Vengeance subsection
player.sp=gear.sp+extra.sp+floor(player.str.*(mdf.TbtL./10))+player.int./cnv.int_sp;
%for future use in case our spellpower and "holy spell power" are both
%relevant.  hsp is what we get from TbtL, and only affects damage.  We're
%back to the old 2.x "spell power" and "healing power" modle, it seems.
player.hsp=player.sp;  

%% Mastery
player.mast=base.mast+gear.mast;

%% Avoidance and Blocking
%TODO: update avoid_dr
avoiddr=avoid_dr(gear.dodge,gear.parry,player.agi-base.stats.agi); %DR for dodge/parry

player.miss=base.miss-0.04.*npc.skillgap;
player.dodge=base.dodge+base.stats.agi./cnv.agi_dodge+avoiddr.dodgedr-0.04.*npc.skillgap;
player.parry=base.parry+avoiddr.parrydr-0.04.*npc.skillgap;

%at the moment, we don't have Redoubt to worry about, so we shouldnt' need
%dynamic effects for block chance (hopefully?)
player.block=base.block+mdf.HolySh+gear.block./cnv.block_block ...
    +player.mast./cnv.mast_block-0.04.*npc.skillgap;

%check for bounding issues, based on the attack table
player.miss=max([player.miss;zeros(size(player.miss))]);
player.dodge=min([max([player.dodge;zeros(size(player.dodge))]); ...
    (100-player.miss).*ones(size(player.dodge))]);
player.parry=min([max([player.parry;zeros(size(player.parry))]); ...
    (100-player.miss-player.dodge).*ones(size(player.parry))]);
player.block=min([max([player.block;zeros(size(player.block))]); ...
    (100-player.miss-player.dodge-player.parry).*ones(size(player.block))]);

player.avoid=player.miss+player.dodge+player.parry;
player.avoidpct=player.avoid./100;

%% Boss Stats
%TODO: This section is a bit weird.  we have the npc structure already, but
%that contains "base" values.  The target structure incorporates a lot
%of the player's stats.  

%For now, I've eliminated the redundant entries and moved anything that
%doesn't get modified into npc_model.  We might want to bring them back
%eventually for ease of use.  As an example, target contains
%miss/dodge/parry/avoid, but not block.  It might be easier to have a
%redundant target.block so that we can refer to it without having to remember
%that it doesn't get modified by player stats.

target.swing=npc.swing.*mdf.JotJ;

target.miss=max([(npc.phmiss-player.phhit);zeros(size(player.phhit))]);
target.dodge=max([(npc.dodge-0.25.*player.exp);zeros(size(player.exp))]);
target.parry=max([(npc.parry.*(1-exec.behind)-0.25.*player.exp);zeros(size(player.exp))]);
target.avoid=target.miss+target.dodge+target.parry;
target.block=npc.block.*npc.blockflag.*(1-exec.behind);

target.spmiss=max([(npc.spmiss-player.sphit);zeros(size(player.sphit))]);
target.resrdx=(100-npc.presist)./100;
%%%%%%%%%%%%%%%% Armor calcs
%since Armor Penetration is being removed from gear, we'll set ArPen to
%zero for now.  Once we know if/how this is implemented for us, we can fix
%it.
player.ArPr=0;
%Armor Penetration Constant C
target.armor_c=400+85*base.lvl+4.5*85*(base.lvl-59);
%debuffed armor
target.dbfarmor=npc.armor.*mdf.Sund.*mdf.ST;
%Armor penetration cap (max amount of armor that can be removed)
target.ArP_cap=min([target.dbfarmor;(target.dbfarmor+target.armor_c)/3]);
%Armor Penetration (%)
target.ArP=min([player.ArPr./cnv.arpen_arpen;100.*ones(size(player.ArPr))]);
%Boss Armor and DR formulas
target.armor=floor(target.dbfarmor - target.ArP./100.*min([target.dbfarmor;target.ArP_cap]));
target.phdr=target.armor./(target.armor+target.armor_c);

%Vengeance AP correction
player.VengAP=min([15.*mdf.VengAP.*(npc.out.phys.*(1-player.phdr)./target.swing ...
    +npc.out.spell.*(1-player.spdr)./npc.cast);0.1.*player.hitpoints]).*exec.timein;
player.ap=floor((base.ap+gear.ap+2.*(player.str-10)+extra.ap+player.VengAP).*mdf.UnRage);

%% Weapon Details
player.wdamage=gear.avgdmg+player.ap./14.*gear.swing;
player.wswing=gear.swing./mdf.phhaste;
player.wdps=player.wdamage./player.wswing;

%alternate values during bloodlust-type effects
bl.wswing=gear.swing./mdf.blphhaste;
bl.wdps=player.wdamage./bl.wswing;

%% Parryhaste corrections
%ignoring this for now until we know how/if parryhaste is implemented

%% Other dynamic or inter-dependent corrections 
%Hit & Damage modifier values
mdf.phdmg=mdf.SavCom.*mdf.ArcTac.*(1-target.phdr);
mdf.mehit=1-(target.miss+target.dodge+target.parry)./100;
mdf.rahit=1-target.miss./100;
mdf.spdmg=mdf.CoE.*mdf.ArcTac;
mdf.sphit=1-target.spmiss./100;

%enforce one-roll system for auto-attacks
player.aacrit=max([min([player.aacrit.*ones(size(target.avoid+npc.glance+target.block)); ...
    (100-target.avoid-npc.glance-target.block)]);zeros(size(player.aacrit))]);
mdf.glancerdx=1-npc.glancerdx./100;
mdf.aamodel=(mdf.mehit) ...                   %hit
    +(mdf.glancerdx-1).*npc.glance./100 ...   %glancing
    +(mdf.phcritmulti-1).*player.aacrit./100; %crit

%% PPM-based uptimes
%this section will have to wait until we know which attacks survive, what
%our rotation looks like, and what procs PPM effects.

%% Power Gains
%Low-priority at the moment.