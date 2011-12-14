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
               'isreforged',0);
           
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
               'isreforged',0);
        
%% Items

%% Head

idb.iid(69558).name='Spiritshield Mask';
idb.iid(69558).ilvl=353;
idb.iid(69558).str=263;
idb.iid(69558).sta=484;
idb.iid(69558).dodge=201;
idb.iid(69558).parry=159;
idb.iid(69558).barmor=2735;
idb.iid(69558).socket='MB';
idb.iid(69558).sbstat='dodge';
idb.iid(69558).sbval=30;
idb.iid(69558).atype=1;
idb.iid(69558).isreforged=0;

idb.iid(58103).name='Helm of the Proud';
idb.iid(58103).ilvl=346;
idb.iid(58103).str=302;
idb.iid(58103).sta=454;
idb.iid(58103).dodge=142;
idb.iid(58103).parry=142;
idb.iid(58103).barmor=2680;
idb.iid(58103).socket='MY';
idb.iid(58103).sbstat='sta';
idb.iid(58103).sbval=45;
idb.iid(58103).atype=1;
idb.iid(58103).isreforged=0;

idb.iid(60356).name='Reinforced Sapphirium Faceguard';
idb.iid(60356).ilvl=359;
idb.iid(60356).str=259;
idb.iid(60356).sta=512;
idb.iid(60356).hit=113;
idb.iid(60356).dodge=281;
idb.iid(60356).barmor=2784;
idb.iid(60356).socket='MY';
idb.iid(60356).sbstat='sta';
idb.iid(60356).sbval=45;
idb.iid(60356).atype=1;
idb.iid(60356).isreforged=0;
idb.iid(60356).istierP=[1 0 0];

idb.iid(65226).name='Reinforced Sapphirium Faceguard (Heroic)';
idb.iid(65226).ilvl=372;
idb.iid(65226).str=293;
idb.iid(65226).sta=578;
idb.iid(65226).hit=135;
idb.iid(65226).dodge=325;
idb.iid(65226).barmor=2891;
idb.iid(65226).socket='MY';
idb.iid(65226).sbstat='sta';
idb.iid(65226).sbval=45;
idb.iid(65226).atype=1;
idb.iid(65226).isreforged=0;
idb.iid(65226).istierP=[1 0 0];

idb.iid(70916).name='Helm of Blazing Glory';
idb.iid(70916).ilvl=378;
idb.iid(70916).str=348;
idb.iid(70916).sta=611;
idb.iid(70916).mast=192;
idb.iid(70916).parry=284;
idb.iid(70916).barmor=2943;
idb.iid(70916).socket='MY';
idb.iid(70916).sbstat='sta';
idb.iid(70916).sbval=45;
idb.iid(70916).atype=1;
idb.iid(70916).isreforged=0;

idb.iid(70948).name='Immolation Faceguard';
idb.iid(70948).ilvl=378;
idb.iid(70948).str=250;
idb.iid(70948).sta=611;
idb.iid(70948).exp=166;
idb.iid(70948).parry=388;
idb.iid(70948).barmor=2943;
idb.iid(70948).socket='MB';
idb.iid(70948).sbstat='sta';
idb.iid(70948).sbval=45;
idb.iid(70948).atype=1;
idb.iid(70948).isreforged=0;
idb.iid(70948).istierP=[0 1 0];

idb.iid(72842).name='Annihilan Helm';
idb.iid(72842).ilvl=378;
idb.iid(72842).str=346;
idb.iid(72842).sta=611;
idb.iid(72842).mast=216;
idb.iid(72842).parry=260;
idb.iid(72842).barmor=2943;
idb.iid(72842).socket='MR';
idb.iid(72842).sbstat='exp';
idb.iid(72842).sbval=30;
idb.iid(72842).atype=1;
idb.iid(72842).isreforged=0;

idb.iid(78790).name='Faceguard of Radiant Glory (Raidfinder)';
idb.iid(78790).ilvl=384;
idb.iid(78790).str=267;
idb.iid(78790).sta=646;
idb.iid(78790).mast=194;
idb.iid(78790).dodge=395;
idb.iid(78790).barmor=2995;
idb.iid(78790).socket='MY';
idb.iid(78790).sbstat='dodge';
idb.iid(78790).sbval=30;
idb.iid(78790).atype=1;
idb.iid(78790).isreforged=0;
idb.iid(78790).istierP=[0 0 1];

idb.iid(78615).name='Jaw of Repudiation';
idb.iid(78615).ilvl=384;
idb.iid(78615).str=248;
idb.iid(78615).sta=646;
idb.iid(78615).exp=200;
idb.iid(78615).parry=423;
idb.iid(78615).barmor=2995;
idb.iid(78615).socket='MB';
idb.iid(78615).sbstat='parry';
idb.iid(78615).sbval=30;
idb.iid(78615).atype=1;
idb.iid(78615).isreforged=0;

idb.iid(71459).name='Helm of Blazing Glory (Heroic)';
idb.iid(71459).ilvl=391;
idb.iid(71459).str=400;
idb.iid(71459).sta=689;
idb.iid(71459).mast=224;
idb.iid(71459).parry=320;
idb.iid(71459).barmor=3057;
idb.iid(71459).socket='MY';
idb.iid(71459).sbstat='sta';
idb.iid(71459).sbval=45;
idb.iid(71459).atype=1;
idb.iid(71459).isreforged=0;

idb.iid(71524).name='Immolation Faceguard (Heroic)';
idb.iid(71524).ilvl=391;
idb.iid(71524).str=289;
idb.iid(71524).sta=689;
idb.iid(71524).exp=193;
idb.iid(71524).parry=440;
idb.iid(71524).barmor=3057;
idb.iid(71524).socket='MB';
idb.iid(71524).sbstat='sta';
idb.iid(71524).sbval=45;
idb.iid(71524).atype=1;
idb.iid(71524).isreforged=0;
idb.iid(71524).istierP=[0 1 0];

idb.iid(77156).name='Jaw of Repudiation';
idb.iid(77156).ilvl=397;
idb.iid(77156).str=288;
idb.iid(77156).sta=730;
idb.iid(77156).exp=233;
idb.iid(77156).parry=478;
idb.iid(77156).barmor=3111;
idb.iid(77156).socket='MB';
idb.iid(77156).sbstat='parry';
idb.iid(77156).sbval=30;
idb.iid(77156).atype=1;
idb.iid(77156).isreforged=0;

idb.iid(77005).name='Faceguard of Radiant Glory';
idb.iid(77005).ilvl=397;
idb.iid(77005).str=310;
idb.iid(77005).sta=730;
idb.iid(77005).mast=222;
idb.iid(77005).dodge=450;
idb.iid(77005).barmor=3111;
idb.iid(77005).socket='MY';
idb.iid(77005).sbstat='dodge';
idb.iid(77005).sbval=30;
idb.iid(77005).atype=1;
idb.iid(77005).isreforged=0;
idb.iid(77005).istierP=[0 0 1];

idb.iid(78535).name='Jaw of Repudiation (Heroic)';
idb.iid(78535).ilvl=410;
idb.iid(78535).str=333;
idb.iid(78535).sta=824;
idb.iid(78535).exp=269;
idb.iid(78535).parry=541;
idb.iid(78535).barmor=3231;
idb.iid(78535).socket='MB';
idb.iid(78535).sbstat='parry';
idb.iid(78535).sbval=30;
idb.iid(78535).atype=1;
idb.iid(78535).isreforged=0;

idb.iid(78695).name='Faceguard of Radiant Glory (Heroic)';
idb.iid(78695).ilvl=410;
idb.iid(78695).str=357;
idb.iid(78695).sta=824;
idb.iid(78695).mast=254;
idb.iid(78695).dodge=513;
idb.iid(78695).barmor=3231;
idb.iid(78695).socket='MY';
idb.iid(78695).sbstat='dodge';
idb.iid(78695).sbval=30;
idb.iid(78695).atype=1;
idb.iid(78695).isreforged=0;
idb.iid(78695).istierP=[0 0 1];

%% Neck 

idb.iid(69635).name='Amulet of Protection';
idb.iid(69635).ilvl=353;
idb.iid(69635).str=180;
idb.iid(69635).sta=270;
idb.iid(69635).mast=102;
idb.iid(69635).dodge=130;
idb.iid(69635).isreforged=0;

idb.iid(59319).name='Ironstar Amulet';
idb.iid(59319).ilvl=359;
idb.iid(59319).str=145;
idb.iid(59319).sta=286;
idb.iid(59319).hit=96;
idb.iid(59319).dodge=190;
idb.iid(59319).isreforged=0;

idb.iid(70107).name='Fireheart Necklace';
idb.iid(70107).ilvl=365;
idb.iid(70107).str=201;
idb.iid(70107).sta=301;
idb.iid(70107).exp=136;
idb.iid(70107).mast=131;
idb.iid(70107).isreforged=0;

idb.iid(65059).name='Ironstar Amulet (Heroic)';
idb.iid(65059).ilvl=372;
idb.iid(65059).str=163;
idb.iid(65059).sta=322;
idb.iid(65059).hit=109;
idb.iid(65059).dodge=215;
idb.iid(65059).isreforged=0;

idb.iid(70935).name='Stoneheart Necklace';
idb.iid(70935).ilvl=378;
idb.iid(70935).str=227;
idb.iid(70935).sta=341;
idb.iid(70935).mast=165;
idb.iid(70935).parry=129;
idb.iid(70935).isreforged=0;

idb.iid(76162).name='Twilight Amulet';
idb.iid(76162).ilvl=378;
idb.iid(76162).str=226;
idb.iid(76162).sta=341;
idb.iid(76162).mast=167;
idb.iid(76162).dodge=126;
idb.iid(76162).isreforged=0;

idb.iid(78623).name='Guardspike Choker (Raidfinder)';
idb.iid(78623).ilvl=384;
idb.iid(78623).str=240;
idb.iid(78623).sta=360;
idb.iid(78623).mast=144;
idb.iid(78623).dodge=169;
idb.iid(78623).isreforged=0;

idb.iid(71589).name='Stoneheart Necklace (Heroic)';
idb.iid(71589).ilvl=391;
idb.iid(71589).str=256;
idb.iid(71589).sta=384;
idb.iid(71589).mast=186;
idb.iid(71589).parry=146;
idb.iid(71589).isreforged=0;

idb.iid(77092).name='Guardspike Choker';
idb.iid(77092).ilvl=397;
idb.iid(77092).str=271;
idb.iid(77092).sta=406;
idb.iid(77092).mast=163;
idb.iid(77092).dodge=191;
idb.iid(77092).isreforged=0;

idb.iid(78544).name='Guardspike Choker (Heroic)';
idb.iid(78544).ilvl=410;
idb.iid(78544).str=306;
idb.iid(78544).sta=459;
idb.iid(78544).mast=184;
idb.iid(78544).dodge=216;
idb.iid(78544).isreforged=0;

%% Shoulder

idb.iid(69573).name='Pauldrons of Sacrifice';
idb.iid(69573).ilvl=353;
idb.iid(69573).str=219;
idb.iid(69573).sta=360;
idb.iid(69573).mast=136;
idb.iid(69573).parry=162;
idb.iid(69573).barmor=2525;
idb.iid(69573).socket='R';
idb.iid(69573).sbstat='sta';
idb.iid(69573).sbval=15;
idb.iid(69573).atype=1;
idb.iid(69573).isreforged=0;

idb.iid(60358).name='Reinforced Sapphirium Shoulderguards';
idb.iid(60358).ilvl=359;
idb.iid(60358).str=193;
idb.iid(60358).sta=380;
idb.iid(60358).hit=128;
idb.iid(60358).dodge=213;
idb.iid(60358).barmor=2570;
idb.iid(60358).socket='R';
idb.iid(60358).sbstat='sta';
idb.iid(60358).sbval=15;
idb.iid(60358).atype=1;
idb.iid(60358).isreforged=0;
idb.iid(60358).istierP=[1 0 0];

idb.iid(65228).name='Reinforced Sapphirium Shoulderguards (Heroic)';
idb.iid(65228).ilvl=372;
idb.iid(65228).str=217;
idb.iid(65228).sta=429;
idb.iid(65228).hit=145;
idb.iid(65228).dodge=246;
idb.iid(65228).barmor=2669;
idb.iid(65228).socket='R';
idb.iid(65228).sbstat='sta';
idb.iid(65228).sbval=15;
idb.iid(65228).atype=1;
idb.iid(65228).isreforged=0;
idb.iid(65228).istierP=[1 0 0];

idb.iid(70737).name='Spaulders of Recurring Flame';
idb.iid(70737).ilvl=378;
idb.iid(70737).str=282;
idb.iid(70737).sta=454;
idb.iid(70737).dodge=207;
idb.iid(70737).parry=164;
idb.iid(70737).barmor=2716;
idb.iid(70737).socket='B';
idb.iid(70737).sbstat='sta';
idb.iid(70737).sbval=15;
idb.iid(70737).atype=1;
idb.iid(70737).isreforged=0;

idb.iid(70946).name='Immolation Shoulderguards';
idb.iid(70946).ilvl=378;
idb.iid(70946).str=196;
idb.iid(70946).sta=454;
idb.iid(70946).hit=177;
idb.iid(70946).mast=282;
idb.iid(70946).barmor=2716;
idb.iid(70946).socket='Y';
idb.iid(70946).sbstat='sta';
idb.iid(70946).sbval=15;
idb.iid(70946).atype=1;
idb.iid(70946).isreforged=0;
idb.iid(70946).istierP=[0 1 0];

idb.iid(72861).name='Pauldrons of the Dragonblight';
idb.iid(72861).ilvl=378;
idb.iid(72861).str=281;
idb.iid(72861).sta=454;
idb.iid(72861).dodge=169;
idb.iid(72861).parry=206;
idb.iid(72861).barmor=2716;
idb.iid(72861).socket='B';
idb.iid(72861).sbstat='sta';
idb.iid(72861).sbval=15;
idb.iid(72861).atype=1;
idb.iid(72861).isreforged=0;

idb.iid(78840).name='Shoulderguards of Radiant Glory (Raidfinder)';
idb.iid(78840).ilvl=384;
idb.iid(78840).str=189;
idb.iid(78840).sta=480;
idb.iid(78840).exp=175;
idb.iid(78840).parry=292;
idb.iid(78840).barmor=2764;
idb.iid(78840).socket='YB';
idb.iid(78840).sbstat='parry';
idb.iid(78840).sbval=20;
idb.iid(78840).atype=1;
idb.iid(78840).isreforged=0;
idb.iid(78840).istierP=[0 0 1];

idb.iid(78378).name='Brackenshell Shoulderplates (Raidfinder)';
idb.iid(78378).ilvl=384;
idb.iid(78378).str=223;
idb.iid(78378).sta=480;
idb.iid(78378).dodge=320;
idb.iid(78378).parry=142;
idb.iid(78378).barmor=2764;
idb.iid(78378).socket='Y';
idb.iid(78378).sbstat='dodge';
idb.iid(78378).sbval=10;
idb.iid(78378).atype=1;
idb.iid(78378).isreforged=0;

idb.iid(70921).name='Pauldrons of Roaring Flame';
idb.iid(70921).ilvl=384;
idb.iid(70921).str=223;
idb.iid(70921).sta=480;
idb.iid(70921).mast=142;
idb.iid(70921).dodge=320;
idb.iid(70921).barmor=2764;
idb.iid(70921).socket='Y';
idb.iid(70921).sbstat='sta';
idb.iid(70921).sbval=15;
idb.iid(70921).atype=1;
idb.iid(70921).isreforged=0;

idb.iid(71432).name='Spaulders of Recurring Flame (Heroic)';
idb.iid(71432).ilvl=391;
idb.iid(71432).str=322;
idb.iid(71432).sta=513;
idb.iid(71432).dodge=236;
idb.iid(71432).parry=186;
idb.iid(71432).barmor=2822;
idb.iid(71432).socket='B';
idb.iid(71432).sbstat='sta';
idb.iid(71432).sbval=15;
idb.iid(71432).atype=1;
idb.iid(71432).isreforged=0;

