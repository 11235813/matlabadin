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
               'armormeta',0, ...
               'critmeta',0, ...
               'istier',[0 0 0 0], ...
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
               'armormeta',0, ...
               'critmeta',0, ...
               'istier',[0 0 0 0], ...
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
idb.iid(51266).agi=0;
idb.iid(51266).critmeta=0;
idb.iid(51266).armormeta=1;
idb.iid(51266).dodge=128-51;
idb.iid(51266).mast=51;
idb.iid(51266).parry=88+10;
idb.iid(51266).istier=[1 0 0 0];

idb.iid(51265).name='Sanctified Lightsworn Chestguard (Heroic)';
idb.iid(51265).atype=1;
idb.iid(51265).ilvl=277;
idb.iid(51265).barmor=2756;
idb.iid(51265).earmor=3140-idb.iid(51265).barmor;
idb.iid(51265).str=183;
idb.iid(51265).sta=251+30+15+9;
idb.iid(51265).agi=0;
idb.iid(51265).dodge=56;
idb.iid(51265).parry=96+10-38;
idb.iid(51265).mast=38;
idb.iid(51265).istier=[1 0 0 0];

idb.iid(51267).name='Sanctified Lightsworn Handguards (Heroic)';
idb.iid(51267).atype=1;
idb.iid(51267).ilvl=277;
idb.iid(51267).barmor=1723;
idb.iid(51267).earmor=2051-idb.iid(51265).barmor;
idb.iid(51267).str=103;
idb.iid(51267).sta=192+30;
idb.iid(51267).dodge=68-27;
idb.iid(51267).hit=69;
idb.iid(51267).mast=27;
idb.iid(51267).istier=[1 0 0 0];

idb.iid(51268).name='Sanctified Lightsworn Legguards (Heroic)';
idb.iid(51268).atype=1;
idb.iid(51268).ilvl=277;
idb.iid(51268).barmor=2412;
idb.iid(51268).str=139;
idb.iid(51268).sta=251+30+30;
idb.iid(51268).dodge=106-42;
idb.iid(51268).mast=42;
idb.iid(51268).exp=93;
idb.iid(51268).istier=[1 0 0 0];

idb.iid(51269).name='Sanctified Lightsworn Shoulderguards (Heroic)';
idb.iid(51269).atype=1;
idb.iid(51269).ilvl=277;
idb.iid(51269).barmor=2067;
idb.iid(51269).str=136;
idb.iid(51269).sta=192+30;
idb.iid(51269).dodge=99-39;
idb.iid(51269).parry=71;
idb.iid(51269).mast=39;
idb.iid(51269).istier=[1 0 0 0];

%% Head
idb.iid(57861).name='Helm of Setesh';
idb.iid(57861).atype=1;
idb.iid(57861).ilvl=333;
idb.iid(57861).barmor=2542;
idb.iid(57861).str=191+10;
idb.iid(57861).sta=401+32+15;
idb.iid(57861).dodge=208;
idb.iid(57861).exp=97;
idb.iid(57861).critmeta=0;
idb.iid(57861).armormeta=1;

%% Neck 
idb.iid(50682).name='Bile-Encrusted Medallion (Heroic)';
idb.iid(50682).ilvl=277;
idb.iid(50682).earmor=216;
idb.iid(50682).str=102;
idb.iid(50682).sta=141+30;
idb.iid(50682).dodge=73-29;
idb.iid(50682).mast=29;

idb.iid(55888).name='Darkhowl Amulet';
idb.iid(55888).ilvl=333;
idb.iid(55888).str=114;
idb.iid(55888).sta=224;
idb.iid(55888).exp=76;
idb.iid(55888).dodge=149;

%% Shoulder
idb.iid(50660).name='Boneguard Commander''s Pauldrons';
idb.iid(50660).ilvl=277;
idb.iid(50660).barmor=2067;
idb.iid(50660).str=136;
idb.iid(50660).sta=180+15+30+9;
idb.iid(50660).dodge=99-39+10;
idb.iid(50660).mast=39;
idb.iid(50660).parry=63;

idb.iid(56124).name='Earthshape Pauldrons';
idb.iid(56124).ilvl=333;
idb.iid(56124).str=199;
idb.iid(56124).sta=298;
idb.iid(56124).mast=133;
idb.iid(56124).dodge=133;
idb.iid(56124).barmor=2346;
idb.iid(56124).atype=1;

%% Cloaks
idb.iid(50466).name='Sentinel''s Winter Cloak';
idb.iid(50466).ilvl=264;
idb.iid(50466).barmor=556;
idb.iid(50466).earmor=716-idb.iid(50466).barmor;
idb.iid(50466).str=90;
idb.iid(50466).sta=124+30;
idb.iid(50466).dodge=72-28;
idb.iid(50466).mast=28;

