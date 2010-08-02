%% stat_model
%this m-file recalculates the final stats of the player, taking into
%account all sources.  It's divided into sections according to topic.

%% Rating/Stat conversions 
%have been moved to a separate file so that they
%can be called independently by other functions/simulations.  We'll call
%that file here
stat_conversions

%% Talents & Glyphs
%I'm going to try and minimize the number of duplicate variables we have.
%Thus, whenever possible I'm going to bake the talent variable into the
%relevant stat calcluation.  Ideally, this section will end up empty?
talent.example=1;  %example for how talents are implemented
mod.VengAP=0.05.*talent.Vengeance;
mod.TbtL=0.15.*talent.TouchedbytheLight; %incorporates both effects
mod.AotL=6.*talent.ArbiteroftheLight;
mod.JotP=1+0.03.*talent.JudgementsofthePure;
mod.PotI=1+0.2.*talent.ProtectoroftheInnocent;
mod.SotP=1+0.05.*talent.SealsofthePure;
mod.JotJ=1+0.1.*talent.JudgementsoftheJust;
mod.Tough=1+floor(3.4.*talent.Toughness)./100;
mod.HalGro=1+talent.HallowedGround;
mod.Sanct=0.02.*talent.Sanctuary;
mod.WotL=0.1.*talent.WrathoftheLightbringer; %incorporates both effects
mod.Reck=0.1.*talent.Reckoning;  %this will probably end up in the parryhaste module
% mod.GC %grand crusader is NIY, we'll code it later on
mod.Vind=0.05.*talent.Vindication; %only the damage reduction ?
mod.SacDut=5.*talent.SacredDuty; %incorporates both effects
mod.EfaE=0.3.*sign(talent.EyeforanEye)+0.05.*talent.EyeforanEye; %hacky, incorporates both effects
mod.RoL=5.*talent.RuleofLaw;
mod.Crus=1+0.1.*talent.Crusade;
mod.ImpJud=1+0.05.*talent.ImprovedJudgement;
mod.Conv=1; %NYI, we need to decide if we implement time-explicit stacking

%% Meta Gems and Enchants
%Similar to talents, I'd like to incorporate these directly into the
%calculations.  I'm leaving the section here to remind myself to check for
%Armsman implementation down the line
mod.ameta=1+0.02.*gear.armormeta;
mod.cmeta=1+0.03.*gear.critmeta;


%% Raid Buffs [WIP]
buff.example=1; %example for how buffs are implemented
mod.BoK=1+0.05.*buff.BoK;
mod.SoE=100.*buff.SoE;
mod.PWF=100.*buff.PWF;
mod.ArcInt=100.*buff.ArcInt;
mod.UnRage=1+0.1.*buff.UnRage;
mod.FMT=6.*buff.FMT; %does it stack with ToW?
mod.ToW=10.*buff.ToW; %does it stack with FMT?
mod.HePr=buff.HePr;
mod.SwRet=1+0.03.*buff.SwRet;
mod.LotP=5.*buff.LotP;
mod.WF=1+0.2.*buff.WF;
mod.WoA=5.*buff.WoA;
mod.BL=1+0.3.*buff.BL;
mod.Devo=1000.*buff.Devo;
mod.Focus=3.*buff.Focus;
%% Raid Debufs [WIP]
mod.SavCom=1+0.04.*buff.SavCom;
mod.Hemo=1.3.*buff.Hemo;
mod.CoE=1+0.08.*buff.CoE;
mod.ISB=5.*buff.ISB;
mod.Sund=1-0.12.*buff.Sund;
mod.ST=1-0.2.*buff.ST;

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
player.str=floor(floor((base.str+gear.str+extra.str)).*mod.BoK);
player.sta=floor(floor((base.sta+gear.sta+extra.sta).*(1+mod.TbtL)).*mod.BoK);
player.agi=floor((base.agi+gear.agi+extra.agi).*mod.BoK);
player.int=floor((base.int+gear.int+extra.int).*mod.BoK);
% player.spi=floor((base.spi+gear.spi).*mod.BoK);