idb.iid(71526).name='Immolation Shoulderguards (Heroic)';
idb.iid(71526).ilvl=391;
idb.iid(71526).str=224;
idb.iid(71526).sta=513;
idb.iid(71526).hit=200;
idb.iid(71526).mast=322;
idb.iid(71526).barmor=2822;
idb.iid(71526).socket='Y';
idb.iid(71526).sbstat='sta';
idb.iid(71526).sbval=15;
idb.iid(71526).atype=1;
idb.iid(71526).isreforged=0;
idb.iid(71526).istierP=[0 1 0];

idb.iid(77268).name='Brackenshell Shoulderplates';
idb.iid(77268).ilvl=397;
idb.iid(77268).str=255;
idb.iid(77268).sta=542;
idb.iid(77268).dodge=361;
idb.iid(77268).parry=163;
idb.iid(77268).barmor=2871;
idb.iid(77268).socket='Y';
idb.iid(77268).sbstat='dodge';
idb.iid(77268).sbval=10;
idb.iid(77268).atype=1;
idb.iid(77268).isreforged=0;

idb.iid(77007).name='Shoulderguards of Radiant Glory';
idb.iid(77007).ilvl=397;
idb.iid(77007).str=218;
idb.iid(77007).sta=542;
idb.iid(77007).exp=199;
idb.iid(77007).parry=333;
idb.iid(77007).barmor=2871;
idb.iid(77007).socket='YB';
idb.iid(77007).sbstat='parry';
idb.iid(77007).sbval=20;
idb.iid(77007).atype=1;
idb.iid(77007).isreforged=0;
idb.iid(77007).istierP=[0 0 1];

idb.iid(71612).name='Pauldrons of Roaring Flame (Heroic)';
idb.iid(71612).ilvl=397;
idb.iid(71612).str=255;
idb.iid(71612).sta=542;
idb.iid(71612).mast=163;
idb.iid(71612).dodge=361;
idb.iid(71612).barmor=2871;
idb.iid(71612).socket='Y';
idb.iid(71612).sbstat='sta';
idb.iid(71612).sbval=15;
idb.iid(71612).atype=1;
idb.iid(71612).isreforged=0;

idb.iid(78367).name='Brackenshell Shoulderplates (Heroic)';
idb.iid(78367).ilvl=410;
idb.iid(78367).str=290;
idb.iid(78367).sta=611;
idb.iid(78367).dodge=408;
idb.iid(78367).parry=186;
idb.iid(78367).barmor=2983;
idb.iid(78367).socket='Y';
idb.iid(78367).sbstat='dodge';
idb.iid(78367).sbval=10;
idb.iid(78367).atype=1;
idb.iid(78367).isreforged=0;

idb.iid(78745).name='Shoulderguards of Radiant Glory (Heroic)';
idb.iid(78745).ilvl=410;
idb.iid(78745).str=251;
idb.iid(78745).sta=611;
idb.iid(78745).exp=226;
idb.iid(78745).parry=380;
idb.iid(78745).barmor=2983;
idb.iid(78745).socket='YB';
idb.iid(78745).sbstat='parry';
idb.iid(78745).sbval=20;
idb.iid(78745).atype=1;
idb.iid(78745).isreforged=0;
idb.iid(78745).istierP=[0 0 1];

%% Cloaks

idb.iid(56549).name='Twilight Dragonscale Cloak';
idb.iid(56549).ilvl=346;
idb.iid(56549).str=128;
idb.iid(56549).sta=252;
idb.iid(56549).mast=112;
idb.iid(56549).dodge=112;
idb.iid(56549).barmor=580;
idb.iid(56549).socket='B';
idb.iid(56549).sbstat='sta';
idb.iid(56549).sbval=15;
idb.iid(56549).isreforged=0;

idb.iid(62383).name='Wrap of the Great Turtle';
idb.iid(62383).ilvl=359;
idb.iid(62383).str=190;
idb.iid(62383).sta=286;
idb.iid(62383).mast=127;
idb.iid(62383).dodge=127;
idb.iid(62383).barmor=625;
idb.iid(62383).isreforged=0;

idb.iid(71270).name='Mantle of Patience';
idb.iid(71270).ilvl=365;
idb.iid(71270).str=201;
idb.iid(71270).sta=301;
idb.iid(71270).mast=134;
idb.iid(71270).dodge=134;
idb.iid(71270).barmor=647;
idb.iid(71270).isreforged=0;

idb.iid(70930).name='Durable Flamewrath Greatcloak';
idb.iid(70930).ilvl=378;
idb.iid(70930).str=173;
idb.iid(70930).sta=341;
idb.iid(70930).hit=115;
idb.iid(70930).parry=227;
idb.iid(70930).barmor=695;
idb.iid(70930).isreforged=0;

idb.iid(71415).name='Dreadfire Drape (Heroic)';
idb.iid(71415).ilvl=391;
idb.iid(71415).sta=384;
idb.iid(71415).agi=241;
idb.iid(71415).hit=158;
idb.iid(71415).mast=113;
idb.iid(71415).barmor=745;
idb.iid(71415).socket='RR';
idb.iid(71415).sbstat='agi';
idb.iid(71415).sbval=20;
idb.iid(71415).isreforged=0;

idb.iid(72854).name='Iceward Cloak';
idb.iid(72854).ilvl=378;
idb.iid(72854).str=226;
idb.iid(72854).sta=341;
idb.iid(72854).mast=129;
idb.iid(72854).parry=165;
idb.iid(72854).barmor=695;
idb.iid(72854).isreforged=0;

idb.iid(78589).name='Indefatigable Greatcloak (Raidfinder)';
idb.iid(78589).ilvl=384;
idb.iid(78589).str=182;
idb.iid(78589).sta=360;
idb.iid(78589).exp=121;
idb.iid(78589).parry=240;
idb.iid(78589).barmor=718;
idb.iid(78589).isreforged=0;

idb.iid(77099).name='Indefatigable Greatcloak';
idb.iid(77099).ilvl=397;
idb.iid(77099).str=186;
idb.iid(77099).sta=406;
idb.iid(77099).exp=127;
idb.iid(77099).parry=261;
idb.iid(77099).barmor=769;
idb.iid(77099).socket='Y';
idb.iid(77099).sbstat='parry';
idb.iid(77099).sbval=10;
idb.iid(77099).isreforged=0;

idb.iid(78507).name='Indefatigable Greatcloak (Heroic)';
idb.iid(78507).ilvl=410;
idb.iid(78507).str=233;
idb.iid(78507).sta=459;
idb.iid(78507).exp=155;
idb.iid(78507).parry=306;
idb.iid(78507).barmor=822;
idb.iid(78507).isreforged=0;

%% Chest

idb.iid(58101).name='Chestplate of the Steadfast';
idb.iid(58101).ilvl=346;
idb.iid(58101).str=282;
idb.iid(58101).sta=454;
idb.iid(58101).mast=182;
idb.iid(58101).dodge=162;
idb.iid(58101).barmor=3298;
idb.iid(58101).socket='YB';
idb.iid(58101).sbstat='dodge';
idb.iid(58101).sbval=20;
idb.iid(58101).atype=1;
idb.iid(58101).isreforged=0;

idb.iid(60354).name='Reinforced Sapphirium Chestguard';
idb.iid(60354).ilvl=359;
idb.iid(60354).str=341;
idb.iid(60354).sta=512;
idb.iid(60354).mast=208;
idb.iid(60354).parry=168;
idb.iid(60354).barmor=3426;
idb.iid(60354).socket='RB';
idb.iid(60354).sbstat='sta';
idb.iid(60354).sbval=30;
idb.iid(60354).atype=1;
idb.iid(60354).isreforged=0;
idb.iid(60354).istierP=[1 0 0];

idb.iid(65224).name='Reinforced Sapphirium Chestguard (Heroic)';
idb.iid(65224).ilvl=372;
idb.iid(65224).str=385;
idb.iid(65224).sta=578;
idb.iid(65224).mast=237;
idb.iid(65224).parry=197;
idb.iid(65224).barmor=3559;
idb.iid(65224).socket='RB';
idb.iid(65224).sbstat='sta';
idb.iid(65224).sbval=30;
idb.iid(65224).atype=1;
idb.iid(65224).isreforged=0;
idb.iid(65224).istierP=[1 0 0];

idb.iid(70914).name='Carapace of Imbibed Flame';
idb.iid(70914).ilvl=378;
idb.iid(70914).str=368;
idb.iid(70914).sta=611;
idb.iid(70914).mast=260;
idb.iid(70914).dodge=238;
idb.iid(70914).barmor=3622;
idb.iid(70914).socket='BB';
idb.iid(70914).sbstat='sta';
idb.iid(70914).sbval=30;
idb.iid(70914).atype=1;
idb.iid(70914).isreforged=0;

idb.iid(72855).name='Corrupted Carapace';
idb.iid(72855).ilvl=378;
idb.iid(72855).str=226;
idb.iid(72855).sta=341;
idb.iid(72855).mast=165;
idb.iid(72855).dodge=129;
idb.iid(72855).barmor=12201;
idb.iid(72855).isreforged=0;

idb.iid(70950).name='Immolation Chestguard';
idb.iid(70950).ilvl=378;
idb.iid(70950).str=368;
idb.iid(70950).sta=611;
idb.iid(70950).dodge=280;
idb.iid(70950).parry=238;
idb.iid(70950).barmor=3622;
idb.iid(70950).socket='RY';
idb.iid(70950).sbstat='sta';
idb.iid(70950).sbval=30;
idb.iid(70950).atype=1;
idb.iid(70950).isreforged=0;
idb.iid(70950).istierP=[0 1 0];

idb.iid(72818).name='Breastplate of Tarnished Bronze';
idb.iid(72818).ilvl=378;
idb.iid(72818).str=366;
idb.iid(72818).sta=611;
idb.iid(72818).mast=243;
idb.iid(72818).dodge=258;
idb.iid(72818).barmor=3622;
idb.iid(72818).socket='RB';
idb.iid(72818).sbstat='sta';
idb.iid(72818).sbval=30;
idb.iid(72818).atype=1;
idb.iid(72818).isreforged=0;

idb.iid(78584).name='Chestplate of the Unshakable Titan (Raidfinder)';
idb.iid(78584).ilvl=384;
idb.iid(78584).str=391;
idb.iid(78584).sta=646;
idb.iid(78584).dodge=294;
idb.iid(78584).parry=226;
idb.iid(78584).barmor=3686;
idb.iid(78584).socket='RY';
idb.iid(78584).sbstat='dodge';
idb.iid(78584).sbval=20;
idb.iid(78584).atype=1;
idb.iid(78584).isreforged=0;

idb.iid(78827).name='Chestguard of Radiant Glory (Raidfinder)';
idb.iid(78827).ilvl=384;
idb.iid(78827).str=371;
idb.iid(78827).sta=646;
idb.iid(78827).mast=268;
idb.iid(78827).parry=241;
idb.iid(78827).barmor=3686;
idb.iid(78827).socket='RYB';
idb.iid(78827).sbstat='parry';
idb.iid(78827).sbval=30;
idb.iid(78827).atype=1;
idb.iid(78827).isreforged=0;
idb.iid(78827).istierP=[0 0 1];

idb.iid(71405).name='Carapace of Imbibed Flame (Heroic)';
idb.iid(71405).ilvl=391;
idb.iid(71405).str=420;
idb.iid(71405).sta=689;
idb.iid(71405).mast=296;
idb.iid(71405).dodge=271;
idb.iid(71405).barmor=3762;
idb.iid(71405).socket='BB';
idb.iid(71405).sbstat='sta';
idb.iid(71405).sbval=30;
idb.iid(71405).atype=1;
idb.iid(71405).isreforged=0;

idb.iid(71522).name='Immolation Chestguard (Heroic)';
idb.iid(71522).ilvl=391;
idb.iid(71522).str=420;
idb.iid(71522).sta=689;
idb.iid(71522).dodge=316;
idb.iid(71522).parry=271;
idb.iid(71522).barmor=3762;
idb.iid(71522).socket='RY';
idb.iid(71522).sbstat='sta';
idb.iid(71522).sbval=30;
idb.iid(71522).atype=1;
idb.iid(71522).isreforged=0;
idb.iid(71522).istierP=[0 1 0];

idb.iid(76874).name='Battleplate of Radiant Glory';
idb.iid(76874).ilvl=397;
idb.iid(76874).str=426;
idb.iid(76874).sta=730;
idb.iid(76874).haste=287;
idb.iid(76874).mast=301;
idb.iid(76874).barmor=3829;
idb.iid(76874).socket='RRR';
idb.iid(76874).sbstat='str';
idb.iid(76874).sbval=30;
idb.iid(76874).atype=1;
idb.iid(76874).isreforged=0;
idb.iid(76874).istierR=[0 0 1];

idb.iid(77003).name='Chestguard of Radiant Glory';
idb.iid(77003).ilvl=397;
idb.iid(77003).str=426;
idb.iid(77003).sta=730;
idb.iid(77003).mast=306;
idb.iid(77003).parry=276;
idb.iid(77003).barmor=3829;
idb.iid(77003).socket='RYB';
idb.iid(77003).sbstat='parry';
idb.iid(77003).sbval=30;
idb.iid(77003).atype=1;
idb.iid(77003).isreforged=0;
idb.iid(77003).istierP=[0 0 1];

idb.iid(77120).name='Chestplate of the Unshakable Titan';
idb.iid(77120).ilvl=397;
idb.iid(77120).str=446;
idb.iid(77120).sta=730;
idb.iid(77120).dodge=334;
idb.iid(77120).parry=259;
idb.iid(77120).barmor=3829;
idb.iid(77120).socket='RY';
idb.iid(77120).sbstat='dodge';
idb.iid(77120).sbval=20;
idb.iid(77120).atype=1;
idb.iid(77120).isreforged=0;

idb.iid(78732).name='Chestguard of Radiant Glory (Heroic)';
idb.iid(78732).ilvl=410;
idb.iid(78732).str=489;
idb.iid(78732).sta=824;
idb.iid(78732).mast=349;
idb.iid(78732).parry=316;
idb.iid(78732).barmor=3977;
idb.iid(78732).socket='RYB';
idb.iid(78732).sbstat='parry';
idb.iid(78732).sbval=30;
idb.iid(78732).atype=1;
idb.iid(78732).isreforged=0;
idb.iid(78732).istierP=[0 0 1];

idb.iid(78500).name='Chestplate of the Unshakable Titan (Heroic)';
idb.iid(78500).ilvl=410;
idb.iid(78500).str=509;
idb.iid(78500).sta=824;
idb.iid(78500).dodge=379;
idb.iid(78500).parry=295;
idb.iid(78500).barmor=3977;
idb.iid(78500).socket='RY';
idb.iid(78500).sbstat='dodge';
idb.iid(78500).sbval=20;
idb.iid(78500).atype=1;
idb.iid(78500).isreforged=0;


%% Bracers

idb.iid(57870).name='Alpha Bracers (Heroic)';
idb.iid(57870).ilvl=346;
idb.iid(57870).str=148;
idb.iid(57870).sta=252;
idb.iid(57870).hit=92;
idb.iid(57870).mast=112;
idb.iid(57870).barmor=1443;
idb.iid(57870).socket='Y';
idb.iid(57870).sbstat='mast';
idb.iid(57870).sbval=10;
idb.iid(57870).atype=1;
idb.iid(57870).isreforged=0;

idb.iid(59470).name='Bracers of Impossible Strength';
idb.iid(59470).ilvl=359;
idb.iid(59470).str=190;
idb.iid(59470).sta=286;
idb.iid(59470).mast=127;
idb.iid(59470).parry=127;
idb.iid(59470).barmor=1499;
idb.iid(59470).atype=1;
idb.iid(59470).isreforged=0;

idb.iid(70121).name='Ricket''s Gun Show';
idb.iid(70121).ilvl=365;
idb.iid(70121).str=201;
idb.iid(70121).sta=301;
idb.iid(70121).mast=111;
idb.iid(70121).parry=147;
idb.iid(70121).barmor=1525;
idb.iid(70121).atype=1;
idb.iid(70121).isreforged=0;