idb.iid(50718).name='Royal Crimson Cloak (Heroic)';
idb.iid(50718).ilvl=277;
idb.iid(50718).barmor=599;
idb.iid(50718).str=78;
idb.iid(50718).sta=141+30;
idb.iid(50718).dodge=102-40;
idb.iid(50718).hit=44;
idb.iid(50718).mast=40;

idb.iid(56219).name='Shroud of Dark Memories';
idb.iid(56219).ilvl=333;
idb.iid(56219).str=114;
idb.iid(56219).sta=224;
idb.iid(56219).exp=76;
idb.iid(56219).dodge=149;
idb.iid(56219).barmor=572;

%% Chest
idb.iid(66933).name='Breastplate of the Witness';
idb.iid(66933).ilvl=333;
idb.iid(66933).barmor=3128;
idb.iid(66933).str=268;
idb.iid(66933).sta=401;
idb.iid(66933).parry=191;
idb.iid(66933).dodge=157;
idb.iid(66933).atype=1;

%% Bracers
idb.iid(51901).name='Gargoyle Spit Bracers (Heroic)';
idb.iid(51901).atype=1;
idb.iid(51901).ilvl=264;
idb.iid(51901).barmor=1156;
idb.iid(51901).earmor=1360-idb.iid(51901).barmor;
idb.iid(51901).str=82;
idb.iid(51901).sta=124+30;
idb.iid(51901).dodge=68-27;
idb.iid(51901).mast=27;

idb.iid(55992).name='Armguards of Unearthly Light';
idb.iid(55992).ilvl=333;
idb.iid(55992).str=114;
idb.iid(55992).sta=224;
idb.iid(55992).hit=76;
idb.iid(55992).dodge=149;
idb.iid(55992).barmor=1369;
idb.iid(55992).atype=1;

%% Gloves
idb.iid(50716).name='Taldaram''s Plated Fists (Heroic)';
idb.iid(50716).ilvl=277;
idb.iid(50716).barmor=1723;
idb.iid(50716).str=136;
idb.iid(50716).sta=180+15+30+9;
idb.iid(50716).dodge=91-36;
idb.iid(50716).mast=36;
idb.iid(50716).parry=71+10;

idb.iid(56099).name='Fingers of Light';
idb.iid(56099).ilvl=333;
idb.iid(56099).str=199;
idb.iid(56099).sta=298;
idb.iid(56099).mast=133;
idb.iid(56099).parry=133;
idb.iid(56099).barmor=1955;
idb.iid(56099).atype=1;

%% Belts
idb.iid(50991).name='Verdigris Chain Belt';
idb.iid(50991).atype=1;
idb.iid(50991).ilvl=264;
idb.iid(50991).barmor=1486;
idb.iid(50991).earmor=1674-idb.iid(50991).barmor;
idb.iid(50991).str=120;
idb.iid(50991).sta=157+15+30+30+9;
idb.iid(50991).agi=0+10;
idb.iid(50991).parry=95-38;
idb.iid(50991).mast=38;

idb.iid(50691).name='Belt of Broken Bones (Heroic)';
idb.iid(50691).atype=1;
idb.iid(50691).ilvl=277;
idb.iid(50691).barmor=1550;
idb.iid(50691).str=136;
idb.iid(50691).sta=180+15+30+30+9;
idb.iid(50691).dodge=91-36;
idb.iid(50691).parry=71;
idb.iid(50691).mast=36;

idb.iid(55867).name='Sand Dune Belt';
idb.iid(55867).atype=1;
idb.iid(55867).ilvl=333;
idb.iid(55867).barmor=1760;
idb.iid(55867).str=151;
idb.iid(55867).sta=298;
idb.iid(55867).exp=101;
idb.iid(55867).dodge=199;

%% Legs
idb.iid(62355).name='Stone-Wrapped Greaves';
idb.iid(62355).atype=1;
idb.iid(62355).ilvl=333;
idb.iid(62355).barmor=2737;
idb.iid(62355).str=248;
idb.iid(62355).sta=401+30+30+15;
idb.iid(62355).parry=158+20+10;
idb.iid(62355).dodge=138;

%% Boots
idb.iid(50625).name='Grinning Skull Greatboots (Heroic)';
idb.iid(50625).atype=1;
idb.iid(50625).ilvl=277;
idb.iid(50625).barmor=1895;
idb.iid(50625).str=103;
idb.iid(50625).sta=180+30+30;
idb.iid(50625).dodge=127-50;
idb.iid(50625).mast=50;
idb.iid(50625).exp=61;

idb.iid(66909).name='Ramkahen Front Boots';
idb.iid(66909).atype=1;
idb.iid(66909).ilvl=333;
idb.iid(66909).sta=151;
idb.iid(66909).str=298;
idb.iid(66909).dodge=199;
idb.iid(66909).hit=101;

