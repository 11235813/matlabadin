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
%relevant stat calculation.  Ideally, this section will end up empty?
mdf.VengAP=0.05.*talent.Vengeance;
mdf.TbtL=6.*talent.TouchedbytheLight; %incorporates all effects
mdf.AotL=6.*talent.ArbiteroftheLight;
mdf.BlazLi=1+0.1.*talent.BlazingLight; %Exo output
mdf.JotP=0.03.*talent.JudgementsofthePure;
mdf.SotP=1+0.06.*talent.SealsofthePure;
% mdf.EG %NYI
mdf.JotJ=0.1.*talent.JudgementsoftheJust;
mdf.Tough=1+0.03.*(talent.Toughness==1)+0.06.*(talent.Toughness==2)+0.1.*(talent.Toughness==3);
mdf.HalGro=1+0.2.*talent.HallowedGround; %Cons output
mdf.Sanct=1-(0.03.*(talent.Sanctuary==1)+0.06.*(talent.Sanctuary==2)+0.1.*(talent.Sanctuary==3)); %damage reduction
mdf.WotL=0.15.*talent.WrathoftheLightbringer; %incorporates both effects
mdf.GC=0.1.*talent.GrandCrusader;
mdf.Vind=1-0.05.*talent.Vindication; %damage reduction
mdf.HolySh=15.*talent.HolyShield;
% mdf.GbtL %NYI
mdf.SacDut=0.25.*talent.SacredDuty; 
mdf.EfaE=0.2.*talent.EyeforanEye; %proc chance
mdf.Crus=1+0.1.*talent.Crusade;
mdf.RoL=5.*talent.RuleofLaw;
%glyphs
mdf.glyphCS=5.*glyph.CrusaderStrike;             %CS crit chance
mdf.glyphExo=1+0.2.*glyph.Exorcism;              %Exo output /TODO check DoT mechanics
mdf.glyphHotR=1+0.1.*glyph.HammeroftheRighteous; %HotR output
mdf.glyphJ=1+0.1.*glyph.Judgement;               %J output
mdf.glyphSoT=10.*glyph.SealofTruth;              %expertise bonus
mdf.glyphSotR=1+0.1.*glyph.ShieldoftheRighteous; %SotR output
mdf.glyphWoG=1+0.1.*glyph.WordofGlory;           %WoG output
mdf.glyphCons=1+0.2.*glyph.Consecration;         %Consecration output (and cooldown)
mdf.glyphAS=1+0.3.*glyph.FocusedShield;          %AS output
 
%% Meta Gems, Enchants, Plate Spec, Tier Bonus
%Similar to talents, I'd like to incorporate these directly into the
%calculations.  I'm leaving the section here to remind myself to check for
%Armsman implementation down the line
mdf.ameta=1+0.02.*gear.armormeta;
mdf.cmeta=1+0.03.*gear.critmeta;
mdf.plate=1+0.05.*gear.isplate;
mdf.t10x2=1+0.2.*gear.tierbonus(1); %HotR output
mdf.t11x2=1+0.1.*gear.tierbonus(3); %CS output
mdf.t11x4=1+0.5.*gear.tierbonus(4); %GoAK duration

%%Standard Professions
%(passive bonuses, independent of gearing choices)
if (isempty(base.prof)==0&&(max(strcmpi('Min',strread(base.prof,'%s')))==1 ...
        ||max(strcmpi('Mining',strread(base.prof,'%s')))==1))
    mdf.mining=120;
else
    mdf.mining=0;
end
if (isempty(base.prof)==0&&(max(strcmpi('Skin',strread(base.prof,'%s')))==1 ...
        ||max(strcmpi('Skinning',strread(base.prof,'%s')))==1))
    mdf.skinning=80;
else
    mdf.skinning=0;
end

%% Raid Buffs
mdf.buffscale=125.*(base.lvl==80)+443.*(base.lvl==85); %level scaling
mdf.BoK=1+0.05.*buff.BoK;
mdf.SoE=round(1.24.*mdf.buffscale).*buff.SoE;
mdf.PWF=round(1.32.*mdf.buffscale).*buff.PWF;
mdf.FelInt=round(4.8.*mdf.buffscale).*buff.FelInt; %only mana
mdf.UnRage=1+0.1.*buff.UnRage;
mdf.FMT=1+0.06.*buff.FMT;
mdf.TW=1+0.1.*buff.TW;
mdf.ArcTac=1+0.03.*buff.ArcTac;
mdf.LotP=5.*buff.LotP;
mdf.WF=1+0.1.*buff.WF;
mdf.WoA=1+0.05.*buff.WoA;
mdf.BL=1+0.3.*buff.BL;
mdf.Devo=round(9.2.*mdf.buffscale).*buff.Devo;
mdf.RF=1+2.*buff.RF;
mdf.Focus=3.*buff.Focus;
%% Raid Debufs
mdf.SavCom=1+0.04.*buff.SavCom;
mdf.Hemo=1.3.*buff.Hemo;
mdf.CoE=1+0.08.*buff.CoE;
mdf.ISB=5.*buff.ISB;
mdf.Sund=1-0.12.*buff.Sund;
mdf.ST=1-0.2.*buff.ST;