idb.iid(65143).name='Bracers of Impossible Strength (Heroic)';
idb.iid(65143).ilvl=372;
idb.iid(65143).str=215;
idb.iid(65143).sta=322;
idb.iid(65143).mast=143;
idb.iid(65143).parry=143;
idb.iid(65143).barmor=1557;
idb.iid(65143).atype=1;
idb.iid(65143).isreforged=0;

idb.iid(70937).name='Bracers of Regal Force';
idb.iid(70937).ilvl=378;
idb.iid(70937).str=153;
idb.iid(70937).sta=341;
idb.iid(70937).dodge=212;
idb.iid(70937).parry=110;
idb.iid(70937).barmor=1584;
idb.iid(70937).socket='Y';
idb.iid(70937).sbstat='sta';
idb.iid(70937).sbval=15;
idb.iid(70937).atype=1;
idb.iid(70937).isreforged=0;

idb.iid(70920).name='Bracers of the Fiery Path';
idb.iid(70920).ilvl=378;
idb.iid(70920).str=207;
idb.iid(70920).sta=341;
idb.iid(70920).mast=133;
idb.iid(70920).parry=149;
idb.iid(70920).barmor=1584;
idb.iid(70920).socket='B';
idb.iid(70920).sbstat='sta';
idb.iid(70920).sbval=15;
idb.iid(70920).atype=1;
idb.iid(70920).isreforged=0;

idb.iid(78397).name='Graveheart Bracers (Raidfinder)';
idb.iid(78397).ilvl=384;
idb.iid(78397).str=220;
idb.iid(78397).sta=360;
idb.iid(78397).mast=152;
idb.iid(78397).dodge=140;
idb.iid(78397).barmor=1613;
idb.iid(78397).socket='Y';
idb.iid(78397).sbstat='dodge';
idb.iid(78397).sbval=10;
idb.iid(78397).atype=1;
idb.iid(78397).isreforged=0;

idb.iid(78650).name='Bracers of Unrelenting Excellence (Raidfinder)';
idb.iid(78650).ilvl=384;
idb.iid(78650).str=240;
idb.iid(78650).sta=360;
idb.iid(78650).dodge=136;
idb.iid(78650).parry=174;
idb.iid(78650).barmor=1613;
idb.iid(78650).atype=1;
idb.iid(78650).isreforged=0;

idb.iid(71470).name='Bracers of the Fiery Path (Heroic)';
idb.iid(71470).ilvl=391;
idb.iid(71470).str=236;
idb.iid(71470).sta=384;
idb.iid(71470).mast=151;
idb.iid(71470).parry=168;
idb.iid(71470).barmor=1646;
idb.iid(71470).socket='B';
idb.iid(71470).sbstat='sta';
idb.iid(71470).sbval=15;
idb.iid(71470).atype=1;
idb.iid(71470).isreforged=0;

idb.iid(71993).name='Titanguard Wristplates';
idb.iid(71993).ilvl=397;
idb.iid(71993).str=231;
idb.iid(71993).sta=406;
idb.iid(71993).mast=147;
idb.iid(71993).parry=169;
idb.iid(71993).barmor=1675;
idb.iid(71993).socket='YY';
idb.iid(71993).sbstat='parry';
idb.iid(71993).sbval=20;
idb.iid(71993).atype=1;
idb.iid(71993).isreforged=0;

idb.iid(77318).name='Bracers of Unrelenting Excellence';
idb.iid(77318).ilvl=397;
idb.iid(77318).str=271;
idb.iid(77318).sta=406;
idb.iid(77318).dodge=154;
idb.iid(77318).parry=196;
idb.iid(77318).barmor=1675;
idb.iid(77318).atype=1;
idb.iid(77318).isreforged=0;

idb.iid(77258).name='Graveheart Bracers';
idb.iid(77258).ilvl=397;
idb.iid(77258).str=251;
idb.iid(77258).sta=406;
idb.iid(77258).mast=174;
idb.iid(77258).dodge=158;
idb.iid(77258).barmor=1675;
idb.iid(77258).socket='Y';
idb.iid(77258).sbstat='dodge';
idb.iid(77258).sbval=10;
idb.iid(77258).atype=1;
idb.iid(77258).isreforged=0;

idb.iid(78570).name='Bracers of Unrelenting Excellence (Heroic)';
idb.iid(78570).ilvl=410;
idb.iid(78570).str=306;
idb.iid(78570).sta=459;
idb.iid(78570).dodge=174;
idb.iid(78570).parry=222;
idb.iid(78570).barmor=1740;
idb.iid(78570).atype=1;
idb.iid(78570).isreforged=0;

idb.iid(78390).name='Graveheart Bracers (Heroic)';
idb.iid(78390).ilvl=410;
idb.iid(78390).str=286;
idb.iid(78390).sta=459;
idb.iid(78390).mast=199;
idb.iid(78390).dodge=179;
idb.iid(78390).barmor=1740;
idb.iid(78390).socket='Y';
idb.iid(78390).sbstat='dodge';
idb.iid(78390).sbval=10;
idb.iid(78390).atype=1;
idb.iid(78390).isreforged=0;


%% Gloves

idb.iid(58105).name='Numbing Handguards';
idb.iid(58105).ilvl=346;
idb.iid(58105).str=215;
idb.iid(58105).sta=337;
idb.iid(58105).mast=140;
idb.iid(58105).dodge=130;
idb.iid(58105).barmor=2061;
idb.iid(58105).socket='B';
idb.iid(58105).sbstat='dodge';
idb.iid(58105).sbval=10;
idb.iid(58105).atype=1;
idb.iid(58105).isreforged=0;

idb.iid(60355).name='Reinforced Sapphirium Handguards';
idb.iid(60355).ilvl=359;
idb.iid(60355).str=253;
idb.iid(60355).sta=380;
idb.iid(60355).mast=149;
idb.iid(60355).parry=149;
idb.iid(60355).barmor=2141;
idb.iid(60355).socket='B';
idb.iid(60355).sbstat='mast';
idb.iid(60355).sbval=10;
idb.iid(60355).atype=1;
idb.iid(60355).isreforged=0;
idb.iid(60355).istierP=[1 0 0];

idb.iid(65225).name='Reinforced Sapphirium Handguards (Heroic)';
idb.iid(65225).ilvl=372;
idb.iid(65225).str=286;
idb.iid(65225).sta=429;
idb.iid(65225).mast=171;
idb.iid(65225).parry=171;
idb.iid(65225).barmor=2224;
idb.iid(65225).socket='B';
idb.iid(65225).sbstat='mast';
idb.iid(65225).sbval=10;
idb.iid(65225).atype=1;
idb.iid(65225).isreforged=0;
idb.iid(65225).istierP=[1 0 0];

idb.iid(69937).name='Eternal Elementium Handguards';
idb.iid(69937).ilvl=378;
idb.iid(69937).str=282;
idb.iid(69937).sta=454;
idb.iid(69937).mast=187;
idb.iid(69937).parry=197;
idb.iid(69937).barmor=2264;
idb.iid(69937).socket='R';
idb.iid(69937).sbstat='sta';
idb.iid(69937).sbval=15;
idb.iid(69937).atype=1;
idb.iid(69937).isreforged=0;

idb.iid(70949).name='Immolation Handguards';
idb.iid(70949).ilvl=378;
idb.iid(70949).str=282;
idb.iid(70949).sta=454;
idb.iid(70949).mast=205;
idb.iid(70949).dodge=177;
idb.iid(70949).barmor=2264;
idb.iid(70949).socket='R';
idb.iid(70949).sbstat='sta';
idb.iid(70949).sbval=15;
idb.iid(70949).atype=1;
idb.iid(70949).isreforged=0;
idb.iid(70949).istierP=[0 1 0];

idb.iid(72800).name='Gauntlets of Temporal Interference';
idb.iid(72800).ilvl=378;
idb.iid(72800).str=281;
idb.iid(72800).sta=454;
idb.iid(72800).mast=157;
idb.iid(72800).dodge=211;
idb.iid(72800).barmor=2264;
idb.iid(72800).socket='B';
idb.iid(72800).sbstat='sta';
idb.iid(72800).sbval=15;
idb.iid(72800).atype=1;
idb.iid(72800).isreforged=0;

idb.iid(78606).name='Gauntlets of Feathery Blows (Raidfinder)';
idb.iid(78606).ilvl=384;
idb.iid(78606).str=300;
idb.iid(78606).sta=480;
idb.iid(78606).exp=150;
idb.iid(78606).parry=235;
idb.iid(78606).barmor=2304;
idb.iid(78606).socket='B';
idb.iid(78606).sbstat='parry';
idb.iid(78606).sbval=10;
idb.iid(78606).atype=1;
idb.iid(78606).isreforged=0;

idb.iid(78772).name='Handguards of Radiant Glory (Raidfinder)';
idb.iid(78772).ilvl=384;
idb.iid(78772).str=203;
idb.iid(78772).sta=480;
idb.iid(78772).hit=132;
idb.iid(78772).dodge=310;
idb.iid(78772).barmor=2304;
idb.iid(78772).socket='Y';
idb.iid(78772).sbstat='dodge';
idb.iid(78772).sbval=10;
idb.iid(78772).atype=1;
idb.iid(78772).isreforged=0;
idb.iid(78772).istierP=[0 0 1];

idb.iid(71523).name='Immolation Handguards (Heroic)';
idb.iid(71523).ilvl=391;
idb.iid(71523).str=322;
idb.iid(71523).sta=513;
idb.iid(71523).mast=231;
idb.iid(71523).dodge=202;
idb.iid(71523).barmor=2351;
idb.iid(71523).socket='R';
idb.iid(71523).sbstat='sta';
idb.iid(71523).sbval=15;
idb.iid(71523).atype=1;
idb.iid(71523).isreforged=0;
idb.iid(71523).istierP=[0 1 0];

idb.iid(77166).name='Gauntlets of Feathery Blows';
idb.iid(77166).ilvl=397;
idb.iid(77166).str=341;
idb.iid(77166).sta=542;
idb.iid(77166).exp=171;
idb.iid(77166).parry=267;
idb.iid(77166).barmor=2393;
idb.iid(77166).socket='B';
idb.iid(77166).sbstat='parry';
idb.iid(77166).sbval=10;
idb.iid(77166).atype=1;
idb.iid(77166).isreforged=0;

idb.iid(77004).name='Handguards of Radiant Glory';
idb.iid(77004).ilvl=397;
idb.iid(77004).str=235;
idb.iid(77004).sta=542;
idb.iid(77004).hit=153;
idb.iid(77004).dodge=351;
idb.iid(77004).barmor=2393;
idb.iid(77004).socket='Y';
idb.iid(77004).sbstat='dodge';
idb.iid(77004).sbval=10;
idb.iid(77004).atype=1;
idb.iid(77004).isreforged=0;
idb.iid(77004).istierP=[0 0 1];

idb.iid(78526).name='Gauntlets of Feathery Blows (Heroic)';
idb.iid(78526).ilvl=410;
idb.iid(78526).str=388;
idb.iid(78526).sta=611;
idb.iid(78526).exp=194;
idb.iid(78526).parry=302;
idb.iid(78526).barmor=2486;
idb.iid(78526).socket='B';
idb.iid(78526).sbstat='parry';
idb.iid(78526).sbval=10;
idb.iid(78526).atype=1;
idb.iid(78526).isreforged=0;

idb.iid(78677).name='Handguards of Radiant Glory (Heroic)';
idb.iid(78677).ilvl=410;
idb.iid(78677).str=270;
idb.iid(78677).sta=611;
idb.iid(78677).hit=176;
idb.iid(78677).dodge=398;
idb.iid(78677).barmor=2486;
idb.iid(78677).socket='Y';
idb.iid(78677).sbstat='dodge';
idb.iid(78677).sbval=10;
idb.iid(78677).atype=1;
idb.iid(78677).isreforged=0;
idb.iid(78677).istierP=[0 0 1];

%% Belts

idb.iid(55059).name='Hardened Elementium Girdle';
idb.iid(55059).ilvl=359;
idb.iid(55059).str=233;
idb.iid(55059).sta=380;
idb.iid(55059).mast=149;
idb.iid(55059).dodge=169;
idb.iid(55059).barmor=1927;
idb.iid(55059).socket='B';
idb.iid(55059).sbstat='dodge';
idb.iid(55059).sbval=10;
idb.iid(55059).atype=1;
idb.iid(55059).isreforged=0;

idb.iid(59117).name='Jumbotron Power Belt';
idb.iid(59117).ilvl=359;
idb.iid(59117).str=253;
idb.iid(59117).sta=380;
idb.iid(59117).mast=159;
idb.iid(59117).dodge=139;
idb.iid(59117).barmor=1927;
idb.iid(59117).socket='Y';
idb.iid(59117).sbstat='sta';
idb.iid(59117).sbval=15;
idb.iid(59117).atype=1;
idb.iid(59117).isreforged=0;

idb.iid(65086).name='Jumbotron Power Belt (Heroic)';
idb.iid(65086).ilvl=372;
idb.iid(65086).str=286;
idb.iid(65086).sta=429;
idb.iid(65086).mast=181;
idb.iid(65086).dodge=161;
idb.iid(65086).barmor=2002;
idb.iid(65086).socket='Y';
idb.iid(65086).sbstat='sta';
idb.iid(65086).sbval=15;
idb.iid(65086).atype=1;
idb.iid(65086).isreforged=0;

idb.iid(71021).name='Uncrushable Belt of Fury';
idb.iid(71021).ilvl=378;
idb.iid(71021).str=210;
idb.iid(71021).sta=454;
idb.iid(71021).exp=133;
idb.iid(71021).mast=302;
idb.iid(71021).barmor=2037;
idb.iid(71021).socket='Y';
idb.iid(71021).sbstat='sta';
idb.iid(71021).sbval=15;
idb.iid(71021).atype=1;
idb.iid(71021).isreforged=0;

idb.iid(72803).name='Girdle of Lost Heroes';
idb.iid(72803).ilvl=378;
idb.iid(72803).str=281;
idb.iid(72803).sta=454;
idb.iid(72803).mast=228;
idb.iid(72803).parry=135;
idb.iid(72803).barmor=2037;
idb.iid(72803).socket='R';
idb.iid(72803).sbstat='mast';
idb.iid(72803).sbval=10;
idb.iid(72803).atype=1;
idb.iid(72803).isreforged=0;

idb.iid(78460).name='Goriona''s Collar (Raidfinder)';
idb.iid(78460).ilvl=384;
idb.iid(78460).str=280;
idb.iid(78460).sta=480;
idb.iid(78460).dodge=201;
idb.iid(78460).parry=184;
idb.iid(78460).barmor=2073;
idb.iid(78460).socket='YY';
idb.iid(78460).sbstat='dodge';
idb.iid(78460).sbval=20;
idb.iid(78460).atype=1;
idb.iid(78460).isreforged=0;

idb.iid(78646).name='Forgesmelter Waistplate (Raidfinder)';
idb.iid(78646).ilvl=384;
idb.iid(78646).str=280;
idb.iid(78646).sta=480;
idb.iid(78646).mast=193;
idb.iid(78646).parry=190;
idb.iid(78646).barmor=2073;
idb.iid(78646).socket='RB';
idb.iid(78646).sbstat='mast';
idb.iid(78646).sbval=20;
idb.iid(78646).atype=1;
idb.iid(78646).isreforged=0;

idb.iid(71400).name='Girdle of the Indomitable Flame (Heroic)';
idb.iid(71400).ilvl=391;
idb.iid(71400).str=322;
idb.iid(71400).sta=513;
idb.iid(71400).dodge=235;
idb.iid(71400).parry=197;
idb.iid(71400).barmor=2116;
idb.iid(71400).socket='B';
idb.iid(71400).sbstat='sta';
idb.iid(71400).sbval=15;
idb.iid(71400).atype=1;
idb.iid(71400).isreforged=0;

idb.iid(71443).name='Uncrushable Belt of Fury (Heroic)';
idb.iid(71443).ilvl=391;
idb.iid(71443).str=240;
idb.iid(71443).sta=513;
idb.iid(71443).exp=153;
idb.iid(71443).mast=342;
idb.iid(71443).barmor=2116;
idb.iid(71443).socket='Y';
idb.iid(71443).sbstat='sta';
idb.iid(71443).sbval=15;
idb.iid(71443).atype=1;
idb.iid(71443).isreforged=0;

