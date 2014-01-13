%DEF_DB is a database of default configurations for gear, talents, glyphs,
%etc.  This is for easy swapping between setups.

global ddb
%% Gem templates
%default gems
tempgems.blu=76639; %solid    (stam)
tempgems.red=76690; %defender (parry/stam)
tempgems.yel=76656; %puissant (mast/stam)
tempgems.pris=76639; %solid
tempgems.meta=76895; %austere (armor)
ddb.gemset{1}=tempgems;

%haste/exp-favoring gems
tempgems.blu=76639; %solid (stam)
tempgems.red=76688; %Guardian (exp/stam)
tempgems.yel=76654; %Forceful (haste/stam)
tempgems.pris=76639; %solid
tempgems.meta=76895; %austere (armor)
ddb.gemset{2}=tempgems;

%% Pre-raid gear sets

%%Starter pre-5-mans, ilvl 450
gem=ddb.gemset{1}; %define gem template
tempegs(1)=equip(82919);  %Masterwork Spiritguard Helm
tempegs(2)=equip(87356); %Badge of the Amber Siege
tempegs(3)=equip(82920); %Masterwork Spiritguard Shoulders
tempegs(4)=equip(87427); %Blade-Dulling Greatcloak
tempegs(5)=equip(82921); %Masterwork Spiritguard Breastplate
tempegs(6)=equip(82924); %Masterwork Spiritguard Bracers
tempegs(7)=equip(82922); %Masterwork Spiritguard Gauntlets
tempegs(8)=equip(82923); %Masterwork Spiritguard Belt
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu);
tempegs(9)=equip(82923); %Masterwork Spiritguard Legplates
tempegs(10)=equip(82925); %Masterwork Spiritguard Boots
tempegs(11)=equip(83796); %Heart of the Earth
tempegs(12)=equip(89525); %Thunderstone Ring
tempegs(13)=equip(85181); %Iron Protector Talisman
tempegs(14)=equip(77530); %Ghost Iron Dragonling
tempegs(15)=equip(81061); %Ook's Hozen Slicer
tempegs(16)=equip(81233); %Impervious Carapace (Heroic)
%%Enchants (21-37)
tempegs(23)=equip(126994,'s'); %Shoulder - Ox Horn Inscription
tempegs(24)=equip(104401,'s'); %Cloak - Greater Protection
tempegs(25)=equip(104397,'s'); %Chest - Superior Stamina
tempegs(26)=equip(104338,'s'); %Wrist - Mastery
tempegs(27)=equip(104420,'s'); %Hands - Superior Mastery
tempegs(29)=equip(124128,'s'); %Legs - Ironscale Leg Armor
tempegs(30)=equip(104414,'s'); %Feet - Pandaren's Step
tempegs(31)=equip(103463,'s'); %Ring - Stamina
tempegs(32)=equip(103463,'s'); %Ring - Stamina
tempegs(35)=equip(104440,'s'); %Weapon - Colossus
tempegs(36)=equip(130758,'s'); %Shield - Greater Parry
ddb.gearset(1)={tempegs};

%%Starter pre-raid, ilvl 463
tempegs(1)=equip(81574); %Helm of Rising Flame
tempegs(1)=socket(tempegs(1),gem.meta,gem.blu);
tempegs(2)=equip(81568); %Armsmaster's Sealed Locket
tempegs(3)=equip(81287); %Spaulders of Immovable Stone
tempegs(3)=socket(tempegs(3),gem.red);
tempegs(4)=equip(81571); %Soulrender Greatcloak
tempegs(5)=equip(81696); %Canine Commander's Breastplate
tempegs(5)=socket(tempegs(5),gem.blu);
tempegs(6)=equip(81065); %Bubble-Breaker Bracers
tempegs(7)=equip(81101); %Gauntlets of Resolute Fury
tempegs(8)=equip(81086); %Sparkbreath Girdle
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu);
tempegs(9)=equip(81270); %Sap-Encrusted Legplates
tempegs(9)=socket(tempegs(9),gem.blu);
tempegs(10)=equip(82852); %Wraithplate Treads
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(81124); %Crystallized Droplet
tempegs(12)=equip(81139); %Lime-Rimmed Signet
tempegs(13)=equip(81243); %Iron Protector's Talisman
tempegs(14)=equip(81181); %Heart of Fire
tempegs(15)=equip(81061); %Ook's Hozen Slicer
tempegs(16)=equip(81096); %Shield of Blind Hate
ddb.gearset(2)={tempegs};

