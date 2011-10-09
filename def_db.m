%DEF_DB is a database of default configurations for gear, talents, glyphs,
%etc.  This is for easy swapping between setups.

%% Gear Sets

%default gems
tempgems.blu=52242; %solid    (stam)
tempgems.red=52210; %defender (parry/stam)
tempgems.yel=52231; %puissant (mast/stam)
tempgems.pris=52242; %solid
tempgems.meta=52294; %austere (armor)
ddb.gemset{1}=tempgems;

tempgems.blu=52231; %puissant
tempgems.red=52215; %fine (parry/mast)
tempgems.yel=52219; %fractured (mast)
tempgems.pris=52219; %fractured (mast)
ddb.gemset{2}=tempgems;

gem=ddb.gemset{2};

%%Starter pre-raid
tempegs(1)=equip(69558);  %Spiritshield Mask
tempegs(1)=reforge(tempegs(1),'dodge','mast');
tempegs(1)=socket(tempegs(1),gem.meta,gem.blu);
tempegs(2)=equip(70107); %Fireheart Necklace
tempegs(2)=reforge(tempegs(2),'exp','dodge');
tempegs(3)=equip(69573); %Pauldrons of Sacrifice
tempegs(3)=socket(tempegs(3),gem.red);
tempegs(4)=equip(71270); %Mantle of Patience
tempegs(5)=equip(60354); %T11
tempegs(5)=socket(tempegs(5),gem.red,gem.blu);
tempegs(6)=equip(70121); %Ricket's Gun Show
tempegs(7)=equip(60355); %T11
tempegs(7)=socket(tempegs(7),gem.blu);
tempegs(8)=equip(55059); %Hardened Elementium Belt
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu);
tempegs(9)=equip(69583); %Legguards of the Unforgiving
tempegs(9)=socket(tempegs(9),gem.red,gem.yel);
tempegs(10)=equip(62418); %Boots of Sullen Rock / Gryphon Rider's Boots
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(70127); %Lylagar Horn Ring
tempegs(11)=equip(58187); %Ring of the Battle Anthem
tempegs(13)=equip(56347); %Leaden Despair
tempegs(14)=equip(56406); %Impetuous Query
tempegs(15)=equip(70163); %Unbreakable Guardian
tempegs(16)=equip(69629); %Shield of the Blood God
tempegs(17)=equip(64676); %Relic of Khaz
tempegs(17)=socket(tempegs(17),gem.blu);

%%Enchants (21-37)
tempegs(21)=equip(86931,'s');%Earthen Ring
tempegs(23)=equip(86854,'s');%Greater Unbreakable Quartz
tempegs(24)=equip(74234,'s');%Protection
tempegs(25)=equip(74251,'s');%Greater Stamina
tempegs(26)=equip(74229,'s');%Dodge
tempegs(27)=equip(74255,'s');%Greater Mastery
tempegs(29)=equip(101598,'s');%Drakehide
tempegs(30)=equip(74238,'s');%Mastery
tempegs(31)=equip(74218,'s');%finger0
tempegs(32)=equip(74218,'s');%finger1
tempegs(35)=equip(74244,'s');%Windwalk?
tempegs(36)=equip(74226,'s');%Mastery
ddb.gearset(1)={tempegs};

%T11 Normal Raid set
tempegs(1)=equip(60356);  %T11
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(59319); %Ironstar
tempegs(3)=equip(60358); %T11
tempegs(3)=socket(tempegs(3),gem.red);
tempegs(4)=equip(62383); %Great Turtle
tempegs(5)=equip(60354); %T11
tempegs(5)=socket(tempegs(5),gem.red,gem.blu);
tempegs(6)=equip(59470); %Impossible Strength
tempegs(7)=equip(60355); %T11
tempegs(7)=socket(tempegs(7),gem.blu);
tempegs(8)=equip(55059); %Hardened Elementium
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu);
tempegs(9)=equip(60357); %T11
tempegs(9)=socket(tempegs(9),gem.red,gem.blu);
tempegs(10)=equip(62418); %Boots of Sullen Rock / Gryphon Rider's Boots
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(58187); %Ring of the Battle Anthem
tempegs(12)=equip(59233); %Bile-o-tron Nut
tempegs(13)=equip(59515); %Vial of Stolen Memories
tempegs(14)=equip(62466); %Mirror of Broken Images / Unsolvable Riddle
tempegs(15)=equip(59347); %Mace of Acrid Death
tempegs(16)=equip(67145); %Blockade's Lost Shield
tempegs(17)=equip(64676); %Relic of Khaz
tempegs(17)=socket(tempegs(17),gem.blu);
ddb.gearset(2)={tempegs};