%% Rings
idb.iid(50622).name='Devium''s Eternally Cold Ring (Heroic)';
idb.iid(50622).ilvl=277;
idb.iid(50622).earmor=216;
idb.iid(50622).str=102;
idb.iid(50622).sta=141+30;
idb.iid(50622).dodge=73-29;
idb.iid(50622).mast=29;

idb.iid(50404).name='Ashen Band of Endless Courage';
idb.iid(50404).ilvl=277;
idb.iid(50404).str=68;
idb.iid(50404).sta=130+30;
idb.iid(50404).dodge=84-33;
idb.iid(50404).mast=33;
idb.iid(50404).hit=55;
idb.iid(50404).earmor=2400.*0.03;

idb.iid(56111).name='Temple Band';
idb.iid(56111).ilvl=333;
idb.iid(56111).str=149;
idb.iid(56111).sta=224;
idb.iid(56111).mast=100;
idb.iid(56111).dodge=100;

idb.iid(55873).name='Ring of Three Lights';
idb.iid(55873).ilvl=333;
idb.iid(55873).str=149;
idb.iid(55873).sta=224;
idb.iid(55873).parry=100;
idb.iid(55873).mast=100;

%% Trinkets
idb.iid(50356).name='Corroded Skeleton Key';
idb.iid(50356).ilvl=264;
idb.iid(50356).sta=228;

idb.iid(54571).name='Sindragosa''s Flawless Fang';
idb.iid(54571).ilvl=264;
idb.iid(54571).sta=228;

idb.iid(50364).name='Sindragosa''s Flawless Fang (Heroic)';
idb.iid(50364).ilvl=277;
idb.iid(50364).sta=258;

idb.iid(56121).name='Throngus''s Finger';
idb.iid(56121).ilvl=333;
idb.iid(56121).dodge=252;

idb.iid(55881).name='Impetuous Query';
idb.iid(55881).ilvl=333;
idb.iid(55881).mast=252;
idb.iid(55881).isproc=92199;

%% Weapons
idb.iid(44638).name='Dalaran Sword';
idb.iid(44638).ilvl=80;
idb.iid(44638).wtype='swo';
idb.iid(44638).tooldps=43.0;
idb.iid(44638).swing=1.4;
idb.iid(44638).avgdmg=(42+79)./2;

idb.iid(50737).name='Havoc''s Call, Blade of Lordaeron Kings (Heroic)';
idb.iid(50737).wtype='axe';
idb.iid(50737).ilvl=284;
idb.iid(50737).tooldps=264.8;
idb.iid(50737).swing=2.6;
idb.iid(50737).avgdmg=688.5;
idb.iid(50737).sta=113;
idb.iid(50737).str=20; %socket
idb.iid(50737).agi=84+4; %socket
idb.iid(50737).crit=56;
idb.iid(50737).haste=48;
% idb.iid(50737).rsock=1;
% idb.iid(50737).sb.agi=4;
% idb.iid(50737).sb.active=[1 0 0];

idb.iid(50738).name='Mithrios, Bronzebeard''s Legacy (Heroic)';
idb.iid(50738).wtype='mac';
idb.iid(50738).ilvl=284;
idb.iid(50738).tooldps=264.7;
idb.iid(50738).swing=1.6;
idb.iid(50738).avgdmg=423.5;
idb.iid(50738).str=64;
idb.iid(50738).sta=113+30+6; %socket
idb.iid(50738).exp=42;
idb.iid(50738).parry=76;
% idb.iid(50738).bsock=1;
% idb.iid(50738).sb.sta=6;
% idb.iid(50738).sb.active=[0 0 1];

idb.iid(50672).name='Bloodvenom Blade (Heroic)';
idb.iid(50672).wtype='swo';
idb.iid(50672).ilvl=277;
idb.iid(50672).tooldps=250.6;
idb.iid(50672).swing=2.6;
idb.iid(50672).avgdmg=651.5; %socket
idb.iid(50672).sta=117+30; %socket
idb.iid(50672).agi=70+4;
idb.iid(50672).hit=52;
idb.iid(50672).crit=44;
% idb.iid(50672).bsock=1;
% idb.iid(50672).sb.agi=4;
% idb.iid(50672).sb.active=[0 0 1];

idb.iid(50708).name='Last Word (Heroic)';
idb.iid(50708).ilvl=277;
idb.iid(50708).wtype='mac';
idb.iid(50708).tooldps=250.6;
idb.iid(50708).swing=1.8;
idb.iid(50708).avgdmg=(315+587)./2;
idb.iid(50708).sta=94+30; %socket
idb.iid(50708).str=115;
idb.iid(50708).isproc=71873;

