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
%egs.barmor 	(base AC)
%egs.earmor 	(extra AC)
%egs.health 	(extra HP)
%egs.sock       ([#red #yellow #blue #meta], undefined if none)
%egs.istier     (logical : [tier11 tier12 tier13], undefined if not a tier set item)
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
idb.iid=struct('name','Empty Slot', ...
               'atype',0, ...
               'wtype','swo', ...
               'ilvl',0, ...
               'tooldps',0, ...
               'swing',0, ...
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
               'barmor',0, ...
               'earmor',0, ...
               'health',0, ...
               'sock',[0 0 0 0], ...
               'istier',[0 0 0], ...
               'isproc',0);
idb.sid=struct('name','Empty Slot', ...
               'atype',0, ...
               'wtype','swo', ... 
               'ilvl',0, ...
               'tooldps',0, ...
               'swing',0, ...
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
               'barmor',0, ...
               'earmor',0, ...
               'health',0, ...
               'sock',[0 0 0 0], ...
               'istier',[0 0 0], ...
               'isproc',0);
        
%% Items

%% Head


%% Neck 


%% Shoulder


%% Cloaks


%% Chest


%% Bracers


%% Gloves


%% Belts


%% Legs


%% Boots


%% Rings


%% Trinkets


%% Weapons


%% Shields


%% Librams



%% Enchant section  
%Enchants work exactly the same way that items do.  There is an idb
%structure that contains all of the relevant enchants, according to the
%spell_id value. Since it has the same form, we can use the same equip()
%function.
%Note that several entries have the generator's 'name' field, instead
%of the effect's. See the Arcanum entries, for a few examples.

%% generic (multiple slots)
idb.sid(78166).name='Heavy Savage Armor Kit';
idb.sid(78166).sta=44;

%% Head
idb.sid(86931).name='Arcanum of the Earthen Ring';
idb.sid(86931).sta=90;
idb.sid(86931).dodge=35;

idb.sid(86932).name='Arcanum of Hyjal';
idb.sid(86932).int=60;
idb.sid(86932).crit=35;

idb.sid(86933).name='Arcanum of the Dragonmaw/Wildhammer';
idb.sid(86933).str=60;
idb.sid(86933).mast=35;

idb.sid(86934).name='Arcanum of the Ramhaken';
idb.sid(86934).agi=60;
idb.sid(86934).haste=35;

%% Shoulder
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
idb.sid(74234).name='Enchant Cloak - Protection';
idb.sid(74234).earmor=250;

idb.sid(74247).name='Enchant Cloak - Greater Critical Strike';
idb.sid(74247).crit=65;

idb.sid(74240).name='Enchant Cloak - Greater Intellect';
idb.sid(74240).int=50;

%% Chest
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

idb.sid(74195).name='Enchant Weapon - Mending';
idb.sid(74195).isproc=74194;

idb.sid(74211).name='Enchant Weapon - Elemental Slayer';
idb.sid(74211).isproc=74208;

idb.sid(74223).name='Enchant Weapon - Hurricane';
idb.sid(74223).isproc=74221;

idb.sid(74242).name='Enchant Weapon - Power Torrent';
idb.sid(74242).isproc=74241;

idb.sid(74244).name='Enchant Weapon - Windwalk';
idb.sid(74244).isproc=74243;

idb.sid(74246).name='Enchant Weapon - Landslide';
idb.sid(74246).isproc=74245;

%% Shield
idb.sid(34009).name='Enchant Shield - Major Stamina';
idb.sid(34009).sta=18;

idb.sid(74207).name='Enchant Shield - Protection';
idb.sid(74207).earmor=160;

%TODO fix
% idb.sid(74226).name='Enchant Shield - Blocking';
% idb.sid(74226).block=40;

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

idb.sid(79481).name='Elixir of Impossible Accuracy';
idb.sid(79481).hit=225;
idb.sid(79481).isproc=1;

idb.sid(79632).name='Elixir of Mighty Speed';
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

idb.sid(79633).name='Potion of the Tol''vir';
idb.sid(79633).agi=1250;

idb.sid(79634).name='Golemblood Potion';
idb.sid(79634).str=1250;

% Food
idb.sid(87584).name='Beer-Basted Crocolisk';
idb.sid(87584).sta=90;
idb.sid(87584).str=90;

idb.sid(87586).name='Skewered Eel';
idb.sid(87586).sta=90;
idb.sid(87586).agi=90;

idb.sid(87587).name='Severed Sagefish Head';
idb.sid(87587).sta=90;
idb.sid(87587).int=90;

idb.sid(87594).name='Lavascale Minestrone';
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

idb.sid(87601).name='Mushroom Sauce Mudfish';
idb.sid(87601).sta=90;
idb.sid(87601).dodge=90;

idb.sid(87602).name='Blackbelly Sushi';
idb.sid(87602).sta=90;
idb.sid(87602).parry=90;

idb.sid(87637).name='Crocolisk Au Gratin';
idb.sid(87637).sta=90;
idb.sid(87637).exp=90;

%% Gems
% Red
idb.iid(52206).name='Bold Inferno Ruby';
idb.iid(52206).str=40;
idb.iid(52206).sock=[0 1 0 0 1 0];

idb.iid(52212).name='Delicate Inferno Ruby';
idb.iid(52212).agi=40;
idb.iid(52212).sock=[0 1 0 0 1 0];

idb.iid(52216).name='Flashing Inferno Ruby';
idb.iid(52216).parry=40;
idb.iid(52216).sock=[0 1 0 0 1 0];

idb.iid(52230).name='Precise Inferno Ruby';
idb.iid(52230).exp=40;
idb.iid(52230).sock=[0 1 0 0 1 0];

idb.iid(52255).name='Bold Chimera''s Eye';
idb.iid(52255).str=67;
idb.iid(52255).sock=[0 1 0 0 1 0];

idb.iid(52258).name='Delicate Chimera''s Eye';
idb.iid(52258).agi=67;
idb.iid(52258).sock=[0 1 0 0 1 0];

idb.iid(52259).name='Flashing Chimera''s Eye';
idb.iid(52259).parry=67;
idb.iid(52259).sock=[0 1 0 0 1 0];

idb.iid(52260).name='Precise Chimera''s Eye';
idb.iid(52260).exp=67;
idb.iid(52260).sock=[0 1 0 0 1 0];

% Orange
idb.iid(52204).name='Adept Ember Topaz';
idb.iid(52204).agi=20;
idb.iid(52204).mast=20;
idb.iid(52204).sock=[0 1 1 0 1 0];

idb.iid(52215).name='Fine Ember Topaz';
idb.iid(52215).parry=20;
idb.iid(52215).mast=20;
idb.iid(52215).sock=[0 1 1 0 1 0];

idb.iid(52222).name='Inscribed Ember Topaz';
idb.iid(52222).str=20;
idb.iid(52222).crit=20;
idb.iid(52222).sock=[0 1 1 0 1 0];

idb.iid(52224).name='Keen Ember Topaz';
idb.iid(52224).exp=20;
idb.iid(52224).mast=20;
idb.iid(52224).sock=[0 1 1 0 1 0];

idb.iid(52229).name='Polished Ember Topaz';
idb.iid(52229).agi=20;
idb.iid(52229).dodge=20;
idb.iid(52229).sock=[0 1 1 0 1 0];

idb.iid(52240).name='Skillful Ember Topaz';
idb.iid(52240).str=20;
idb.iid(52240).mast=20;
idb.iid(52240).sock=[0 1 1 0 1 0];

idb.iid(52249).name='Resolute Ember Topaz';
idb.iid(52249).exp=20;
idb.iid(52249).dodge=20;
idb.iid(52249).sock=[0 1 1 0 1 0];

% Yellow
idb.iid(52219).name='Fractured Amberjewel';
idb.iid(52219).mast=40;
idb.iid(52219).sock=[0 0 1 0 1 0];

idb.iid(52247).name='Subtle Amberjewel';
idb.iid(52247).dodge=40;
idb.iid(52247).sock=[0 0 1 0 1 0];

idb.iid(52265).name='Subtle Chimera''s Eye';
idb.iid(52265).dodge=67;
idb.iid(52265).sock=[0 0 1 0 1 0];

idb.iid(52269).name='Fractured Chimera''s Eye';
idb.iid(52269).mast=67;
idb.iid(52269).sock=[0 0 1 0 1 0];

% Green
idb.iid(52227).name='Nimble Dream Emerald';
idb.iid(52227).dodge=20;
idb.iid(52227).hit=20;
idb.iid(52227).sock=[0 0 1 1 1 0];

idb.iid(52231).name='Puissant Dream Emerald';
idb.iid(52231).mast=20;
idb.iid(52231).sta=30;
idb.iid(52231).sock=[0 0 1 1 1 0];

idb.iid(52233).name='Regal Dream Emerald';
idb.iid(52233).dodge=20;
idb.iid(52233).sta=30;
idb.iid(52233).sock=[0 0 1 1 1 0];

idb.iid(52237).name='Sensei''s Dream Emerald';
idb.iid(52237).mast=20;
idb.iid(52237).hit=20;
idb.iid(52237).sock=[0 0 1 1 1 0];

% Blue
idb.iid(52235).name='Rigid Ocean Sapphire';
idb.iid(52235).hit=40;
idb.iid(52235).sock=[0 0 0 1 1 0];

idb.iid(52242).name='Solid Ocean Sapphire';
idb.iid(52242).sta=60;
idb.iid(52242).sock=[0 0 0 1 1 0];

idb.iid(52261).name='Solid Chimera''s Eye';
idb.iid(52261).sta=101;
idb.iid(52261).sock=[0 0 0 1 1 0];

idb.iid(52264).name='Rigid Chimera''s Eye';
idb.iid(52264).hit=67;
idb.iid(52264).sock=[0 0 0 1 1 0];

% Purple
idb.iid(52203).name='Accurate Demonseye';
idb.iid(52203).exp=20;
idb.iid(52203).hit=20;
idb.iid(52203).sock=[0 1 0 1 1 0];

idb.iid(52210).name='Defender''s Demonseye';
idb.iid(52210).parry=20;
idb.iid(52210).sta=30;
idb.iid(52210).sock=[0 1 0 1 1 0];

idb.iid(52213).name='Etched Demonseye';
idb.iid(52213).str=20;
idb.iid(52213).hit=20;
idb.iid(52213).sock=[0 1 0 1 1 0];

idb.iid(52220).name='Glinting Demonseye';
idb.iid(52220).agi=20;
idb.iid(52220).hit=20;
idb.iid(52220).sock=[0 1 0 1 1 0];

idb.iid(52221).name='Guardian''s Demonseye';
idb.iid(52221).exp=20;
idb.iid(52221).sta=30;
idb.iid(52221).sock=[0 1 0 1 1 0];

idb.iid(52234).name='Retaliating Demonseye';
idb.iid(52234).parry=20;
idb.iid(52234).hit=20;
idb.iid(52234).sock=[0 1 0 1 1 0];

idb.iid(52238).name='Shifting Demonseye';
idb.iid(52238).agi=20;
idb.iid(52238).sta=30;
idb.iid(52238).sock=[0 1 0 1 1 0];

idb.iid(52243).name='Sovereign Demonseye';
idb.iid(52243).str=20;
idb.iid(52243).sta=30;
idb.iid(52243).sock=[0 1 0 1 1 0];

% Meta
idb.iid(52291).name='Chaotic Shadowspirit Diamond';
idb.iid(52291).crit=54;
idb.iid(52291).isproc=44797;
idb.iid(52291).sock=[1 0 0 0 0 0];

idb.iid(52293).name='Eternal Shadowspirit Diamond';
idb.iid(52293).sta=81;
idb.iid(52293).isproc=55283;
idb.iid(52293).sock=[1 0 0 0 0 0];

idb.iid(52294).name='Austere Shadowspirit Diamond';
idb.iid(52294).sta=81;
idb.iid(52294).isproc=55344;
idb.iid(52294).sock=[1 0 0 0 0 0];

idb.iid(52295).name='Effulgent Shadowspirit Diamond';
idb.iid(52295).sta=81;
idb.iid(52295).isproc=55345;
idb.iid(52295).sock=[1 0 0 0 0 0];

idb.iid(52299).name='Powerful Shadowspirit Diamond';
idb.iid(52299).sta=81;
idb.iid(52299).isproc=55358;
idb.iid(52299).sock=[1 0 0 0 0 0];

% Cogwheel
idb.iid(59477).name='Subtle Cogwheel';
idb.iid(59477).dodge=208;
idb.iid(59477).sock=[0 0 0 0 0 1];

idb.iid(59478).name='Smooth Cogwheel';
idb.iid(59478).crit=208;
idb.iid(59478).sock=[0 0 0 0 0 1];

idb.iid(59480).name='Fractured Cogwheel';
idb.iid(59480).mast=208;
idb.iid(59480).sock=[0 0 0 0 0 1];

idb.iid(59489).name='Precise Cogwheel';
idb.iid(59489).exp=208;
idb.iid(59489).sock=[0 0 0 0 0 1];

idb.iid(59491).name='Flashing Cogwheel';
idb.iid(59491).parry=208;
idb.iid(59491).sock=[0 0 0 0 0 1];

idb.iid(59493).name='Rigid Cogwheel';
idb.iid(59493).hit=208;
idb.iid(59493).sock=[0 0 0 0 0 1];