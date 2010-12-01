%DEF_DB is a database of default configurations for gear, talents, glyphs,
%etc.  This is for easy swapping between setups.

%% Gear Sets

%%Starter pre-raid
tempegs(1)=equip(58103);  %Helm of the Proud
tempegs(2)=equip(57932); %Lustrous Eye
tempegs(3)=equip(58103);%Sunburnt Pauldrons
tempegs(4)=equip(56549); %Twilight Dragonscale
tempegs(5)=equip(58101); %Chestplate of the Steadfast
tempegs(6)=equip(57870); %Alpha Bracers
tempegs(7)=equip(58105); %Numbing Handguards
tempegs(8)=equip(55059); %Hardened Elementium
tempegs(9)=equip(58102); %Greaves of Splendor
tempegs(10)=equip(62432); %Gryphon Rider's Boots
tempegs(11)=equip(62440); %Red Rock Band
tempegs(12)=equip(62351); %Felsen's Ring
tempegs(13)=equip(56347); %Leaden Despair
tempegs(14)=equip(56406); %Impetuous Query
tempegs(15)=equip(56346); %Elementium Fang
tempegs(16)=equip(57926); %Shield of hte Four Grey Towers
tempegs(17)=equip(64676); %Relic of Khaz
%%Enchants (21-37)
tempegs(21)=equip(86931,'s');%Earthen Ring
% tempegs(22)=equip(2);%neck
tempegs(23)=equip(86847,'s');%Unbreakable Quartz
tempegs(24)=equip(74234,'s');%Protection
tempegs(25)=equip(74251,'s');%Greater STamina
tempegs(26)=equip(74229,'s');%Dodge
tempegs(27)=equip(74255,'s');%Greater Mastery
% tempegs(28)=equip(4);%waist
tempegs(29)=equip(78172,'s');%Charscale
tempegs(30)=equip(74238,'s');%Mastery
tempegs(31)=equip(74218,'s');%finger0
tempegs(32)=equip(74218,'s');%finger1
% tempegs(33)=equip(2);%trinket0
% tempegs(34)=equip(2);%trinket1
tempegs(35)=equip(74244,'s');%Windwalk?
tempegs(36)=equip(34009,'s');%Stamina, for now
% tempegs(37)=equip(4);%ranged
ddb.gearset{1}=tempegs;

%Progression Raid set
tempegs(1)=equip(60356);  %T11
tempegs(2)=equip(59319); %Ironstar
tempegs(3)=equip(60358); %T11
tempegs(4)=equip(62383); %Great Turtle
tempegs(5)=equip(60354); %T11
tempegs(6)=equip(59470); %Impossible Strength
tempegs(7)=equip(60355); %T11
tempegs(8)=equip(55059); %Hardened Elementium
tempegs(9)=equip(60357); %T11
tempegs(10)=equip(62432); %Gryphon Rider's Boots
tempegs(11)=equip(58187); %Ring of the Battle Anthem
tempegs(12)=equip(59233); %Bile-o-tron Nut
tempegs(13)=equip(59515); %Vial of Stolen Memories
tempegs(14)=equip(62468); %Unsolvable Riddle
tempegs(15)=equip(59347); %Mace of Acrid Death
tempegs(16)=equip(67145); %Blockade's Lost Shield
tempegs(17)=equip(64676); %Relic of Khaz

ddb.gearset{2}=tempegs;



%% Talent Specs
%38 points in prot, 0 in holy/ret
temptree.holy=zeros(2,4);temptree.ret=zeros(2,4);temptree.prot=zeros(7,4);
temptree.prot=[3 2 2 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
ddb.talentset{1}=temptree;

temptree.prot=[3 2 0 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 0 0; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 0 0 0];
ddb.talentset{2}=temptree;

%0/31/5 spec for baseline calcs
temptree.prot=[3 2 0 0; 2 3 0 0; 2 3 1 2; 2 1 2 0; 1 1 0 0; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 0 0 0];
ddb.talentset{3}=temptree;


%% Glyphs
tempglyphs.prime=[0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0];
ddb.glyphset{1}=tempglyphs;