idb.iid(50012).name='Havoc''s Call, Blade of Lordaeron Kings';
idb.iid(50012).wtype='axe';
idb.iid(50012).ilvl=271;
idb.iid(50012).tooldps=239.2;
idb.iid(50012).swing=2.6;
idb.iid(50012).avgdmg=622;
idb.iid(50012).sta=111;
idb.iid(50012).agi=74;
idb.iid(50012).crit=49;
idb.iid(50012).haste=49;

idb.iid(49997).name='Mithrios, Bronzebeard''s Legacy';
idb.iid(49997).wtype='mac';
idb.iid(49997).ilvl=271;
idb.iid(49997).tooldps=239.4;
idb.iid(49997).swing=1.6;
idb.iid(49997).avgdmg=383;
idb.iid(49997).str=56;
idb.iid(49997).sta=111;
idb.iid(49997).exp=38;
idb.iid(49997).parry=74;

idb.iid(51947).name='Troggbane, Axe of the Frostborne King (Heroic)';
idb.iid(51947).wtype='axe';
idb.iid(51947).ilvl=271;
idb.iid(51947).tooldps=239.4;
idb.iid(51947).swing=1.6;
idb.iid(51947).avgdmg=383;
idb.iid(51947).str=66;
idb.iid(51947).sta=111+30+6; %socket
idb.iid(51947).dodge=50;
idb.iid(51947).parry=39;
% idb.iid(51947).bsock=1;
% idb.iid(51947).sb.sta=6;
% idb.iid(51947).sb.active=[0 0 1];

idb.iid(50412).name='Bloodvenom Blade';
idb.iid(50412).wtype='swo';
idb.iid(50412).ilvl=264;
idb.iid(50412).tooldps=226.7;
idb.iid(50412).swing=2.6;
idb.iid(50412).avgdmg=589.5;
idb.iid(50412).sta=104;
idb.iid(50412).agi=69;
idb.iid(50412).hit=46;
idb.iid(50412).crit=46;

idb.iid(50179).name='Last Word';
idb.iid(50179).ilvl=264;
idb.iid(50179).wtype='mac';
idb.iid(50179).tooldps=226.8;
idb.iid(50179).swing=1.8;
idb.iid(50179).avgdmg=(285+531)./2;
idb.iid(50179).sta=104;
idb.iid(50179).str=100;
idb.iid(50179).isproc=71873;

idb.iid(51937).name='Bonebreaker Scepter (Heroic)';
idb.iid(51937).wtype='mac';
idb.iid(51937).ilvl=264;
idb.iid(51937).tooldps=226.8;
idb.iid(51937).swing=1.7;
idb.iid(51937).avgdmg=385.5;
idb.iid(51937).str=48;
idb.iid(51937).sta=92+30; %socket
idb.iid(51937).hit=44;
idb.iid(51937).dodge=60;
% idb.iid(51937).ysock=1;
% idb.iid(51937).sb.dodge=4;
% idb.iid(51937).sb.active=[0 1 0];

idb.iid(51916).name='Frost Giant''s Cleaver (Heroic)';
idb.iid(51916).wtype='axe';
idb.iid(51916).ilvl=264;
idb.iid(51916).tooldps=226.7;
idb.iid(51916).swing=2.6;
idb.iid(51916).avgdmg=589.5;
idb.iid(51916).sta=99;
idb.iid(51916).agi=61;
idb.iid(51916).crit=50;
idb.iid(51916).haste=31;
% idb.iid(51916).rsock=1;
idb.iid(51916).str=20; %socket

idb.iid(51893).name='Gutbuster (Heroic)';
idb.iid(51893).wtype='mac';
idb.iid(51893).ilvl=264;
idb.iid(51893).tooldps=226.7;
idb.iid(51893).swing=2.6;
idb.iid(51893).avgdmg=589.5;
idb.iid(51893).sta=118;
idb.iid(51893).agi=45;
idb.iid(51893).hit=36;
idb.iid(51893).crit=48+4; %socket
% idb.iid(51893).rsock=1;
% idb.iid(51893).sb.crit=4;
% idb.iid(51893).sb.active=[1 0 0];
idb.iid(51893).str=20; %socket

idb.iid(51858).name='Soulbreaker (Heroic)';
idb.iid(51858).wtype='swo';
idb.iid(51858).ilvl=264;
idb.iid(51858).tooldps=226.7;
idb.iid(51858).swing=2.6;
idb.iid(51858).avgdmg=589.5;
idb.iid(51858).sta=99;
idb.iid(51858).agi=61;
idb.iid(51858).crit=40;
idb.iid(51858).haste=43;
% idb.iid(51858).rsock=1;
idb.iid(51858).str=20; %socket
idb.iid(51858).ap=8; %socket