%T11 Heroic Raid set
tempegs(1)=equip(65226);  %T11H
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(65059); %Ironstar Amulet H
tempegs(3)=equip(65228); %T11H
tempegs(3)=socket(tempegs(3),gem.red);
tempegs(4)=equip(62383); %Wrap of the Great Turtle
tempegs(5)=equip(65224); %T11H
tempegs(5)=socket(tempegs(5),gem.red,gem.blu);
tempegs(6)=equip(65143); %Bracers of Impossible Strength H
tempegs(7)=equip(65225); %T11H
tempegs(7)=socket(tempegs(7),gem.blu);
tempegs(8)=equip(65086); %Jumbotron Power Belt H
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.yel,gem.blu);
tempegs(9)=equip(65227); %T11H
tempegs(9)=socket(tempegs(9),gem.red,gem.blu);
tempegs(10)=equip(65051); %Molten Tantrum Boots H
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(58187); %Ring of the Battle Anthem
tempegs(12)=equip(65070); %Bile-o-tron Nut H
tempegs(13)=equip(65109); %Vial of Stolen Memories H
tempegs(14)=equip(62466); %Mirror of Broken Images / Unsolvable Riddle
tempegs(15)=equip(65036); %Mace of Acrid Death H
tempegs(16)=equip(65023); %Akmin-Kurai H
tempegs(17)=equip(64676); %Relic of Khaz
tempegs(17)=socket(tempegs(17),gem.blu);
ddb.gearset(3)={tempegs};


%T12 Normal Raid set
tempegs(1)=equip(70916);  %Helm of Blazing Glory
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(70935); %Stoneheart Necklace
tempegs(3)=equip(70946); %T12
tempegs(3)=reforge(tempegs(3),'hit','dodge');
tempegs(3)=socket(tempegs(3),gem.yel);
tempegs(4)=equip(70930); %Durable Flamewrath Greatcloak
tempegs(4)=reforge(tempegs(4),'hit','mast');
tempegs(5)=equip(70950); %T12
tempegs(5)=reforge(tempegs(5),'dodge','mast');
tempegs(5)=socket(tempegs(5),gem.red,gem.yel);
tempegs(6)=equip(70920); %Bracers of The Fiery Path
tempegs(6)=socket(tempegs(6),gem.blu);
tempegs(7)=equip(70949); %T12
tempegs(7)=socket(tempegs(7),gem.red);
tempegs(8)=equip(71021); %Uncrushable Belt of Fury
tempegs(8)=reforge(tempegs(8),'exp','dodge');
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.yel,gem.blu);
tempegs(9)=equip(70947); %T12
tempegs(9)=socket(tempegs(9),gem.red,gem.blu);
tempegs(10)=equip(69947); %Mirrored Boots
tempegs(10)=socket(tempegs(10),gem.red);
tempegs(11)=equip(71367); %Theck's Emberseal
tempegs(11)=reforge(tempegs(11),'hit','mast');
tempegs(12)=equip(70940); %Deflecting Brimstone Band
tempegs(13)=equip(68915); %Scales of Life
tempegs(14)=equip(68981); %Spidersilk Spindle
tempegs(15)=equip(70922); %Mandible of Beth'tilac
tempegs(16)=equip(70915); %Shard of Torment
tempegs(16)=reforge(tempegs(16),'parry','mast');
tempegs(16)=socket(tempegs(16),gem.blu,gem.blu);
tempegs(17)=equip(70939); %Deathclutch Figurine
tempegs(17)=reforge(tempegs(17),'dodge','mast');
tempegs(17)=socket(tempegs(17),gem.blu);
ddb.gearset(4)={tempegs};

