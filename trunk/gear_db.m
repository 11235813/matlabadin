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
            'ilvl',213, ...
            'tooldps',156.6, ...
            'rate',1/2.5, ...
            'avgdmg',391, ...
            'str',29, ...
            'sta',64, ...
            'agi',0, ...
            'int',0, ...
            'spi',0, ...
            'hit',16, ...
            'crit',0, ...
            'exp',20, ...
            'haste',0, ...
            'mast',0, ...
            'dodge',0, ...
            'parry',0, ...
            'blrat',0, ...
            'blval',0, ...
            'barmor',0, ...
            'earmor',0, ...
            'health',0);

        
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
idb(40402).rate=1/1.6;
idb(40402).avgdmg=274.5;
idb(40402).str=37;
idb(40402).sta=73;
idb(40402).parry=34;
idb(40402).hit=24;

%Define a new item - Broken Promise, item number 40345
%note that doing it this way, we *have* to define every value, otherwise we
%generate an assignment subscript error.  As such, we probably won't use
%struct() to generate most items.
idb(40345)=struct('name','Broken Promise', ...
            'wtype','swo', ...
            'ilvl',213, ...
            'tooldps',156.6, ...
            'rate',1/2.5, ...
            'avgdmg',391.5, ...
            'str',29, ...
            'sta',64, ...
            'agi',0, ...
            'int',0, ...
            'spi',0, ...
            'hit',16, ...
            'crit',0, ...
            'exp',20, ...
            'haste',0, ...
            'mast',0, ...
            'dodge',0, ...
            'parry',0, ...
            'blrat',0, ...
            'blval',0, ...
            'barmor',0, ...
            'earmor',0, ...
            'health',0);

%% Sample items, to be deleted later.  Just for testing purposes while we
% build the code
idb(2).name='GenericTwo';
idb(2).ilvl=2;
idb(2).sta=100;

idb(3).name='GenericThree';
idb(3).ilvl=3;
idb(3).hit=100;

idb(4).name='GenericFour';
idb(4).ilvl=4;
idb(4).str=100;

idb(5).name='GenericFive';
idb(5).ilvl=5;
idb(5).dodge=100;

idb(16).name='GenericWeap';
idb(16).ilvl=16;
idb(16).wtype='swo';
idb(16).tooldps=250;
idb(16).rate=1/2;
idb(16).avgdmg=500;

%% Enchant section - to be written.  

%Enchants work exactly the same way that items do.  There is an idb
%structure that contains all of the relevant enchants, according to the
%spell_id value.  Since it has the same form, we can use the same equip()
%function.

% Accuracy as example
idb(59619).name='Accuracy';
idb(59619).hit=25;
idb(59619).crit=25;