idb.iid(71400).name='Girdle of the Indomitable Flame (Heroic)';
idb.iid(71400).ilvl=391;
idb.iid(71400).str=322;
idb.iid(71400).sta=513;
idb.iid(71400).dodge=235;
idb.iid(71400).parry=197;
idb.iid(71400).barmor=2116;
idb.iid(71400).socket='B';
idb.iid(71400).sbstat='sta';
idb.iid(71400).sbval=15;
idb.iid(71400).atype=1;
idb.iid(71400).isreforged=0;

idb.iid(78889).name='Waistplate of the Desecrated Future';
idb.iid(78889).ilvl=397;
idb.iid(78889).str=341;
idb.iid(78889).sta=542;
idb.iid(78889).hit=224;
idb.iid(78889).parry=233;
idb.iid(78889).barmor=2154;
idb.iid(78889).socket='B';
idb.iid(78889).sbstat='parry';
idb.iid(78889).sbval=10;
idb.iid(78889).atype=1;
idb.iid(78889).isreforged=0;

idb.iid(77239).name='Goriona''s Collar';
idb.iid(77239).ilvl=397;
idb.iid(77239).str=321;
idb.iid(77239).sta=542;
idb.iid(77239).dodge=229;
idb.iid(77239).parry=211;
idb.iid(77239).barmor=2154;
idb.iid(77239).socket='YY';
idb.iid(77239).sbstat='dodge';
idb.iid(77239).sbval=20;
idb.iid(77239).atype=1;
idb.iid(77239).isreforged=0;

idb.iid(77186).name='Forgesmelter Waistplate';
idb.iid(77186).ilvl=397;
idb.iid(77186).str=321;
idb.iid(77186).sta=542;
idb.iid(77186).mast=221;
idb.iid(77186).parry=216;
idb.iid(77186).barmor=2154;
idb.iid(77186).socket='RB';
idb.iid(77186).sbstat='mast';
idb.iid(77186).sbval=20;
idb.iid(77186).atype=1;
idb.iid(77186).isreforged=0;

idb.iid(78560).name='Forgesmelter Waistplate (Heroic)';
idb.iid(78560).ilvl=410;
idb.iid(78560).str=368;
idb.iid(78560).sta=611;
idb.iid(78560).mast=253;
idb.iid(78560).parry=245;
idb.iid(78560).barmor=2237;
idb.iid(78560).socket='RB';
idb.iid(78560).sbstat='mast';
idb.iid(78560).sbval=20;
idb.iid(78560).atype=1;
idb.iid(78560).isreforged=0;

idb.iid(78452).name='Goriona''s Collar (Heroic)';
idb.iid(78452).ilvl=410;
idb.iid(78452).str=368;
idb.iid(78452).sta=611;
idb.iid(78452).dodge=260;
idb.iid(78452).parry=241;
idb.iid(78452).barmor=2237;
idb.iid(78452).socket='YY';
idb.iid(78452).sbstat='dodge';
idb.iid(78452).sbval=20;
idb.iid(78452).atype=1;
idb.iid(78452).isreforged=0;

%% Legs

idb.iid(69583).name='Legguards of the Unforgiving';
idb.iid(69583).ilvl=353;
idb.iid(69583).str=283;
idb.iid(69583).sta=484;
idb.iid(69583).mast=192;
idb.iid(69583).parry=197;
idb.iid(69583).barmor=2946;
idb.iid(69583).socket='RY';
idb.iid(69583).sbstat='parry';
idb.iid(69583).sbval=20;
idb.iid(69583).atype=1;
idb.iid(69583).isreforged=0;

idb.iid(60357).name='Reinforced Sapphirium Legguards';
idb.iid(60357).ilvl=359;
idb.iid(60357).str=301;
idb.iid(60357).sta=512;
idb.iid(60357).dodge=188;
idb.iid(60357).parry=228;
idb.iid(60357).barmor=2998;
idb.iid(60357).socket='RB';
idb.iid(60357).sbstat='sta';
idb.iid(60357).sbval=30;
idb.iid(60357).atype=1;
idb.iid(60357).isreforged=0;
idb.iid(60357).istierP=[1 0 0];

idb.iid(65227).name='Reinforced Sapphirium Legguards (Heroic)';
idb.iid(65227).ilvl=372;
idb.iid(65227).str=345;
idb.iid(65227).sta=578;
idb.iid(65227).dodge=217;
idb.iid(65227).parry=257;
idb.iid(65227).barmor=3114;
idb.iid(65227).socket='RB';
idb.iid(65227).sbstat='sta';
idb.iid(65227).sbval=30;
idb.iid(65227).atype=1;
idb.iid(65227).isreforged=0;
idb.iid(65227).istierP=[1 0 0];

idb.iid(70947).name='Immolation Legguards';
idb.iid(70947).ilvl=378;
idb.iid(70947).str=368;
idb.iid(70947).sta=611;
idb.iid(70947).mast=252;
idb.iid(70947).parry=244;
idb.iid(70947).barmor=3169;
idb.iid(70947).socket='RB';
idb.iid(70947).sbstat='sta';
idb.iid(70947).sbval=30;
idb.iid(70947).atype=1;
idb.iid(70947).isreforged=0;
idb.iid(70947).istierP=[0 1 0];

idb.iid(72815).name='Bloodhoof Legguards';
idb.iid(72815).ilvl=378;
idb.iid(72815).str=366;
idb.iid(72815).sta=611;
idb.iid(72815).dodge=230;
idb.iid(72815).parry=263;
idb.iid(72815).barmor=3169;
idb.iid(72815).socket='RY';
idb.iid(72815).sbstat='sta';
idb.iid(72815).sbval=30;
idb.iid(72815).atype=1;
idb.iid(72815).isreforged=0;

idb.iid(78810).name='Legguards of Radiant Glory (Raidfinder)';
idb.iid(78810).ilvl=384;
idb.iid(78810).str=371;
idb.iid(78810).sta=646;
idb.iid(78810).dodge=246;
idb.iid(78810).parry=260;
idb.iid(78810).barmor=3225;
idb.iid(78810).socket='RYB';
idb.iid(78810).sbstat='parry';
idb.iid(78810).sbval=30;
idb.iid(78810).atype=1;
idb.iid(78810).isreforged=0;
idb.iid(78810).istierP=[0 0 1];

idb.iid(71525).name='Immolation Legguards (Heroic)';
idb.iid(71525).ilvl=391;
idb.iid(71525).str=420;
idb.iid(71525).sta=689;
idb.iid(71525).mast=284;
idb.iid(71525).parry=280;
idb.iid(71525).barmor=3292;
idb.iid(71525).socket='RB';
idb.iid(71525).sbstat='sta';
idb.iid(71525).sbval=30;
idb.iid(71525).atype=1;
idb.iid(71525).isreforged=0;
idb.iid(71525).istierP=[0 1 0];

idb.iid(77006).name='Legguards of Radiant Glory';
idb.iid(77006).ilvl=397;
idb.iid(77006).str=426;
idb.iid(77006).sta=730;
idb.iid(77006).dodge=280;
idb.iid(77006).parry=299;
idb.iid(77006).barmor=3350;
idb.iid(77006).socket='RYB';
idb.iid(77006).sbstat='parry';
idb.iid(77006).sbval=30;
idb.iid(77006).atype=1;
idb.iid(77006).isreforged=0;
idb.iid(77006).istierP=[0 0 1];

idb.iid(71984).name='Foundations of Courage';
idb.iid(71984).ilvl=397;
idb.iid(71984).str=426;
idb.iid(71984).sta=730;
idb.iid(71984).mast=260;
idb.iid(71984).dodge=319;
idb.iid(71984).barmor=3350;
idb.iid(71984).socket='YBB';
idb.iid(71984).sbstat='mast';
idb.iid(71984).sbval=30;
idb.iid(71984).atype=1;
idb.iid(71984).isreforged=0;

idb.iid(78715).name='Legguards of Radiant Glory (Heroic)';
idb.iid(78715).ilvl=410;
idb.iid(78715).str=489;
idb.iid(78715).sta=824;
idb.iid(78715).dodge=319;
idb.iid(78715).parry=342;
idb.iid(78715).barmor=3480;
idb.iid(78715).socket='RYB';
idb.iid(78715).sbstat='parry';
idb.iid(78715).sbval=30;
idb.iid(78715).atype=1;
idb.iid(78715).isreforged=0;
idb.iid(78715).istierP=[0 0 1];


%% Boots

% Boots of Sullen Rock (H) = Gryphon's Rider Boots (A)
idb.iid(62418).name='Boots of Sullen Rock';
idb.iid(62418).ilvl=359;
idb.iid(62418).str=253;
idb.iid(62418).sta=380;
idb.iid(62418).mast=159;
idb.iid(62418).parry=139;
idb.iid(62418).barmor=2355;
idb.iid(62418).socket='Y';
idb.iid(62418).sbstat='parry';
idb.iid(62418).sbval=10;
idb.iid(62418).atype=1;
idb.iid(62418).isreforged=0;

idb.iid(65051).name='Molten Tantrum Boots (Heroic)';
idb.iid(65051).ilvl=372;
idb.iid(65051).str=286;
idb.iid(65051).sta=429;
idb.iid(65051).mast=147;
idb.iid(65051).dodge=185;
idb.iid(65051).barmor=2447;
idb.iid(65051).socket='Y';
idb.iid(65051).sbstat='sta';
idb.iid(65051).sbval=15;
idb.iid(65051).atype=1;
idb.iid(65051).isreforged=0;

idb.iid(69947).name='Mirrored Boots';
idb.iid(69947).ilvl=378;
idb.iid(69947).str=282;
idb.iid(69947).sta=454;
idb.iid(69947).mast=197;
idb.iid(69947).parry=187;
idb.iid(69947).barmor=2490;
idb.iid(69947).socket='R';
idb.iid(69947).sbstat='sta';
idb.iid(69947).sbval=15;
idb.iid(69947).atype=1;
idb.iid(69947).isreforged=0;

idb.iid(72819).name='Chrono Boots';
idb.iid(72819).ilvl=378;
idb.iid(72819).str=281;
idb.iid(72819).sta=454;
idb.iid(72819).exp=186;
idb.iid(72819).dodge=198;
idb.iid(72819).barmor=2490;
idb.iid(72819).socket='Y';
idb.iid(72819).sbstat='sta';
idb.iid(72819).sbval=15;
idb.iid(72819).atype=1;
idb.iid(72819).isreforged=0;

idb.iid(78591).name='Bladeshatter Treads';
idb.iid(78591).ilvl=384;
idb.iid(78591).str=280;
idb.iid(78591).sta=480;
idb.iid(78591).dodge=189;
idb.iid(78591).parry=199;
idb.iid(78591).barmor=2534;
idb.iid(78591).socket='YB';
idb.iid(78591).sbstat='parry';
idb.iid(78591).sbval=20;
idb.iid(78591).atype=1;
idb.iid(78591).isreforged=0;

idb.iid(78439).name='Stillheart Warboots';
idb.iid(78439).ilvl=384;
idb.iid(78439).str=280;
idb.iid(78439).sta=480;
idb.iid(78439).mast=198;
idb.iid(78439).parry=183;
idb.iid(78439).barmor=2534;
idb.iid(78439).socket='RB';
idb.iid(78439).sbstat='parry';
idb.iid(78439).sbval=20;
idb.iid(78439).atype=1;
idb.iid(78439).isreforged=0;

idb.iid(71420).name='Cracked Obsidian Stompers (Heroic)';
idb.iid(71420).ilvl=391;
idb.iid(71420).str=240;
idb.iid(71420).sta=513;
idb.iid(71420).exp=173;
idb.iid(71420).dodge=322;
idb.iid(71420).barmor=2586;
idb.iid(71420).socket='B';
idb.iid(71420).sbstat='sta';
idb.iid(71420).sbval=15;
idb.iid(71420).atype=1;
idb.iid(71420).isreforged=0;

idb.iid(77171).name='Bladeshatter Treads';
idb.iid(77171).ilvl=397;
idb.iid(77171).str=321;
idb.iid(77171).sta=542;
idb.iid(77171).dodge=216;
idb.iid(77171).parry=226;
idb.iid(77171).barmor=2632;
idb.iid(77171).socket='YB';
idb.iid(77171).sbstat='parry';
idb.iid(77171).sbval=20;
idb.iid(77171).atype=1;
idb.iid(77171).isreforged=0;

idb.iid(77246).name='Stillheart Warboots';
idb.iid(77246).ilvl=397;
idb.iid(77246).str=321;
idb.iid(77246).sta=542;
idb.iid(77246).mast=227;
idb.iid(77246).parry=208;
idb.iid(77246).barmor=2632;
idb.iid(77246).socket='RB';
idb.iid(77246).sbstat='parry';
idb.iid(77246).sbval=20;
idb.iid(77246).atype=1;
idb.iid(77246).isreforged=0;

idb.iid(78431).name='Stillheart Warboots (Heroic)';
idb.iid(78431).ilvl=410;
idb.iid(78431).str=368;
idb.iid(78431).sta=611;
idb.iid(78431).mast=259;
idb.iid(78431).parry=237;
idb.iid(78431).barmor=2734;
idb.iid(78431).socket='RB';
idb.iid(78431).sbstat='parry';
idb.iid(78431).sbval=20;
idb.iid(78431).atype=1;
idb.iid(78431).isreforged=0;

idb.iid(78511).name='Bladeshatter Treads (Heroic)';
idb.iid(78511).ilvl=410;
idb.iid(78511).str=368;
idb.iid(78511).sta=611;
idb.iid(78511).dodge=247;
idb.iid(78511).parry=257;
idb.iid(78511).barmor=2734;
idb.iid(78511).socket='YB';
idb.iid(78511).sbstat='parry';
idb.iid(78511).sbval=20;
idb.iid(78511).atype=1;
idb.iid(78511).isreforged=0;


%% Rings

idb.iid(62440).name='Red Rock Band';
idb.iid(62440).ilvl=346;
idb.iid(62440).str=120;
idb.iid(62440).sta=252;
idb.iid(62440).exp=98;
idb.iid(62440).mast=168;
idb.iid(62440).isreforged=0;

idb.iid(62351).name='Felsen''s Ring of Resolve';
idb.iid(62351).ilvl=346;
idb.iid(62351).str=168;
idb.iid(62351).sta=252;
idb.iid(62351).mast=112;
idb.iid(62351).dodge=112;
idb.iid(62351).isreforged=0;

idb.iid(58187).name='Ring of the Battle Anthem';
idb.iid(58187).ilvl=359;
idb.iid(58187).str=190;
idb.iid(58187).sta=286;
idb.iid(58187).mast=127;
idb.iid(58187).dodge=127;
idb.iid(58187).isreforged=0;

idb.iid(59233).name='Bile-O-Tron Nut';
idb.iid(59233).ilvl=359;
idb.iid(59233).str=136;
idb.iid(59233).sta=286;
idb.iid(59233).exp=111;
idb.iid(59233).dodge=190;
idb.iid(59233).isreforged=0;

idb.iid(70127).name='Lylagar Horn Ring';
idb.iid(70127).ilvl=365;
idb.iid(70127).str=201;
idb.iid(70127).sta=301;
idb.iid(70127).mast=140;
idb.iid(70127).parry=124;
idb.iid(70127).isreforged=0;

idb.iid(65070).name='Bile-O-Tron Nut (Heroic)';
idb.iid(65070).ilvl=372;
idb.iid(65070).str=153;
idb.iid(65070).sta=322;
idb.iid(65070).exp=126;
idb.iid(65070).dodge=215;
idb.iid(65070).isreforged=0;

idb.iid(71367).name='Theck''s Emberseal';
idb.iid(71367).ilvl=378;
idb.iid(71367).str=173;
idb.iid(71367).sta=341;
idb.iid(71367).hit=115;
idb.iid(71367).dodge=227;
idb.iid(71367).isreforged=0;

idb.iid(70940).name='Deflecting Brimstone Band';
idb.iid(70940).ilvl=378;
idb.iid(70940).str=227;
idb.iid(70940).sta=341;
idb.iid(70940).mast=154;
idb.iid(70940).dodge=148;
idb.iid(70940).isreforged=0;