%armory strength
player.armorystr=floor(floor((base.str+gear.str)));

%hit points
player.hitpoints=base.health+10.*(player.sta-10)+gear.health;

%armor
player.armor=gear.barmor.*mod.Tough.*mod.ameta ...
    +gear.earmor+player.agi.*2+mod.Devo;

%Vengeance - first initialize a "damage dealt" tracker in case we haven't
%already.  This could be defaulted to 0 if we want, for now I've set it to
%player.hitpoints so it'll be much larger than the minimum required
if exist('target.dmgdealt')==0 target.dmgdealt=player.hitpoints; end

%now calculate the max ap contribution and the current one.  For most
%cases, we'll want it fixed at vengapmax.  However, if we do any real
%combat simulating, we can initialize target.dmgdealt separately and
%track it, giving real-time vengeance AP data.
player.vengapmax=player.hitpoints.*2.*mod.VengAP; %max of 10% hitpoints
player.vengap=min([player.vengapmax mod.VengAP.*target.dmgdealt]);

%% Hit Rating (TODO check HePr later on)
player.phhit=buff.example+(gear.hit+extra.hit)./cnv.hit_phhit+mod.HePr;
player.sphit=buff.example+(gear.hit+extra.hit)./cnv.hit_sphit+mod.HePr;


%% Expertise
if (base.race==1 && (strcmp(egs(15).wtype,'swo') || strcmp(egs(15).wtype,'mac')))
        base.exp=3;
elseif (base.race==2 && strcmp(egs(15).wtype,'mac'))
        base.exp=5;
end

player.exp=(base.exp + (gear.exp+extra.exp)./cnv.exp_exp + talent.example);

%% Haste (only physical haste is relevant)
player.haste=100.*( ...
    (1 + (gear.haste+extra.haste)./cnv.haste_phhaste./100).* ...
    mod.JotP .* ...
    mod.WF .* ...
    mod.BL ...
    -1);
    

%% Crit
%multipliers
mod.phcritmulti=2.*mod.cmeta;   %for physical attacks
mod.spcritmulti=1.5.*mod.cmeta; %for spells


%melee abilities ("physical crit")
player.phcrit=min([(base.phcrit + ...               %base physical crit
    player.agi./cnv.agi_phcrit + ...                %AGI
    (gear.crit+extra.crit)./cnv.crit_phcrit + ...   %crit rating
    -npc.phcritsupp) 100]);                         %crit suppression

%spell abilities ("spell crit")
player.spcrit=min([(base.spcrit + ...               %base spell crit
    player.int./cnv.int_spcrit + ...                %INT
    (gear.crit+extra.crit)./cnv.crit_spcrit + ...   %crit rating
    -npc.spcritsupp) 100]);                         %crit suppression

%regular melee attacks (one-roll system)
%this gets modified again after boss stats to enforce crit cap
player.aacrit=(base.phcrit + ...                    %base physical crit
    player.agi./cnv.agi_phcrit + ...                %AGI
    (gear.crit+extra.crit)./cnv.crit_phcrit + ...   %crit rating
    -npc.phcritsupp);                               %crit suppression

%% SP and AP
player.ap=floor((base.ap+gear.ap+2.*(player.str-10)+extra.ap+buff.example+player.vengap).*mod.UnRage);
player.sp=gear.sp+extra.sp+floor(player.str.*4.*mod.TbtL)+player.int./cnv.int_sp+buff.example;
%for future use in case our spellpower and "holy spell power" are both
%relevant.  hsp is what we get from TbtL, and only affects damage.  We're
%back to the old 2.x "spell power" and "healing power" modle, it seems.
player.hsp=player.sp;  

%% Mastery
player.mast=base.mast+gear.mast+talent.example;

%% Avoidance and Blocking
%TODO: modify avoid_dr to get rid of defense and fix parry
[dr.dodge dr.parry dr.miss dr.total] =  avoid_dr(gear.dodge,gear.parry,0,player.agi-base.agi);

