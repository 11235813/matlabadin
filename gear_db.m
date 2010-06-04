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
%egs.name
%egs.type
%egs.ilvl
%egs.tooldps %TODELETE : this will store tooltip dps, for referencing only /TODELETE 
%egs.rate %TODELETE : store 1/base_swing explicitly, e.g. 1/2.0 /TODELETE
%egs.avgdmg %TODELETE : store average base damage, for more precise calcs /TODELETE
%egs.str
%egs.sta
%egs.agi
%egs.int
%egs.spi
%egs.hit
%egs.crit
%egs.exp
%egs.haste
%egs.mast %TODELETE : shorter version /TODELEE
%egs.dodge
%egs.parry
%egs.blrat %TODELETE : use the same nomenclature as blval /TODELETE
%egs.blval
%egs.barmor %TODELETE : base AC /TODELETE
%egs.earmor %TODELETE : extra AC /TODELETE
%egs.health %TODELETE : extra HP, mainly for enchants/buffs /TODELETE

%however, egs only has 20 slots.  those slots correspond to the 20 slots on
%the paper doll:
% AmmoSlot      0
% HeadSlot      1
% NeckSlot      2
% ShoulderSlot 	3
% ShirtSlot 	4
% ChestSlot 	5
% WaistSlot 	6
% LegsSlot      7
% FeetSlot      8
% WristSlot 	9
% HandsSlot 	10
% Finger0Slot 	11
% Finger1Slot 	12
% Trinket0Slot 	13
% Trinket1Slot 	14
% BackSlot      15
% MainHandSlot 	16
% SecondaryHandSlot 	17
% RangedSlot 	18
% TabardSlot 	19
%TODELETE : aren't we better off with only 18 ? ammo and tabard are redundant /TODELETE

%Equipping an item is as simple as invoking the equip() function.  See the
%equip file for details about the syntax, but for a simple example we could
%equip Last Laugh in our main hand with either of the following lines:
% egs(16)=equip('Last Laugh');
% egs(16)=equip(40402);
%Note that the second one will execute much faster (direct reference rather
%than a search)

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
            'type','swo', ... %TODELETE : use consistent nomenclature; say 3letters axe/mac/swo /TODELETE
            'ilvl',213, ...
            'tooldps',156.6, ... %TODELETE : use tooltip dps as parsed by armory /TODELETE
            'rate',1/2.5, ...
            'avgdmg',391, ... %TODELETE : use accurate values, not based on tooltip dps which is rounded /TODELETE
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
            'health',0,);

        
%% Begin adding items

%NOTE: Since defense is being removed, I'm just ignoring it.  We'll
%probably purge the database of all lvl 80 items at some point anyhow, so
%having exact stats won't matter too much.  Note that it *will* have an
%effect on any current avoidance calculations though.
        
%Define a new item - Last Laugh, item number 40402  
idb(40402).name='Last Laugh';
idb(40402).type='axe';
idb(40402).ilvl=226;
idb(40402).tooldps=171.6;
idb(40402).rate=1/1.6;
idb(40402).avgdmg=274.5;
idb(40402).str=37;
idb(40402).sta=73;
idb(40402).parry=34;
idb(40402).hit=24;

%Define a new item - Broken Proimse, item number 40345
%note that doing it this way, we *have* to define every value, otherwise we
%generate an assignment subscript error.  As such, we probably won't use
%struct() to generate most items.
idb(40345)=struct('name','Broken Promise', ...
            'type','swo', ...
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

%% Alternate Method - deprecated
% idb.brokenpromise =struct('name','Broken Promise', ...
%             'type','ohw', ...
%             'ilvl',213, ...
%             'dps',156.6, ...
%             'speed',2.5, ...
%             'str',29, ...
%             'sta',64,...
%             'agi',0,...
%             'int',0,...
%             'spi',0,...
%             'hit',16,...
%             'crit',0,...
%             'exp',20,...
%             'haste',0,...
%             'mastery',0,...
%             'dodge',0,...
%             'parry',0,...
%             'block',0,...
%             'blval',0,...
%             'armor',0,...
%             'bonusarmor',0);
% 
% idb.tempitem=idb.brokenpromise;

%% Enchant section - to be written.  

%TODO: Decide how we want to deal with enchants.  Presumably we'll want
%more fields in egs, like egs.headenchant, egs.shoulderenchant, etc.  We
%could also just edit the individual fields and write a separate enchant()
%function.  I.e.  enchant('head',####) would apply enchant #### to the head
%slot by simply increasing the appropriate stats (i.e. +37 sta, +20 def).


% %% Enchants
% %Format:
% %Item   = [STR STA AGI INT SPI Hit Crit Exp AP SP Haste ArP Def Dod Parr BV BR Armor]
% HelmEnch= [37    0  0   0   0   0   0    0   0  0   0    0   20   0   0   0  0     0];
% ShouEnch= [0     0  0   0   0   0   0    0   0  0   0    0   15  20   0   0  0     0];
% BackEnch= [0     0  0   0   0   0   0    0   0  0   0    0   16   0   0   0  0     0];
% ChesEnch= [0     0  0   0   0   0   0    0   0  0   0    0   22   0   0   0  0     0];
% BracEnch= [0    40  0   0   0   0   0    0   0  0   0    0    0   0   0   0  0     0];
% GlovEnch= [0     0  0   0   0   0   0    0   0  0   0    0    0   0  10   0  0     0]; %armsman
% BeltEnch= [0     0  0   0   0   0   0    0   0  0   0    0    0   0   0   0  0     0]; %placeholder for future useful tinkers
% LegsEnch= [0    55 22   0   0   0   0    0   0  0   0    0    0   0   0   0  0     0];
% BootEnch= [0    15  0   0   0   0   0    0   0  0   0    0    0   0   0   0  0     0];
% Rin1Ench= [0     0  0   0   0   0   0    0   0  0   0    0    0   0   0   0  0     0];
% Rin2Ench= [0     0  0   0   0   0   0    0   0  0   0    0    0   0   0   0  0     0];
% WeapEnch= [ 0    0  0   0   0  25  25    0   0  0   0    0    0   0   0   0  0     0];
% ShieEnch= [0     0  0   0   0   0   0    0   0  0   0    0   20   0   0   0  0     0];



