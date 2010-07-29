%% stats_recalc
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

%% Meta Gems and Enchants
%Similar to talents, I'd like to incorporate these directly into the
%calculations.  I'm leaving the section here to remind myself to check for
%Armsman implementation down the line

%% Raid Buffs [WIP]
%awaiting tlitp's buff/debuff imlementation
buff.example=1; %example for how buffs are implemented
buff.BoK=1;  %this line would be in the buffs/debuffs module
BoK=1.05.*buff.BoK;
SoE=100.*buff.SoE;
PWF=100.*buff.PWF;
ArcInt=100.*buff.ArcInt;
UnRage=1.1.*buff.UnRage;
FMT=6.*buff.FMT; %does it stack with ToW?
ToW=10.*buff.ToW; %does it stack with FMT?
HePr=buff.HePr;
SwRet=1.03.*buff.SwRet;
LotP=5.*buff.LotP;
WF=20.*buff.WF;
WoA=5.*buff.WoA;
BL=30.*buff.BL;
Devo=1000.*buff.Devo;
Focus=3.*buff.Focus;
%% Raid Debufs [WIP]
%awaiting tlitp's buff/debuff imlementation
SavCom=1.04.*buff.SavCom;
Hemo=1.3.*buff.Hemo;
CoE=1.08.*buff.CoE;
ISB=5.*buff.ISB;
Sund=12.*buff.Sund;


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

player.str=floor(floor((base.str+gear.str+extra.str)).*BoK);
player.sta=floor(floor((base.sta+gear.sta+extra.sta).*(1+0.15.*talent.TouchedbytheLight)).*BoK);
player.agi=floor((base.agi+gear.agi+extra.agi).*BoK);
player.int=floor((base.int+gear.int+extra.int).*BoK);
% spi=floor((base.spi+gear.spi).*BoK);

%armory strength
player.armorystr=floor(floor((base.str+gear.str)));

%hit points
player.hitpoints=base.health+10.*(player.sta-10)+gear.health;

%armor
player.armor=gear.barmor.*(1+floor(3.4.*talent.Toughness)./100).*(1+0.2*gear.armormeta) ...
    +gear.earmor+player.agi.*2+Devo;

player.vengap=0.1.*player.hitpoints.*talent.Vengeance;

%% Hit Rating
player.sphit=buff.example + (gear.hit+extra.hit)./cnv.hit_sphit;

player.mehit=buff.example + (gear.hit+extra.hit)./cnv.hit_phhit;

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
    (1 + talent.example./100) .* ...
    (1 + WF./100) .* ...
    (1 + BL./100) ...
    -1);
    

%% Crit
phcrit_multiplier=2.*(1+0.03.*gear.critmeta);   %for physical attacks
spcrit_multiplier=1.5.*(1+0.03.*gear.critmeta);  %for spells


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

%crit cap for regular melee attacks (one-roll system)
%this gets modified again after boss stats to enforce crit cap
player.aacrit=(base.phcrit + ...                    %base physical crit
    player.agi./cnv.agi_phcrit + ...                %AGI
    (gear.crit+extra.crit)./cnv.crit_phcrit + ...   %crit rating
    -npc.phcritsupp);                               %crit suppression

%% SP and AP
player.ap=floor((base.ap+gear.ap+2.*(player.str-10)+extra.ap+buff.example+player.vengap).*(1+0.2.*buff.example));
player.sp=gear.sp + extra.sp + floor(player.str.*0.6.*talent.TouchedbytheLight) + player.int./cnv.int_sp + buff.example;
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
%that contains "base" values.  The boss structure incorporates a lot
%of the player's stats.  While we certainly need before and after
%structures, the names aren't as descriptive as I'd like.  On the other
%hand, this seems like the simplest way to organize things, with "npc"
%covering all the values that don't get modified by player stats, and
%"boss" containing anything that does.  We could always rename it "target"
%if we want to be more descriptive with the names.

%For now, I've eliminated the redundant entries and moved anything that
%doesn't get modified into npc_model.  We might want to bring them back
%eventually for ease of use.  As an example, boss contains
%miss/dodge/parry/avoid, but not block.  It might be easier to have a
%redundant boss.block so that we can refer to it without having to remember
%that it doesn't get modified by player stats.

%I'm considering giving player stats the same treatment, and combining them
%with the avoid structure.  In other words, we'd have player.sphit,
%player.dodge, player.avoid, and so forth.

boss.swing=npc.swing.*max([1.2.*talent.example 1]);

boss.miss=max([(npc.phmiss-player.mehit) zeros(size(player.mehit))]);
boss.dodge=max([(npc.dodge-0.25.*player.exp) zeros(size(player.exp))]);
boss.parry=max([(npc.parry-0.25.*player.exp) zeros(size(player.exp))]);
boss.avoid=boss.miss+boss.dodge+boss.parry;


boss.spmiss=max([(npc.spmiss-player.sphit-buff.example) zeros(size(player.sphit))]);
boss.resrdx=(100-npc.presist)./100;
%%%%%%%%%%%%%%%% EJ Armor calcs
%since Armor Penetration is being removed from gear, we'll set ArPen to
%zero for now.  Once we know if/how this is implemented for us, we can fix
%it.
ArPen=0;

%Armor Penetration Constant C
C=400+85*base.level+4.5*85*(base.level-59);

%debuffed armor
temp_debuffed_armor=npc.armor.*(1-0.2.*buff.example).*(1-0.05.*buff.example).*(1-0.2.*buff.example);

%Armor penetration cap (max amount of armor that can be removed)
ArPenCap=min([temp_debuffed_armor; (temp_debuffed_armor+C)/3]);

%Armor Penetration Rating in %, up to a max of 100%
ArP=min([ArPen./cnv.arpen_arpen; 100.*ones(size(ArPen))]);

%Boss Armor and DR formulas
boss.armor=floor(temp_debuffed_armor - ArP./100.*min([temp_debuffed_armor; ArPenCap]));
boss.phdr=boss.armor./(boss.armor+C);

%% Weapon Details
%Should these also be wrapped into the "player" structure?  s/weapon/player
weapon.basedps=gear.avgdmg./gear.swing + player.ap./14;  %was for HotR, may be obsolete now
weapon.damage=gear.avgdmg+player.ap./14.*gear.swing;
weapon.swing=gear.swing./(1+player.haste./100);
weapon.dps=weapon.damage./weapon.swing;

%% Parryhaste corrections
%ignoring this for now until we know how/if parryhaste is implemented

%% Other dynamic or inter-dependent corrections
player.aacrit=max([player.aacrit.*ones(size(boss.avoid+npc.glance+npc.block))   %corrects for size of boss_avoid
    (100-boss.avoid-npc.glance-npc.block)]);                                    %crit cap

%% PPM-based uptimes
%this section will have to wait until we know which attacks survive, what
%our rotation looks like, and what procs PPM effects.

%% Power Gains
%Low-priority at the moment.