idb.iid(72837).name='Queen''s Boon';
idb.iid(72837).ilvl=378;
idb.iid(72837).str=226;
idb.iid(72837).sta=341;
idb.iid(72837).dodge=171;
idb.iid(72837).parry=119;
idb.iid(72837).isreforged=0;

idb.iid(78602).name='Signet of the Resolute';
idb.iid(78602).ilvl=384;
idb.iid(78602).str=220;
idb.iid(78602).sta=360;
idb.iid(78602).dodge=134;
idb.iid(78602).parry=159;
idb.iid(78602).socket='Y';
idb.iid(78602).sbstat='parry';
idb.iid(78602).sbval=10;
idb.iid(78602).isreforged=0;

idb.iid(78498).name='Hardheart Ring';
idb.iid(78498).ilvl=384;
idb.iid(78498).str=220;
idb.iid(78498).sta=360;
idb.iid(78498).mast=157;
idb.iid(78498).parry=138;
idb.iid(78498).socket='B';
idb.iid(78498).sbstat='mast';
idb.iid(78498).sbval=10;
idb.iid(78498).isreforged=0;

idb.iid(71564).name='Theck''s Emberseal (Heroic)';
idb.iid(71564).ilvl=391;
idb.iid(71564).str=195;
idb.iid(71564).sta=384;
idb.iid(71564).hit=130;
idb.iid(71564).dodge=256;
idb.iid(71564).isreforged=0;

idb.iid(70934).name='Adamantine Signet of the Avengers';
idb.iid(70934).ilvl=391;
idb.iid(70934).str=175;
idb.iid(70934).sta=384;
idb.iid(70934).hit=110;
idb.iid(70934).dodge=256;
idb.iid(70934).socket='R';
idb.iid(70934).sbstat='sta';
idb.iid(70934).sbval=15;
idb.iid(70934).isreforged=0;

idb.iid(77112).name='Signet of the Resolute';
idb.iid(77112).ilvl=397;
idb.iid(77112).str=251;
idb.iid(77112).sta=406;
idb.iid(77112).dodge=153;
idb.iid(77112).parry=181;
idb.iid(77112).socket='Y';
idb.iid(77112).sbstat='parry';
idb.iid(77112).sbval=10;
idb.iid(77112).isreforged=0;

idb.iid(77232).name='Hardheart Ring';
idb.iid(77232).ilvl=397;
idb.iid(77232).str=251;
idb.iid(77232).sta=406;
idb.iid(77232).mast=179;
idb.iid(77232).parry=157;
idb.iid(77232).socket='B';
idb.iid(77232).sbstat='mast';
idb.iid(77232).sbval=10;
idb.iid(77232).isreforged=0;

idb.iid(78521).name='Signet of the Resolute (Heroic)';
idb.iid(78521).ilvl=410;
idb.iid(78521).str=286;
idb.iid(78521).sta=459;
idb.iid(78521).dodge=174;
idb.iid(78521).parry=206;
idb.iid(78521).socket='Y';
idb.iid(78521).sbstat='parry';
idb.iid(78521).sbval=10;
idb.iid(78521).isreforged=0;

idb.iid(78493).name='Hardheart Ring (Heroic)';
idb.iid(78493).ilvl=410;
idb.iid(78493).str=286;
idb.iid(78493).sta=459;
idb.iid(78493).mast=203;
idb.iid(78493).parry=179;
idb.iid(78493).socket='B';
idb.iid(78493).sbstat='mast';
idb.iid(78493).sbval=10;
idb.iid(78493).isreforged=0;


%% Trinkets

idb.iid(56347).name='Leaden Despair (Heroic)';
idb.iid(56347).ilvl=346;
idb.iid(56347).sta=427;
idb.iid(56347).isreforged=0;

idb.iid(56406).name='Impetuous Query (Heroic)';
idb.iid(56406).ilvl=346;
idb.iid(56406).mast=285;
idb.iid(56406).isreforged=0;

idb.iid(59515).name='Vial of Stolen Memories';
idb.iid(59515).ilvl=359;
idb.iid(59515).sta=482;
idb.iid(59515).isreforged=0;

idb.iid(65109).name='Vial of Stolen Memories (Heroic)';
idb.iid(65109).ilvl=372;
idb.iid(65109).sta=544;
idb.iid(65109).isreforged=0;

% Mirror of Broken Images (H) =  Unsolvable Riddle (A) 
idb.iid(62466).name='Mirror of Broken Images';
idb.iid(62466).ilvl=359;
idb.iid(62466).mast=321;
idb.iid(62466).isreforged=0;

idb.iid(68981).name='Spidersilk Spindle';
idb.iid(68981).ilvl=378;
idb.iid(68981).mast=383;
idb.iid(68981).isreforged=0;

idb.iid(68915).name='Scales of Life';
idb.iid(68915).ilvl=378;
idb.iid(68915).sta=575;
idb.iid(68915).isreforged=0;

idb.iid(72900).name='Veil of Lies';
idb.iid(72900).ilvl=378;
idb.iid(72900).sta=575;
idb.iid(72900).isreforged=0;

idb.iid(68996).name='Stay of Execution';
idb.iid(68996).ilvl=378;
idb.iid(68996).dodge=383;
idb.iid(68996).isreforged=0;


idb.iid(77983).name='Indomitable Pride (Raidfinder)';
idb.iid(77983).ilvl=384;
idb.iid(77983).sta=609;
idb.iid(77983).isreforged=0;

idb.iid(77970).name='Soulshifter Vortex (Raidfinder)';
idb.iid(77970).ilvl=384;
idb.iid(77970).sta=609;
idb.iid(77970).isreforged=0;

idb.iid(77978).name='Resolve of Undying (Raidfinder)';
idb.iid(77978).ilvl=390;
idb.iid(77978).isreforged=0;

idb.iid(69138).name='Spidersilk Spindle (Heroic)';
idb.iid(69138).ilvl=391;
idb.iid(69138).mast=433;
idb.iid(69138).isreforged=0;

idb.iid(69109).name='Scales of Life (Heroic)';
idb.iid(69109).ilvl=391;
idb.iid(69109).sta=650;
idb.iid(69109).isreforged=0;

idb.iid(77117).name='Fire of the Deep';
idb.iid(77117).ilvl=397;
idb.iid(77117).mast=458;
idb.iid(77117).isreforged=0;

idb.iid(77211).name='Indomitable Pride';
idb.iid(77211).ilvl=397;
idb.iid(77211).sta=687;
idb.iid(77211).isreforged=0;

idb.iid(77206).name='Soulshifter Vortex';
idb.iid(77206).ilvl=397;
idb.iid(77206).sta=687;
idb.iid(77206).isreforged=0;

idb.iid(77201).name='Resolve of Undying';
idb.iid(77201).ilvl=403;
idb.iid(77201).isreforged=0;

idb.iid(78003).name='Indomitable Pride (Heroic)';
idb.iid(78003).ilvl=410;
idb.iid(78003).sta=775;
idb.iid(78003).isreforged=0;

idb.iid(77990).name='Soulshifter Vortex (Heroic)';
idb.iid(77990).ilvl=410;
idb.iid(77990).sta=775;
idb.iid(77990).isreforged=0;

idb.iid(77998).name='Resolve of Undying (Heroic)';
idb.iid(77998).ilvl=416;
idb.iid(77998).isreforged=0;

%% Weapons - Axes
idb.iid(55067).name='Elementium Bonesplitter';
idb.iid(55067).wtype='axe';
idb.iid(55067).ilvl=346;
idb.iid(55067).tooldps=409.4;
idb.iid(55067).swing=2.6;
idb.iid(55067).avgdmg=1064.5;
idb.iid(55067).str=129;
idb.iid(55067).sta=194;
idb.iid(55067).exp=86;
idb.iid(55067).haste=86;
idb.iid(55067).isreforged=0;

idb.iid(56266).name='Lightning Whelk Axe (Heroic)';
idb.iid(56266).wtype='axe';
idb.iid(56266).ilvl=346;
idb.iid(56266).tooldps=409.4;
idb.iid(56266).swing=2.6;
idb.iid(56266).avgdmg=1064.5;
idb.iid(56266).sta=194;
idb.iid(56266).agi=129;
idb.iid(56266).hit=86;
idb.iid(56266).crit=86;
idb.iid(56266).isreforged=0;

idb.iid(56364).name='Axe of the Eclipse (Heroic)';
idb.iid(56364).wtype='axe';
idb.iid(56364).ilvl=346;
idb.iid(56364).tooldps=409.4;
idb.iid(56364).swing=2.6;
idb.iid(56364).avgdmg=1064.5;
idb.iid(56364).str=129;
idb.iid(56364).sta=194;
idb.iid(56364).hit=66;
idb.iid(56364).mast=98;
idb.iid(56364).isreforged=0;

idb.iid(62457).name='Ravening Slicer';
idb.iid(62457).wtype='axe';
idb.iid(62457).ilvl=346;
idb.iid(62457).tooldps=409.4;
idb.iid(62457).swing=2.6;
idb.iid(62457).avgdmg=1064.5;
idb.iid(62457).sta=194;
idb.iid(62457).agi=129;
idb.iid(62457).haste=86;
idb.iid(62457).mast=86;
idb.iid(62457).isreforged=0;

idb.iid(65170).name='Smite''s Reaver (Heroic)';
idb.iid(65170).wtype='axe';
idb.iid(65170).ilvl=346;
idb.iid(65170).tooldps=409.4;
idb.iid(65170).swing=2.6;
idb.iid(65170).avgdmg=1064.5;
idb.iid(65170).str=129;
idb.iid(65170).sta=194;
idb.iid(65170).hit=86;
idb.iid(65170).exp=86;
idb.iid(65170).isreforged=0;

idb.iid(67602).name='Elementium Gutslicer';
idb.iid(67602).wtype='axe';
idb.iid(67602).ilvl=346;
idb.iid(67602).tooldps=409.4;
idb.iid(67602).swing=2.6;
idb.iid(67602).avgdmg=1064.5;
idb.iid(67602).sta=194;
idb.iid(67602).agi=129;
idb.iid(67602).hit=86;
idb.iid(67602).mast=86;
idb.iid(67602).isreforged=0;

idb.iid(68740).name='Darkheart Hacker';
idb.iid(68740).wtype='axe';
idb.iid(68740).ilvl=346;
idb.iid(68740).tooldps=409.4;
idb.iid(68740).swing=2.6;
idb.iid(68740).avgdmg=1064.5;
idb.iid(68740).str=129;
idb.iid(68740).sta=194;
idb.iid(68740).exp=78;
idb.iid(68740).mast=91;
idb.iid(68740).isreforged=0;

idb.iid(59443).name='Crul''korak, the Lightning''s Arc';
idb.iid(59443).wtype='axe';
idb.iid(59443).ilvl=359;
idb.iid(59443).tooldps=462.3;
idb.iid(59443).swing=2.6;
idb.iid(59443).avgdmg=1202;
idb.iid(59443).sta=219;
idb.iid(59443).agi=146;
idb.iid(59443).crit=97;
idb.iid(59443).haste=97;
idb.iid(59443).isreforged=0;

idb.iid(61324).name='Vicious Gladiator''s Cleaver';
idb.iid(61324).wtype='axe';
idb.iid(61324).ilvl=359;
idb.iid(61324).tooldps=462.3;
idb.iid(61324).swing=2.6;
idb.iid(61324).avgdmg=1202;
idb.iid(61324).sta=219;
idb.iid(61324).agi=146;
idb.iid(61324).crit=97;
idb.iid(61324).isreforged=0;

idb.iid(61325).name='Vicious Gladiator''s Hacker';
idb.iid(61325).wtype='axe';
idb.iid(61325).ilvl=359;
idb.iid(61325).tooldps=462.3;
idb.iid(61325).swing=2.6;
idb.iid(61325).avgdmg=1202;
idb.iid(61325).str=146;
idb.iid(61325).sta=219;
idb.iid(61325).crit=97;
idb.iid(61325).isreforged=0;

idb.iid(70158).name='Elementium-Edged Scalper';
idb.iid(70158).wtype='axe';
idb.iid(70158).ilvl=365;
idb.iid(70158).tooldps=488.8;
idb.iid(70158).swing=2.6;
idb.iid(70158).avgdmg=1271;
idb.iid(70158).str=155;
idb.iid(70158).sta=232;
idb.iid(70158).hit=103;
idb.iid(70158).mast=103;
idb.iid(70158).isreforged=0;

idb.iid(65024).name='Crul''korak, the Lightning''s Arc (Heroic)';
idb.iid(65024).wtype='axe';
idb.iid(65024).ilvl=372;
idb.iid(65024).tooldps=521.9;
idb.iid(65024).swing=2.6;
idb.iid(65024).avgdmg=1357;
idb.iid(65024).sta=248;
idb.iid(65024).agi=165;
idb.iid(65024).crit=110;
idb.iid(65024).haste=110;
idb.iid(65024).isreforged=0;

idb.iid(67473).name='Vicious Gladiator''s Hacker';
idb.iid(67473).wtype='axe';
idb.iid(67473).ilvl=372;
idb.iid(67473).tooldps=521.9;
idb.iid(67473).swing=2.6;
idb.iid(67473).avgdmg=1357;
idb.iid(67473).str=165;
idb.iid(67473).sta=248;
idb.iid(67473).crit=110;
idb.iid(67473).isreforged=0;

idb.iid(67474).name='Vicious Gladiator''s Cleaver';
idb.iid(67474).wtype='axe';
idb.iid(67474).ilvl=372;
idb.iid(67474).tooldps=521.9;
idb.iid(67474).swing=2.6;
idb.iid(67474).avgdmg=1357;
idb.iid(67474).sta=248;
idb.iid(67474).agi=165;
idb.iid(67474).crit=110;
idb.iid(67474).isreforged=0;

idb.iid(70212).name='Ruthless Gladiator''s Hacker';
idb.iid(70212).wtype='axe';
idb.iid(70212).ilvl=378;
idb.iid(70212).tooldps=551.7;
idb.iid(70212).swing=2.6;
idb.iid(70212).avgdmg=1434.5;
idb.iid(70212).str=175;
idb.iid(70212).sta=262;
idb.iid(70212).crit=116;
idb.iid(70212).isreforged=0;

idb.iid(71312).name='Gatecrasher';
idb.iid(71312).wtype='axe';
idb.iid(71312).ilvl=378;
idb.iid(71312).tooldps=551.7;
idb.iid(71312).swing=2.6;
idb.iid(71312).avgdmg=1434.5;
idb.iid(71312).sta=262;
idb.iid(71312).agi=175;
idb.iid(71312).crit=120;
idb.iid(71312).exp=111;
idb.iid(71312).isreforged=0;

idb.iid(71362).name='Obsidium Cleaver';
idb.iid(71362).wtype='axe';
idb.iid(71362).ilvl=378;
idb.iid(71362).tooldps=551.7;
idb.iid(71362).swing=2.6;
idb.iid(71362).avgdmg=1434.5;
idb.iid(71362).str=175;
idb.iid(71362).sta=262;
idb.iid(71362).hit=105;
idb.iid(71362).mast=123;
idb.iid(71362).isreforged=0;

idb.iid(71776).name='Eye of Purification';
idb.iid(71776).wtype='axe';
idb.iid(71776).ilvl=378;
idb.iid(71776).tooldps=551.9;
idb.iid(71776).swing=2.4;
idb.iid(71776).avgdmg=1324.5;
idb.iid(71776).sta=262;
idb.iid(71776).int=175;
idb.iid(71776).spi=131;
idb.iid(71776).mast=91;
idb.iid(71776).sp=2333;
idb.iid(71776).isreforged=0;

idb.iid(72828).name='Trickster''s Edge';
idb.iid(72828).wtype='axe';
idb.iid(72828).ilvl=378;
idb.iid(72828).tooldps=551.7;
idb.iid(72828).swing=2.6;
idb.iid(72828).avgdmg=1434.5;
idb.iid(72828).sta=262;
idb.iid(72828).agi=174;
idb.iid(72828).crit=128;
idb.iid(72828).exp=97;
idb.iid(72828).isreforged=0;

