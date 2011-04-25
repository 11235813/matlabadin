%DEF_DB is a database of default configurations for gear, talents, glyphs,
%etc.  This is for easy swapping between setups.

%% Gear Sets

%default gems
tempgems.blu=52242;
tempgems.red=52210;
tempgems.yel=52231;
tempgems.pris=52242;
tempgems.meta=52294;
ddb.gemset{1}=tempgems;
gem=tempgems;

%%Starter pre-raid
tempegs(1)=equip(69558);  %Spiritshield Mask
tempegs(1)=socket(tempegs(1),gem.meta,gem.blu);
tempegs(2)=equip(69635); %Amulet of Protection
tempegs(3)=equip(69573); %Pauldrons of Sacrifice
tempegs(3)=socket(tempegs(3),gem.blu);
tempegs(4)=equip(56549); %Twilight Dragonscale Cloak
tempegs(4)=socket(tempegs(4),gem.blu);
tempegs(5)=equip(58101); %Chestplate of the Steadfast
tempegs(5)=socket(tempegs(5),gem.yel,gem.blu);
tempegs(6)=equip(57870); %Alpha Bracers
tempegs(6)=socket(tempegs(6),gem.yel);
tempegs(7)=equip(58105); %Numbing Handguards
tempegs(7)=socket(tempegs(7),gem.blu);
tempegs(8)=equip(55059); %Hardened Elementium Belt
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu);
tempegs(9)=equip(69583); %Legguards of the Unforgiving
tempegs(9)=socket(tempegs(9),gem.blu,gem.blu);
tempegs(10)=equip(62418); %Boots of Sullen Rock / Gryphon Rider's Boots
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(62440); %Red Rock Band
tempegs(12)=equip(62351); %Felsen's Ring
tempegs(13)=equip(56347); %Leaden Despair
tempegs(14)=equip(56406); %Impetuous Query
tempegs(15)=equip(69609); %Bloodlord's Protector
tempegs(16)=equip(69629); %Shield of the Blood God
tempegs(17)=equip(64676); %Relic of Khaz
tempegs(17)=socket(tempegs(17),gem.blu);

%%Enchants (21-37)
tempegs(21)=equip(86931,'s');%Earthen Ring
tempegs(23)=equip(86847,'s');%Unbreakable Quartz
tempegs(24)=equip(74234,'s');%Protection
tempegs(25)=equip(74251,'s');%Greater STamina
tempegs(26)=equip(74229,'s');%Dodge
tempegs(27)=equip(74255,'s');%Greater Mastery
tempegs(29)=equip(78172,'s');%Charscale
tempegs(30)=equip(74238,'s');%Mastery
tempegs(31)=equip(74218,'s');%finger0
tempegs(32)=equip(74218,'s');%finger1
tempegs(35)=equip(74244,'s');%Windwalk?
tempegs(36)=equip(74226,'s');%Mastery
ddb.gearset(1)={tempegs};

%Progression Raid set
tempegs(1)=equip(65226);  %T11H
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(65059); %Ironstar Amulet H
tempegs(3)=equip(65228); %T11H
tempegs(3)=socket(tempegs(3),gem.blu);
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
ddb.gearset(2)={tempegs};


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
%standard load-out with both CS and HotR for prio sims
tempglyphs.prime=[1 0 1 0 1 1 0 0];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{4}=tempglyphs;
%wog load-out with both CS and HotR for prio sims
tempglyphs.prime=[1 0 1 0 0 0 1 1];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{5}=tempglyphs;
%no glyphs
tempglyphs.prime=[0 0 0 0 0 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{6}=tempglyphs;


clear tempegs tempgems tempglyphs temptree