%% T14 gear sets

%%T14 LFR, ilvl 483
tempegs(1)=equip(86661); %White Tiger Faceguard (LFR)
tempegs(1)=socket(tempegs(1),gem.meta,gem.blu);
tempegs(2)=equip(86872); %Kaolan's Withering Necklace (LFR)
tempegs(3)=equip(86659); %White Tiger Shoulderguards (LFR)
tempegs(3)=socket(tempegs(3),gem.blu);
tempegs(4)=equip(86883); %Daybreak Drape (LFR)
tempegs(5)=equip(86663); %White Tiger Chestguard (LFR)
tempegs(5)=socket(tempegs(5),gem.yel,gem.yel);
tempegs(6)=equip(86848); %Serrated Wasp Bracers (LFR)
tempegs(7)=equip(86662); %White Tiger Handguards (LFR)
tempegs(8)=equip(86903); %Protector's Girlde of Endless Spring (LFR)
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu);
tempegs(9)=equip(86660); %White Tiger's Legguards (LFR)
tempegs(9)=socket(tempegs(9),gem.red);
tempegs(10)=equip(86870); %Deepwater Greatboots (LFR)
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(86830); %Ring of the Shattered Shell (LFR)
tempegs(12)=equip(86813); %Vizier's Ruby Signet (LFR)
tempegs(13)=equip(86775); %Jade Warlord Figurine (LFR)
tempegs(14)=equip(86790); %Vial of Dragon's Blood (LFR)
tempegs(15)=equip(86863); %Scimitar of Seven Stars (LFR)
tempegs(15)=socket(tempegs(15),gem.blu);
tempegs(16)=equip(86778); %Steelskin, Qiang's Impervious Shield (LFR)
ddb.gearset(3)={tempegs};

%%T14 Normal, ilvl 496
tempegs(1)=equip(85321); %White Tiger Faceguard
tempegs(1)=socket(tempegs(1),gem.meta,gem.blu);
tempegs(2)=equip(86234); %Kaolan's Withering Necklace 
tempegs(3)=equip(85319); %White Tiger Shoulderguards
tempegs(3)=socket(tempegs(3),gem.blu);
tempegs(4)=equip(86325); %Daybreak Drape 
tempegs(5)=equip(85323); %White Tiger Chestguard 
tempegs(5)=socket(tempegs(5),gem.yel,gem.yel);
tempegs(6)=equip(86190); %Serrated Wasp Bracers 
tempegs(7)=equip(85322); %White Tiger Handguards 
tempegs(8)=equip(86384); %Protector's Girlde of Endless Spring 
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu);
tempegs(9)=equip(85320); %White Tiger's Legguards 
tempegs(9)=socket(tempegs(9),gem.red);
tempegs(10)=equip(86232); %Deepwater Greatboots
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(86172); %Ring of the Shattered Shell 
tempegs(12)=equip(86155); %Vizier's Ruby Signet 
tempegs(13)=equip(86046); %Jade Warlord Figurine 
tempegs(14)=equip(89079); %Lao-Chin's Liquid Courage
tempegs(15)=equip(86219); %Scimitar of Seven Stars 
tempegs(15)=socket(tempegs(15),gem.blu);
tempegs(16)=equip(86075); %Steelskin, Quiang's Impervious Shield
ddb.gearset(4)={tempegs};

%all subsequent sets use the haste gem template
gem=ddb.gemset{2}; %define gem template