idb.iid(72812).name='Crescent Moon';
idb.iid(72812).wtype='axe';
idb.iid(72812).ilvl=378;
idb.iid(72812).tooldps=551.9;
idb.iid(72812).swing=1.6;
idb.iid(72812).avgdmg=883;
idb.iid(72812).sta=262;
idb.iid(72812).int=174;
idb.iid(72812).spi=91;
idb.iid(72812).mast=131;
idb.iid(72812).sp=2333;
idb.iid(72812).isreforged=0;

idb.iid(70204).name='Ruthless Gladiator''s Hacker';
idb.iid(70204).wtype='axe';
idb.iid(70204).ilvl=391;
idb.iid(70204).tooldps=622.9;
idb.iid(70204).swing=2.6;
idb.iid(70204).avgdmg=1619.5;
idb.iid(70204).str=197;
idb.iid(70204).sta=296;
idb.iid(70204).crit=131;
idb.iid(70204).isreforged=0;

idb.iid(71454).name='Gatecrasher (Heroic)';
idb.iid(71454).wtype='axe';
idb.iid(71454).ilvl=391;
idb.iid(71454).tooldps=622.9;
idb.iid(71454).swing=2.6;
idb.iid(71454).avgdmg=1619.5;
idb.iid(71454).sta=296;
idb.iid(71454).agi=197;
idb.iid(71454).crit=135;
idb.iid(71454).exp=125;
idb.iid(71454).isreforged=0;

idb.iid(71562).name='Obsidium Cleaver (Heroic)';
idb.iid(71562).wtype='axe';
idb.iid(71562).ilvl=391;
idb.iid(71562).tooldps=622.9;
idb.iid(71562).swing=2.6;
idb.iid(71562).avgdmg=1619.5;
idb.iid(71562).str=197;
idb.iid(71562).sta=296;
idb.iid(71562).hit=119;
idb.iid(71562).mast=139;
idb.iid(71562).isreforged=0;

idb.iid(71777).name='Eye of Purification (Heroic)';
idb.iid(71777).wtype='axe';
idb.iid(71777).ilvl=391;
idb.iid(71777).tooldps=622.7;
idb.iid(71777).swing=2.4;
idb.iid(71777).avgdmg=1494.5;
idb.iid(71777).sta=296;
idb.iid(71777).int=197;
idb.iid(71777).spi=148;
idb.iid(71777).mast=103;
idb.iid(71777).sp=2636;
idb.iid(71777).isreforged=0;

idb.iid(77212).name='Hand of Morchok';
idb.iid(77212).wtype='axe';
idb.iid(77212).ilvl=397;
idb.iid(77212).tooldps=658.7;
idb.iid(77212).swing=2.6;
idb.iid(77212).avgdmg=1712.5;
idb.iid(77212).str=188;
idb.iid(77212).sta=312;
idb.iid(77212).crit=139;
idb.iid(77212).mast=119;
idb.iid(77212).socket='R';
idb.iid(77212).sbstat='str';
idb.iid(77212).sbval=10;
idb.iid(77212).isreforged=0;

idb.iid(77188).name='No''Kaled, the Elements of Death';
idb.iid(77188).wtype='axe';
idb.iid(77188).ilvl=403;
idb.iid(77188).tooldps=696.5;
idb.iid(77188).swing=2.6;
idb.iid(77188).avgdmg=1811;
idb.iid(77188).sta=331;
idb.iid(77188).agi=220;
idb.iid(77188).isreforged=0;

idb.iid(78371).name='Hand of Morchok (Heroic)';
idb.iid(78371).wtype='axe';
idb.iid(78371).ilvl=410;
idb.iid(78371).tooldps=743.5;
idb.iid(78371).swing=2.6;
idb.iid(78371).avgdmg=1933;
idb.iid(78371).str=215;
idb.iid(78371).sta=353;
idb.iid(78371).crit=157;
idb.iid(78371).mast=137;
idb.iid(78371).socket='R';
idb.iid(78371).sbstat='str';
idb.iid(78371).sbval=10;
idb.iid(78371).isreforged=0;

idb.iid(78472).name='No''Kaled, the Elements of Death (Heroic)';
idb.iid(78472).wtype='axe';
idb.iid(78472).ilvl=416;
idb.iid(78472).tooldps=786.3;
idb.iid(78472).swing=2.6;
idb.iid(78472).avgdmg=2044.5;
idb.iid(78472).sta=373;
idb.iid(78472).agi=249;
idb.iid(78472).isreforged=0;

%% Weapons - Maces

idb.iid(55065).name='Elementium Hammer';
idb.iid(55065).wtype='mac';
idb.iid(55065).ilvl=346;
idb.iid(55065).tooldps=409.7;
idb.iid(55065).swing=1.9;
idb.iid(55065).avgdmg=778.5;
idb.iid(55065).sta=194;
idb.iid(55065).int=129;
idb.iid(55065).spi=86;
idb.iid(55065).mast=86;
idb.iid(55065).sp=1729;
idb.iid(55065).isreforged=0;

idb.iid(56312).name='Torturer''s Mercy (Heroic)';
idb.iid(56312).wtype='mac';
idb.iid(56312).ilvl=346;
idb.iid(56312).tooldps=409.6;
idb.iid(56312).swing=2.3;
idb.iid(56312).avgdmg=942;
idb.iid(56312).sta=194;
idb.iid(56312).int=129;
idb.iid(56312).spi=91;
idb.iid(56312).mast=78;
idb.iid(56312).sp=1729;
idb.iid(56312).isreforged=0;

idb.iid(56353).name='Heavy Geode Mace (Heroic)';
idb.iid(56353).wtype='mac';
idb.iid(56353).ilvl=346;
idb.iid(56353).tooldps=409.4;
idb.iid(56353).swing=2.6;
idb.iid(56353).avgdmg=1064.5;
idb.iid(56353).sta=194;
idb.iid(56353).agi=129;
idb.iid(56353).hit=86;
idb.iid(56353).exp=86;
idb.iid(56353).isreforged=0;

idb.iid(56396).name='Hammer of Sparks (Heroic)';
idb.iid(56396).wtype='mac';
idb.iid(56396).ilvl=346;
idb.iid(56396).tooldps=409.4;
idb.iid(56396).swing=2.6;
idb.iid(56396).avgdmg=1064.5;
idb.iid(56396).sta=194;
idb.iid(56396).agi=129;
idb.iid(56396).hit=86;
idb.iid(56396).crit=86;
idb.iid(56396).isreforged=0;

idb.iid(56459).name='Mace of Transformed Bone (Heroic)';
idb.iid(56459).wtype='mac';
idb.iid(56459).ilvl=346;
idb.iid(56459).tooldps=409.4;
idb.iid(56459).swing=2.6;
idb.iid(56459).avgdmg=1064.5;
idb.iid(56459).str=98;
idb.iid(56459).sta=194;
idb.iid(56459).hit=66;
idb.iid(56459).dodge=129;
idb.iid(56459).isreforged=0;

idb.iid(57872).name='Scepter of Power (Heroic)';
idb.iid(57872).wtype='mac';
idb.iid(57872).ilvl=346;
idb.iid(57872).tooldps=409.6;
idb.iid(57872).swing=2.3;
idb.iid(57872).avgdmg=942;
idb.iid(57872).sta=194;
idb.iid(57872).int=129;
idb.iid(57872).spi=86;
idb.iid(57872).haste=86;
idb.iid(57872).sp=1729;
idb.iid(57872).isreforged=0;

idb.iid(62459).name='Shimmering Morningstar';
idb.iid(62459).wtype='mac';
idb.iid(62459).ilvl=346;
idb.iid(62459).tooldps=409.6;
idb.iid(62459).swing=2.3;
idb.iid(62459).avgdmg=942;
idb.iid(62459).sta=194;
idb.iid(62459).int=129;
idb.iid(62459).spi=86;
idb.iid(62459).crit=86;
idb.iid(62459).sp=1729;
idb.iid(62459).isreforged=0;

idb.iid(65171).name='Cookie''s Tenderizer (Heroic)';
idb.iid(65171).wtype='mac';
idb.iid(65171).ilvl=346;
idb.iid(65171).tooldps=409.6;
idb.iid(65171).swing=2.8;
idb.iid(65171).avgdmg=1147;
idb.iid(65171).str=129;
idb.iid(65171).sta=194;
idb.iid(65171).hit=86;
idb.iid(65171).mast=86;
idb.iid(65171).isreforged=0;

idb.iid(69575).name='Mace of the Sacrificed';
idb.iid(69575).wtype='mac';
idb.iid(69575).ilvl=353;
idb.iid(69575).tooldps=437.3;
idb.iid(69575).swing=2.6;
idb.iid(69575).avgdmg=1137;
idb.iid(69575).sta=207;
idb.iid(69575).agi=138;
idb.iid(69575).hit=85;
idb.iid(69575).haste=96;
idb.iid(69575).isreforged=0;

idb.iid(69581).name='Amani Scepter of Rites';
idb.iid(69581).wtype='mac';
idb.iid(69581).ilvl=353;
idb.iid(69581).tooldps=437.2;
idb.iid(69581).swing=1.6;
idb.iid(69581).avgdmg=699.5;
idb.iid(69581).sta=207;
idb.iid(69581).int=138;
idb.iid(69581).spi=92;
idb.iid(69581).mast=92;
idb.iid(69581).sp=1848;
idb.iid(69581).isreforged=0;

idb.iid(69803).name='Gurubashi Punisher';
idb.iid(69803).wtype='mac';
idb.iid(69803).ilvl=353;
idb.iid(69803).tooldps=437.3;
idb.iid(69803).swing=2.6;
idb.iid(69803).avgdmg=1137;
idb.iid(69803).str=138;
idb.iid(69803).sta=207;
idb.iid(69803).hit=77;
idb.iid(69803).haste=101;
idb.iid(69803).isreforged=0;

idb.iid(59347).name='Mace of Acrid Death';
idb.iid(59347).wtype='mac';
idb.iid(59347).ilvl=359;
idb.iid(59347).tooldps=462.3;
idb.iid(59347).swing=2.6;
idb.iid(59347).avgdmg=1202;
idb.iid(59347).str=146;
idb.iid(59347).sta=219;
idb.iid(59347).mast=97;
idb.iid(59347).parry=97;
idb.iid(59347).isreforged=0;

idb.iid(59459).name='Andoros, Fist of the Dragon King';
idb.iid(59459).wtype='mac';
idb.iid(59459).ilvl=359;
idb.iid(59459).tooldps=462.5;
idb.iid(59459).swing=1.8;
idb.iid(59459).avgdmg=832.5;
idb.iid(59459).sta=219;
idb.iid(59459).int=146;
idb.iid(59459).spi=97;
idb.iid(59459).mast=97;
idb.iid(59459).sp=1954;
idb.iid(59459).isreforged=0;

idb.iid(61335).name='Vicious Gladiator''s Pummeler';
idb.iid(61335).wtype='mac';
idb.iid(61335).ilvl=359;
idb.iid(61335).tooldps=462.3;
idb.iid(61335).swing=2.6;
idb.iid(61335).avgdmg=1202;
idb.iid(61335).sta=219;
idb.iid(61335).agi=146;
idb.iid(61335).crit=97;
idb.iid(61335).isreforged=0;

idb.iid(61336).name='Vicious Gladiator''s Bonecracker';
idb.iid(61336).wtype='mac';
idb.iid(61336).ilvl=359;
idb.iid(61336).tooldps=462.3;
idb.iid(61336).swing=2.6;
idb.iid(61336).avgdmg=1202;
idb.iid(61336).str=146;
idb.iid(61336).sta=219;
idb.iid(61336).crit=97;
idb.iid(61336).isreforged=0;

idb.iid(61338).name='Vicious Gladiator''s Gavel';
idb.iid(61338).wtype='mac';
idb.iid(61338).ilvl=359;
idb.iid(61338).tooldps=462.5;
idb.iid(61338).swing=1.6;
idb.iid(61338).avgdmg=740;
idb.iid(61338).sta=219;
idb.iid(61338).int=146;
idb.iid(61338).crit=97;
idb.iid(61338).sp=1954;
idb.iid(61338).isreforged=0;

idb.iid(63680).name='Twilight''s Hammer';
idb.iid(63680).wtype='mac';
idb.iid(63680).ilvl=359;
idb.iid(63680).tooldps=462.4;
idb.iid(63680).swing=1.7;
idb.iid(63680).avgdmg=786;
idb.iid(63680).sta=219;
idb.iid(63680).int=146;
idb.iid(63680).crit=97;
idb.iid(63680).haste=97;
idb.iid(63680).sp=1954;
idb.iid(63680).isreforged=0;

idb.iid(70157).name='Lightforged Elementium Hammer';
idb.iid(70157).wtype='mac';
idb.iid(70157).ilvl=365;
idb.iid(70157).tooldps=488.9;
idb.iid(70157).swing=1.9;
idb.iid(70157).avgdmg=929;
idb.iid(70157).sta=232;
idb.iid(70157).int=155;
idb.iid(70157).spi=103;
idb.iid(70157).mast=103;
idb.iid(70157).sp=2066;
idb.iid(70157).isreforged=0;

idb.iid(65017).name='Andoros, Fist of the Dragon King (Heroic)';
idb.iid(65017).wtype='mac';
idb.iid(65017).ilvl=372;
idb.iid(65017).tooldps=521.9;
idb.iid(65017).swing=1.8;
idb.iid(65017).avgdmg=939.5;
idb.iid(65017).sta=247;
idb.iid(65017).int=165;
idb.iid(65017).spi=110;
idb.iid(65017).mast=110;
idb.iid(65017).sp=2207;
idb.iid(65017).isreforged=0;

idb.iid(65036).name='Mace of Acrid Death (Heroic)';
idb.iid(65036).wtype='mac';
idb.iid(65036).ilvl=372;
idb.iid(65036).tooldps=521.9;
idb.iid(65036).swing=2.6;
idb.iid(65036).avgdmg=1357;
idb.iid(65036).str=165;
idb.iid(65036).sta=248;
idb.iid(65036).mast=110;
idb.iid(65036).parry=110;
idb.iid(65036).isreforged=0;

idb.iid(65090).name='Twilight''s Hammer (Heroic)';
idb.iid(65090).wtype='mac';
idb.iid(65090).ilvl=372;
idb.iid(65090).tooldps=521.8;
idb.iid(65090).swing=1.7;
idb.iid(65090).avgdmg=887;
idb.iid(65090).sta=248;
idb.iid(65090).int=165;
idb.iid(65090).crit=110;
idb.iid(65090).haste=110;
idb.iid(65090).sp=2207;
idb.iid(65090).isreforged=0;

idb.iid(67454).name='Vicious Gladiator''s Gavel';
idb.iid(67454).wtype='mac';
idb.iid(67454).ilvl=372;
idb.iid(67454).tooldps=521.6;
idb.iid(67454).swing=1.6;
idb.iid(67454).avgdmg=834.5;
idb.iid(67454).sta=248;
idb.iid(67454).int=165;
idb.iid(67454).crit=110;
idb.iid(67454).sp=2207;
idb.iid(67454).isreforged=0;

idb.iid(67470).name='Vicious Gladiator''s Bonecracker';
idb.iid(67470).wtype='mac';
idb.iid(67470).ilvl=372;
idb.iid(67470).tooldps=521.9;
idb.iid(67470).swing=2.6;
idb.iid(67470).avgdmg=1357;
idb.iid(67470).str=165;
idb.iid(67470).sta=248;
idb.iid(67470).crit=110;
idb.iid(67470).isreforged=0;

idb.iid(67471).name='Vicious Gladiator''s Pummeler';
idb.iid(67471).wtype='mac';
idb.iid(67471).ilvl=372;
idb.iid(67471).tooldps=521.9;
idb.iid(67471).swing=2.6;
idb.iid(67471).avgdmg=1357;
idb.iid(67471).sta=248;
idb.iid(67471).agi=165;
idb.iid(67471).crit=110;
idb.iid(67471).isreforged=0;