idb.iid(51869).name='The Facelifter (Heroic)';
idb.iid(51869).wtype='swo';
idb.iid(51869).ilvl=264;
idb.iid(51869).tooldps=226.9;
idb.iid(51869).swing=1.6;
idb.iid(51869).avgdmg=363;
idb.iid(51869).str=42;
idb.iid(51869).sta=92+30; %socket
idb.iid(51869).dodge=4; %socket
idb.iid(51869).exp=41;
idb.iid(51869).parry=69;
% idb.iid(51869).bsock=1;
% idb.iid(51869).sb.dodge=4;
% idb.iid(51869).sb.active=[0 0 1];

idb.iid(47526).name='Remorseless (Heroic)';
idb.iid(47526).wtype='mac';
idb.iid(47526).ilvl=258;
idb.iid(47526).tooldps=216.5;
idb.iid(47526).swing=2.6;
idb.iid(47526).avgdmg=563;
idb.iid(47526).sta=99;
idb.iid(47526).agi=58;
idb.iid(47526).crit=44;
idb.iid(47526).haste=36;
% idb.iid(47526).ysock=1;
idb.iid(47526).str=20; %socket

idb.iid(47506).name='Silverwing Defender (Heroic)';
idb.iid(47506).wtype='swo';
idb.iid(47506).ilvl=258;
idb.iid(47506).tooldps=216.9;
idb.iid(47506).swing=1.6;
idb.iid(47506).avgdmg=347;
idb.iid(47506).str=66;
idb.iid(47506).sta=87+30; %socket
idb.iid(47506).dodge=45;
idb.iid(47506).parry=35;
% idb.iid(47506).ysock=1;
% idb.iid(47506).sb.sta=6;
% idb.iid(47506).sb.active=[0 1 0];

idb.iid(47156).name='Stormpike Cleaver (Heroic)';
idb.iid(47156).wtype='axe';
idb.iid(47156).ilvl=258;
idb.iid(47156).tooldps=216.5;
idb.iid(47156).swing=2.6;
idb.iid(47156).avgdmg=563;
idb.iid(47156).sta=87;
idb.iid(47156).agi=58;
idb.iid(47156).hit=44;
idb.iid(47156).haste=44;
% idb.iid(47156).ysock=1;
% idb.iid(47156).sb.agi=4;
% idb.iid(47156).sb.active=[0 1 0];
idb.iid(47156).str=20;

idb.iid(51795).name='Troggbane, Axe of the Frostborne King';
idb.iid(51795).wtype='axe';
idb.iid(51795).ilvl=258;
idb.iid(51795).tooldps=216.9;
idb.iid(51795).swing=1.6;
idb.iid(51795).avgdmg=347;
idb.iid(51795).str=66;
idb.iid(51795).sta=99;
idb.iid(51795).dodge=49;
idb.iid(51795).parry=37;

idb.iid(50760).name='Bonebreaker Scepter';
idb.iid(50760).wtype='mac';
idb.iid(50760).ilvl=251;
idb.iid(50760).tooldps=205.6;
idb.iid(50760).swing=1.7;
idb.iid(50760).avgdmg=349.5;
idb.iid(50760).str=42;
idb.iid(50760).sta=92;
idb.iid(50760).hit=39;
idb.iid(50760).dodge=60;

idb.iid(50050).name='Cudgel of Furious Justice';
idb.iid(50050).wtype='mac';
idb.iid(50050).ilvl=251;
idb.iid(50050).tooldps=205.6;
idb.iid(50050).swing=2.6;
idb.iid(50050).avgdmg=534.5;
idb.iid(50050).sta=92;
idb.iid(50050).agi=62;
idb.iid(50050).crit=42;
idb.iid(50050).haste=40;

idb.iid(50787).name='Frost Giant''s Cleaver';
idb.iid(50787).wtype='axe';
idb.iid(50787).ilvl=251;
idb.iid(50787).tooldps=205.6;
idb.iid(50787).swing=2.6;
idb.iid(50787).avgdmg=534.5;
idb.iid(50787).sta=88;
idb.iid(50787).agi=62;
idb.iid(50787).crit=45;
idb.iid(50787).haste=35;

idb.iid(50810).name='Gutbuster';
idb.iid(50810).wtype='mac';
idb.iid(50810).ilvl=251;
idb.iid(50810).tooldps=205.6;
idb.iid(50810).swing=2.6;
idb.iid(50810).avgdmg=534.5;
idb.iid(50810).sta=104;
idb.iid(50810).agi=47;
idb.iid(50810).hit=39;
idb.iid(50810).crit=42;

idb.iid(51021).name='Soulbreaker';
idb.iid(51021).wtype='swo';
idb.iid(51021).ilvl=251;
idb.iid(51021).tooldps=205.6;
idb.iid(51021).swing=2.6;
idb.iid(51021).avgdmg=534.5;
idb.iid(51021).sta=88;
idb.iid(51021).agi=62;
idb.iid(51021).crit=43;
idb.iid(51021).haste=38;

