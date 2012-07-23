function [c]=stat_model(c)
%STAT_MODEL recalculates the final stats of the player and target, as well
%as many different modifier (mdf) values.  It's divided into sections
%according to topic.
%
%stat_model takes one input argument "c", which is the configuration
%structure for the simulation.  "c" contains the standard fields (base,
%npc, exec, buff, spec, talent, glyph, egs, gear, extra).  
%
%stat_model returns an updated "c" that contains final player and target 
%stats as well as all necessary modifiers (mdf, consum).


%% Cleanup
%This clears existing mdf, player, and target information (in case we're
%passing a previously-used configuration.

%Remove modifier field
if isfield(c,'mdf'), c=rmfield(c,'mdf'); end;
if isfield(c,'mdf'), c=rmfield(c,'player'); end;
if isfield(c,'mdf'), c=rmfield(c,'target'); end;

%% Make sure gear_stats has run
c.gear=gear_stats(c.egs);
%% Unpack
%this is mostly so I don't have to find/replace every instance of base,
%npc, etc. with c.base, c.npc, and so on.  I may go through and do this
%later anyway, but for now it's a quick workaround that keeps the code a
%little more readable.  These are all local variables that never leave the
%function workspace, so the memory impact should be negligible.  
base=c.base;
npc=c.npc;
exec=c.exec;
buff=c.buff;
spec=c.spec;
talent=c.talent;
glyph=c.glyph;
egs=c.egs;
gear=c.gear;

if isfield(c,'extra')==0
    extra=extra_init;
else
    extra=c.extra;
end

%% seal choice
mdf.tseal=strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal);
mdf.rseal=mdf.tseal||strcmpi('Righteousness',exec.seal)||strcmpi('SoR',exec.seal);

%% Rating/Stat conversions 
stat_conversions

%% Spec
mdf.VengAP=0.05.*spec.Vengeance;
mdf.GbtL=0.05.*spec.GuardedbytheLight; %everything
%TODO: RFury here instead of in buffs?
mdf.GrCr=0.2.*spec.GrandCrusader;
mdf.Sanct=0.10.*spec.Sanctuary; %both effects
mdf.DivineBulwark=1.2.*spec.DivineBulwark;

%% Abilities
mdf.SoI = 0.05.*(strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)); %healing increase

%% Talents
mdf.EternalFlame=1.*talent.EternalFlame; %PH
mdf.UnbreakableSpirit=1.*talent.UnbreakableSpirit; %PH
mdf.HolyAvenger=1.*talent.HolyAvenger; %PH
mdf.SanctifiedWrath=1.*talent.SanctifiedWrath; %PH
mdf.DivinePurpose=1.*talent.DivinePurpose; %PH

%% Glyphs
mdf.glyphAS=0.5.*glyph.AlabasterShield;         %Both effects
mdf.glyphAC=1-0.3*glyph.AsceticCrusader;        %mcost redux
mdf.glyphBH=0;                                  %NYI
mdf.glyphBL=mdf.SoI.*glyph.BlessedLife;         %HPG, 1/20 sec
mdf.glyphDS=0.1.*glyph.DivineStorm;             %passive healing
mdf.glyphDJ=0.1.*glyph.DoubleJeopardy.*(exec.npccount>1); %assume alternating J if possible
mdf.glyphFoL=0;                                 %NYI
mdf.glyphFS=1+0.3.*glyph.FocusedShield;         %AS output
mdf.glyphFW=1-glyph.FocusedWrath;               %Inverse Binary
mdf.glyphHotR=0.1.*glyph.HammeroftheRighteous;  %HotR output
mdf.glyphIT=glyph.ImmediateTruth;               %both effects
mdf.glyphInq=0.9.*glyph.Inquisition;            %both effects
mdf.glyphWoG=1+0.1.*glyph.WordofGlory;          %WoG output

%% Meta Gems, Enchants, Plate Spec, Tier Bonus
%%%%%%%%%%% META
mdf.meta_armor=1+0.02.*(gear.meta==1);
mdf.meta_block=1+0.01.*(gear.meta==2);
mdf.meta_crit=1+0.03.*(gear.meta==3);
mdf.meta_spell=1+0.02.*(gear.meta==4);
mdf.meta_stun=1+0.10.*(gear.meta==5);

