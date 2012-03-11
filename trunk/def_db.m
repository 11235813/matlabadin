%DEF_DB is a database of default configurations for gear, talents, glyphs,
%etc.  This is for easy swapping between setups.

global ddb
%% Gear Sets

%default gems
tempgems.blu=52242; %solid    (stam)
tempgems.red=52210; %defender (parry/stam)
tempgems.yel=52231; %puissant (mast/stam)
tempgems.pris=52242; %solid
tempgems.meta=52294; %austere (armor)
ddb.gemset{1}=tempgems;


%%Starter pre-raid
gem=ddb.gemset{1}; %define gem template
%TODO: update all gear
tempegs(1)=equip(72842);  %Annihilan Helm
tempegs(1)=socket(tempegs(1),gem.meta,gem.red);
tempegs(2)=equip(70935); %Stoneheart Necklace
tempegs(3)=equip(72861); %Pauldrons of the Dragonblight
tempegs(3)=reforge(tempegs(3),'parry','mast');
tempegs(3)=socket(tempegs(3),gem.blu);
tempegs(4)=equip(72854); %Iceward Cloak
tempegs(5)=equip(72818); %Breastplate of Tarnished Bronze
tempegs(5)=socket(tempegs(5),gem.red,gem.blu);
tempegs(6)=equip(70937); %Bracers of Regal Force
tempegs(6)=reforge(tempegs(6),'dodge','mast');
tempegs(6)=socket(tempegs(6),gem.yel);
tempegs(7)=equip(70949); %Immolation Handguards
tempegs(7)=socket(tempegs(7),gem.red);
tempegs(8)=equip(72803); %Girdle of Lost Heroes
tempegs(8)=enhance(tempegs(8),equip(76168,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.red,gem.yel);
tempegs(9)=equip(70947); %Immolation Legguards
tempegs(9)=socket(tempegs(9),gem.red,gem.blu);
tempegs(10)=equip(72819); %Chrono Boots
tempegs(10)=reforge(tempegs(10),'exp','mast');
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(72837); %Queen's Boon
tempegs(11)=reforge(tempegs(11),'dodge','mast');
tempegs(12)=equip(70940); %Deflecting Brimstone Band
tempegs(13)=equip(72900); %Veil of Lies
tempegs(14)=equip(68996); %Stay of Execution
tempegs(14)=reforge(tempegs(14),'dodge','mast');
tempegs(15)=equip(72827); %Gavel of Peroth'arn
tempegs(16)=equip(72855); %Corrupted Carapace


%% Glyphs
%TODO: convert this to new 3x3 structure, if needed
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