idb.iid(51010).name='The Facelifter';
idb.iid(51010).wtype='swo';
idb.iid(51010).ilvl=251;
idb.iid(51010).tooldps=205.6;
idb.iid(51010).swing=1.6;
idb.iid(51010).avgdmg=329;
idb.iid(51010).str=44;
idb.iid(51010).sta=92;
idb.iid(51010).exp=36;
idb.iid(51010).parry=62;

idb.iid(47967).name='Crusader''s Glory (Heroic)';
idb.iid(47967).wtype='swo';
idb.iid(47967).ilvl=245;
idb.iid(47967).tooldps=197;
idb.iid(47967).swing=1.5;
idb.iid(47967).avgdmg=295.5;
idb.iid(47967).str=58;
idb.iid(47967).sta=76+30; %socket
idb.iid(47967).dodge=4; %socket
idb.iid(47967).dodge=32;
% idb.iid(47967).bsock=1;
% idb.iid(47967).sb.dodge=4;
% idb.iid(47967).sb.active=[0 0 1];

idb.iid(48714).name='Honor of the Fallen (Heroic)';
idb.iid(48714).wtype='mac';
idb.iid(48714).ilvl=245;
idb.iid(48714).tooldps=196.6;
idb.iid(48714).swing=1.6;
idb.iid(48714).avgdmg=314.5;
idb.iid(48714).str=58;
idb.iid(48714).sta=76+30; %socket
idb.iid(48714).dodge=46;
idb.iid(48714).parry=23;
% idb.iid(48714).ysock=1;
% idb.iid(48714).sb.dodge=4;
% idb.iid(48714).sb.active=[0 1 0];

idb.iid(47148).name='Stormpike Cleaver';
idb.iid(47148).wtype='axe';
idb.iid(47148).ilvl=245;
idb.iid(47148).tooldps=196.7;
idb.iid(47148).swing=2.6;
idb.iid(47148).avgdmg=511.5;
idb.iid(47148).sta=87;
idb.iid(47148).agi=58;
idb.iid(47148).hit=39;
idb.iid(47148).haste=39;

idb.iid(49501).name='Tempered Vis''kag the Bloodletter';
idb.iid(49501).wtype='swo';
idb.iid(49501).ilvl=245;
idb.iid(49501).tooldps=196.7;
idb.iid(49501).swing=2.6;
idb.iid(49501).avgdmg=511.5;

idb.iid(47973).name='The Grinder (Heroic)';
idb.iid(47973).wtype='mac';
idb.iid(47973).ilvl=245;
idb.iid(47973).tooldps=196.7;
idb.iid(47973).swing=2.6;
idb.iid(47973).avgdmg=511.5;
idb.iid(47973).sta=71+30; %socket
idb.iid(47973).agi=54+4; %socket
idb.iid(47973).crit=40;
idb.iid(47973).haste=35;
% idb.iid(47973).bsock=1;
% idb.iid(47973).sb.agi=4;
% idb.iid(47973).sb.active=[0 0 1];

idb.iid(47966).name='The Lion''s Maw (Heroic)';
idb.iid(47966).wtype='axe';
idb.iid(47966).ilvl=245;
idb.iid(47966).tooldps=196.7;
idb.iid(47966).swing=2.6;
idb.iid(47966).avgdmg=511.5;
idb.iid(47966).sta=83;
idb.iid(47966).agi=50+4; %socket
idb.iid(47966).crit=43;
idb.iid(47966).haste=24;
% idb.iid(47966).rsock=1;
% idb.iid(47966).sb.agi=4;
% idb.iid(47966).sb.active=[1 0 0];
idb.iid(47966).str=20; %socket

idb.iid(45442).name='Sorthalis, Hammer of the Watchers';
idb.iid(45442).wtype='mac';
idb.iid(45442).ilvl=239;
idb.iid(45442).tooldps=188.4;
idb.iid(45442).swing=1.6;
idb.iid(45442).avgdmg=301.5;
idb.iid(45442).str=40;
idb.iid(45442).sta=70+6; %socket
idb.iid(45442).exp=32;
idb.iid(45442).parry=49;
% idb.iid(45442).rsock=1;
% idb.iid(45442).sb.sta=6;
% idb.iid(45442).sb.active=[1 0 0];
idb.iid(45442).str=20; %socket

idb.iid(50303).name='Black Icicle';
idb.iid(50303).wtype='mac';
idb.iid(50303).ilvl=232;
idb.iid(50303).tooldps=179;
idb.iid(50303).swing=2.6;
idb.iid(50303).avgdmg=465.5;
idb.iid(50303).sta=87;
idb.iid(50303).agi=39;
idb.iid(50303).hit=29;
idb.iid(50303).crit=38;

