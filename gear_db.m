%% Gear
%This file serves as a master gear database.

%To generate these entries, use make_gear_db.pl
%at command line, "perl make_gear_db.pl > gear_db_gen.m" and then copy
%entries over

%% Contribution from gear
%Item stats and effects are stored in the global databases "idb.iid", respectively "idb.sid".
%Items are referenced by IIDs (as can be found from the wowhead link), effects by SIDs.
%The databases are structure arrays with fields that correspond to the item's stats. The
%fields are initialized by the Sample Item below, which we've assigned an
%item number of 1.  All additional items can be added the way Broken
%Promise is in the section that follows.


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
%egs.ap
%egs.sp
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
%egs.socket     'XYZ' string that labels sockets, RYBMP are valid chars
%egs.meta       boolean for meta, 0 for no meta, 1/2/3 for ?/?/?
%egs.sbstat     stat string for the socket bonus
%egs.sbval      value of socket bonus
%egs.istierP    (logical : [tier11P tier12P tier13P], undefined if not a tier set item)
%egs.istierR    (logical : [tier11P tier12P tier13P], undefined if not a tier set item)
%egs.isreforged (logical)

%However, egs only has 16 slots, corresponding to the 16 relevant slots on
%the paper doll. Shirt(18), Tabard (19) are ignored.
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
               'ap',0, ...
               'sp',0, ...
               'hit',0, ...
               'crit',0, ...
               'exp',0, ...
               'haste',0, ...
               'mast',0, ...
               'dodge',0, ...
               'parry',0, ...
               'barmor',0, ...
               'earmor',0, ...
               'health',0, ...
               'socket','', ...
               'meta',0, ...
               'sbstat','', ...
               'sbval',0, ...
               'istierP',[0 0 0],...
               'istierR',[0 0 0],...
               'isreforged',0, ...
               'procid',0);
           
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
               'ap',0, ...
               'sp',0, ...
               'hit',0, ...
               'crit',0, ...
               'exp',0, ...
               'haste',0, ...
               'mast',0, ...
               'dodge',0, ...
               'parry',0, ...
               'barmor',0, ...
               'earmor',0, ...
               'health',0, ...
               'socket','', ...
               'meta',0, ...
               'sbstat','', ...
               'sbval',0, ...
               'istierP',[0 0 0],...
               'istierR',[0 0 0],...
               'isreforged',0, ...
               'procid',0);
        
%% Items

%% Head

idb.iid(82919).name='Masterwork Spiritguard Helm';
idb.iid(82919).ilvl=450;
idb.iid(82919).str=797;
idb.iid(82919).sta=1195;
idb.iid(82919).dodge=555;
idb.iid(82919).mast=492;
idb.iid(82919).barmor=3813;
idb.iid(82919).atype=1;
idb.iid(82919).isreforged=0;

%% Neck 

idb.iid(87356).name='Badge of the Amber Siege';
idb.iid(87356).ilvl=450;
idb.iid(87356).str=404;
idb.iid(87356).sta=607;
idb.iid(87356).mast=217;
idb.iid(87356).parry=300;
idb.iid(87356).isreforged=0;

%% Shoulder

idb.iid(82920).name='Masterwork Spiritguard Shoulders';
idb.iid(82920).ilvl=450;
idb.iid(82920).str=592;
idb.iid(82920).sta=888;
idb.iid(82920).mast=346;
idb.iid(82920).parry=423;
idb.iid(82920).barmor=3520;
idb.iid(82920).atype=1;
idb.iid(82920).isreforged=0;
%% Cloaks

idb.iid(87427).name='Blade-Dulling Greatcloak';
idb.iid(87427).ilvl=450;
idb.iid(87427).str=444;
idb.iid(87427).sta=666;
idb.iid(87427).hit=232;
idb.iid(87427).dodge=333;
idb.iid(87427).barmor=970;
idb.iid(87427).isreforged=0;

%% Chest

idb.iid(82921).name='Masterwork Spiritguard Breastplate';
idb.iid(82921).ilvl=450;
idb.iid(82921).str=797;
idb.iid(82921).sta=1195;
idb.iid(82921).mast=539;
idb.iid(82921).dodge=518;
idb.iid(82921).barmor=4693;
idb.iid(82921).atype=1;
idb.iid(82921).isreforged=0;