%T12 Heroic Raid set
tempegs(1)=equip(71459);  %Helm of Blazing Glory (H)
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(71589); %Stoneheart Necklace (H)
tempegs(3)=equip(71526); %T12 (H)
tempegs(3)=reforge(tempegs(3),'hit','dodge');
tempegs(3)=socket(tempegs(3),gem.yel);
tempegs(4)=equip(71415);  %Dreadfire Drape (H)
tempegs(4)=reforge(tempegs(4),'hit','dodge');
tempegs(4)=socket(tempegs(4),gem.yel,gem.yel);
tempegs(5)=equip(71522); %T12 (H)
tempegs(5)=reforge(tempegs(5),'dodge','mast');
tempegs(5)=socket(tempegs(5),gem.red,gem.yel);
tempegs(6)=equip(71470); %Bracers of The Fiery Path (H)
tempegs(6)=socket(tempegs(6),gem.blu);
tempegs(7)=equip(71523); %T12 (H)
tempegs(7)=socket(tempegs(7),gem.red);
tempegs(8)=equip(71443);  %Uncrushable Belt of Fury (H)
tempegs(8)=reforge(tempegs(8),'exp','dodge');
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.yel,gem.blu);
tempegs(9)=equip(71525); %T12 (H)
tempegs(9)=socket(tempegs(9),gem.red,gem.blu);
tempegs(10)=equip(71420); %Cracked Obsidian Stompers (H)
tempegs(10)=reforge(tempegs(10),'exp','mast');
tempegs(10)=socket(tempegs(10),gem.blu);
tempegs(11)=equip(70934); %Adamantite Signet of the Avengers
tempegs(11)=reforge(tempegs(11),'hit','mast');
tempegs(11)=socket(tempegs(11),gem.red);
tempegs(12)=equip(71564); %Theck's Emberseal (H)
tempegs(12)=reforge(tempegs(12),'hit','mast');
tempegs(13)=equip(69109); %Scales of Life (H)
tempegs(14)=equip(69138); %Spidersilk Spindle (H)
tempegs(15)=equip(71406); %Mandible of Beth'tilac (H)
tempegs(16)=equip(71460);  %Shard of Torment (H)
tempegs(16)=reforge(tempegs(16),'parry','mast');
tempegs(16)=socket(tempegs(16),gem.blu,gem.blu);
tempegs(17)=equip(71590); %Deathclutch Figurine (H)
tempegs(17)=reforge(tempegs(17),'dodge','mast');
tempegs(17)=socket(tempegs(17),gem.blu);
ddb.gearset(5)={tempegs};



%% Talent Specs
%0/32/9 spec for baseline calcs
%http://www.wowhead.com/talent#sZGMhcRddRRucbu
temptree.prot=[3 2 0 0; 2 3 0 0; 0 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 3 0 1];
ddb.talentset{1}=temptree;

%0/32/9 WoG survivability spec
%http://www.wowhead.com/talent#sZhrhcRddRRucbu
temptree.prot=[3 0 2 0; 2 3 0 0; 0 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 3 0 1];
ddb.talentset{2}=temptree;

%0/33/8 spec w/HG (PoJ+AD->HG)
%http://www.wowhead.com/talent#sZGMhfRddoMucbG
temptree.prot=[3 2 0 0; 2 3 0 0; 2 3 1 2; 2 1 2 0; 1 1 2 0; 0 2 3 0; 0 0 0 0];
temptree.ret=[0 3 2 0; 0 3 0 0];
ddb.talentset{3}=temptree;

%0/33/8 spec to get everything relevant in prot (skip DG, PoJ, HG)
%http://www.wowhead.com/talent#sZGrhcRddRMucbh
temptree.prot=[3 2 2 0; 2 3 0 0; 0 3 1 2; 2 1 2 0; 1 1 2 0; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 3 0 0];
ddb.talentset{4}=temptree;


%% Glyphs
%standard load-out, SoT/SotR/HotR, AS/Cons
tempglyphs.prime=[0 0 1 0 1 1 0 0];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{1}=tempglyphs;
%wog load-out, WoG/SoI/HotR, AS/Cons
tempglyphs.prime=[0 0 1 0 0 0 1 1];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{2}=tempglyphs;
%just SoT
tempglyphs.prime=[0 0 0 0 1 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{3}=tempglyphs;
%standard load-out+CS: SoT/SotR/HotR/CS, AS/Cons (for rot sims)
tempglyphs.prime=[1 0 1 0 1 1 0 0];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{4}=tempglyphs;
%wog load-out+CS: WoG/SoI/HotR/CS, AS/Cons (for rot sims)
tempglyphs.prime=[1 0 1 0 0 0 1 1];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{5}=tempglyphs;
%no glyphs
tempglyphs.prime=[0 0 0 0 0 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{6}=tempglyphs;
%standard load-out+CS-AS: SoT/SotR/HotR/CS, Cons (for aoe sims)
tempglyphs.prime=[1 0 1 0 1 1 0 0];
tempglyphs.major=[0 1 0 0 0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{7}=tempglyphs;


clear tempegs tempgems tempglyphs temptree