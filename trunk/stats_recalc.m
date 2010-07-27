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

%% Raid Buffs 
%awaiting tlitp's buff/debuff imlementation
buff.example=1; %example for how buffs are implemented
buff.BoK=1;  %this line would be in the buffs/debuffs module
BoK=1.1.*buff.BoK;
%% Raid Debufs
%awaiting tlitp's buff/debuff imlementation

%% Extras
%this section is a way to incorporate extra amounts of different stats to
%compare itemization benefits
%extra is a struct array with fields shown below.  The "extra.val.x" and
%"extra.itm.x" contain the contributions to stat x in terms of raw stats
%(val) and ipoints (itm)
%the ipoint conversion factors are defined in stat_conversions
%extra_by_ipoints is an 11x? binary array, which can be used to add item
%points 
%extra_by_value is a 11x? integer array which can be used to add stat
%point
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

str=floor(floor((base.str+gear.str+extra.str)).*BoK);
sta=floor(floor((base.sta+gear.sta+extra.sta)).*BoK);
agi=floor((base.agi+gear.agi+extra.agi).*BoK);
int=floor((base.int+gear.int+extra.int).*BoK);
% spi=floor((base.spi+gear.spi).*BoK);

armory_str=floor(floor((base.str+gear.str)));

%% Hit Rating
spellhit=buff.example + (gear.hit+extra.hit)./hit_to_spellhit;

meleehit=buff.example + (gear.hit+extra.hit)./hit_to_meleehit;

%% Expertise
if (base.race==1 && (strcmp(egs(15).wtype,'swo') || strcmp(egs(15).wtype,'mac')))
        base.exp=3;
elseif (base.race==2 && strcmp(egs(15).wtype,'mac'))
        base.exp=5;
end

expertise=(base.exp + (gear.exp+extra.exp)./exp_to_exp + talent.example);

%% Haste
haste=100.*( ...
    (1 + (gear.haste+extra.haste)./haste_to_haste./100).* ...
    (1 + talent.example./100) .* ...
    -1);
%     (1 + WF./100) .* ...    %lines for WF and BL when implemented
%     (1 + BL./100) ...

%% Crit
phcrit_multiplier=2.*(1+0.03.*gear.critmeta);   %for physical attacks
spcrit_multiplier=1.5.*(1+0.03.*gear.critmeta);  %for spells


%melee abilities ("physical crit")
phcrit=min([(base.phcrit + ...                    %base physical crit
    agi./agi_to_phcrit + ...                         %AGI
    (gear.crit+extra.crit)./crit_to_phcrit + ...    %crit rating
    -npc.phcritsupp) 100]);                            %crit suppression

%spell abilities ("spell crit")
spcrit=min([(base.spcrit + ...                        %base spell crit
    int./int_to_spcrit + ...                              %INT
    (gear.crit+extra.crit)./crit_to_spcrit + ...    %crit rating
    -npc.spcritsupp) 100]);                              %crit suppression

%crit cap for regular melee attacks (one-roll system)
aacrit=(base.phcrit + ...                       %base physical crit
    agi./agi_to_phcrit + ...                         %AGI
    (gear.crit+extra.crit)./crit_to_phcrit + ...    %crit rating
    -npc.phcritsupp);                                %crit suppression

%% SP and AP
ap=floor((base.ap+gear.ap+2.*(str-10)+extra.ap+buff.example).*(1+0.2.*buff.example));
SP=gear.sp + extra.sp + floor(str.*0.3.*talent.example) + int./int_to_sp + buff.example;

%% Mastery
mast=base.mast+gear.mast+talent.example;

%% Avoidance and Blocking
%TODO: modify avoid_dr to get rid of defense and fix parry
[dr.dodge dr.parry dr.miss dr.total] =  avoid_dr(gear.dodge,gear.parry,0,agi-base.agi);

avoid.miss=base.miss+dr.miss+buff.example-0.04.*npc.skillgap;
avoid.dodge=base.dodge+base.agi./agi_to_dodge+dr.dodge-0.04.*npc.skillgap-buff.example;
avoid.parry=base.parry+dr.parry-0.04.*npc.skillgap;

%check for bounding issues
avoid.dodge=min([max([avoid.dodge zeros(size(avoid.dodge))]) (100-avoid.miss).*ones(size(avoid.dodge))]);
avoid.parry=min([avoid.parry (100-avoid.dodge-avoid.miss).*ones(size(avoid.parry))]);

avoid.total=avoid.miss+avoid.dodge+avoid.parry;
avoid.totalpct=avoid.total./100;

%at the moment, we don't have Redoubt to worry about, so we shouldnt' need
%dynamic effects for block chance (hopefully?)
block=base.block+mast./mast_to_block;

%% Boss Stats
%attacking from behind flag
if exist('they_came_from_behind')==0
    they_came_from_behind=0;
end

boss.swing=npc.swing.*max([1.2.*talent.example 1]);

boss.miss=max([(npc.miss-meleehit) zeros(size(meleehit))]);
boss.dodge=max([(npc.dodge-0.25.*expertise) zeros(size(expertise))]);
boss.parry=max([(npc.parry-0.25.*expertise).*(1-they_came_from_behind) zeros(size(expertise))]);
boss.avoid=boss.miss+boss.dodge+boss.parry;
boss.block=npc.block.*npc.blockflag.*(1-they_came_from_behind);

boss.glancing=npc.glancing;
boss.glanceredux=(npc.glancing./100).*(0.05+0.1.*(npc.lvlgap-1));

boss.spresist=max([(npc.spresist-spellhit-buff.example) zeros(size(spellhit))]);
boss.resredux=(100-npc.partialresist)./100;
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
ArP=min([ArPen./ArPen_to_ArPen; 100.*ones(size(ArPen))]);

%Boss Armor and DR formulas
boss.armor=floor(temp_debuffed_armor - ArP./100.*min([temp_debuffed_armor; ArPenCap]));
boss.phdr=boss.armor./(boss.armor+C);

%% Weapon Details
weapon.basedps=gear.avgdmg./gear.swing + ap./14;  %was for HotR, may be obsolete now
weapon.damage=gear.avgdmg+ap./14.*gear.swing;
weapon.swing=gear.swing./(1+haste./100);
weapon.dps=weapon.damage./weapon.swing;

%% Parryhaste corrections
%ignoring this for now until we know how/if parryhaste is implemented

%% Other dynamic or inter-dependent corrections
aacrit=max([aacrit.*ones(size(boss.avoid+boss.glancing+boss.block))                            %corrects for size of boss_avoid
    (100-boss.avoid-boss.glancing-boss.block)]);                                      %crit cap

%% PPM-based uptimes
%this section will have to wait until we know which attacks survive, what
%our rotation looks like, and what procs PPM effects.

%% Power Gains
%Low-priority at the moment.