%% Bracers

idb.iid(82924).name='Masterwork Spiritguard Bracers';
idb.iid(82924).ilvl=450;
idb.iid(82924).str=444;
idb.iid(82924).sta=666;
idb.iid(82924).parry=288;
idb.iid(82924).mast=300;
idb.iid(82924).barmor=2053;
idb.iid(82924).atype=1;
idb.iid(82924).isreforged=0;


%% Gloves

idb.iid(82922).name='Masterwork Spiritguard Gauntlets';
idb.iid(82922).ilvl=450;
idb.iid(82922).str=592;
idb.iid(82922).sta=888;
idb.iid(82922).mast=401;
idb.iid(82922).parry=385;
idb.iid(82922).barmor=2933;
idb.iid(82922).atype=1;
idb.iid(82922).isreforged=0;

%% Belts

idb.iid(82926).name='Masterwork Spiritguard Belt';
idb.iid(82926).ilvl=450;
idb.iid(82926).str=592;
idb.iid(82926).sta=888;
idb.iid(82926).mast=423;
idb.iid(82926).parry=346;
idb.iid(82926).barmor=2640;
idb.iid(82926).atype=1;
idb.iid(82926).isreforged=0;

%% Legs

idb.iid(82923).name='Masterwork Spiritguard Legplates';
idb.iid(82923).ilvl=450;
idb.iid(82923).str=797;
idb.iid(82923).sta=1195;
idb.iid(82923).mast=492;
idb.iid(82923).dodge=555;
idb.iid(82923).barmor=4106;
idb.iid(82923).atype=1;
idb.iid(82923).isreforged=0;


%% Boots

idb.iid(82925).name='Masterwork Spiritguard Boots';
idb.iid(82925).ilvl=450;
idb.iid(82925).str=592;
idb.iid(82925).sta=888;
idb.iid(82925).mast=375;
idb.iid(82925).dodge=406;
idb.iid(82925).barmor=3226;
idb.iid(82925).atype=1;
idb.iid(82925).isreforged=0;

%% Rings

idb.iid(83729).name='Dreadling Signet';
idb.iid(83729).ilvl=450;
idb.iid(83729).str=444;
idb.iid(83729).sta=666;
idb.iid(83729).dodge=300;
idb.iid(83729).mast=288;
idb.iid(83729).isreforged=0;

idb.iid(83730).name='Dreadling Seal';
idb.iid(83730).ilvl=450;
idb.iid(83730).str=444;
idb.iid(83730).sta=666;
idb.iid(83730).mast=326;
idb.iid(83730).exp=246;
idb.iid(83730).isreforged=0;


%% Trinkets

idb.iid(85181).name='Iron Protector Talisman';
idb.iid(85181).ilvl=450;
idb.iid(85181).sta=1126;
idb.iid(85181).dodge=3386/6; %guess at ICD
idb.iid(85181).isreforged=0;

idb.iid(77530).name='Ghost Iron Dragonling';
idb.iid(77530).ilvl=450;
idb.iid(77530).mast=751;
idb.iid(77530).isreforged=0;

%% Weapons - Axes

idb.iid(85567).name='Test Rare Spawn Axe';
idb.iid(55067).wtype='axe';
idb.iid(55067).ilvl=460;
idb.iid(55067).tooldps=2369.5;
idb.iid(55067).swing=2.6;
idb.iid(55067).avgdmg=(8009+4312)/2;
idb.iid(55067).str=375;
idb.iid(55067).sta=562;
idb.iid(55067).mast=250;
idb.iid(55067).haste=250;
idb.iid(55067).isreforged=0;

%% Weapons - Maces

idb.iid(81062).name='Gao''s Keg Tapper';
idb.iid(81062).wtype='mac';
idb.iid(81062).ilvl=463;
idb.iid(81062).tooldps=2436.7;
idb.iid(81062).swing=2.6;
idb.iid(81062).avgdmg=(4434+8236)/2;
idb.iid(81062).sta=578;
idb.iid(81062).agi=385;
idb.iid(81062).mast=279;
idb.iid(81062).hit=219;
idb.iid(81062).isreforged=0;

%% Weapons - Swords