idb.iid(70222).name='Ruthless Gladiator''s Bonecracker';
idb.iid(70222).wtype='mac';
idb.iid(70222).ilvl=378;
idb.iid(70222).tooldps=551.7;
idb.iid(70222).swing=2.6;
idb.iid(70222).avgdmg=1434.5;
idb.iid(70222).str=175;
idb.iid(70222).sta=262;
idb.iid(70222).crit=116;
idb.iid(70222).isreforged=0;

idb.iid(71782).name='Shatterskull Bonecrusher';
idb.iid(71782).wtype='mac';
idb.iid(71782).ilvl=378;
idb.iid(71782).tooldps=551.7;
idb.iid(71782).swing=2.6;
idb.iid(71782).avgdmg=1434.5;
idb.iid(71782).sta=262;
idb.iid(71782).agi=175;
idb.iid(71782).crit=123;
idb.iid(71782).haste=105;
idb.iid(71782).isreforged=0;

idb.iid(72827).name='Gavel of Peroth''arn';
idb.iid(72827).wtype='mac';
idb.iid(72827).ilvl=378;
idb.iid(72827).tooldps=551.7;
idb.iid(72827).swing=2.6;
idb.iid(72827).avgdmg=1434.5;
idb.iid(72827).str=174;
idb.iid(72827).sta=262;
idb.iid(72827).mast=91;
idb.iid(72827).parry=131;
idb.iid(72827).isreforged=0;

idb.iid(72833).name='Scepter of Azshara';
idb.iid(72833).wtype='mac';
idb.iid(72833).ilvl=378;
idb.iid(72833).tooldps=551.9;
idb.iid(72833).swing=1.6;
idb.iid(72833).avgdmg=883;
idb.iid(72833).sta=262;
idb.iid(72833).int=174;
idb.iid(72833).spi=131;
idb.iid(72833).crit=91;
idb.iid(72833).sp=2333;
idb.iid(72833).isreforged=0;

idb.iid(72804).name='Dragonshrine Scepter';
idb.iid(72804).wtype='mac';
idb.iid(72804).ilvl=378;
idb.iid(72804).tooldps=551.7;
idb.iid(72804).swing=2.6;
idb.iid(72804).avgdmg=1434.5;
idb.iid(72804).str=174;
idb.iid(72804).sta=262;
idb.iid(72804).crit=113;
idb.iid(72804).mast=118;
idb.iid(72804).isreforged=0;

idb.iid(71355).name='Ko''gun, Hammer of the Firelord';
idb.iid(71355).wtype='mac';
idb.iid(71355).ilvl=384;
idb.iid(71355).tooldps=583.6;
idb.iid(71355).swing=2.1;
idb.iid(71355).avgdmg=1225.5;
idb.iid(71355).sta=277;
idb.iid(71355).int=185;
idb.iid(71355).spi=134;
idb.iid(71355).haste=105;
idb.iid(71355).sp=2467;
idb.iid(71355).isreforged=0;

idb.iid(78485).name='Maw of the Dragonlord (Raid Finder)';
idb.iid(78485).wtype='mac';
idb.iid(78485).ilvl=390;
idb.iid(78485).tooldps=617;
idb.iid(78485).swing=2.2;
idb.iid(78485).avgdmg=1357.5;
idb.iid(78485).sta=293;
idb.iid(78485).int=195;
idb.iid(78485).sp=2607;
idb.iid(78485).isreforged=0;

idb.iid(70201).name='Ruthless Gladiator''s Bonecracker';
idb.iid(70201).wtype='mac';
idb.iid(70201).ilvl=391;
idb.iid(70201).tooldps=622.9;
idb.iid(70201).swing=2.6;
idb.iid(70201).avgdmg=1619.5;
idb.iid(70201).str=197;
idb.iid(70201).sta=296;
idb.iid(70201).crit=131;
idb.iid(70201).isreforged=0;

idb.iid(71783).name='Shatterskull Bonecrusher (Heroic)';
idb.iid(71783).wtype='mac';
idb.iid(71783).ilvl=391;
idb.iid(71783).tooldps=622.9;
idb.iid(71783).swing=2.6;
idb.iid(71783).avgdmg=1619.5;
idb.iid(71783).sta=296;
idb.iid(71783).agi=197;
idb.iid(71783).crit=139;
idb.iid(71783).haste=119;
idb.iid(71783).isreforged=0;

idb.iid(71615).name='Ko''gun, Hammer of the Firelord (Heroic)';
idb.iid(71615).wtype='mac';
idb.iid(71615).ilvl=397;
idb.iid(71615).tooldps=658.6;
idb.iid(71615).swing=2.1;
idb.iid(71615).avgdmg=1383;
idb.iid(71615).sta=312;
idb.iid(71615).int=208;
idb.iid(71615).spi=151;
idb.iid(71615).haste=118;
idb.iid(71615).sp=2783;
idb.iid(71615).isreforged=0;

idb.iid(73448).name='Cataclysmic Gladiator''s Bonecracker';
idb.iid(73448).wtype='mac';
idb.iid(73448).ilvl=397;
idb.iid(73448).tooldps=658.7;
idb.iid(73448).swing=2.6;
idb.iid(73448).avgdmg=(1198+2227)/2;
idb.iid(73448).str=208;
idb.iid(73448).sta=312;
idb.iid(73448).crit=139;
idb.iid(73448).isreforged=0;

idb.iid(77214).name='Vagaries of Time';
idb.iid(77214).wtype='mac';
idb.iid(77214).ilvl=397;
idb.iid(77214).tooldps=658.6;
idb.iid(77214).swing=2.2;
idb.iid(77214).avgdmg=1449;
idb.iid(77214).sta=312;
idb.iid(77214).int=188;
idb.iid(77214).crit=123;
idb.iid(77214).haste=135;
idb.iid(77214).socket='R';
idb.iid(77214).sbstat='int';
idb.iid(77214).sbval=10;
idb.iid(77214).sp=2783;
idb.iid(77214).isreforged=0;

idb.iid(77223).name='Morningstar of Heroic Will';
idb.iid(77223).wtype='mac';
idb.iid(77223).ilvl=397;
idb.iid(77223).tooldps=658.7;
idb.iid(77223).swing=2.6;
idb.iid(77223).avgdmg=1712.5;
idb.iid(77223).sta=312;
idb.iid(77223).agi=188;
idb.iid(77223).exp=141;
idb.iid(77223).haste=111;
idb.iid(77223).socket='R';
idb.iid(77223).sbstat='agi';
idb.iid(77223).sbval=10;
idb.iid(77223).isreforged=0;

idb.iid(77196).name='Maw of the Dragonlord';
idb.iid(77196).wtype='mac';
idb.iid(77196).ilvl=403;
idb.iid(77196).tooldps=696.6;
idb.iid(77196).swing=2.2;
idb.iid(77196).avgdmg=1532.5;
idb.iid(77196).sta=331;
idb.iid(77196).int=220;
idb.iid(77196).sp=2945;
idb.iid(77196).isreforged=0;

idb.iid(73415).name='Cataclysmic Gladiator''s Bonecracker (Elite)';
idb.iid(73415).wtype='mac';
idb.iid(73415).ilvl=410;
idb.iid(73415).tooldps=743.5;
idb.iid(73415).swing=2.6;
idb.iid(73415).avgdmg=(1353+2514)/2;
idb.iid(73415).str=235;
idb.iid(73415).sta=353;
idb.iid(73415).crit=157;
idb.iid(73415).isreforged=0;

idb.iid(78363).name='Vagaries of Time (Heroic)';
idb.iid(78363).wtype='mac';
idb.iid(78363).ilvl=410;
idb.iid(78363).tooldps=743.6;
idb.iid(78363).swing=2.2;
idb.iid(78363).avgdmg=1636;
idb.iid(78363).sta=353;
idb.iid(78363).int=215;
idb.iid(78363).crit=141;
idb.iid(78363).haste=153;
idb.iid(78363).socket='R';
idb.iid(78363).sbstat='int';
idb.iid(78363).sbval=10;
idb.iid(78363).sp=3142;
idb.iid(78363).isreforged=0;

idb.iid(78429).name='Morningstar of Heroic Will (Heroic)';
idb.iid(78429).wtype='mac';
idb.iid(78429).ilvl=410;
idb.iid(78429).tooldps=743.5;
idb.iid(78429).swing=2.6;
idb.iid(78429).avgdmg=1933;
idb.iid(78429).sta=353;
idb.iid(78429).agi=215;
idb.iid(78429).exp=160;
idb.iid(78429).haste=127;
idb.iid(78429).socket='R';
idb.iid(78429).sbstat='agi';
idb.iid(78429).sbval=10;
idb.iid(78429).isreforged=0;

idb.iid(78476).name='Maw of the Dragonlord (Heroic)';
idb.iid(78476).wtype='mac';
idb.iid(78476).ilvl=416;
idb.iid(78476).tooldps=786.4;
idb.iid(78476).swing=2.2;
idb.iid(78476).avgdmg=1730;
idb.iid(78476).sta=373;
idb.iid(78476).int=249;
idb.iid(78476).sp=3324;
idb.iid(78476).isreforged=0;

%% Weapons - Swords

idb.iid(56346).name='Elementium Fang (Heroic)';
idb.iid(56346).wtype='swo';
idb.iid(56346).ilvl=346;
idb.iid(56346).tooldps=409.4;
idb.iid(56346).swing=2.6;
idb.iid(56346).avgdmg=1064.5;
idb.iid(56346).str=129;
idb.iid(56346).sta=194;
idb.iid(56346).mast=86;
idb.iid(56346).parry=86;
idb.iid(56346).isreforged=0;

idb.iid(56384).name='Resonant Kris (Heroic)';
idb.iid(56384).wtype='swo';
idb.iid(56384).ilvl=346;
idb.iid(56384).tooldps=409.4;
idb.iid(56384).swing=2.6;
idb.iid(56384).avgdmg=1064.5;
idb.iid(56384).str=129;
idb.iid(56384).sta=194;
idb.iid(56384).hit=86;
idb.iid(56384).haste=86;
idb.iid(56384).isreforged=0;

idb.iid(56430).name='Sun Strike (Heroic)';
idb.iid(56430).wtype='swo';
idb.iid(56430).ilvl=346;
idb.iid(56430).tooldps=409.4;
idb.iid(56430).swing=2.6;
idb.iid(56430).avgdmg=1064.5;
idb.iid(56430).str=129;
idb.iid(56430).sta=194;
idb.iid(56430).hit=86;
idb.iid(56430).mast=86;
idb.iid(56430).isreforged=0;

idb.iid(56433).name='Blade of the Burning Sun (Heroic)';
idb.iid(56433).wtype='swo';
idb.iid(56433).ilvl=346;
idb.iid(56433).tooldps=409.7;
idb.iid(56433).swing=1.6;
idb.iid(56433).avgdmg=655.5;
idb.iid(56433).sta=194;
idb.iid(56433).int=129;
idb.iid(56433).crit=93;
idb.iid(56433).haste=76;
idb.iid(56433).sp=1729;
idb.iid(56433).isreforged=0;

idb.iid(65164).name='Cruel Barb (Heroic)';
idb.iid(65164).wtype='swo';
idb.iid(65164).ilvl=346;
idb.iid(65164).tooldps=409.6;
idb.iid(65164).swing=2.7;
idb.iid(65164).avgdmg=1106;
idb.iid(65164).sta=194;
idb.iid(65164).agi=129;
idb.iid(65164).hit=86;
idb.iid(65164).crit=86;
idb.iid(65164).isreforged=0;

idb.iid(65166).name='Buzz Saw (Heroic)';
idb.iid(65166).wtype='swo';
idb.iid(65166).ilvl=346;
idb.iid(65166).tooldps=409.4;
idb.iid(65166).swing=2.6;
idb.iid(65166).avgdmg=1064.5;
idb.iid(65166).str=129;
idb.iid(65166).sta=194;
idb.iid(65166).crit=86;
idb.iid(65166).mast=86;
idb.iid(65166).isreforged=0;

idb.iid(65173).name='Thief''s Blade (Heroic)';
idb.iid(65173).wtype='swo';
idb.iid(65173).ilvl=346;
idb.iid(65173).tooldps=409.4;
idb.iid(65173).swing=2.6;
idb.iid(65173).avgdmg=1064.5;
idb.iid(65173).sta=194;
idb.iid(65173).agi=129;
idb.iid(65173).haste=86;
idb.iid(65173).mast=86;
idb.iid(65173).isreforged=0;

idb.iid(69609).name='Bloodlord''s Protector';
idb.iid(69609).wtype='swo';
idb.iid(69609).ilvl=353;
idb.iid(69609).tooldps=437.3;
idb.iid(69609).swing=2.6;
idb.iid(69609).avgdmg=1137;
idb.iid(69609).str=138;
idb.iid(69609).sta=207;
idb.iid(69609).dodge=92;
idb.iid(69609).parry=92;
idb.iid(69609).isreforged=0;

idb.iid(69618).name='Zulian Slasher';
idb.iid(69618).wtype='swo';
idb.iid(69618).ilvl=353;
idb.iid(69618).tooldps=437.3;
idb.iid(69618).swing=2.6;
idb.iid(69618).avgdmg=1137;
idb.iid(69618).str=138;
idb.iid(69618).sta=207;
idb.iid(69618).hit=96;
idb.iid(69618).crit=85;
idb.iid(69618).isreforged=0;

idb.iid(69639).name='Renataki''s Soul Slicer';
idb.iid(69639).wtype='swo';
idb.iid(69639).ilvl=353;
idb.iid(69639).tooldps=437.3;
idb.iid(69639).swing=2.6;
idb.iid(69639).avgdmg=1137;
idb.iid(69639).str=138;
idb.iid(69639).sta=207;
idb.iid(69639).exp=95;
idb.iid(69639).mast=88;
idb.iid(69639).isreforged=0;

idb.iid(59333).name='Lava Spine';
idb.iid(59333).wtype='swo';
idb.iid(59333).ilvl=359;
idb.iid(59333).tooldps=462.3;
idb.iid(59333).swing=2.6;
idb.iid(59333).avgdmg=1202;
idb.iid(59333).str=146;
idb.iid(59333).sta=219;
idb.iid(59333).crit=97;
idb.iid(59333).haste=97;
idb.iid(59333).isreforged=0;

idb.iid(59463).name='Maldo''s Sword Cane';
idb.iid(59463).wtype='swo';
idb.iid(59463).ilvl=359;
idb.iid(59463).tooldps=462.5;
idb.iid(59463).swing=1.6;
idb.iid(59463).avgdmg=740;
idb.iid(59463).sta=219;
idb.iid(59463).int=146;
idb.iid(59463).crit=88;
idb.iid(59463).mast=103;
idb.iid(59463).sp=1954;
idb.iid(59463).isreforged=0;

idb.iid(59521).name='Soul Blade';
idb.iid(59521).wtype='swo';
idb.iid(59521).ilvl=359;
idb.iid(59521).tooldps=462.3;
idb.iid(59521).swing=2.6;
idb.iid(59521).avgdmg=1202;
idb.iid(59521).str=146;
idb.iid(59521).sta=219;
idb.iid(59521).hit=97;
idb.iid(59521).mast=97;
idb.iid(59521).isreforged=0;

idb.iid(61344).name='Vicious Gladiator''s Slicer';
idb.iid(61344).wtype='swo';
idb.iid(61344).ilvl=359;
idb.iid(61344).tooldps=462.3;
idb.iid(61344).swing=2.6;
idb.iid(61344).avgdmg=1202;
idb.iid(61344).str=146;
idb.iid(61344).sta=219;
idb.iid(61344).crit=97;
idb.iid(61344).isreforged=0;

idb.iid(61345).name='Vicious Gladiator''s Quickblade';
idb.iid(61345).wtype='swo';
idb.iid(61345).ilvl=359;
idb.iid(61345).tooldps=462.3;
idb.iid(61345).swing=2.6;
idb.iid(61345).avgdmg=1202;
idb.iid(61345).sta=219;
idb.iid(61345).agi=146;
idb.iid(61345).crit=97;
idb.iid(61345).isreforged=0;

idb.iid(63533).name='Fang of Twilight';
idb.iid(63533).wtype='swo';
idb.iid(63533).ilvl=359;
idb.iid(63533).tooldps=462.3;
idb.iid(63533).swing=2.6;
idb.iid(63533).avgdmg=1202;
idb.iid(63533).sta=219;
idb.iid(63533).agi=146;
idb.iid(63533).crit=97;
idb.iid(63533).mast=97;
idb.iid(63533).isreforged=0;