%%T14 Heroic, ilvl 509
tempegs(1)=equip(87111); %White Tiger Faceguard (Heroic)
tempegs(1)=reforge(tempegs(1),'parry','haste');
tempegs(1)=socket(tempegs(1),gem.meta,gem.blu);
tempegs(2)=equip(87147); %Shackle of Eversparks (Heroic)
% tempegs(2)=reforge(tempegs(2),'hit','haste');
tempegs(3)=equip(87113); %White Tiger Shoulderguards (Heroic)
tempegs(3)=reforge(tempegs(3),'mast','haste');
tempegs(3)=socket(tempegs(3),gem.blu);
tempegs(4)=equip(86980); %Cloak of Raining Blades (Heroic)
tempegs(4)=reforge(tempegs(4),'dodge','exp');
tempegs(5)=equip(87109); %White Tiger Chestguard (Heroic)
tempegs(5)=reforge(tempegs(5),'parry','exp');
tempegs(5)=socket(tempegs(5),gem.yel,gem.yel);
tempegs(6)=equip(87001); %Serrated Wasp Bracers (Heroic)
tempegs(6)=reforge(tempegs(6),'dodge','haste');
tempegs(7)=equip(87110); %White Tiger Handguards (Heroic)
tempegs(7)=reforge(tempegs(7),'dodge','haste');
tempegs(8)=equip(87185); %Protector's Girlde of Endless Spring (Heroic)
tempegs(8)=reforge(tempegs(8),'dodge','haste');
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu);
tempegs(9)=equip(87112); %White Tiger's Legguards (Heroic)
tempegs(9)=reforge(tempegs(9),'dodge','exp');
tempegs(9)=socket(tempegs(9),gem.red);
tempegs(10)=equip(90507); %Deepwater Greatboots (Heroic)
tempegs(10)=reforge(tempegs(10),'parry','exp');
tempegs(10)=socket(tempegs(10),gem.yel);
tempegs(11)=equip(86968); %Ring of the Shattered Shell (Heroic)
tempegs(11)=reforge(tempegs(11),'dodge','exp');
tempegs(12)=equip(86946); %Vizier's Ruby Signet (Heroic)
tempegs(12)=reforge(tempegs(12),'parry','haste');
tempegs(13)=equip(87083); %Jade Warlord Figurine 
tempegs(14)=equip(89079); %Lao-Chin's Liquid Courage
tempegs(15)=equip(86987); %Scimitar of Seven Stars (Heroic)
tempegs(15)=reforge(tempegs(15),'mast','exp');
tempegs(15)=socket(tempegs(15),gem.blu);
tempegs(16)=equip(87050); %Steelskin, Quiang's Impervious Shield (Heroic)
tempegs(16)=reforge(tempegs(16),'parry','exp');
ddb.gearset(5)={tempegs};

%% T15 gear sets
gem=ddb.gemset{2}; %define gem template

%%Skip T15 RaidFinder, ilvl 502 < 509


%%T15 Normal, ilvl 522
tempegs(1)=equip(95292); %Lightning Emperor's Faceguard
tempegs(1)=reforge(tempegs(1),'mast','haste');
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(95142); %Striker's Battletags
% tempegs(2)=reforge(tempegs(2),'hit','haste');
tempegs(3)=equip(95294); %Lightning Emperor's Shoulderguards
tempegs(3)=reforge(tempegs(3),'mast','haste');
tempegs(3)=socket(tempegs(3),gem.red,gem.yel);
tempegs(4)=equip(95114); %Spikeshard Greatcloak
% tempegs(4)=reforge(tempegs(4),'dodge','exp');
tempegs(5)=equip(95280); %Lightning Emperor's Battleplate (RET)
% tempegs(5)=reforge(tempegs(5),'parry','exp');
tempegs(5)=socket(tempegs(5),gem.red,gem.yel,gem.blu);
tempegs(6)=equip(94742); %Frozen Warlord's Bracers
% tempegs(6)=reforge(tempegs(6),'dodge','haste');
tempegs(7)=equip(95291); %Lightning Emperor's Handguards
tempegs(7)=reforge(tempegs(7),'dodge','haste');
tempegs(8)=equip(94726); %Cloudbreaker Greatbelt
% tempegs(8)=reforge(tempegs(8),'mast','hit');
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu,gem.blu);
tempegs(9)=equip(95293); %Lightning Emperor's Legguards
tempegs(9)=reforge(tempegs(9),'parry','exp');
tempegs(9)=socket(tempegs(9),gem.yel,gem.blu);
tempegs(10)=equip(94265); %Haunted Steel Treads
% tempegs(10)=reforge(tempegs(10),'parry','exp');
tempegs(10)=socket(tempegs(10),gem.red,gem.red);
tempegs(11)=equip(95513); %Band of the Scaled Tyrant
tempegs(11)=reforge(tempegs(11),'hit','exp');
tempegs(11)=socket(tempegs(11),gem.red);
tempegs(12)=equip(95511); %Durumu's Severed Tentacle
tempegs(12)=reforge(tempegs(12),'dodge','haste');
tempegs(13)=equip(94528); %Soul Barrier
tempegs(14)=equip(94516); %Fortitude of the Zandalari
tempegs(14)=reforge(tempegs(14),'mast','haste');
tempegs(15)=equip(95502); %Do-tharak, the Swordbreaker
tempegs(15)=reforge(tempegs(15),'mast','haste');
tempegs(15)=enhance(tempegs(15),equip(93403,'s')); %Eye of the BP
tempegs(15)=socket(tempegs(15),gem.yel,gem.blu);
tempegs(16)=equip(95472); %Ultimate Protection of the Emperor
tempegs(16)=reforge(tempegs(16),'parry','exp');
tempegs(16)=socket(tempegs(16),gem.red);
ddb.gearset(6)={tempegs};