idb.iid(47810).name='Crusader''s Glory';
idb.iid(47810).wtype='swo';
idb.iid(47810).ilvl=232;
idb.iid(47810).tooldps=179;
idb.iid(47810).swing=1.5;
idb.iid(47810).avgdmg=268.5;
idb.iid(47810).str=52;
idb.iid(47810).sta=77;
idb.iid(47810).dodge=35;

idb.iid(50290).name='Falric''s Wrist-Chopper';
idb.iid(50290).wtype='axe';
idb.iid(50290).ilvl=232;
idb.iid(50290).tooldps=178.8;
idb.iid(50290).swing=1.6;
idb.iid(50290).avgdmg=286;
idb.iid(50290).str=52;
idb.iid(50290).sta=77;
idb.iid(50290).dodge=31;
idb.iid(50290).parry=36;

idb.iid(50191).name='Nighttime';
idb.iid(50191).wtype='axe';
idb.iid(50191).ilvl=232;
idb.iid(50191).tooldps=179;
idb.iid(50191).swing=2.6;
idb.iid(50191).avgdmg=465.5;
idb.iid(50191).sta=73;
idb.iid(50191).agi=52;
idb.iid(50191).crit=34;
idb.iid(50191).haste=34;

idb.iid(50268).name='Rimefang''s Claw';
idb.iid(50268).wtype='swo';
idb.iid(50268).ilvl=232;
idb.iid(50268).tooldps=179.1;
idb.iid(50268).swing=1.7;
idb.iid(50268).avgdmg=304.5;
idb.iid(50268).str=52;
idb.iid(50268).sta=77;
idb.iid(50268).dodge=44;
idb.iid(50268).parry=21;

idb.iid(45947).name='Serilas, Blood Blade of Invar One-Arm';
idb.iid(45947).wtype='swo';
idb.iid(45947).ilvl=232;
idb.iid(45947).tooldps=179;
idb.iid(45947).swing=2.6;
idb.iid(45947).avgdmg=465.5;
idb.iid(45947).sta=66;
idb.iid(45947).agi=52;
idb.iid(45947).hit=32;
idb.iid(45947).exp=26;
% idb.iid(45947).ysock=1;
% idb.iid(45947).sb.crit=4;
% idb.iid(45947).sb.active=[0 1 0];

idb.iid(45876).name='Shiver';
idb.iid(45876).wtype='mac';
idb.iid(45876).ilvl=232;
idb.iid(45876).tooldps=178.8;
idb.iid(45876).swing=1.6;
idb.iid(45876).avgdmg=286;
idb.iid(45876).str=36+20; %socket
idb.iid(45876).sta=78;
idb.iid(45876).hit=23+4; %socket
idb.iid(45876).parry=45;
% idb.iid(45876).rsock=1;

idb.iid(49296).name='Singed Vis''kag the Bloodletter';
idb.iid(49296).wtype='swo';
idb.iid(49296).ilvl=232;
idb.iid(49296).tooldps=179;
idb.iid(49296).swing=2.6;
idb.iid(49296).avgdmg=465.5;

idb.iid(47816).name='The Grinder';
idb.iid(47816).wtype='mac';
idb.iid(47816).ilvl=232;
idb.iid(47816).tooldps=179;
idb.iid(47816).swing=2.6;
idb.iid(47816).avgdmg=465.5;
idb.iid(47816).sta=62+30; %socket
idb.iid(47816).agi=48+4; %socket
idb.iid(47816).crit=35;
idb.iid(47816).haste=30;
% idb.iid(47816).bsock=1;
% idb.iid(47816).sb.agi=4;
% idb.iid(47816).sb.active=[0 0 1];

idb.iid(47808).name='The Lion''s Maw';
idb.iid(47808).wtype='axe';
idb.iid(47808).ilvl=232;
idb.iid(47808).tooldps=179;
idb.iid(47808).swing=2.6;
idb.iid(47808).avgdmg=465.5;
idb.iid(47808).sta=73;
idb.iid(47808).agi=52;
idb.iid(47808).crit=38;
idb.iid(47808).haste=29;

idb.iid(45110).name='Titanguard';
idb.iid(45110).wtype='swo';
idb.iid(45110).ilvl=232;
idb.iid(45110).tooldps=178.8;
idb.iid(45110).swing=1.6;
idb.iid(45110).avgdmg=286;
idb.iid(45110).str=37;
idb.iid(45110).sta=78;
idb.iid(45110).hit=29;
idb.iid(45110).parry=51;

idb.iid(45463).name='Vulmir, the Northern Tempest';
idb.iid(45463).wtype='mac';
idb.iid(45463).ilvl=232;
idb.iid(45463).tooldps=179;
idb.iid(45463).swing=2.6;
idb.iid(45463).avgdmg=465.5;
idb.iid(45463).sta=80;
idb.iid(45463).agi=52;
idb.iid(45463).hit=37;
idb.iid(45463).exp=29;