mdf.plate=1+0.05.*gear.isplate;
mdf.pvphands=0.05.*gear.pvphands; %CS output
mdf.t11x2P=0.1.*gear.tierbonusP(1); %CS output
mdf.t11x4P=1+0.5.*gear.tierbonusP(2); %GoAK duration
mdf.t12x2P=1+0.2.*gear.tierbonusP(3); %Righteous Flames
mdf.t12x4P=12.*gear.tierbonusP(4); %Fiery Aegis
mdf.t12x2R=1+0.15.*gear.tierbonusR(3); %Flames of the Faithful
mdf.t13x2P=gear.tierbonusP(5); %Judgement bubbles
mdf.t13x2R=gear.tierbonusR(5); %Judgement Hopo

%% Professions
%(passive bonuses, independent of gearing choices)
if ((~isempty(base.prof))&&((~isempty(regexpi(base.prof,'Min'))) ...
        ||(~isempty(regexpi(base.prof,'Mining')))))
    mdf.mining=480;
else
    mdf.mining=0;
end
if ((~isempty(base.prof))&&((~isempty(regexpi(base.prof,'Skin'))) ...
        ||(~isempty(regexpi(base.prof,'Skinning')))))
    mdf.skinning=320;
else
    mdf.skinning=0;
end

%% Raid Buffs
mdf.STA=1+0.1.*buff.STA; %PWF/ComShout/BloodPact
mdf.AP=1+0.2.*buff.AP; %BatShout/TSA/HoW
mdf.SP=1+0.1.*buff.SP; %BurningWrath/DarkIntent/ArcaneBrilliance
mdf.mhaste=1-0.1.*buff.mhaste; % WFury/IcyTalons/HuntParty
mdf.shaste=1+0.05.*buff.shaste; %WoAir/Moonkin/MindQuickening
mdf.crit=5.*buff.crit; %LotP/Rampage/Moonkin/HAT/etc.
mdf.mast=5.*buff.mast; %BoMight/Grace of Air
mdf.stats=1+0.05.*buff.stats; % BoK/MoW/Spider

%other effects
mdf.RFury=1+4.*buff.RFury;
%TODO: Thorns?

%Temporary buffs
mdf.BLust=1+0.3.*buff.BLust;
mdf.AvWr=1+0.2.*buff.AvWr;

%% Raid Debufs
%TODO: convert these to stat-based descriptors (in buff_model as well)
mdf.PhysVuln=1+0.04.*buff.PhysVuln;
mdf.spdmg=1+0.05.*buff.spdmg; %harmful only, healing spells do not benefut from it
mdf.WeakBlow=1-0.1.*buff.WeakBlow;
mdf.WeakArmor=1-0.12.*buff.WeakArmor;
mdf.SThrow=1-0.2.*buff.SThrow;

%% Consumables
%TODO: update for MoP items/profs
%apply Mixology bonus
if ((~isempty(base.prof))&&((~isempty(regexpi(base.prof,'Alch'))) ...
        ||(~isempty(regexpi(base.prof,'Alchemy')))))
switch buff.flask.name
    case 'Flask of Steelskin'
        mdf.mixo(1)=570./450;
    case {'Flask of Titanic Strength','Flask of the Winds','Flask of the Draconic Mind'}
        mdf.mixo(1)=380./300;
    otherwise
        mdf.mixo(1)=1;
end
switch buff.belixir.name
    case {'Elixir of the Cobra','Elixir of Impossible Accuracy','Elixir of the Master'}
        mdf.mixo(2)=265./225;
    otherwise
        mdf.mixo(2)=1;
end
switch buff.gelixir.name
    case 'Elixir of Deep Earth'
        mdf.mixo(3)=1020./900;
    case 'Elixir of the Naga'
        mdf.mixo(3)=265./225;
    otherwise
        mdf.mixo(3)=1;
end
else
    mdf.mixo=ones(1,3);
end
%get stats
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

%support for healing abilities
mdf.hthreat=0.5;

%% Extras
%this section is a way to incorporate extra amounts of different stats to
%compare itemization benefits
%extra is a struct array with fields shown below.  The "extra.val.x" and
%"extra.itm.x" contain the contributions to stat x in terms of raw stats
%(val) and ipoints (itm)
%the ipoint conversion factors are defined in stat_conversions
extra.str=  extra.itm.str.*ipconv.str       + extra.val.str;
extra.sta=  extra.itm.sta.*ipconv.sta       + extra.val.sta;
extra.agi=  extra.itm.agi.*ipconv.agi       + extra.val.agi;
extra.int=  extra.itm.int.*ipconv.int       + extra.val.int;
extra.hit=  extra.itm.hit.*ipconv.hit       + extra.val.hit;
extra.crit= extra.itm.crit.*ipconv.crit     + extra.val.crit;
extra.exp=  extra.itm.exp.*ipconv.exp       + extra.val.exp;
extra.ap=   extra.itm.ap.*ipconv.ap         + extra.val.ap;
extra.sp=   extra.itm.sp.*ipconv.sp         + extra.val.sp;
extra.haste=extra.itm.haste.*ipconv.haste   + extra.val.haste;
extra.mas=  extra.itm.mas.*ipconv.mas       + extra.val.mas;
extra.dodge=extra.itm.dodge.*ipconv.dodge   + extra.val.dodge;
extra.parry=extra.itm.parry.*ipconv.parry   + extra.val.parry;

