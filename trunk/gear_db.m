%% Gear
%This file serves as a master gear database.

%% Contribution from gear
%Item stats are stored in a global database "idb".  Each item is referenced
%by its item number (as can be found from the wowhead link).  The database
%is a structure array with fields that correspond to the item's stats.  The
%fields are initialized by the Sample Item below, which we've assigned an
%item number of 1.  All additional items can be added the way Broken
%Promise is in the section that follows.

%Note that while I've initialized the fields with the sample item, we don't
%need to initialize zero-valued fields in additional items.  If we fail to
%define idb(12345).sta, it defaults to the empty array [].  The equip()
%function that serves as the go-between (or librarian, if you prefer)
%should recognize the empty array as a zero value when loading items into
%the equipped gear set.

%This also means that we can add fields on the fly if we want to.  So if they
%put "awesomeness rating" on item 12345, we wouldn't have to go back and
%define idb(###).awe for every other item.  A simple line like
% idb(12345).awe=9001;
%would create a new field for all items initialized to an empty array [].

%% Invoking Gear and the Equipped Gear Set

%The currently-equipped set is called the Equipped Gear Set, and stored in
%structure egs.  The fields of egs are identical to the fields of idb:
%egs.name       (Item Name)
%egs.wtype      (axe/mac/swo; non-weapons are ignored)
%egs.ilvl       (item level)
%egs.tooldps    (tooltip dps, for referencing only)
%egs.rate       (1/base_swing explicitly)
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
%egs.blrat      (block rating)
%egs.blval      (block value)
%egs.barmor 	(base AC)
%egs.earmor 	(extra AC)
%egs.health 	(extra HP, mainly for enchants/buffs)
%egs.critmeta   (crit meta gem)

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
global idb

%initialize the structure array with a fake item
idb=struct('name','Sample Item', ...
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
            'health',0,...
            'critmeta',0,...
            'armormeta',0);

        
%% Begin adding items

%NOTE: Since defense is being removed, I'm just ignoring it.  We'll
%probably purge the database of all lvl 80 items at some point anyhow, so
%having exact stats won't matter too much.  Note that it *will* have an
%effect on any current avoidance calculations though.
        
%Define a new item - Last Laugh, item number 40402  
idb(40402).name='Last Laugh';
idb(40402).wtype='axe';
idb(40402).ilvl=226;
idb(40402).tooldps=171.6;
idb(40402).swing=1.6;
idb(40402).avgdmg=274.5;
idb(40402).str=37;
idb(40402).sta=73;
idb(40402).parry=34;
idb(40402).hit=24;

%Define a new item - Broken Promise, item number 40345
idb(40345).name='Broken Promise';
idb(40345).wtype='swo';
idb(40345).ilvl=213;
idb(40345).tooldps=156.6;
idb(40345).swing=2.5;
idb(40345).avgdmg=391.5;
idb(40345).str=29;
idb(40345).sta=64;
idb(40345).exp=20;

% %Alternate way of defining items - this is a pain because it causes errors
% %whenever you add or remove fields from idb, which happens often while
% %we're in early development
% %note that doing it this way, we *have* to define every value, otherwise we
% %generate an assignment subscript error.  As such, we probably won't use
% %struct() to generate most items.
% idb(40345)=struct('name','Broken Promise', ...
%             'wtype','swo', ...
%             'ilvl',213, ...
%             'tooldps',156.6, ...
%             'swing',2.5, ...
%             'avgdmg',391.5, ...
%             'str',29, ...
%             'sta',64, ...
%             'agi',0, ...
%             'int',0, ...
%             'spi',0, ...
%             'hit',16, ...
%             'crit',0, ...
%             'exp',20, ...
%             'haste',0, ...
%             'mast',0, ...
%             'dodge',0, ...
%             'parry',0, ...
%             'block',0, ...
%             'barmor',0, ...
%             'earmor',0, ...
%             'health',0,...
%             'critmeta',0);

%% Items
%% T10.277 set
idb(51266).name='Sanctified Lightsworn Faceguard (Heroic)';
idb(51266).ilvl=277;
idb(51266).barmor=2239;
idb(51266).str=183;
idb(51266).sta=243+32+15+12;
idb(51266).agi=0+10;
idb(51266).critmeta=0;
idb(51266).armormeta=1;
idb(51266).dodge=128;
idb(51266).parry=88;

idb(51265).name='Sanctified Lightsworn Chestguard (Heroic)';
idb(51265).ilvl=277;
idb(51265).barmor=2756;
idb(51265).earmor=3140-idb(51265).barmor;
idb(51265).str=183;
idb(51265).sta=251+30+15+9;
idb(51265).agi=0+10;
idb(51265).dodge=56;
idb(51265).parry=96;

idb(51267).name='Sanctified Lightsworn Handguards (Heroic)';
idb(51267).ilvl=277;
idb(51267).barmor=1723;
idb(51267).earmor=2051-idb(51265).barmor;
idb(51267).str=103;
idb(51267).sta=192+30;
idb(51267).dodge=68;
idb(51267).hit=69;

idb(51268).name='Sanctified Lightsworn Legguards (Heroic)';
idb(51268).ilvl=277;
idb(51268).barmor=2412;
idb(51268).str=139;
idb(51268).sta=251+30+30;
idb(51268).dodge=106;
idb(51268).exp=93;

idb(51269).name='Sanctified Lightsworn Shoulderguards (Heroic)';
idb(51269).ilvl=277;
idb(51269).barmor=2067;
idb(51269).str=136;
idb(51269).sta=192+30;
idb(51269).dodge=99;
idb(51269).parry=71;

%% Neck 
idb(50682).name='Bile-Encrusted Medallion (Heroic)';
idb(50682).ilvl=277;
idb(50682).earmor=216;
idb(50682).str=102;
idb(50682).sta=141+30;
idb(50682).dodge=73;

%% Cloaks
idb(50466).name='Sentinel''s Winter Cloak';
idb(50466).ilvl=264;
idb(50466).barmor=556;
idb(50466).earmor=716-idb(50466).barmor;
idb(50466).str=90;
idb(50466).sta=124+30;
idb(50466).dodge=72;

%% Bracers
idb(51901).name='Gargoyle Spit Bracers (Heroic)';
idb(51901).ilvl=264;
idb(51901).barmor=1156;
idb(51901).earmor=1360-idb(51901).barmor;
idb(51901).str=82;
idb(51901).sta=124+30;
idb(51901).dodge=68;


%% Belts
idb(50991).name='Verdigris Chain Belt';
idb(50991).ilvl=264;
idb(50991).barmor=1486;
idb(50991).earmor=1674-idb(50991).barmor;
idb(50991).str=120;
idb(50991).sta=157+15+30+30+9;
idb(50991).agi=0+10;
idb(50991).parry=95;

%% Boots
idb(50625).name='Grinning Skull Greatboots (Heroic)';
idb(50625).ilvl=277;
idb(50625).barmor=1895;
idb(50625).str=103;
idb(50625).sta=180+30+30;
idb(50625).dodge=127;
idb(50625).exp=61;

%% Rings
idb(50622).name='Devium''s Eternally Cold Ring (Heroic)';
idb(50622).ilvl=277;
idb(50622).earmor=216;
idb(50622).str=102;
idb(50622).sta=141+30;
idb(50622).dodge=73;

idb(50404).name='Ashen Band of Endless Courage';
idb(50404).ilvl=277;
idb(50404).str=68;
idb(50404).sta=130+30;
idb(50404).dodge=84;
idb(50404).hit=55;
idb(50404).earmor=2400.*0.03;

%% Trinkets
idb(50356).name='Corroded Skeleton Key';
idb(50356).ilvl=264;
idb(50356).sta=228;

idb(54571).name='Sindragosa''s Flawless Fang';
idb(54571).ilvl=264;
idb(54571).sta=228;

%% Weapons
idb(50708).name='Last Word (Heroic)';
idb(50708).ilvl=277;
idb(50708).wtype='mac';
idb(50708).tooldps=250.6;
idb(50708).swing=1.8;
idb(50708).avgdmg=(315+587)/2;
idb(50708).sta=94+30;
idb(50708).str=115;

%% Shields
idb(50729).name='Icecrown Glacial Wall (Heroic)';
idb(50729).ilvl=277;
idb(50729).barmor=7699;
idb(50729).str=102;
idb(50729).sta=141+30;
idb(50729).dodge=68;
idb(50729).parry=72;

%% Librams
idb(50461).name='Libram of the Eternal Tower';
idb(50461).dodge=219;

%% Enchant section - to be written.  

%Enchants work exactly the same way that items do.  There is an idb
%structure that contains all of the relevant enchants, according to the
%spell_id value.  Since it has the same form, we can use the same equip()
%function.

%% Head
idb(44150).name='Arcanum of the Stalwart Protector';
idb(44150).sta=37;

%% Shoulder
idb(44136).name='Greater Inscription of the Pinnacle';
idb(44136).dodge=20;

%% Cloak
idb(39001).name='Enchant Cloak - Mighty Armor';
idb(39001).barmor=225;

%% Chest
idb(39005).name='Enchant Chest - Super Health';
idb(39005).health=275;

%% Wrists
idb(44947).name='Enchant Bracer - Major Stamina';
idb(44947).sta=40;

%% Hands
idb(38376).name='Heavy Borean Armor Kit';
idb(38376).sta=18;

%% Legs
idb(38373).name='Frosthide Leg Armor';
idb(38373).sta=55;
idb(38373).agi=22;

%% Feet
idb(39006).name='Enchant Boots - Tuskarr''s Vitality';
idb(39006).sta=15;

%% Rings
idb(50).name='Enchant Ring - Stamina';
idb(50).sta=30;

%% Weapon
idb(59619).name='Enchant Weapon - Accuracy';
idb(59619).hit=25;
idb(59619).crit=25;

%% Shield
idb(38945).name='Enchant Shield - Major Stamina';
idb(38945).sta=18;



