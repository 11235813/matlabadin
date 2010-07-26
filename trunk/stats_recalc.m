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


%% Meta Gems and Enchants
%Similar to talents, I'd like to incorporate these directly into the
%calculations.  I'm leaving the section here to remind myself to check for
%Armsman implementation down the line

%% Raid Buffs 
%awaiting tlitp's buff/debuff imlementation

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

str=floor(floor((base.str+gear.str+SoE+MotW+extra.str)).*BoK);
sta=floor(floor((base.sta+gear.sta+PWF+MotW+extra.sta)).*BoK);
agi=floor((base.agi+gear.agi+SoE+MotW+extra.agi).*BoK);
int=floor((base.int+gear.int+MotW+ArcInt+extra.int).*BoK);
spi=floor((base.spi+gear.spi+MotW).*BoK);

armory_str=floor(floor((base.str+gear.str)));

%% Hit Rating
spell_hit=Draenei_Aura + (gear.hit+extra.hit)./hit_to_spellhit;

melee_hit=Draenei_Aura + (gear.hit+extra.hit)./hit_to_meleehit;

%% Expertise
if (base.race==1 && (egs(15).wtype=='swo' || egs(15).wtype=='mac'))
        base.exp=3;
elseif (base.race==2 && (egs(15).wtype=='mac'))
        base.exp=5;
end

expertise=(base.exp + (gear.exp+extra.exp)./exp_to_exp);

%% Haste
haste=100.*( ...
    (1 + (gear.haste+extra.haste)./haste_to_haste./100).* ...
    (1 + talent.example./100) .* ...
    (1 + WF./100) .* ...
    (1 + BL./100) ...
    -1);

%% Crit

%% SP and AP

%% Avoidance and Blocking

%% Boss Stats

%% Weapon Details

%% Parryhaste corrections

%% PPM-based uptimes

%% Power Gains