%%T15 Heroic, ilvl 535
clear tempegs
tempegs(1)=equip(96666); %Lightning Emperor's Faceguard (Heroic)
tempegs(1)=reforge(tempegs(1),'mast','haste');
tempegs(1)=socket(tempegs(1),gem.meta,gem.yel);
tempegs(2)=equip(96721); %Necklace of the Terra-Cotta Vanquisher (Heroic)
tempegs(2)=reforge(tempegs(2),'hit','haste');
tempegs(3)=equip(96668); %Lightning Emperor's Shoulderguards (Heroic)
tempegs(3)=reforge(tempegs(3),'hit','haste');
tempegs(3)=socket(tempegs(3),gem.red,gem.yel);
tempegs(4)=equip(96397); %Horn-Rimmed Doomcloak (Heroic)
tempegs(4)=reforge(tempegs(4),'hit','haste');
tempegs(5)=equip(96654); %Lightning Emperor's Battleplate (Heroic) (RET)
tempegs(5)=socket(tempegs(5),gem.red,gem.yel,gem.blu);
tempegs(6)=equip(96394); %Frozen Warlord's Bracers (Heroic)
tempegs(7)=equip(96665); %Lightning Emperor's Handguards (Heroic)
tempegs(7)=reforge(tempegs(7),'dodge','haste');
tempegs(8)=equip(96373); %Cloudbreaker Greatbelt (Heroic)
tempegs(8)=reforge(tempegs(8),'mast','exp');
tempegs(8)=enhance(tempegs(8),equip(90046,'s')); %Belt Buckle
tempegs(8)=socket(tempegs(8),gem.blu,gem.blu,gem.blu);
tempegs(9)=equip(96667); %Lightning Emperor's Legguards (Heroic)
tempegs(9)=reforge(tempegs(9),'hit','haste');
tempegs(9)=socket(tempegs(9),gem.yel,gem.blu);
tempegs(10)=equip(96722); %Locksmahser Greaves (Heroic)
tempegs(10)=reforge(tempegs(10),'hit','exp');
tempegs(11)=equip(96500); %Band of the Scaled Tyrant (Heroic)
tempegs(11)=reforge(tempegs(11),'hit','exp');
tempegs(11)=socket(tempegs(11),gem.red);
tempegs(12)=equip(96481); %Durumu's Severed Tentacle (Heroic)
tempegs(12)=reforge(tempegs(12),'hit','haste');
tempegs(13)=equip(96555); %Soul Barrier (Heroic)
tempegs(14)=equip(96421); %Fortitude of the Zandalari (Heroic)
tempegs(14)=reforge(tempegs(14),'mast','haste');
tempegs(15)=equip(96620); %Do-tharak, the Swordbreaker (Heroic)
tempegs(15)=reforge(tempegs(15),'hit','haste');
tempegs(15)=enhance(tempegs(15),equip(93403,'s')); %Eye of the BP
tempegs(15)=socket(tempegs(15),gem.yel,gem.blu);
tempegs(16)=equip(96554); %Ultimate Protection of the Emperor (Heroic)
tempegs(16)=reforge(tempegs(16),'parry','exp');
tempegs(16)=socket(tempegs(16),gem.red);
ddb.gearset(7)={tempegs};



%% Glyphs
%TODO: convert this to new 3x3 structure, if needed
%standard load-out, HotR / Alabaster Shield / wildcard
tempglyphs=[1 12 0];
ddb.glyphset{1}=tempglyphs;


%% Vengeance
ddb.v1=75;
ddb.v2=150;

ddb.v=[75 150];

clear tempegs tempgems tempglyphs temptree