%% Primary stats
player.str=floor(base.stats.str.*mdf.stats)+floor((gear.str+extra.str+consum.str).*mdf.stats);
player.sta=floor((base.stats.sta+mdf.mining).*(1+3.*mdf.GbtL).*mdf.stats.*mdf.plate.*mdf.STA)+ ...
    floor((gear.sta+extra.sta+consum.sta).*(1+3.*mdf.GbtL).*mdf.stats.*mdf.plate.*mdf.STA);
player.agi=floor(base.stats.agi.*mdf.stats)+floor((gear.agi+extra.agi+consum.agi).*mdf.stats);
player.int=floor(base.stats.int.*mdf.stats)+floor((gear.int+extra.int+consum.int).*mdf.stats);
% player.spi=floor(base.stats.spi.*mdf.stats)+floor((gear.spi+extra.spi).*mdf.stats);

%armory strength
player.armorystr=base.stats.str+gear.str+extra.str; 

%hit points
player.HP=base.health+(14.*player.sta-260)+gear.health+consum.health;

%armor
player.armor=gear.barmor.*(1+mdf.Sanct).*mdf.meta_armor ...
    +gear.earmor+consum.earmor;

%resistance and spell damage reduction
player.spdr=0; %TODO: move this down with phdr?  Account for Sanctuary?

%maximum mana
player.mana=base.mana; %no more int scaling

%% Haste 
player.rating.haste=gear.haste+extra.haste+consum.haste;
player.phhaste=player.rating.haste./cnv.haste_phhaste;
player.sphaste=100.*(...
    (1+player.rating.haste./cnv.haste_sphaste./100).* ...
    mdf.shaste ...
    -1);
player.spgcd=max([1.5./(1+player.sphaste./100);ones(size(player.sphaste))]);

mdf.phhaste=(1+player.phhaste./100);
mdf.sphaste=(1+player.sphaste./100);

%alternate values under Bloodlust-type effects
bl.phhaste=100.*((1+player.phhaste./100).*mdf.BLust-1);
bl.sphaste=100.*((1+player.sphaste./100).*mdf.BLust-1);
bl.spgcd=max([1.5./(1+bl.sphaste./100);ones(size(player.sphaste))]); 

mdf.blphhaste=(1+bl.phhaste./100);
mdf.blsphaste=(1+bl.sphaste./100);

%haste scaling for DoT effects
%refer to http://elitistjerks.com/f73/t110354-resto_cataclysm_release_updated_4_0_6_a/p42/#post1896784
%further testing has shown the use of Gaussian rounding (IEEE 754)
%TODO: The only value used in ability_model is cens.NetTick.  For now I've
%commented out all the unused code.
cens.BaseTick=3;
% cens.BaseDur=15;
player.censTick=round(cens.BaseTick./mdf.sphaste.*1e3)./1e3; %spell haste
% for kkk=1:length(mdf.sphaste)
%     if rem(cens.BaseDur./cens.NetTick(kkk),1)==0.5 && rem(floor(cens.BaseDur./cens.NetTick(kkk)),2)==1
%         cens.NumTicks(kkk)=floor(cens.BaseDur./cens.NetTick(kkk)+0.5);
%     else
%         cens.NumTicks(kkk)=ceil(cens.BaseDur./cens.NetTick(kkk)-0.5);
%     end
% end
% cens.NetDur=cens.NumTicks.*cens.NetTick;


%% Crit
%multipliers
mdf.phcritm=2.*mdf.meta_crit;   %for physical attacks
mdf.spcritm=1.5.*mdf.meta_crit; %for spells
mdf.hcritm=2;                   %the critical healing meta can be safely ignored (4.2 compliance)

%rating
player.rating.crit=gear.crit+mdf.skinning+extra.crit+consum.crit;

%melee abilities ("physical crit")
player.phcrit=base.phcrit + ...                                            %base physical crit
    player.agi./cnv.agi_phcrit + ...                                       %AGI
    (player.rating.crit)./cnv.crit_phcrit + ... %crit rating
    mdf.crit ...                                                           %buffs
    -npc.critsupp;                                                       %crit suppression