%% Consumables
%Mixology bonus (the specific values are stored in gear_db's .isproc fields) 
if (isempty(base.prof)==0&&(max(strcmpi('Alch',strread(base.prof,'%s')))==1 ...
        ||max(strcmpi('Alchemy',strread(base.prof,'%s')))==1))
    mdf.mixo(1)=buff.flask.isproc;
    mdf.mixo(2)=buff.belixir.isproc;
    mdf.mixo(3)=buff.gelixir.isproc;
else
    mdf.mixo(1)=1;
    mdf.mixo(2)=1;
    mdf.mixo(3)=1;
end
consum.str=sum([buff.flask.str.*mdf.mixo(1); ...
    buff.belixir.str.*mdf.mixo(2);buff.gelixir.str.*mdf.mixo(3);buff.food.str]);
consum.sta=sum([buff.flask.sta.*mdf.mixo(1); ...
    buff.belixir.sta.*mdf.mixo(2);buff.gelixir.sta.*mdf.mixo(3);buff.food.sta]);
consum.agi=sum([buff.flask.agi.*mdf.mixo(1); ...
    buff.belixir.agi.*mdf.mixo(2);buff.gelixir.agi.*mdf.mixo(3);buff.food.agi]);
consum.int=sum([buff.flask.int.*mdf.mixo(1); ...
    buff.belixir.int.*mdf.mixo(2);buff.gelixir.int.*mdf.mixo(3);buff.food.int]);
consum.ap=sum([buff.flask.ap.*mdf.mixo(1); ...
    buff.belixir.ap.*mdf.mixo(2);buff.gelixir.ap.*mdf.mixo(3);buff.food.ap]);
consum.sp=sum([buff.flask.sp.*mdf.mixo(1); ...
    buff.belixir.sp.*mdf.mixo(2);buff.gelixir.sp.*mdf.mixo(3);buff.food.sp]);
consum.hit=sum([buff.flask.hit.*mdf.mixo(1); ...
    buff.belixir.hit.*mdf.mixo(2);buff.gelixir.hit.*mdf.mixo(3);buff.food.hit]);
consum.exp=sum([buff.flask.exp.*mdf.mixo(1); ...
    buff.belixir.exp.*mdf.mixo(2);buff.gelixir.exp.*mdf.mixo(3);buff.food.exp]);
consum.crit=sum([buff.flask.crit.*mdf.mixo(1); ...
    buff.belixir.crit.*mdf.mixo(2);buff.gelixir.crit.*mdf.mixo(3);buff.food.crit]);
consum.haste=sum([buff.flask.haste.*mdf.mixo(1); ...
    buff.belixir.haste.*mdf.mixo(2);buff.gelixir.haste.*mdf.mixo(3);buff.food.haste]);
consum.mast=sum([buff.flask.mast.*mdf.mixo(1); ...
    buff.belixir.mast.*mdf.mixo(2);buff.gelixir.mast.*mdf.mixo(3);buff.food.mast]);
consum.dodge=sum([buff.flask.dodge.*mdf.mixo(1); ...
    buff.belixir.dodge.*mdf.mixo(2);buff.gelixir.dodge.*mdf.mixo(3);buff.food.dodge]);
consum.parry=sum([buff.flask.parry.*mdf.mixo(1); ...
    buff.belixir.parry.*mdf.mixo(2);buff.gelixir.parry.*mdf.mixo(3);buff.food.parry]);
consum.earmor=sum([buff.flask.earmor.*mdf.mixo(1); ...
    buff.belixir.earmor.*mdf.mixo(2);buff.gelixir.earmor.*mdf.mixo(3);buff.food.earmor]);
consum.health=sum([buff.flask.health.*mdf.mixo(1); ...
    buff.belixir.health.*mdf.mixo(2);buff.gelixir.health.*mdf.mixo(3);buff.food.health]);

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
extra.haste=extra.itm.haste.*ipconv.has     + extra.val.haste;
extra.mas=extra.itm.mas.*ipconv.mas     + extra.val.mas;

%% Primary stats
player.str=floor(base.stats.str.*mdf.BoK)+floor((gear.str+mdf.SoE+extra.str+consum.str).*mdf.BoK);
player.sta=floor((base.stats.sta+mdf.mining).*(1+(mdf.TbtL./40)).*mdf.BoK.*mdf.plate)+ ...
    floor((gear.sta+mdf.PWF+extra.sta+consum.sta).*(1+(mdf.TbtL./40)).*mdf.BoK.*mdf.plate);
player.agi=floor(base.stats.agi.*mdf.BoK)+floor((gear.agi+mdf.SoE+extra.agi+consum.agi).*mdf.BoK);
player.int=floor(base.stats.int.*mdf.BoK)+floor((gear.int+extra.int+consum.int).*mdf.BoK);
% player.spi=floor(base.stats.spi.*mdf.BoK)+floor((gear.spi+extra.spi).*mdf.BoK);

%armory strength
player.armorystr=base.stats.str+gear.str+extra.str; %TODO fix/delete

%hit points
player.hitpoints=base.health.*(1+0.05.*(strcmpi('Tauren',base.race)||strcmpi('Taur',base.race))) ...
    +10.*(player.sta-18)+gear.health+consum.health;

%armor and physical damage reduction
player.armor=gear.barmor.*mdf.Tough.*mdf.ameta ...
    +gear.earmor+mdf.Devo+consum.earmor;
player.armor_c=2167.5*npc.lvl-158167.5; %85
player.armor_c=467.5*npc.lvl-22167.5;
player.phdr=min([player.armor./(player.armor+player.armor_c);0.75]);

%resistance and spell damage reduction
player.resistance=0; %TODO : fix it (buff etc.)
player.resist_c=400;
player.spdr=player.resistance./(player.resistance+player.resist_c);


%% Hit Rating
player.phhit=(gear.hit+extra.hit+consum.hit)./cnv.hit_phhit ...
    +(strcmpi('Draenei',base.race)||strcmpi('Drae',base.race));
player.sphit=(gear.hit+extra.hit+consum.hit)./cnv.hit_sphit+mdf.TbtL ...
    +(strcmpi('Draenei',base.race)||strcmpi('Drae',base.race));


%% Expertise
if ((strcmpi('Human',base.race)||strcmpi('Hum',base.race)) ...
        &&(strcmp(egs(15).wtype,'swo')||strcmp(egs(15).wtype,'mac')))
        base.exp=3;
elseif ((strcmpi('Dwarf',base.race)||strcmpi('Dwa',base.race)) ...
        &&strcmp(egs(15).wtype,'mac'))
        base.exp=3;
end

player.exp=base.exp+((gear.exp+extra.exp+consum.exp)./cnv.exp_exp)+mdf.glyphSoT;

%% Haste 
player.phhaste=100.*( ...
    (1 + (gear.haste+extra.haste+consum.haste)./cnv.haste_phhaste./100).* ...
    (1+mdf.JotP.*(isempty(exec.seal)==0)).*mdf.WF ...
    -1);
player.sphaste=100.*(...
    (1+(gear.haste+extra.haste+consum.haste)./cnv.haste_sphaste./100).* ...
    (1+mdf.JotP.*(isempty(exec.seal)==0)).*mdf.WoA ...
    -1);
player.effhaste=100.*( ...
    (1 + (gear.haste+extra.haste+consum.haste)./cnv.haste_phhaste./100) ...
    .*(1+mdf.JotP.*(isempty(exec.seal)==0)) ...
    -1); %"true" physical haste, lowering the GCD
player.phgcd=max([1.5./(1+player.effhaste./100);ones(size(player.effhaste))]);
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
player.phcrit=base.phcrit + ...                                            %base physical crit
    player.agi./cnv.agi_phcrit + ...                                       %AGI
    (gear.crit+mdf.skinning+extra.crit+consum.crit)./cnv.crit_phcrit + ... %crit rating
    mdf.LotP ...                                                           %buffs
    -npc.phcritsupp;                                                       %crit suppression

%spell abilities ("spell crit")
player.spcrit=base.spcrit + ...                                            %base spell crit
    player.int./cnv.int_spcrit + ...                                       %INT
    (gear.crit+mdf.skinning+extra.crit+consum.crit)./cnv.crit_spcrit + ... %crit rating
    mdf.LotP+mdf.ISB+mdf.Focus ...                                         %buffs
    -npc.spcritsupp;                                                       %crit suppression

%regular melee attacks (one-roll system)
%this gets modified again after boss stats to enforce crit cap
player.aacrit=base.phcrit + ...                                            %base physical crit
    player.agi./cnv.agi_phcrit + ...                                       %AGI
    (gear.crit+mdf.skinning+extra.crit+consum.crit)./cnv.crit_phcrit + ... %crit rating
    mdf.LotP ...                                                           %buffs
    -npc.phcritsupp;                                                       %crit suppression

%explicit crit for non-standard abilities
player.HWcrit=player.spcrit+mdf.WotL.*100;       %WotL
player.HoWcrit=player.phcrit+mdf.WotL.*100;      %WotL
player.CScrit=player.phcrit+mdf.RoL+mdf.glyphCS; %RoL, glyph
player.Jcrit=player.phcrit+mdf.AotL;             %AotL
player.WoGcrit=player.spcrit+mdf.RoL;            %RoL
player.HotRphcrit=player.phcrit+mdf.RoL;         %RoL /TODO check
player.HotRspcrit=player.spcrit+mdf.RoL;         %RoL /TODO check

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
player.HotRphcrit=max([min([player.HotRphcrit;100.*ones(size(player.HotRphcrit))]); ...
    zeros(size(player.HotRphcrit))]);
player.HotRspcrit=max([min([player.HotRspcrit;100.*ones(size(player.HotRspcrit))]); ...
    zeros(size(player.HotRspcrit))]);


%Crit modifier values
mdf.phcrit=1+(mdf.phcritmulti-1).*player.phcrit./100;
mdf.spcrit=1+(mdf.spcritmulti-1).*player.spcrit./100;

mdf.HWcrit=1+(mdf.spcritmulti-1).*player.HWcrit./100;
mdf.HoWcrit=1+(mdf.phcritmulti-1).*player.HoWcrit./100;
mdf.CScrit=1+(mdf.phcritmulti-1).*player.CScrit./100;
mdf.Jcrit=1+(mdf.phcritmulti-1).*player.Jcrit./100;
mdf.WoGcrit=1+(mdf.spcritmulti-1).*player.WoGcrit./100;
mdf.HotRphcrit=1+(mdf.phcritmulti-1).*player.HotRphcrit./100;
mdf.HotRspcrit=1+(mdf.spcritmulti-1).*player.HotRspcrit./100;

%% SP and AP
%AP gets computed later on, in the Vengeance subsection
player.sp=floor((gear.sp+extra.sp+consum.sp+floor(player.str.*(mdf.TbtL./10)) ...
    +(player.int-10).*cnv.int_sp).*max([mdf.FMT;mdf.TW])); %TODO : check it
%for future use in case our spellpower and "holy spell power" are both
%relevant.  hsp is what we get from TbtL, and only affects damage.  We're
%back to the old 2.x "spell power" and "healing power" modle, it seems.
player.hsp=player.sp;  

%% Mastery
player.mast=base.mast+((gear.mast+extra.mas+consum.mast)./cnv.mast_mast);

%% Avoidance and Blocking
%TODO: update avoid_dr
avoiddr=avoid_dr(base,gear.dodge+consum.dodge,gear.parry+consum.parry ...
    +floor((player.str-base.stats.str)./4),player.agi-base.stats.agi); %DR for dodge/parry

player.miss=base.miss-0.04.*npc.skillgap;
player.dodge=base.dodge+base.stats.agi./cnv.agi_dodge+avoiddr.dodgedr-0.04.*npc.skillgap;
player.parry=base.parry+avoiddr.parrydr-0.04.*npc.skillgap;

%at the moment, we don't have Redoubt to worry about, so we shouldnt' need
%dynamic effects for block chance (hopefully?)
player.block=base.block+mdf.HolySh+2.*player.mast-0.04.*npc.skillgap; %TODO : fix HS

%check for bounding issues, based on the attack table
player.miss=max([player.miss;zeros(size(player.miss))]);
player.dodge=max([player.dodge;zeros(size(player.dodge))]);
player.parry=max([player.parry;zeros(size(player.parry))]);
player.block=max([player.block;zeros(size(player.block))]);

player.size.av=max([size(player.miss);size(player.parry);size(player.dodge);size(player.block)]);
player.dodge=min([player.dodge.*ones(player.size.av); ...
    (100-player.miss).*ones(player.size.av)]);
player.parry=min([player.parry.*ones(player.size.av); ...
    (100-player.miss-player.dodge).*ones(player.size.av)]);
player.block=min([player.block.*ones(player.size.av); ...
    (100-player.miss-player.dodge-player.parry).*ones(player.size.av)]);

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

target.swing=npc.swing.*(1+mdf.JotJ.*(isempty(exec.seal)==0));

target.miss=max([(npc.phmiss-player.phhit);zeros(size(player.phhit))]);
target.dodge=max([(npc.dodge-0.25.*player.exp);zeros(size(player.exp))]);
target.parry=max([(npc.parry.*(exec.behind==0)-0.25.*player.exp);zeros(size(player.exp))]);
target.avoid=target.miss+target.dodge+target.parry;
target.block=npc.block.*npc.blockflag.*(exec.behind==0);

target.spmiss=max([(npc.spmiss-player.sphit);zeros(size(player.sphit))]);
target.resrdx=(100-npc.presist)./100;

%% Armor calcs
%Armor Penetration Constant C
if base.lvl==80
    mdf.boss_acoeff=467.5*base.lvl-22167.5;
elseif base.lvl>80
    mdf.boss_acoeff=2167.5*base.lvl-158167.5; %85
end
%Boss Armor and DR formulas
target.armor=npc.armor.*mdf.Sund.*((290+mdf.ST.*10)./300);
target.phdr=target.armor./(target.armor+mdf.boss_acoeff);

%Vengeance AP correction
% player.VengAP=min([15.*mdf.VengAP.*(npc.out.phys.*(1-player.phdr)./target.swing ...
%     +npc.out.spell.*(1-player.spdr)./npc.cast);0.1.*player.hitpoints]).*exec.timein;
player.VengAP=0.095.*player.hitpoints.*exec.timein; %temporary
player.ap=floor((base.ap+gear.ap+(player.str-10).*cnv.str_ap+extra.ap ...
    +player.VengAP+consum.ap).*mdf.UnRage);

%% Weapon Details
player.wdamage=gear.avgdmg+player.ap./14.*gear.swing; %not normalized (AA, Reck, phys HotR)
player.ndamage=gear.avgdmg+player.ap./14.*2.4; %normalized attacks (hardcoded)
player.swing=gear.swing./mdf.phhaste;
%PHR corrections
phr=phr_model(exec,player.swing,target.swing,player.parry,player.block,talent.Reckoning);
player.reck=phr.reck;   %store ru
player.wswing=phr.phrs; %store st
player.wdps=player.wdamage./player.wswing;
%alternate values during bloodlust-type effects
phr=phr_model(exec,gear.swing./mdf.blphhaste,target.swing,player.parry,player.block,talent.Reckoning);
bl.reck=phr.reck;   %store ru
bl.wswing=phr.phrs; %store st
bl.wdps=player.wdamage./bl.wswing;


%% Other dynamic or inter-dependent corrections 
%Hit & Damage modifier values
mdf.phdmg=mdf.SavCom.*mdf.ArcTac.*(1-target.phdr);
mdf.mehit=1-(target.miss+target.dodge+target.parry)./100;
mdf.rahit=1-target.miss./100;
mdf.spdmg=mdf.CoE.*mdf.ArcTac;
mdf.sphit=1-target.spmiss./100;

%enforce one-roll system for auto-attacks
player.size.hit=max([size(player.phhit);size(player.sphit);size(player.exp)]);
player.aacrit=max([min([player.aacrit.*ones(player.size.hit); ...
    (100-target.avoid-npc.glance-target.block)]);zeros(player.size.hit)]);
mdf.glancerdx=1-npc.glancerdx./100;
mdf.blockrdx=0.7;
mdf.aamodel=(mdf.mehit) ...                   %hit
    +(mdf.glancerdx-1).*npc.glance./100 ...   %glancing
    +(mdf.blockrdx-1).*target.block./100 ...  %block
    +(mdf.phcritmulti-1).*player.aacrit./100; %crit
%enforce block events for two-roll systems (no critical blocks)
mdf.memodel=mdf.mehit-target.block./100;
mdf.ramodel=mdf.rahit-target.block./100;
mdf.blockmodel=mdf.blockrdx.*target.block./100;

%% PPM-based uptimes
%this section will have to wait until we know which attacks survive, what
%our rotation looks like, and what procs PPM effects.

%% Power Gains
%Low-priority at the moment.