idb.iid(64885).name='Scimitar of the Sirocco';
idb.iid(64885).wtype='swo';
idb.iid(64885).ilvl=359;
idb.iid(64885).tooldps=462.3;
idb.iid(64885).swing=2.6;
idb.iid(64885).avgdmg=1202;
idb.iid(64885).str=146;
idb.iid(64885).sta=219;
idb.iid(64885).crit=111;
idb.iid(64885).haste=74;
idb.iid(64885).isreforged=0;

idb.iid(68161).name='Krol Decapitator';
idb.iid(68161).wtype='swo';
idb.iid(68161).ilvl=359;
idb.iid(68161).tooldps=462.3;
idb.iid(68161).swing=2.6;
idb.iid(68161).avgdmg=1202;
idb.iid(68161).sta=219;
idb.iid(68161).agi=146;
idb.iid(68161).hit=86;
idb.iid(68161).haste=105;
idb.iid(68161).isreforged=0;

idb.iid(70162).name='Pyrium Spellward';
idb.iid(70162).wtype='swo';
idb.iid(70162).ilvl=365;
idb.iid(70162).tooldps=488.8;
idb.iid(70162).swing=2.6;
idb.iid(70162).avgdmg=1271;
idb.iid(70162).sta=232;
idb.iid(70162).agi=155;
idb.iid(70162).hit=103;
idb.iid(70162).mast=103;
idb.iid(70162).isreforged=0;

idb.iid(70163).name='Unbreakable Guardian';
idb.iid(70163).wtype='swo';
idb.iid(70163).ilvl=365;
idb.iid(70163).tooldps=488.8;
idb.iid(70163).swing=2.6;
idb.iid(70163).avgdmg=1271;
idb.iid(70163).str=155;
idb.iid(70163).sta=232;
idb.iid(70163).mast=103;
idb.iid(70163).parry=103;
idb.iid(70163).isreforged=0;

idb.iid(65013).name='Maldo''s Sword Cane (Heroic)';
idb.iid(65013).wtype='swo';
idb.iid(65013).ilvl=372;
idb.iid(65013).tooldps=521.6;
idb.iid(65013).swing=1.6;
idb.iid(65013).avgdmg=834.5;
idb.iid(65013).sta=247;
idb.iid(65013).int=165;
idb.iid(65013).crit=99;
idb.iid(65013).mast=117;
idb.iid(65013).sp=2207;
idb.iid(65013).isreforged=0;

idb.iid(65047).name='Lava Spine (Heroic)';
idb.iid(65047).wtype='swo';
idb.iid(65047).ilvl=372;
idb.iid(65047).tooldps=521.9;
idb.iid(65047).swing=2.6;
idb.iid(65047).avgdmg=1357;
idb.iid(65047).str=165;
idb.iid(65047).sta=248;
idb.iid(65047).crit=110;
idb.iid(65047).haste=110;
idb.iid(65047).isreforged=0;

idb.iid(65094).name='Fang of Twilight (Heroic)';
idb.iid(65094).wtype='swo';
idb.iid(65094).ilvl=372;
idb.iid(65094).tooldps=521.9;
idb.iid(65094).swing=2.6;
idb.iid(65094).avgdmg=1357;
idb.iid(65094).sta=248;
idb.iid(65094).agi=165;
idb.iid(65094).crit=110;
idb.iid(65094).mast=110;
idb.iid(65094).isreforged=0;

idb.iid(65103).name='Soul Blade (Heroic)';
idb.iid(65103).wtype='swo';
idb.iid(65103).ilvl=372;
idb.iid(65103).tooldps=521.9;
idb.iid(65103).swing=2.6;
idb.iid(65103).avgdmg=1357;
idb.iid(65103).str=165;
idb.iid(65103).sta=248;
idb.iid(65103).hit=110;
idb.iid(65103).mast=110;
idb.iid(65103).isreforged=0;

idb.iid(67468).name='Vicious Gladiator''s Quickblade';
idb.iid(67468).wtype='swo';
idb.iid(67468).ilvl=372;
idb.iid(67468).tooldps=521.9;
idb.iid(67468).swing=2.6;
idb.iid(67468).avgdmg=1357;
idb.iid(67468).sta=248;
idb.iid(67468).agi=165;
idb.iid(67468).crit=110;
idb.iid(67468).isreforged=0;

idb.iid(67469).name='Vicious Gladiator''s Slicer';
idb.iid(67469).wtype='swo';
idb.iid(67469).ilvl=372;
idb.iid(67469).tooldps=521.9;
idb.iid(67469).swing=2.6;
idb.iid(67469).avgdmg=1357;
idb.iid(67469).str=165;
idb.iid(67469).sta=248;
idb.iid(67469).crit=110;
idb.iid(67469).isreforged=0;

idb.iid(70229).name='Ruthless Gladiator''s Slicer';
idb.iid(70229).wtype='swo';
idb.iid(70229).ilvl=378;
idb.iid(70229).tooldps=551.7;
idb.iid(70229).swing=2.6;
idb.iid(70229).avgdmg=1434.5;
idb.iid(70229).str=175;
idb.iid(70229).sta=262;
idb.iid(70229).crit=116;
idb.iid(70229).isreforged=0;

idb.iid(70922).name='Mandible of Beth''tilac';
idb.iid(70922).wtype='swo';
idb.iid(70922).ilvl=378;
idb.iid(70922).tooldps=551.7;
idb.iid(70922).swing=2.6;
idb.iid(70922).avgdmg=1434.5;
idb.iid(70922).str=175;
idb.iid(70922).sta=262;
idb.iid(70922).mast=99;
idb.iid(70922).dodge=126;
idb.iid(70922).isreforged=0;

idb.iid(72866).name='Treachery''s Bite';
idb.iid(72866).wtype='swo';
idb.iid(72866).ilvl=378;
idb.iid(72866).tooldps=551.7;
idb.iid(72866).swing=2.6;
idb.iid(72866).avgdmg=1434.5;
idb.iid(72866).str=174;
idb.iid(72866).sta=262;
idb.iid(72866).hit=116;
idb.iid(72866).haste=116;
idb.iid(72866).isreforged=0;

idb.iid(71006).name='Volcanospike';
idb.iid(71006).wtype='swo';
idb.iid(71006).ilvl=378;
idb.iid(71006).tooldps=551.9;
idb.iid(71006).swing=1.6;
idb.iid(71006).avgdmg=883;
idb.iid(71006).sta=262;
idb.iid(71006).int=175;
idb.iid(71006).hit=105;
idb.iid(71006).haste=123;
idb.iid(71006).sp=2333;
idb.iid(71006).isreforged=0;

idb.iid(71785).name='Firethorn Mindslicer';
idb.iid(71785).wtype='swo';
idb.iid(71785).ilvl=378;
idb.iid(71785).tooldps=552.1;
idb.iid(71785).swing=1.7;
idb.iid(71785).avgdmg=938.5;
idb.iid(71785).sta=262;
idb.iid(71785).int=175;
idb.iid(71785).hit=88;
idb.iid(71785).haste=133;
idb.iid(71785).sp=2333;
idb.iid(71785).isreforged=0;

idb.iid(78488).name='Souldrinker (Raid Finder)';
idb.iid(78488).wtype='swo';
idb.iid(78488).ilvl=390;
idb.iid(78488).tooldps=617.1;
idb.iid(78488).swing=2.6;
idb.iid(78488).avgdmg=1604.5;
idb.iid(78488).str=195;
idb.iid(78488).sta=293;
idb.iid(78488).isreforged=0;

idb.iid(70200).name='Ruthless Gladiator''s Slicer';
idb.iid(70200).wtype='swo';
idb.iid(70200).ilvl=391;
idb.iid(70200).tooldps=622.9;
idb.iid(70200).swing=2.6;
idb.iid(70200).avgdmg=1619.5;
idb.iid(70200).str=197;
idb.iid(70200).sta=296;
idb.iid(70200).crit=131;
idb.iid(70200).isreforged=0;

idb.iid(71406).name='Mandible of Beth''tilac (Heroic)';
idb.iid(71406).wtype='swo';
idb.iid(71406).ilvl=391;
idb.iid(71406).tooldps=622.9;
idb.iid(71406).swing=2.6;
idb.iid(71406).avgdmg=1619.5;
idb.iid(71406).str=197;
idb.iid(71406).sta=296;
idb.iid(71406).mast=112;
idb.iid(71406).dodge=143;
idb.iid(71406).isreforged=0;

idb.iid(71422).name='Volcanospike (Heroic)';
idb.iid(71422).wtype='swo';
idb.iid(71422).ilvl=391;
idb.iid(71422).tooldps=623.1;
idb.iid(71422).swing=1.6;
idb.iid(71422).avgdmg=997;
idb.iid(71422).sta=296;
idb.iid(71422).int=197;
idb.iid(71422).hit=119;
idb.iid(71422).haste=139;
idb.iid(71422).sp=2636;
idb.iid(71422).isreforged=0;

idb.iid(71784).name='Firethorn Mindslicer (Heroic)';
idb.iid(71784).wtype='swo';
idb.iid(71784).ilvl=391;
idb.iid(71784).tooldps=622.9;
idb.iid(71784).swing=1.7;
idb.iid(71784).avgdmg=1059;
idb.iid(71784).sta=296;
idb.iid(71784).int=197;
idb.iid(71784).hit=100;
idb.iid(71784).crit=150;
idb.iid(71784).sp=2636;
idb.iid(71784).isreforged=0;

idb.iid(78878).name='Spine of the Thousand Cuts';
idb.iid(78878).wtype='swo';
idb.iid(78878).ilvl=397;
idb.iid(78878).tooldps=658.7;
idb.iid(78878).swing=2.6;
idb.iid(78878).avgdmg=1712.5;
idb.iid(78878).sta=312;
idb.iid(78878).agi=208;
idb.iid(78878).exp=149;
idb.iid(78878).haste=122;
idb.iid(78878).isreforged=0;

idb.iid(77193).name='Souldrinker';
idb.iid(77193).wtype='swo';
idb.iid(77193).ilvl=403;
idb.iid(77193).tooldps=696.5;
idb.iid(77193).swing=2.6;
idb.iid(77193).avgdmg=1811;
idb.iid(77193).str=220;
idb.iid(77193).sta=331;
idb.iid(77193).isreforged=0;

idb.iid(78479).name='Souldrinker (Heroic)';
idb.iid(78479).wtype='swo';
idb.iid(78479).ilvl=416;
idb.iid(78479).tooldps=786.3;
idb.iid(78479).swing=2.6;
idb.iid(78479).avgdmg=2044.5;
idb.iid(78479).str=249;
idb.iid(78479).sta=373;
idb.iid(78479).isreforged=0;


%% Shields

idb.iid(69629).name='Shield of the Blood God';
idb.iid(69629).ilvl=353;
idb.iid(69629).str=180;
idb.iid(69629).sta=270;
idb.iid(69629).mast=117;
idb.iid(69629).dodge=122;
idb.iid(69629).barmor=11803;
idb.iid(69629).isreforged=0;

idb.iid(67145).name='Blockade''s Lost Shield';
idb.iid(67145).ilvl=359;
idb.iid(67145).str=190;
idb.iid(67145).sta=286;
idb.iid(67145).mast=134;
idb.iid(67145).parry=114;
idb.iid(67145).barmor=11896;
idb.iid(67145).isreforged=0;

idb.iid(65023).name='Akmin-Kurai, Dominion''s Shield (Heroic)';
idb.iid(65023).ilvl=372;
idb.iid(65023).str=215;
idb.iid(65023).sta=322;
idb.iid(65023).mast=143;
idb.iid(65023).parry=143;
idb.iid(65023).barmor=12103;
idb.iid(65023).isreforged=0;

idb.iid(70915).name='Shard of Torment';
idb.iid(70915).ilvl=378;
idb.iid(70915).str=147;
idb.iid(70915).sta=341;
idb.iid(70915).dodge=148;
idb.iid(70915).parry=154;
idb.iid(70915).barmor=12201;
idb.iid(70915).socket='BB';
idb.iid(70915).sbstat='sta';
idb.iid(70915).sbval=30;
idb.iid(70915).isreforged=0;

idb.iid(78456).name='Blackhorn''s Mighty Bulwark (Raidfinder)';
idb.iid(78456).ilvl=384;
idb.iid(78456).str=200;
idb.iid(78456).sta=360;
idb.iid(78456).mast=148;
idb.iid(78456).dodge=132;
idb.iid(78456).barmor=12302;
idb.iid(78456).socket='YB';
idb.iid(78456).sbstat='dodge';
idb.iid(78456).sbval=20;
idb.iid(78456).isreforged=0;

idb.iid(71460).name='Shard of Torment (Heroic)';
idb.iid(71460).ilvl=391;
idb.iid(71460).str=176;
idb.iid(71460).sta=384;
idb.iid(71460).dodge=166;
idb.iid(71460).parry=173;
idb.iid(71460).barmor=12421;
idb.iid(71460).socket='BB';
idb.iid(71460).sbstat='sta';
idb.iid(71460).sbval=30;
idb.iid(71460).isreforged=0;

idb.iid(77226).name='Blackhorn''s Mighty Bulwark';
idb.iid(77226).ilvl=397;
idb.iid(77226).str=231;
idb.iid(77226).sta=406;
idb.iid(77226).mast=169;
idb.iid(77226).dodge=153;
idb.iid(77226).barmor=12525;
idb.iid(77226).socket='YB';
idb.iid(77226).sbstat='dodge';
idb.iid(77226).sbval=20;
idb.iid(77226).isreforged=0;

idb.iid(78448).name='Blackhorn''s Mighty Bulwark (Heroic)';
idb.iid(78448).ilvl=410;
idb.iid(78448).str=266;
idb.iid(78448).sta=459;
idb.iid(78448).mast=192;
idb.iid(78448).dodge=176;
idb.iid(78448).barmor=12756;
idb.iid(78448).socket='YB';
idb.iid(78448).sbstat='dodge';
idb.iid(78448).sbval=20;
idb.iid(78448).isreforged=0;



%% Librams

idb.iid(64674).name='Relic of Aggramar';
idb.iid(64674).ilvl=359;
idb.iid(64674).str=107;
idb.iid(64674).sta=161;
idb.iid(64674).crit=72;
idb.iid(64674).exp=72;
idb.iid(64674).socket='P';
idb.iid(64674).isreforged=0;

idb.iid(64676).name='Relic of Khaz''goroth';
idb.iid(64676).ilvl=359;
idb.iid(64676).str=107;
idb.iid(64676).sta=161;
idb.iid(64676).mast=72;
idb.iid(64676).dodge=72;
idb.iid(64676).socket='P';
idb.iid(64676).isreforged=0;

idb.iid(70939).name='Deathclutch Figurine';
idb.iid(70939).ilvl=378;
idb.iid(70939).str=128;
idb.iid(70939).sta=192;
idb.iid(70939).dodge=90;
idb.iid(70939).parry=77;
idb.iid(70939).socket='P';
idb.iid(70939).isreforged=0;

idb.iid(71590).name='Deathclutch Figurine (Heroic)';
idb.iid(71590).ilvl=391;
idb.iid(71590).str=145;
idb.iid(71590).sta=217;
idb.iid(71590).dodge=102;
idb.iid(71590).parry=87;
idb.iid(71590).socket='P';
idb.iid(71590).isreforged=0;

idb.iid(77084).name='Stoutheart Talisman';
idb.iid(77084).ilvl=397;
idb.iid(77084).str=153;
idb.iid(77084).sta=230;
idb.iid(77084).mast=102;
idb.iid(77084).parry=102;
idb.iid(77084).socket='P';
idb.iid(77084).isreforged=0;


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

idb.sid(74211).name='Enchant Weapon - Elemental Slayer';

idb.sid(74223).name='Enchant Weapon - Hurricane';

idb.sid(74242).name='Enchant Weapon - Power Torrent';

idb.sid(74244).name='Enchant Weapon - Windwalk';

idb.sid(74246).name='Enchant Weapon - Landslide';

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