idb.iid(51522).name='Wrathful Gladiator''s Longblade';
idb.iid(51522).wtype='swo';
idb.iid(51522).ilvl=277;
idb.iid(51522).tooldps=250.6;
idb.iid(51522).swing=2.6;
idb.iid(51522).avgdmg=(521+782)/2;
idb.iid(51522).sta=118+30; %socket
idb.iid(51522).crit=44;
idb.iid(51522).ap=141+8; %socket

idb.iid(51521).name='Wrathful Gladiator''s Slicer';
idb.iid(51521).wtype='swo';
idb.iid(51521).ilvl=264;
idb.iid(51521).tooldps=226.8;
idb.iid(51521).swing=2.6;
idb.iid(51521).avgdmg=(471+708)/2;
idb.iid(51521).sta=104+30; %socket
idb.iid(51521).crit=44;
idb.iid(51521).ap=123+8; %socket


%spellpower weapons
idb.iid(51932).name='Frost Needle (Heroic)';
idb.iid(51932).wtype='swo';
idb.iid(51932).ilvl=264;
idb.iid(51932).tooldps=113.4;
idb.iid(51932).swing=1.8;
idb.iid(51932).avgdmg=(142+266)/2;
idb.iid(51932).sta=114;
idb.iid(51932).str=20;
idb.iid(51932).hit=52;
idb.iid(51932).haste=56;
idb.iid(51932).sp=928;

idb.iid(50771).name='Frost Needle';
idb.iid(50771).wtype='swo';
idb.iid(50771).ilvl=251;
idb.iid(50771).tooldps=102.8;
idb.iid(50771).swing=1.8;
idb.iid(50771).avgdmg=(129+241)/2;
idb.iid(50771).sta=111;
idb.iid(50771).hit=49;
idb.iid(50771).haste=54;
idb.iid(50771).sp=823;

%lol
idb.iid(40345).name='Broken Promise';
idb.iid(40345).wtype='swo';
idb.iid(40345).ilvl=213;
idb.iid(40345).tooldps=156.7;
idb.iid(40345).swing=2.5;
idb.iid(40345).avgdmg=(274+510)/2;
idb.iid(40345).dodge=43;
idb.iid(40345).hit=16;
idb.iid(40345).exp=20;
idb.iid(40345).str=29;
idb.iid(40345).sta=64;

%cata weapons
idb.iid(56433).name='Blade of the Burning Sun';
idb.iid(56433).ilvl=346;
idb.iid(56433).wtype='swo';
idb.iid(56433).tooldps=41.7;
idb.iid(56433).swing=1.60;
idb.iid(56433).avgdmg=(1+132)/2;
idb.iid(56433).sta=172;
idb.iid(56433).int=115;
idb.iid(56433).sp=1532;
idb.iid(56433).haste=67;
idb.iid(56433).crit=82;

idb.iid(63799).name='Mace of the Gullet';
idb.iid(63799).ilvl=333;
idb.iid(63799).wtype='mac';
idb.iid(63799).tooldps=362.7;
idb.iid(63799).swing=2.6;
idb.iid(63799).avgdmg=(660+1226)./2;
idb.iid(63799).sta=172;
idb.iid(63799).str=115;
idb.iid(63799).exp=82;
idb.iid(63799).mast=67;

%% Shields
idb.iid(50729).name='Icecrown Glacial Wall (Heroic)';
idb.iid(50729).ilvl=277;
idb.iid(50729).barmor=7699;
idb.iid(50729).str=102;
idb.iid(50729).sta=141+30;
idb.iid(50729).dodge=68;
idb.iid(50729).parry=72-28;
idb.iid(50729).mast=28;

idb.iid(55880).name='Zora''s Ward';
idb.iid(55880).ilvl=333;
idb.iid(55880).barmor=11504;
idb.iid(55880).sta=224;
idb.iid(55880).int=149;
idb.iid(55880).haste=107;
idb.iid(55880).mast=87;

idb.iid(56096).name='Bulwark of the Primordial Mound';
idb.iid(56096).ilvl=333;
idb.iid(56096).str=114;
idb.iid(56096).sta=224;
idb.iid(56096).hit=76;
idb.iid(56096).dodge=149;
idb.iid(56096).barmor=11504;

%% Librams
idb.iid(50461).name='Libram of the Eternal Tower';
idb.iid(50461).str=51;
idb.iid(50461).sta=77+30;
idb.iid(50461).parry=34;
idb.iid(50461).dodge=34-13;
idb.iid(50461).mast=13;


idb.iid(63888).name='Blackblood Freedom Standard';
idb.iid(63888).ilvl=318;
idb.iid(63888).str=73;
idb.iid(63888).sta=110;
idb.iid(63888).exp=40;
idb.iid(63888).mast=54;


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
idb.sid(59955).name='Arcanum of the Stalwart Protector';
idb.sid(59955).sta=37;

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