idb.iid(81061).name='Ook''s Hozen Slicer (Heroic)';
idb.iid(81061).wtype='swo';
idb.iid(81061).ilvl=463;
idb.iid(81061).tooldps=2436.7;
idb.iid(81061).swing=2.6;
idb.iid(81061).avgdmg=(4434+8236)/2;
idb.iid(81061).str=385;
idb.iid(81061).sta=578;
idb.iid(81061).mast=219;
idb.iid(81061).exp=279;
idb.iid(81061).isreforged=0;

%% Shields

idb.iid(81233).name='Impervious Carapace (Heroic)';
idb.iid(81233).ilvl=463;
idb.iid(81233).str=381;
idb.iid(81233).sta=752;
idb.iid(81233).hit=254;
idb.iid(81233).parry=501;
idb.iid(81233).barmor=15800;
idb.iid(81233).isreforged=0;

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

idb.sid(86933).name='Arcanum of the Dragonmaw/Wildhammer';
idb.sid(86933).str=60;
idb.sid(86933).mast=35;

%% Shoulder
idb.sid(86847).name='Inscription of Unbreakable Quartz';
idb.sid(86847).sta=45;
idb.sid(86847).dodge=20;

idb.sid(86900).name='Inscription of Jagged Stone';
idb.sid(86900).str=30;
idb.sid(86900).crit=20;

idb.sid(86909).name='Inscription of Shattered Crystal';
idb.sid(86909).agi=30;
idb.sid(86909).mast=20;

idb.sid(86854).name='Greater Inscription of Unbreakable Quartz';
idb.sid(86854).sta=75;
idb.sid(86854).dodge=25;

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

%% Cloak
idb.sid(74234).name='Enchant Cloak - Protection';
idb.sid(74234).earmor=250;

idb.sid(74247).name='Enchant Cloak - Greater Critical Strike';
idb.sid(74247).crit=65;

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

idb.sid(85009).name='Draconic Embossment - Strength';
idb.sid(85009).sta=130;

idb.sid(74229).name='Enchant Bracer - Dodge';
idb.sid(74229).dodge=50;

idb.sid(74232).name='Enchant Bracer - Precision';
idb.sid(74232).hit=50;

idb.sid(74239).name='Enchant Bracer - Greater Expertise';
idb.sid(74239).exp=50;

idb.sid(74248).name='Enchant Bracer - Greater Critical Strike';
idb.sid(74248).crit=65;

idb.sid(96261).name='Enchant Bracer - Major Strength';
idb.sid(96261).str=50;

%% Hands
idb.sid(74254).name='Enchant Gloves - Mighty Strength';
idb.sid(74254).str=50;

idb.sid(74255).name='Enchant Gloves - Greater Mastery';
idb.sid(74255).mast=65;

idb.sid(74220).name='Enchant Gloves - Greater Expertise';
idb.sid(74220).exp=50;

idb.sid(82175).name='Synapse Springs';

idb.sid(82177).name='Quickflip Deflection Plates';

%% Waist
idb.sid(76168).name='Ebonsteel Belt Buckle';
idb.sid(76168).socket='P';

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

idb.sid(101598).name='Drakehide Leg Armor';
idb.sid(101598).sta=145;
idb.sid(101598).dodge=55;

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

%% Rings
idb.sid(74218).name='Enchant Ring - Greater Stamina';
idb.sid(74218).sta=75;

idb.sid(74215).name='Enchant Ring - Strength';
idb.sid(74215).str=50;

%% Weapon
%LK enchants
idb.sid(59619).name='Enchant Weapon - Accuracy';
idb.sid(59619).hit=25;
idb.sid(59619).crit=25;

idb.sid(38995).name='Enchant Weapon - Exceptional Agility';
idb.sid(38995).agi=26;

idb.sid(60621).name='Enchant Weapon - Greater Potency';
idb.sid(60621).ap=50;

idb.sid(27972).name='Enchant Weapon - Potency';
idb.sid(27972).str=20;

idb.sid(41976).name='Titanium Weapon Chain';
idb.sid(41976).hit=28;

idb.sid(55057).name='Pyrium Weapon Chain';
idb.sid(55057).hit=40;


%Cata enchants
idb.sid(74195).name='Enchant Weapon - Mending';
idb.sid(74195).procid=74195;

idb.sid(74211).name='Enchant Weapon - Elemental Slayer';