player.miss=base.miss+dr.miss+buff.example-0.04.*npc.skillgap;
player.dodge=base.dodge+base.agi./cnv.agi_dodge+dr.dodge-0.04.*npc.skillgap-buff.example;
player.parry=base.parry+dr.parry-0.04.*npc.skillgap;

%check for bounding issues
player.dodge=min([max([player.dodge zeros(size(player.dodge))]) (100-player.miss).*ones(size(player.dodge))]);
player.parry=min([player.parry (100-player.dodge-player.miss).*ones(size(player.parry))]);

player.avoid=player.miss+player.dodge+player.parry;
player.avoidpct=player.avoid./100;

%at the moment, we don't have Redoubt to worry about, so we shouldnt' need
%dynamic effects for block chance (hopefully?)
player.block=base.block+player.mast./cnv.mast_block;

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

target.swing=npc.swing.*mod.JotJ;

target.miss=max([(npc.phmiss-player.phhit) zeros(size(player.phhit))]);
target.dodge=max([(npc.dodge-0.25.*player.exp) zeros(size(player.exp))]);
target.parry=max([(npc.parry.*(1-exec.behind)-0.25.*player.exp) zeros(size(player.exp))]);
target.avoid=target.miss+target.dodge+target.parry;


target.spmiss=max([(npc.spmiss-player.sphit-buff.example) zeros(size(player.sphit))]);
target.resrdx=(100-npc.presist)./100;
%%%%%%%%%%%%%%%% EJ Armor calcs
%since Armor Penetration is being removed from gear, we'll set ArPen to
%zero for now.  Once we know if/how this is implemented for us, we can fix
%it.
ArPen=0;

%Armor Penetration Constant C
C=400+85*base.level+4.5*85*(base.level-59);

%debuffed armor
target.dbfarmor=npc.armor.*mod.Sund.*mod.ST;

%Armor penetration cap (max amount of armor that can be removed)
ArPenCap=min([target.dbfarmor; (target.dbfarmor+C)/3]);

%Armor Penetration Rating in %, up to a max of 100%
ArP=min([ArPen./cnv.arpen_arpen; 100.*ones(size(ArPen))]);

%Boss Armor and DR formulas
target.armor=floor(target.dbfarmor - ArP./100.*min([target.dbfarmor; ArPenCap]));
target.phdr=target.armor./(target.armor+C);

%% Weapon Details
player.wdamage=gear.avgdmg+player.ap./14.*gear.swing;
player.wswing=gear.swing./(1+player.haste./100);
player.wdps=player.wdamage./player.wswing;

%% Hit/Crit modifier values
mod.phdmg=mod.Conv.*mod.SwRet.*mod.SavCom.*(1-target.phdr);
mod.mehit=1-(target.miss+target.dodge+target.parry)./100;
mod.rahit=1-target.miss./100;
mod.phcrit=1+(mod.phcritmulti-1).*player.phcrit./100;

mod.spdmg=mod.Conv.*mod.SwRet.*mod.CoE;
mod.sphit=1-target.spmiss./100;
mod.spcrit=1+(mod.spcritmulti-1).*player.spcrit./100;

%enforce one-roll system crit cap for auto-attacks
player.aacrit=max([player.aacrit.*ones(size(target.avoid+npc.glance+npc.block)) ...   %corrects for size of boss_avoid
    (100-target.avoid-npc.glance-npc.block)]);         
mod.aahitcrit=1-npc.glancerdx+(mod.mehit-1)+(mod.phcritmulti-1).*player.aacrit./100;

%% Parryhaste corrections
%ignoring this for now until we know how/if parryhaste is implemented

%% Other dynamic or inter-dependent corrections 


%% PPM-based uptimes
%this section will have to wait until we know which attacks survive, what
%our rotation looks like, and what procs PPM effects.

%% Power Gains
%Low-priority at the moment.