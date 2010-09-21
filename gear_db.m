%% Gear
%This file serves as a master gear database.

%% Contribution from gear
%Item stats and effects are stored in the global databases "idb.iid", respectively "idb.sid".
%Items are referenced by IIDs (as can be found from the wowhead link), effects by SIDs.
%The databases are structure arrays with fields that correspond to the item's stats. The
%fields are initialized by the Sample Item below, which we've assigned an
%item number of 1.  All additional items can be added the way Broken
%Promise is in the section that follows.

%Note that while I've initialized the fields with the sample item, we don't
%need to initialize zero-valued fields in additional items.  If we fail to
%define idb.iid(12345).sta, it defaults to the empty array [].  The equip()
%function that serves as the go-between (or librarian, if you prefer)
%should recognize the empty array as a zero value when loading items into
%the equipped gear set.

%This also means that we can add fields on the fly if we want to.  So if they
%put "awesomeness rating" on item 12345, we wouldn't have to go back and
%define idb.iid(###).awe for every other item.  A simple line like
% idb.iid(12345).awe=9001;
%would create a new field for all items initialized to an empty array [].

%% Invoking Gear and the Equipped Gear Set

%The currently-equipped set is called the Equipped Gear Set, and stored in
%structure egs.  The fields of egs are identical to the fields of idb:
%egs.name       (item name)
%egs.atype      (logical : 1 for plate, 0 for the other armor types)
%egs.wtype      (axe/mac/swo; non-weapons are ignored)
%egs.ilvl       (item level)
%egs.tooldps    (tooltip dps, for referencing only)
%egs.swing      (base swing timer)
%egs.avgdmg 	(average base damage, for more precise calcs)
%egs.str
%egs.sta
%egs.agi
%egs.int
%egs.spi
%egs.hit
%egs.crit
%egs.exp
%egs.haste
%egs.mast       (mastery)
%egs.dodge
%egs.parry
%egs.block      (block rating)
%egs.barmor 	(base AC)
%egs.earmor 	(extra AC)
%egs.health 	(extra HP, mainly for enchants/buffs)
%egs.armormeta  (logical : armor meta gem)
%egs.critmeta   (logical : crit meta gem)
%egs.istier     (logical : [tier10 tier11 tier12 tier13], undefined if not a tier set item)
%egs.isproc     (spell ID of the associated proc, undefined if none)

%However, egs only has 17 slots, corresponding to the 17 relevant slots on
%the paper doll. Ammo (0), Shirt(18), Tabard (19) are ignored.
% HeadSlot          1
% NeckSlot          2
% ShoulderSlot      3
% BackSlot          4
% ChestSlot         5
% WristSlot         6
% HandsSlot         7
% WaistSlot         8
% LegsSlot          9
% FeetSlot          10
% Finger0Slot       11
% Finger1Slot       12
% Trinket0Slot      13
% Trinket1Slot      14
% MainHandSlot      15
% OffHandSlot       16
% RangedSlot        17


%Equipping an item is as simple as invoking the equip() function.  See the
%equip file for details about the syntax, but for a simple example we could
%equip Last Laugh in our main hand with either of the following lines:
% egs(15)=equip('Last Laugh');
% egs(15)=equip(40402);
%Note that the second one will execute much faster (direct reference rather
%than exhaustive search)

%To equip a particular set of items, one can make a gearset file that looks
%like this:
%
%egs(1)=equip('Sanctified Lightsworn Faceguard(Heroic)')
%egs(2)=equip('Bile-Encrusted Medallion')
%egs(3)=equip('Boneguard Commander's Pauldrons(Heroic)')
%
%and so forth.  

%TODO: Come up with a consistent way to handle items with identical names.
%They'll obviously have different item numbers, but the names should also
%be different so that the search function can return the proper stats.  For
%the moment, appending (Heroic) to heroic items will probably suffice, but
%there may be other situations we want to handle.



%% Initialize Item database
clear global idb;  %temporary fix for weird re-initialization issue
global idb
%initialize the substructure arrays
idb.iid=struct('name','Sample Item', ...
               'atype',0, ...
               'wtype','swo', ...
               'ilvl',0, ...
               'tooldps',0, ...
               'swing',2.5, ...
               'avgdmg',0, ...
               'str',0, ...
               'sta',0, ...
               'agi',0, ...
               'int',0, ...
               'spi',0, ...
               'hit',0, ...
               'crit',0, ...
               'exp',0, ...
               'haste',0, ...
               'mast',0, ...
               'sp',0, ...
               'ap',0, ...
               'dodge',0, ...
               'parry',0, ...
               'block',0, ...
               'barmor',0, ...
               'earmor',0, ...
               'health',0, ...
               'armormeta',0, ...
               'critmeta',0, ...
               'istier',0, ...
               'isproc',0);
idb.sid=struct('name','Sample Item', ...
               'atype',0, ...
               'wtype','swo', ...
               'ilvl',0, ...
               'tooldps',0, ...
               'swing',2.5, ...
               'avgdmg',0, ...
               'str',0, ...
               'sta',0, ...
               'agi',0, ...
               'int',0, ...
               'spi',0, ...
               'hit',0, ...
               'crit',0, ...
               'exp',0, ...
               'haste',0, ...
               'mast',0, ...
               'sp',0, ...
               'ap',0, ...
               'dodge',0, ...
               'parry',0, ...
               'block',0, ...
               'barmor',0, ...
               'earmor',0, ...
               'health',0, ...
               'armormeta',0, ...
               'critmeta',0, ...
               'istier',0, ...
               'isproc',0);

%% Begin adding items
%NOTE: Since defense is being removed, I'm just ignoring it.  We'll
%probably purge the database of all lvl 80 items at some point anyhow, so
%having exact stats won't matter too much.  Note that it *will* have an
%effect on any current avoidance calculations though.
        
%% Items
%% T10.277 set
idb.iid(51266).name='Sanctified Lightsworn Faceguard (Heroic)';
idb.iid(51266).atype=1;
idb.iid(51266).ilvl=277;
idb.iid(51266).barmor=2239;
idb.iid(51266).str=183;
idb.iid(51266).sta=243+32+15+12;
idb.iid(51266).agi=0+10;
idb.iid(51266).critmeta=0;
idb.iid(51266).armormeta=1;
idb.iid(51266).dodge=128;
idb.iid(51266).parry=88;
idb.iid(51266).istier=[1 0 0 0];

idb.iid(51265).name='Sanctified Lightsworn Chestguard (Heroic)';
idb.iid(51265).atype=1;
idb.iid(51265).ilvl=277;
idb.iid(51265).barmor=2756;
idb.iid(51265).earmor=3140-idb.iid(51265).barmor;
idb.iid(51265).str=183;
idb.iid(51265).sta=251+30+15+9;
idb.iid(51265).agi=0+10;
idb.iid(51265).dodge=56;
idb.iid(51265).parry=96;
idb.iid(51265).istier=[1 0 0 0];

idb.iid(51267).name='Sanctified Lightsworn Handguards (Heroic)';
idb.iid(51267).atype=1;
idb.iid(51267).ilvl=277;
idb.iid(51267).barmor=1723;
idb.iid(51267).earmor=2051-idb.iid(51265).barmor;
idb.iid(51267).str=103;
idb.iid(51267).sta=192+30;
idb.iid(51267).dodge=68;
idb.iid(51267).hit=69;
idb.iid(51267).istier=[1 0 0 0];

idb.iid(51268).name='Sanctified Lightsworn Legguards (Heroic)';
idb.iid(51268).atype=1;
idb.iid(51268).ilvl=277;
idb.iid(51268).barmor=2412;
idb.iid(51268).str=139;
idb.iid(51268).sta=251+30+30;
idb.iid(51268).dodge=106;
idb.iid(51268).exp=93;
idb.iid(51268).istier=[1 0 0 0];

idb.iid(51269).name='Sanctified Lightsworn Shoulderguards (Heroic)';
idb.iid(51269).atype=1;
idb.iid(51269).ilvl=277;
idb.iid(51269).barmor=2067;
idb.iid(51269).str=136;
idb.iid(51269).sta=192+30;
idb.iid(51269).dodge=99;
idb.iid(51269).parry=71;
idb.iid(51269).istier=[1 0 0 0];

%% Neck 
idb.iid(50682).name='Bile-Encrusted Medallion (Heroic)';
idb.iid(50682).ilvl=277;
idb.iid(50682).earmor=216;
idb.iid(50682).str=102;
idb.iid(50682).sta=141+30;
idb.iid(50682).dodge=73;

%% Cloaks
idb.iid(50466).name='Sentinel''s Winter Cloak';
idb.iid(50466).ilvl=264;
idb.iid(50466).barmor=556;
idb.iid(50466).earmor=716-idb.iid(50466).barmor;
idb.iid(50466).str=90;
idb.iid(50466).sta=124+30;
idb.iid(50466).dodge=72;

%% Bracers
idb.iid(51901).name='Gargoyle Spit Bracers (Heroic)';
idb.iid(51901).atype=1;
idb.iid(51901).ilvl=264;
idb.iid(51901).barmor=1156;
idb.iid(51901).earmor=1360-idb.iid(51901).barmor;
idb.iid(51901).str=82;
idb.iid(51901).sta=124+30;
idb.iid(51901).dodge=68;


%% Belts
idb.iid(50991).name='Verdigris Chain Belt';
idb.iid(50991).atype=1;
idb.iid(50991).ilvl=264;
idb.iid(50991).barmor=1486;
idb.iid(50991).earmor=1674-idb.iid(50991).barmor;
idb.iid(50991).str=120;
idb.iid(50991).sta=157+15+30+30+9;
idb.iid(50991).agi=0+10;
idb.iid(50991).parry=95;

%% Boots
idb.iid(50625).name='Grinning Skull Greatboots (Heroic)';
idb.iid(50625).atype=1;
idb.iid(50625).ilvl=277;
idb.iid(50625).barmor=1895;
idb.iid(50625).str=103;
idb.iid(50625).sta=180+30+30;
idb.iid(50625).dodge=127;
idb.iid(50625).exp=61;

%% Rings
idb.iid(50622).name='Devium''s Eternally Cold Ring (Heroic)';
idb.iid(50622).ilvl=277;
idb.iid(50622).earmor=216;
idb.iid(50622).str=102;
idb.iid(50622).sta=141+30;
idb.iid(50622).dodge=73;

idb.iid(50404).name='Ashen Band of Endless Courage';
idb.iid(50404).ilvl=277;
idb.iid(50404).str=68;
idb.iid(50404).sta=130+30;
idb.iid(50404).dodge=84;
idb.iid(50404).hit=55;
idb.iid(50404).earmor=2400.*0.03;

%% Trinkets
idb.iid(50356).name='Corroded Skeleton Key';
idb.iid(50356).ilvl=264;
idb.iid(50356).sta=228;

idb.iid(54571).name='Sindragosa''s Flawless Fang';
idb.iid(54571).ilvl=264;
idb.iid(54571).sta=228;

%% Weapons
idb.iid(50708).name='Last Word (Heroic)';
idb.iid(50708).ilvl=277;
idb.iid(50708).wtype='mac';
idb.iid(50708).tooldps=250.6;
idb.iid(50708).swing=1.8;
idb.iid(50708).avgdmg=(315+587)/2;
idb.iid(50708).sta=94+30;
idb.iid(50708).str=115;
idb.iid(50708).isproc=71873;

%% Shields
idb.iid(50729).name='Icecrown Glacial Wall (Heroic)';
idb.iid(50729).ilvl=277;
idb.iid(50729).barmor=7699;
idb.iid(50729).str=102;
idb.iid(50729).sta=141+30;
idb.iid(50729).dodge=68;
idb.iid(50729).parry=72;

%% Librams
idb.iid(50461).name='Libram of the Eternal Tower';
idb.iid(50461).dodge=219;
idb.iid(50461).isproc=71194;

%% Enchant section - to be written.  
%Enchants work exactly the same way that items do.  There is an idb
%structure that contains all of the relevant enchants, according to the
%spell_id value. Since it has the same form, we can use the same equip()
%function.

%% generic (multiple slots)
idb.sid(78166).name='Heavy Savage Armor Kit';
idb.sid(78166).sta=44;

%% Head
idb.sid(59955).name='Arcanum of the Stalwart Protector';
idb.sid(59955).sta=37;

idb.sid(86931).name='Earthen Ring';
idb.sid(86931).sta=90;
idb.sid(86931).dodge=35;

idb.sid(86932).name='Guardian of Hyjal';
idb.sid(86932).int=60;
idb.sid(86932).crit=35;

idb.sid(86933).name='Dragonmaw/Wildhammer';
idb.sid(86933).str=60;
idb.sid(86933).mast=35;

idb.sid(86934).name='Ramhaken';
idb.sid(86934).agi=60;
idb.sid(86934).haste=35;

%% Shoulder
idb.sid(59941).name='Greater Inscription of the Pinnacle';
idb.sid(59941).dodge=20;

idb.sid(62384).name='Greater Inscription of the Gladiator';
idb.sid(62384).sta=30;

idb.sid(86847).name='Inscription of Unbreakable Quartz';
idb.sid(86847).sta=45;
idb.sid(86847).dodge=20;

idb.sid(86898).name='Inscription of Charged Lodestone';
idb.sid(86898).int=30;
idb.sid(86898).haste=20;

idb.sid(86900).name='Inscription of Jagged Stone';
idb.sid(86900).str=30;
idb.sid(86900).crit=20;

idb.sid(86909).name='Inscription of Shattered Crystal';
idb.sid(86909).agi=30;
idb.sid(86909).mast=20;

idb.sid(86854).name='Greater Inscription of Unbreakable Quartz';
idb.sid(86854).sta=75;
idb.sid(86854).dodge=25;

idb.sid(86899).name='Greater Inscription of Charged Lodestone';
idb.sid(86899).int=50;
idb.sid(86899).haste=25;

idb.sid(86901).name='Greater Inscription of Jagged Stone';
idb.sid(86901).str=50;
idb.sid(86901).crit=25;

idb.sid(86907).name='Greater Inscription of Shattered Crystal';
idb.sid(86907).agi=50;
idb.sid(86907).mast=25;

idb.sid(86375).name='Swiftsteel Inscription';
idb.sid(86375).agi=130;
idb.sid(86375).mast=25;

idb.sid(86401).name='Lionsmane Inscription';
idb.sid(86401).str=130;
idb.sid(86401).crit=25;

idb.sid(86402).name='Inscription of the Earth Prince';
idb.sid(86402).sta=195;
idb.sid(86402).dodge=25;

idb.sid(86403).name='Felfire Inscription';
idb.sid(86403).int=130;
idb.sid(86403).haste=25;

%% Cloak
idb.sid(47672).name='Enchant Cloak - Mighty Armor';
idb.sid(47672).earmor=225;

idb.sid(74234).name='Enchant Cloak - Protection';
idb.sid(74234).earmor=250;

idb.sid(74247).name='Enchant Cloak - Greater Critical Strike';
idb.sid(74247).crit=65;

idb.sid(74240).name='Enchant Cloak - Greater Intellect';
idb.sid(74240).int=50;

%% Chest
idb.sid(47900).name='Enchant Chest - Super Health';
idb.sid(47900).health=275;

idb.sid(74251).name='Enchant Chest - Greater Stamina';
idb.sid(74251).sta=75;

idb.sid(74250).name='Enchant Chest - Peerless Stats';
idb.sid(74250).sta=20;
idb.sid(74250).str=20;
idb.sid(74250).agi=20;
idb.sid(74250).int=20;

%% Wrists
idb.sid(62256).name='Enchant Bracer - Major Stamina';
idb.sid(62256).sta=40;

idb.sid(85007).name='Draconic Embossment - Stamina';
idb.sid(85007).sta=195;

idb.sid(85008).name='Draconic Embossment - Agility';
idb.sid(85008).sta=130;

idb.sid(85009).name='Draconic Embossment - Strength';
idb.sid(85009).sta=130;

idb.sid(85010).name='Draconic Embossment - Intellect';
idb.sid(85010).sta=130;

idb.sid(74229).name='Enchant Bracer - Dodge';
idb.sid(74229).dodge=50;

idb.sid(74232).name='Enchant Bracer - Precision';
idb.sid(74232).hit=50;

idb.sid(74239).name='Enchant Bracer - Greater Expertise';
idb.sid(74239).exp=50;

idb.sid(74248).name='Enchant Bracer - Greater Critical Strike';
idb.sid(74248).crit=65;

idb.sid(74256).name='Enchant Bracer - Greater Speed';
idb.sid(74256).haste=65;

%% Hands
idb.sid(50909).name='Heavy Borean Armor Kit';
idb.sid(50909).sta=18;

idb.sid(74254).name='Enchant Gloves - Mighty Strength';
idb.sid(74254).str=50;

idb.sid(74255).name='Enchant Gloves - Greater Mastery';
idb.sid(74255).mast=65;

idb.sid(74220).name='Enchant Gloves - Greater Expertise';
idb.sid(74220).exp=50;

idb.sid(74198).name='Enchant Gloves - Haste';
idb.sid(74198).haste=50;

idb.sid(82175).name='Synapse Springs';
idb.sid(82175).int=480;
idb.sid(82175).isproc=82174;

idb.sid(82177).name='Quickflip Deflection Plates';
idb.sid(82177).earmor=1500;
idb.sid(82177).isproc=82176;

%% Legs
idb.sid(60581).name='Frosthide Leg Armor';
idb.sid(60581).sta=55;
idb.sid(60581).agi=22;

idb.sid(78169).name='Scorched Leg Armor';
idb.sid(78169).ap=110;
idb.sid(78169).crit=45;

idb.sid(78170).name='Twilight Leg Armor';
idb.sid(78170).sta=85;
idb.sid(78170).agi=45;

idb.sid(78171).name='Dragonscale Leg Armor';
idb.sid(78171).ap=190;
idb.sid(78171).crit=55;

idb.sid(78172).name='Charscale Leg Armor';
idb.sid(78172).sta=145;
idb.sid(78172).agi=55;

%% Feet
idb.sid(47901).name='Enchant Boots - Tuskarr''s Vitality';
idb.sid(47901).sta=15;

idb.sid(44528).name='Enchant Boots - Greater Fortitude';
idb.sid(44528).sta=22;

idb.sid(74189).name='Enchant Boots - Earthen Vitality';
idb.sid(74189).sta=30;

idb.sid(74252).name='Enchant Boots - Assassin''s Step';
idb.sid(74252).agi=25;

idb.sid(74253).name='Enchant Boots - Lavawalker';
idb.sid(74253).mast=35;

idb.sid(74213).name='Enchant Boots - Major Agility';
idb.sid(74213).agi=35;

idb.sid(74238).name='Enchant Boots - Mastery';
idb.sid(74238).mast=50;

idb.sid(74236).name='Enchant Boots - Precision';
idb.sid(74236).hit=50;

idb.sid(74199).name='Enchant Boots - Haste';
idb.sid(74199).haste=50;

%% Rings
idb.sid(59636).name='Enchant Ring - Stamina';
idb.sid(59636).sta=30;

idb.sid(74218).name='Enchant Ring - Greater Stamina';
idb.sid(74218).sta=75;

idb.sid(74215).name='Enchant Ring - Strength';
idb.sid(74215).str=50;

idb.sid(74216).name='Enchant Ring - Agility';
idb.sid(74216).agi=50;

idb.sid(74217).name='Enchant Ring - Intellect';
idb.sid(74217).int=50;

%% Weapon
idb.sid(59619).name='Enchant Weapon - Accuracy';
idb.sid(59619).hit=25;
idb.sid(59619).crit=25;

%% Shield
idb.sid(34009).name='Enchant Shield - Major Stamina';
idb.sid(34009).sta=18;

idb.sid(74207).name='Enchant Shield - Protection';
idb.sid(74207).earmor=160;

idb.sid(74226).name='Enchant Shield - Blocking';
idb.sid(74226).block=40;

idb.sid(74235).name='Enchant Shield - Superior Intellect';
idb.sid(74235).int=35;


%% Consumables (invoked by buff_model)
%note that Mixology modifiers (placeholders for now) are stored in .isproc fields
% Flasks
idb.sid(79469).name='Flask of Steelskin';
idb.sid(79469).sta=300;
idb.sid(79469).isproc=1;

idb.sid(79470).name='Flask of the Draconic Mind';
idb.sid(79470).int=300;
idb.sid(79470).isproc=1;

idb.sid(79471).name='Flask of the Winds';
idb.sid(79471).agi=300;
idb.sid(79471).isproc=1;

idb.sid(79472).name='Flask of Titanic Strength';
idb.sid(79472).str=300;
idb.sid(79472).isproc=1;

% Battle Elixirs
idb.sid(79477).name='Elixir of the Cobra';
idb.sid(79477).crit=225;
idb.sid(79477).isproc=1;

idb.sid(79481).name='Impossible Accuracy';
idb.sid(79481).hit=225;
idb.sid(79481).isproc=1;

idb.sid(79632).name='Mighty Speed';
idb.sid(79632).haste=225;
idb.sid(79632).isproc=1;

idb.sid(79635).name='Elixir of the Master';
idb.sid(79635).mast=225;
idb.sid(79635).isproc=1;

% Guardian Elixirs
idb.sid(79474).name='Elixir of the Naga';
idb.sid(79474).exp=225;
idb.sid(79474).isproc=1;

idb.sid(79480).name='Elixir of Deep Earth';
idb.sid(79480).earmor=900;
idb.sid(79480).isproc=1;

% Potions
idb.sid(79475).name='Earthen Potion';
idb.sid(79475).earmor=8750;

idb.sid(79476).name='Volcanic Potion';
idb.sid(79476).int=1250;

idb.sid(79633).name='Tol''vir Agility';
idb.sid(79633).agi=1250;

idb.sid(79634).name='Golem''s Strength';
idb.sid(79634).str=1250;

% Food
idb.sid(87584).name='Beer-Basted Crocolisk';
idb.sid(87584).sta=90;
idb.sid(87584).str=90;

idb.sid(87586).name='Placeholder1';
idb.sid(87586).sta=90;
idb.sid(87586).agi=90;

idb.sid(87587).name='Placeholder2';
idb.sid(87587).sta=90;
idb.sid(87587).int=90;

idb.sid(87594).name='Placeholder3';
idb.sid(87594).sta=90;
idb.sid(87594).mast=90;

idb.sid(87595).name='Grilled Dragon';
idb.sid(79634).sta=90;
idb.sid(79634).hit=90;

idb.sid(87597).name='Baked Rockfish';
idb.sid(87597).sta=90;
idb.sid(87597).crit=90;

idb.sid(87599).name='Basilisk Liverdog';
idb.sid(87599).sta=90;
idb.sid(87599).haste=90;

idb.sid(87601).name='Placeholder4';
idb.sid(87601).sta=90;
idb.sid(87601).dodge=90;

idb.sid(87602).name='Placeholder5';
idb.sid(87602).sta=90;
idb.sid(87602).parry=90;

idb.sid(87637).name='Placeholder6';
idb.sid(87637).sta=90;
idb.sid(87637).exp=90;