idb.sid(74223).name='Enchant Weapon - Hurricane';
idb.sid(74223).procid=74223;

idb.sid(74242).name='Enchant Weapon - Power Torrent';
idb.sid(74242).procid=74242;

idb.sid(74244).name='Enchant Weapon - Windwalk';
idb.sid(74244).procid=74244;

idb.sid(74246).name='Enchant Weapon - Landslide';
idb.sid(74246).procid=74246;

idb.sid(74197).name='Enchant Weapon - Avalanche';
idb.sid(74197).procid=74197;

%% Shield
idb.sid(34009).name='Enchant Shield - Major Stamina';
idb.sid(34009).sta=18;

idb.sid(74207).name='Enchant Shield - Protection';
idb.sid(74207).earmor=160;

idb.sid(74226).name='Enchant Shield - Mastery';
idb.sid(74226).mast=50;


%% Consumables (invoked by buff_model)
% Flasks
idb.sid(79469).name='Flask of Steelskin';
idb.sid(79469).sta=450;

idb.sid(79472).name='Flask of Titanic Strength';
idb.sid(79472).str=300;

idb.sid(79471).name='Flask of the Winds';
idb.sid(79471).agi=300;

idb.sid(79470).name='Flask of the Draconic Mind';
idb.sid(79470).int=300;

% Battle Elixirs
idb.sid(79477).name='Elixir of the Cobra';
idb.sid(79477).crit=225;

idb.sid(79481).name='Elixir of Impossible Accuracy';
idb.sid(79481).hit=225;

idb.sid(79635).name='Elixir of the Master';
idb.sid(79635).mast=225;

% Guardian Elixirs
idb.sid(79474).name='Elixir of the Naga';
idb.sid(79474).exp=225;

idb.sid(79480).name='Elixir of Deep Earth';
idb.sid(79480).earmor=900;

% Potions
idb.sid(79475).name='Earthen Potion';
idb.sid(79475).earmor=4800;

idb.sid(79634).name='Golemblood Potion';
idb.sid(79634).str=1200;

% Food
idb.sid(87584).name='Beer-Basted Crocolisk';
idb.sid(87584).sta=90;
idb.sid(87584).str=90;

idb.sid(87594).name='Lavascale Minestrone';
idb.sid(87594).sta=90;
idb.sid(87594).mast=90;

idb.sid(87595).name='Grilled Dragon';
idb.sid(87595).sta=90;
idb.sid(87595).hit=90;

idb.sid(87597).name='Baked Rockfish';
idb.sid(87597).sta=90;
idb.sid(87597).crit=90;

idb.sid(87601).name='Mushroom Sauce Mudfish';
idb.sid(87601).sta=90;
idb.sid(87601).dodge=90;

idb.sid(87602).name='Blackbelly Sushi';
idb.sid(87602).sta=90;
idb.sid(87602).parry=90;

idb.sid(87637).name='Crocolisk Au Gratin';
idb.sid(87637).sta=90;
idb.sid(87637).exp=90;

idb.sid(62665).name='Basilisk Liverdog';
idb.sid(62665).sta=90;
idb.sid(62665).haste=90;

idb.sid(62669).name='Skewered Eel';
idb.sid(62669).sta=90;
idb.sid(62669).agi=90;

%% Gems (nota bene : mixt gems are counted twice, so a green one will be YB)
% Red
idb.iid(52206).name='Bold Inferno Ruby';
idb.iid(52206).str=40;
idb.iid(52206).socket='R';

idb.iid(52212).name='Delicate Inferno Ruby';
idb.iid(52212).agi=40;
idb.iid(52212).socket='R';

idb.iid(52216).name='Flashing Inferno Ruby';
idb.iid(52216).parry=40;
idb.iid(52216).socket='R';

idb.iid(52230).name='Precise Inferno Ruby';
idb.iid(52230).exp=40;
idb.iid(52230).socket='R';

idb.iid(52255).name='Bold Chimera''s Eye';
idb.iid(52255).str=67;
idb.iid(52255).socket='R';

idb.iid(52258).name='Delicate Chimera''s Eye';
idb.iid(52258).agi=67;
idb.iid(52258).socket='R';

idb.iid(52259).name='Flashing Chimera''s Eye';
idb.iid(52259).parry=67;
idb.iid(52259).socket='R';