%spell abilities ("spell crit")
player.spcrit=base.spcrit + ...                                            %base spell crit
    player.int./cnv.int_spcrit + ...                                       %INT
    (player.rating.crit)./cnv.crit_spcrit + ... %crit rating
    mdf.crit ...                                                           %buffs
    -npc.critsupp;                                                       %crit suppression

%healing abilities ("heal crit")
player.hcrit=player.spcrit+npc.critsupp;

%regular melee attacks (one-roll system)
%this gets modified again after boss stats to enforce crit cap
player.aacrit=base.phcrit + ...                                            %base physical crit
    player.agi./cnv.agi_phcrit + ...                                       %AGI
    (player.rating.crit)./cnv.crit_phcrit + ... %crit rating
    mdf.crit ...                                                           %buffs
    -npc.critsupp;                                                       %crit suppression

%enforce crit caps for two-roll
player.phcrit=max([min([player.phcrit;100.*ones(size(player.phcrit))]); ...
    zeros(size(player.phcrit))]);
player.spcrit=max([min([player.spcrit;100.*ones(size(player.spcrit))]); ...
    zeros(size(player.spcrit))]);
player.hcrit=max([min([player.hcrit;100.*ones(size(player.hcrit))]); ...
    zeros(size(player.hcrit))]);

%Crit modifier values
mdf.phcrit=1+(mdf.phcritm-1).*player.phcrit./100;
mdf.spcrit=1+(mdf.spcritm-1).*player.spcrit./100;
mdf.hcrit=1+(mdf.hcritm-1).*player.hcrit./100;


%% Mastery
player.rating.mast=(gear.mast+extra.mas+consum.mast);
player.mast=base.mast+mdf.mast+(player.rating.mast./cnv.mast_mast);

%% Hit Rating and Expertise
%TODO: check percentages when stats are available
if ((strcmpi('Human',base.race)||strcmpi('Hum',base.race)) ...
        &&(strcmp(egs(15).wtype,'swo')||strcmp(egs(15).wtype,'mac')))
        base.exp=0.75;
elseif ((strcmpi('Dwarf',base.race)||strcmpi('Dwa',base.race)) ...
        &&strcmp(egs(15).wtype,'mac'))
        base.exp=0.75;
end

%player expertise in percent
player.rating.exp=(gear.exp+extra.exp+consum.exp);
player.exp=base.exp+(player.rating.exp./cnv.exp_exp);

player.rating.hit=(gear.hit+extra.hit+consum.hit);
player.mehit=player.rating.hit./cnv.hit_hit ...
    +(strcmpi('Draenei',base.race)||strcmpi('Drae',base.race));

player.sphit=player.rating.hit./cnv.hit_hit ...
    +player.exp ... %TODO: check if this is min(player.exp,7.5) or whether exp over the 7.5% dodge cap still contributes
    +(strcmpi('Draenei',base.race)||strcmpi('Drae',base.race));

%% Avoidance and Blocking
player.rating.dodge=gear.dodge+consum.dodge;
player.rating.parry=gear.parry+consum.parry;

%pre-DR avoidance
player.predr.block=player.mast./cnv.mast_block;
player.predr.dodge=player.rating.dodge./cnv.dodge_dodge;
player.predr.parry=player.rating.parry./cnv.parry_parry ...
                    +floor((player.str-base.stats.str))./cnv.str_parry;                
                
%calculate DR for avoidance and block
avoiddr=avoid_dr(player.predr.dodge, ... %dodge
                 player.predr.parry, ... %parry
                 player.predr.block);    %block
             
player.postdr.block=avoiddr.blockdr;
player.postdr.dodge=avoiddr.dodgedr;
player.postdr.parry=avoiddr.parrydr;

player.miss=base.miss-1.5.*npc.lvlgap;
player.dodge=base.dodge+20.*mdf.Sanct+player.postdr.dodge-1.5.*npc.lvlgap;
player.parry=base.parry+player.postdr.parry-1.5.*npc.lvlgap;
player.block=base.block+200.*mdf.GbtL+player.postdr.block-1.5.*npc.lvlgap;

%check for bounding issues, based on the attack table
player.miss=max([player.miss;zeros(size(player.miss))]);
player.dodge=max([player.dodge;zeros(size(player.dodge))]);
player.parry=max([player.parry;zeros(size(player.parry))]);
player.block=max([player.block;zeros(size(player.block))]);

%Enforce combat table limits (for completeness)
arrsize.av=max([size(player.miss);size(player.parry);size(player.dodge);size(player.block)]);
player.dodge=min([player.dodge.*ones(arrsize.av); ...
    (100-player.miss).*ones(arrsize.av)]);
