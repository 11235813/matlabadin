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
tempegs(1)=equip(58103);  %Helm of the Proud
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel,1);
tempegs(2)=equip(57932); %Lustrous Eye
tempegs(3)=equip(58104);%Sunburnt Pauldrons
tempegs(3)=socket(tempegs(3),gem.blu,0); %red socket, blue gem, no bonus
tempegs(4)=equip(56549); %Twilight Dragonscale
tempegs(4)=socket(tempegs(4),gem.blu,1);
tempegs(5)=equip(58101); %Chestplate of the Steadfast
tempegs(5)=socket(tempegs(5),gem.yel,gem.blu,1);
tempegs(6)=equip(57870); %Alpha Bracers
tempegs(6)=socket(tempegs(6),gem.yel,1);
tempegs(7)=equip(58105); %Numbing Handguards
tempegs(7)=socket(tempegs(7),gem.blu,1);
tempegs(8)=equip(55059); %Hardened Elementium
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,0);
tempegs(9)=equip(58102); %Greaves of Splendor
tempegs(9)=socket(tempegs(9),gem.yel,gem.blu,1);
tempegs(10)=equip(62418); %Boots of Sullen Rock / Gryphon Rider's Boots
tempegs(10)=socket(tempegs(10),gem.yel,1);
tempegs(11)=equip(62440); %Red Rock Band
tempegs(12)=equip(62351); %Felsen's Ring
tempegs(13)=equip(56347); %Leaden Despair
tempegs(14)=equip(56406); %Impetuous Query
tempegs(15)=equip(56346); %Elementium Fang
tempegs(16)=equip(57926); %Shield of hte Four Grey Towers
tempegs(17)=equip(64676); %Relic of Khaz
tempegs(17)=socket(tempegs(17),gem.blu,0);

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
tempegs(36)=equip(74226,'s');%Blocking (mastery)
ddb.gearset{1}=tempegs;

%Progression Raid set
tempegs(1)=equip(60356);  %T11
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel,1);
tempegs(2)=equip(59319); %Ironstar
tempegs(3)=equip(60358); %T11
tempegs(3)=socket(tempegs(3),gem.blu,1);
tempegs(4)=equip(62383); %Great Turtle
tempegs(5)=equip(60354); %T11
tempegs(5)=socket(tempegs(5),gem.red,gem.blu,1);
tempegs(6)=equip(59470); %Impossible Strength
tempegs(7)=equip(60355); %T11
tempegs(7)=socket(tempegs(7),gem.blu,1);
tempegs(8)=equip(55059); %Hardened Elementium
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,0);
tempegs(9)=equip(60357); %T11
tempegs(9)=socket(tempegs(9),gem.red,gem.blu,1);
tempegs(10)=equip(62418); %Boots of Sullen Rock / Gryphon Rider's Boots
tempegs(10)=socket(tempegs(10),gem.yel,1);
tempegs(11)=equip(58187); %Ring of the Battle Anthem
tempegs(12)=equip(59233); %Bile-o-tron Nut
tempegs(13)=equip(59515); %Vial of Stolen Memories
tempegs(14)=equip(62466); %Mirror of Broken Images / Unsolvable Riddle
tempegs(15)=equip(59347); %Mace of Acrid Death
tempegs(16)=equip(67145); %Blockade's Lost Shield
tempegs(17)=equip(64676); %Relic of Khaz
tempegs(17)=socket(tempegs(17),gem.blu,0);

ddb.gearset{2}=tempegs;



%% Talent Specs
%0/31/10 spec for baseline calcs
%http://www.wowhead.com/talent#sZGMhcRddkRucbG
temptree.prot=[3 2 0 0; 2 3 0 0; 0 3 1 2; 2 1 2 0; 1 1 1 1; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 3 0 2];
ddb.talentset{1}=temptree;

%0/31/10 spec w/HG
%http://www.wowhead.com/talent#sZGMhfRddoMucbG
temptree.prot=[3 2 0 0; 2 3 0 0; 2 3 1 2; 2 1 2 0; 1 1 0 0; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 3 0 2];
ddb.talentset{2}=temptree;
% 
% temptree.prot=[3 2 0 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 0 0; 0 2 3 0; 0 1 0 0];
% temptree.ret=[0 3 2 0; 0 0 0 0];
% ddb.talentset{2}=temptree;


%% Glyphs
%standard load-out
tempglyphs.prime=[0 0 1 0 1 1 0];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{1}=tempglyphs;
%no glyphs
tempglyphs.prime=[0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0];
ddb.glyphset{2}=tempglyphs;
%just SoT
tempglyphs.prime=[0 0 0 0 1 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0];
ddb.glyphset{3}=tempglyphs;
%standard load-out with both CS and HotR for prio sims
tempglyphs.prime=[1 0 1 0 1 1 0];
tempglyphs.major=[0 1 0 0 1 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
ddb.glyphset{4}=tempglyphs;