idb.iid(52260).name='Precise Chimera''s Eye';
idb.iid(52260).exp=67;
idb.iid(52260).socket='R';

idb.iid(71883).name='Bold Queen''s Garnet';
idb.iid(71883).str=50;
idb.iid(71883).socket='R';

idb.iid(71879).name='Delicate Queen''s Garnet';
idb.iid(71879).agi=50;
idb.iid(71879).socket='R';

idb.iid(71882).name='Flashing Queen''s Garnet';
idb.iid(71882).parry=50;
idb.iid(71882).socket='R';

idb.iid(71880).name='Precise Queen''s Garnet';
idb.iid(71880).exp=50;
idb.iid(71880).socket='R';

% Orange
idb.iid(52204).name='Adept Ember Topaz';
idb.iid(52204).agi=20;
idb.iid(52204).mast=20;
idb.iid(52204).socket='RY';

idb.iid(52215).name='Fine Ember Topaz';
idb.iid(52215).parry=20;
idb.iid(52215).mast=20;
idb.iid(52215).socket='RY';

idb.iid(52222).name='Inscribed Ember Topaz';
idb.iid(52222).str=20;
idb.iid(52222).crit=20;
idb.iid(52222).socket='RY';

idb.iid(52224).name='Keen Ember Topaz';
idb.iid(52224).exp=20;
idb.iid(52224).mast=20;
idb.iid(52224).socket='RY';

idb.iid(52229).name='Polished Ember Topaz';
idb.iid(52229).agi=20;
idb.iid(52229).dodge=20;
idb.iid(52229).socket='RY';

idb.iid(52240).name='Skillful Ember Topaz';
idb.iid(52240).str=20;
idb.iid(52240).mast=20;
idb.iid(52240).socket='RY';

idb.iid(52249).name='Resolute Ember Topaz';
idb.iid(52249).exp=20;
idb.iid(52249).dodge=20;
idb.iid(52249).socket='RY';

idb.iid(71841).name='Crafty Lava Coral';
idb.iid(71841).exp=25;
idb.iid(71841).crit=25;
idb.iid(71841).socket='RY';

idb.iid(71855).name='Fine Lava Coral';
idb.iid(71855).parry=25;
idb.iid(71855).mast=25;
idb.iid(71855).socket='RY';

idb.iid(71843).name='Inscribed Lava Coral';
idb.iid(71843).str=25;
idb.iid(71843).crit=25;
idb.iid(71843).socket='RY';

idb.iid(71853).name='Keen Lava Coral';
idb.iid(71853).exp=25;
idb.iid(71853).mast=25;
idb.iid(71853).socket='RY';

idb.iid(71856).name='Skillful Lava Coral';
idb.iid(71856).str=25;
idb.iid(71856).mast=25;
idb.iid(71856).socket='RY';

% Yellow
idb.iid(52219).name='Fractured Amberjewel';
idb.iid(52219).mast=40;
idb.iid(52219).socket='Y';

idb.iid(52247).name='Subtle Amberjewel';
idb.iid(52247).dodge=40;
idb.iid(52247).socket='Y';

idb.iid(52265).name='Subtle Chimera''s Eye';
idb.iid(52265).dodge=67;
idb.iid(52265).socket='Y';

idb.iid(52269).name='Fractured Chimera''s Eye';
idb.iid(52269).mast=67;
idb.iid(52269).socket='Y';

idb.iid(71877).name='Fractured Lightstone';
idb.iid(71877).mast=50;
idb.iid(71877).socket='Y';

% Green
idb.iid(52227).name='Nimble Dream Emerald';
idb.iid(52227).dodge=20;
idb.iid(52227).hit=20;
idb.iid(52227).socket='YB';

idb.iid(52231).name='Puissant Dream Emerald';
idb.iid(52231).mast=20;
idb.iid(52231).sta=30;
idb.iid(52231).socket='YB';

idb.iid(52233).name='Regal Dream Emerald';
idb.iid(52233).dodge=20;
idb.iid(52233).sta=30;
idb.iid(52233).socket='YB';

idb.iid(52237).name='Sensei''s Dream Emerald';
idb.iid(52237).mast=20;
idb.iid(52237).hit=20;
idb.iid(52237).socket='YB';