player.parry=min([player.parry.*ones(arrsize.av); ...
    (100-player.miss-player.dodge).*ones(arrsize.av)]);

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

target.miss=max([(npc.memiss-player.mehit);zeros(size(player.mehit))]);
target.dodge=max([(npc.dodge-player.exp);zeros(size(player.exp))]);
target.parry=max([(npc.parry.*(exec.behind==0)-max([(player.exp-7.5);zeros(size(player.exp))]));zeros(size(player.exp))]);
target.avoid=target.miss+target.dodge+target.parry;
target.block=npc.block.*npc.blockflag.*(exec.behind==0);

target.spmiss=max([(npc.spmiss-player.sphit);zeros(size(player.sphit))]);
target.resrdx=(100-npc.presist)./100;

%% Armor calcs
%armor constant
%TODO: re-check formula
player.acoeff=2167.5*npc.lvl-158167.5;
target.acoeff=2167.5*base.lvl-158167.5;
target.acoeff=46203.33; %FIXME
%damage reduction
player.phdr=min([player.armor./(player.armor+player.acoeff);0.75]);
target.armor=npc.armor.*mdf.WeakArmor.*((290+mdf.SThrow.*10)./300); %fix ST
target.phdr=target.armor./(target.armor+target.acoeff);
%% AP & SP

%Vengeance
player.VengAP=(0.1.*base.health+player.sta).*exec.veng.*exec.timein;

%total melee AP
player.ap=floor((base.ap+gear.ap+(player.str-10).*cnv.str_ap+extra.ap ...
          +player.VengAP+consum.ap).*mdf.AP);

%SP
player.sp=10.*mdf.GbtL.*player.ap;

%% Weapon Details
player.wdamage=gear.avgdmg+player.ap./14.*gear.swing; %not normalized (AA, Reck, phys HotR)
player.ndamage=gear.avgdmg+player.ap./14.*2.4; %normalized attacks (hardcoded)
player.swing=gear.swing.*mdf.mhaste./mdf.phhaste;
%PHR corrections
phr=phr_model(exec,player.swing,npc.swing,player.parry,player.block,0); %TODO: placeholder for deprecated Reckoning talent, modify phr_model inputs
% player.phs=phr.phs;     %store ph %TODO: I think this is redundant now?
player.wswing=phr.phrs; %store st 
player.wdps=player.wdamage./player.wswing;
%alternate values during bloodlust-type effects
phr=phr_model(exec,gear.swing./mdf.blphhaste,npc.swing,player.parry,player.block,0); %TODO: see above
bl.wswing=phr.phrs; %store st
bl.wdps=player.wdamage./bl.wswing;


%% Other dynamic or inter-dependent corrections 
%Hit & Damage modifier values
mdf.phdmg=mdf.PhysVuln.*(1-target.phdr);
mdf.mehit=1-(target.miss+target.dodge+target.parry)./100;
% mdf.rahit=1-target.miss./100;
mdf.sphit=1-target.spmiss./100;

%enforce one-roll system for auto-attacks
arrsize.hit=max([size(player.mehit);size(player.sphit);size(player.exp)]);
player.aacrit=max([min([player.aacrit.*ones(arrsize.hit); ...
    (100-target.avoid-npc.glance)]);zeros(arrsize.hit)]);
%add second roll (blocks), compute the average
mdf.glancerdx=1-npc.glancerdx./100;
mdf.blockrdx=0.7;
mdf.aamodel=(mdf.mehit ...                  %hit
    +(mdf.glancerdx-1).*npc.glance./100 ...  %glancing
    +(mdf.phcritm-1).*player.aacrit./100) ...    %crit
    .*(1+(mdf.blockrdx-1).*target.block./100); ... %block

%enforce block events for three-roll systems
mdf.memodel=mdf.mehit.*(1+(mdf.blockrdx-1).*target.block./100);
% mdf.ramodel=mdf.rahit.*(1+(mdf.blockrdx-1).*target.block./100);

%% PPM-based uptimes
%this section will have to wait until we know which attacks survive, what
%our rotation looks like, and what procs PPM effects.

%% Power Gains
%Low-priority at the moment.  
player.mps=0.06.*base.mana/2;
% mps.Repl=0.01.*player.manapoints./10;

%% Repack
c.player=player;
c.target=target;
c.mdf=mdf;
c.consum=consum;
c.extra=extra;
%TODO: decide whether to repack bloodlust modifiers

%order fields alphabetically
c=orderfields(c);
end