idb.iid(71838).name='Puissant Elven Peridot';
idb.iid(71838).mast=25;
idb.iid(71838).sta=37;
idb.iid(71838).socket='YB';

idb.iid(71825).name='Sensei''s Elven Peridot';
idb.iid(71825).mast=25;
idb.iid(71825).hit=25;
idb.iid(71825).socket='YB';

% Blue
idb.iid(52235).name='Rigid Ocean Sapphire';
idb.iid(52235).hit=40;
idb.iid(52235).socket='B';

idb.iid(52242).name='Solid Ocean Sapphire';
idb.iid(52242).sta=60;
idb.iid(52242).socket='B';

idb.iid(52261).name='Solid Chimera''s Eye';
idb.iid(52261).sta=101;
idb.iid(52261).socket='B';

idb.iid(52264).name='Rigid Chimera''s Eye';
idb.iid(52264).hit=67;
idb.iid(52264).socket='B';

idb.iid(71817).name='Rigid Deepholm Iolite';
idb.iid(71817).hit=50;
idb.iid(71817).socket='B';

idb.iid(71820).name='Solid Deepholm Iolite';
idb.iid(71820).sta=75;
idb.iid(71820).socket='B';

% Purple
idb.iid(52203).name='Accurate Demonseye';
idb.iid(52203).exp=20;
idb.iid(52203).hit=20;
idb.iid(52203).socket='RB';

idb.iid(52210).name='Defender''s Demonseye';
idb.iid(52210).parry=20;
idb.iid(52210).sta=30;
idb.iid(52210).socket='RB';

idb.iid(52213).name='Etched Demonseye';
idb.iid(52213).str=20;
idb.iid(52213).hit=20;
idb.iid(52213).socket='RB';

idb.iid(52220).name='Glinting Demonseye';
idb.iid(52220).agi=20;
idb.iid(52220).hit=20;
idb.iid(52220).socket='RB';

idb.iid(52221).name='Guardian''s Demonseye';
idb.iid(52221).exp=20;
idb.iid(52221).sta=30;
idb.iid(52221).socket='RB';

idb.iid(52234).name='Retaliating Demonseye';
idb.iid(52234).parry=20;
idb.iid(52234).hit=20;
idb.iid(52234).socket='RB';

idb.iid(52238).name='Shifting Demonseye';
idb.iid(52238).agi=20;
idb.iid(52238).sta=30;
idb.iid(52238).socket='RB';

idb.iid(52243).name='Sovereign Demonseye';
idb.iid(52243).str=20;
idb.iid(52243).sta=30;
idb.iid(52243).socket='RB';

idb.iid(71863).name='Accurate Shadow Spinel';
idb.iid(71863).exp=25;
idb.iid(71863).hit=25;
idb.iid(71863).socket='RB';

idb.iid(71872).name='Defender''s Shadow Spinel';
idb.iid(71872).parry=25;
idb.iid(71872).sta=37;
idb.iid(71872).socket='RB';

idb.iid(71866).name='Etched Shadow Spinel';
idb.iid(71866).str=25;
idb.iid(71866).hit=25;
idb.iid(71866).socket='RB';

% Prismatic /TODO check for lvl85 homologue
idb.iid(49110).name='Nightmare Tear';
idb.iid(49110).str=10;
idb.iid(49110).sta=10;
idb.iid(49110).agi=10;
idb.iid(49110).socket='P';

% Meta
idb.iid(68779).name='Chaotic Shadowspirit Diamond';
idb.iid(68779).str=54;
idb.iid(68779).meta=3;
idb.iid(68779).socket='M';

idb.iid(52293).name='Eternal Shadowspirit Diamond';
idb.iid(52293).sta=81;
idb.iid(52293).meta=2;
idb.iid(52293).socket='M';

idb.iid(52294).name='Austere Shadowspirit Diamond';
idb.iid(52294).sta=81;
idb.iid(52294).meta=1;
idb.iid(52294).socket='M';

idb.iid(52295).name='Effulgent Shadowspirit Diamond';
idb.iid(52295).sta=81;
idb.iid(52295).meta=4;
idb.iid(52295).socket='M';

idb.iid(52299).name='Powerful Shadowspirit Diamond';
idb.iid(52299).sta=81;
idb.iid(52299).meta=5;
idb.iid(52299).socket='M';