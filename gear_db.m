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
%egs.istier     (logical : [tier11 tier12 tier13], undefined if not a tier set item)

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
               'istier',[0 0 0],...
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
               'istier',[0 0 0],...
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
idb.iid(65226).istier=[1 0 0];

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
idb.iid(70948).istier=[0 1 0];

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
idb.iid(71524).istier=[0 1 0];


%% Neck 

idb.iid(69635).name='Amulet of Protection';
idb.iid(69635).ilvl=353;
idb.iid(69635).str=180;
idb.iid(69635).sta=270;
idb.iid(69635).mast=102;
idb.iid(69635).dodge=130;

idb.iid(59319).name='Ironstar Amulet';
idb.iid(59319).ilvl=359;
idb.iid(59319).str=145;
idb.iid(59319).sta=286;
idb.iid(59319).hit=96;
idb.iid(59319).dodge=190;

idb.iid(65059).name='Ironstar Amulet (Heroic)';
idb.iid(65059).ilvl=372;
idb.iid(65059).str=163;
idb.iid(65059).sta=322;
idb.iid(65059).hit=109;
idb.iid(65059).dodge=215;

idb.iid(70935).name='Stoneheart Necklace';
idb.iid(70935).ilvl=378;
idb.iid(70935).str=227;
idb.iid(70935).sta=341;
idb.iid(70935).mast=165;
idb.iid(70935).parry=129;

idb.iid(71589).name='Stoneheart Necklace (Heroic)';
idb.iid(71589).ilvl=391;
idb.iid(71589).str=256;
idb.iid(71589).sta=384;
idb.iid(71589).mast=186;
idb.iid(71589).parry=146;


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
idb.iid(65228).istier=[1 0 0];

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
idb.iid(70946).istier=[0 1 0];

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
idb.iid(71526).istier=[0 1 0];


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

idb.iid(62383).name='Wrap of the Great Turtle';
idb.iid(62383).ilvl=359;
idb.iid(62383).str=190;
idb.iid(62383).sta=286;
idb.iid(62383).mast=127;
idb.iid(62383).dodge=127;
idb.iid(62383).barmor=625;

idb.iid(70930).name='Durable Flamewrath Cloak';
idb.iid(70930).ilvl=378;
idb.iid(70930).str=173;
idb.iid(70930).sta=341;
idb.iid(70930).hit=115;
idb.iid(70930).parry=227;
idb.iid(70930).barmor=695;

idb.iid(71392).name='Durable Flamewrath Cloak (Heroic)';
idb.iid(71392).ilvl=391;
idb.iid(71392).str=195;
idb.iid(71392).sta=384;
idb.iid(71392).hit=130;
idb.iid(71392).parry=256;
idb.iid(71392).barmor=745;


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
idb.iid(65224).istier=[1 0 0];

idb.iid(70914).name='Flamescarred Carapace';
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
idb.iid(70950).istier=[0 1 0];

idb.iid(71405).name='Flamescarred Carapace (Heroic)';
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
idb.iid(71522).istier=[0 1 0];


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

idb.iid(59470).name='Bracers of Impossible Strength';
idb.iid(59470).ilvl=359;
idb.iid(59470).str=190;
idb.iid(59470).sta=286;
idb.iid(59470).mast=127;
idb.iid(59470).parry=127;
idb.iid(59470).barmor=1499;
idb.iid(59470).atype=1;

idb.iid(65143).name='Bracers of Impossible Strength (Heroic)';
idb.iid(65143).ilvl=372;
idb.iid(65143).str=215;
idb.iid(65143).sta=322;
idb.iid(65143).mast=143;
idb.iid(65143).parry=143;
idb.iid(65143).barmor=1557;
idb.iid(65143).atype=1;

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
idb.iid(60355).istier=[1 0 0];

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
idb.iid(65225).istier=[1 0 0];

idb.iid(69937).name='Eternal Elementium Handguards';
idb.iid(69937).ilvl=378;
idb.iid(69937).str=302;
idb.iid(69937).sta=454;
idb.iid(69937).mast=202;
idb.iid(69937).parry=202;
idb.iid(69937).barmor=2264;
idb.iid(69937).atype=1;

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
idb.iid(70949).istier=[0 1 0];

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
idb.iid(71523).istier=[0 1 0];


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

idb.iid(70933).name='Girdle of the Indomitable Flame';
idb.iid(70933).ilvl=378;
idb.iid(70933).str=282;
idb.iid(70933).sta=454;
idb.iid(70933).dodge=208;
idb.iid(70933).parry=172;
idb.iid(70933).barmor=2037;
idb.iid(70933).socket='B';
idb.iid(70933).sbstat='sta';
idb.iid(70933).sbval=15;
idb.iid(70933).atype=1;

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

idb.iid(60357).name='Reinforced Sapphirium Legguards';
idb.iid(60357).ilvl=359;
idb.iid(60357).str=341;
idb.iid(60357).sta=512;
idb.iid(60357).dodge=188;
idb.iid(60357).parry=188;
idb.iid(60357).barmor=2998;
idb.iid(60357).socket='RB';
idb.iid(60357).sbstat='sta';
idb.iid(60357).sbval=30;
idb.iid(60357).atype=1;

idb.iid(65227).name='Reinforced Sapphirium Legguards (Heroic)';
idb.iid(65227).ilvl=372;
idb.iid(65227).str=385;
idb.iid(65227).sta=578;
idb.iid(65227).dodge=217;
idb.iid(65227).parry=217;
idb.iid(65227).barmor=3114;
idb.iid(65227).socket='RB';
idb.iid(65227).sbstat='sta';
idb.iid(65227).sbval=30;
idb.iid(65227).atype=1;
idb.iid(65227).istier=[1 0 0];

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
idb.iid(70947).istier=[0 1 0];

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
idb.iid(71525).istier=[0 1 0];


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

idb.iid(69947).name='Mirrored Boots';
idb.iid(69947).ilvl=378;
idb.iid(69947).str=302;
idb.iid(69947).sta=454;
idb.iid(69947).mast=202;
idb.iid(69947).parry=202;
idb.iid(69947).barmor=2490;
idb.iid(69947).atype=1;

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


%% Rings

idb.iid(62440).name='Red Rock Band';
idb.iid(62440).ilvl=346;
idb.iid(62440).str=120;
idb.iid(62440).sta=252;
idb.iid(62440).exp=98;
idb.iid(62440).mast=168;

idb.iid(62351).name='Felsen''s Ring of Resolve';
idb.iid(62351).ilvl=346;
idb.iid(62351).str=168;
idb.iid(62351).sta=252;
idb.iid(62351).mast=112;
idb.iid(62351).dodge=112;

idb.iid(58187).name='Ring of the Battle Anthem';
idb.iid(58187).ilvl=359;
idb.iid(58187).str=190;
idb.iid(58187).sta=286;
idb.iid(58187).mast=127;
idb.iid(58187).dodge=127;

idb.iid(59233).name='Bile-O-Tron Nut';
idb.iid(59233).ilvl=359;
idb.iid(59233).str=136;
idb.iid(59233).sta=286;
idb.iid(59233).exp=111;
idb.iid(59233).dodge=190;

idb.iid(65070).name='Bile-O-Tron Nut (Heroic)';
idb.iid(65070).ilvl=372;
idb.iid(65070).str=153;
idb.iid(65070).sta=322;
idb.iid(65070).exp=126;
idb.iid(65070).dodge=215;

idb.iid(71367).name='Theck''s Emberseal';
idb.iid(71367).ilvl=378;
idb.iid(71367).str=173;
idb.iid(71367).sta=341;
idb.iid(71367).hit=115;
idb.iid(71367).dodge=227;

idb.iid(70940).name='Deflecting Brimstone Band';
idb.iid(70940).ilvl=378;
idb.iid(70940).str=227;
idb.iid(70940).sta=341;
idb.iid(70940).mast=154;
idb.iid(70940).dodge=148;

idb.iid(71591).name='Deflecting Brimstone Band (Heroic)';
idb.iid(71591).ilvl=391;
idb.iid(71591).str=256;
idb.iid(71591).sta=384;
idb.iid(71591).mast=173;
idb.iid(71591).dodge=166;

idb.iid(70934).name='Adamantine Signet of the Avengers';
idb.iid(70934).ilvl=391;
idb.iid(70934).str=175;
idb.iid(70934).sta=384;
idb.iid(70934).hit=110;
idb.iid(70934).dodge=256;
idb.iid(70934).socket='R';
idb.iid(70934).sbstat='sta';
idb.iid(70934).sbval=15;


%% Trinkets

idb.iid(56347).name='Leaden Despair (Heroic)';
idb.iid(56347).ilvl=346;
idb.iid(56347).sta=427;

idb.iid(56406).name='Impetuous Query (Heroic)';
idb.iid(56406).ilvl=346;
idb.iid(56406).mast=285;

idb.iid(59515).name='Vial of Stolen Memories';
idb.iid(59515).ilvl=359;
idb.iid(59515).sta=482;

idb.iid(65109).name='Vial of Stolen Memories (Heroic)';
idb.iid(65109).ilvl=372;
idb.iid(65109).sta=544;

% Mirror of Broken Images (H) =  Unsolvable Riddle (A) 
idb.iid(62466).name='Mirror of Broken Images';
idb.iid(62466).ilvl=359;
idb.iid(56466).mast=321;

idb.iid(68981).name='Spidersilk Spindle';
idb.iid(68981).ilvl=378;
idb.iid(68981).mast=383;

idb.iid(68915).name='Scales of Life';
idb.iid(68915).ilvl=378;
idb.iid(68915).sta=575;

idb.iid(69138).name='Spidersilk Spindle (Heroic)';
idb.iid(69138).ilvl=391;
idb.iid(69138).mast=433;

idb.iid(69109).name='Scales of Life (Heroic)';
idb.iid(69109).ilvl=391;
idb.iid(69109).sta=650;

%% Weapons
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

% Darkheart Hacker (H,68740) =  Darkheart Hacker (A,68739) 
idb.iid(68740).name='Darkheart Hacker';
idb.iid(68740).wtype='axe';
idb.iid(68740).ilvl=346;
idb.iid(68740).tooldps=409.6;
idb.iid(68740).swing=2.6;
idb.iid(68740).avgdmg=1065;
idb.iid(68740).sta=194;
idb.iid(68740).agi=129;
idb.iid(68740).exp=78;
idb.iid(68740).mast=91;

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

idb.iid(61324).name='Vicious Gladiator''s Cleaver';
idb.iid(61324).wtype='axe';
idb.iid(61324).ilvl=359;
idb.iid(61324).tooldps=462.3;
idb.iid(61324).swing=2.6;
idb.iid(61324).avgdmg=1202;
idb.iid(61324).sta=219;
idb.iid(61324).agi=146;
idb.iid(61324).crit=97;

idb.iid(61325).name='Vicious Gladiator''s Hacker';
idb.iid(61325).wtype='axe';
idb.iid(61325).ilvl=359;
idb.iid(61325).tooldps=462.3;
idb.iid(61325).swing=2.6;
idb.iid(61325).avgdmg=1202;
idb.iid(61325).str=146;
idb.iid(61325).sta=219;
idb.iid(61325).crit=97;

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

idb.iid(67473).name='Vicious Gladiator''s Hacker';
idb.iid(67473).wtype='axe';
idb.iid(67473).ilvl=372;
idb.iid(67473).tooldps=521.9;
idb.iid(67473).swing=2.6;
idb.iid(67473).avgdmg=1357;
idb.iid(67473).str=165;
idb.iid(67473).sta=248;
idb.iid(67473).crit=110;

idb.iid(67474).name='Vicious Gladiator''s Cleaver';
idb.iid(67474).wtype='axe';
idb.iid(67474).ilvl=372;
idb.iid(67474).tooldps=521.9;
idb.iid(67474).swing=2.6;
idb.iid(67474).avgdmg=1357;
idb.iid(67474).sta=248;
idb.iid(67474).agi=165;
idb.iid(67474).crit=110;

idb.iid(70212).name='Ruthless Gladiator''s Hacker';
idb.iid(70212).wtype='axe';
idb.iid(70212).ilvl=378;
idb.iid(70212).tooldps=551.7;
idb.iid(70212).swing=2.6;
idb.iid(70212).avgdmg=1434.5;
idb.iid(70212).str=175;
idb.iid(70212).sta=262;
idb.iid(70212).crit=116;

idb.iid(71362).name='Blackcleave Chopper';
idb.iid(71362).wtype='axe';
idb.iid(71362).ilvl=378;
idb.iid(71362).tooldps=551.7;
idb.iid(71362).swing=2.6;
idb.iid(71362).avgdmg=1434.5;
idb.iid(71362).str=175;
idb.iid(71362).sta=262;
idb.iid(71362).hit=105;
idb.iid(71362).mast=123;

idb.iid(70204).name='Ruthless Gladiator''s Hacker';
idb.iid(70204).wtype='axe';
idb.iid(70204).ilvl=391;
idb.iid(70204).tooldps=622.9;
idb.iid(70204).swing=2.6;
idb.iid(70204).avgdmg=1619.5;
idb.iid(70204).str=197;
idb.iid(70204).sta=296;
idb.iid(70204).crit=131;

idb.iid(71562).name='Blackcleave Chopper (Heroic)';
idb.iid(71562).wtype='axe';
idb.iid(71562).ilvl=391;
idb.iid(71562).tooldps=622.9;
idb.iid(71562).swing=2.6;
idb.iid(71562).avgdmg=1619.5;
idb.iid(71562).str=197;
idb.iid(71562).sta=296;
idb.iid(71562).hit=119;
idb.iid(71562).mast=139;

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

idb.iid(61335).name='Vicious Gladiator''s Pummeler';
idb.iid(61335).wtype='mac';
idb.iid(61335).ilvl=359;
idb.iid(61335).tooldps=462.3;
idb.iid(61335).swing=2.6;
idb.iid(61335).avgdmg=1202;
idb.iid(61335).sta=219;
idb.iid(61335).agi=146;
idb.iid(61335).crit=97;

idb.iid(61336).name='Vicious Gladiator''s Bonecracker';
idb.iid(61336).wtype='mac';
idb.iid(61336).ilvl=359;
idb.iid(61336).tooldps=462.3;
idb.iid(61336).swing=2.6;
idb.iid(61336).avgdmg=1202;
idb.iid(61336).str=146;
idb.iid(61336).sta=219;
idb.iid(61336).crit=97;

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

idb.iid(67470).name='Vicious Gladiator''s Bonecracker';
idb.iid(67470).wtype='mac';
idb.iid(67470).ilvl=372;
idb.iid(67470).tooldps=521.9;
idb.iid(67470).swing=2.6;
idb.iid(67470).avgdmg=1357;
idb.iid(67470).str=165;
idb.iid(67470).sta=248;
idb.iid(67470).crit=110;

idb.iid(67471).name='Vicious Gladiator''s Pummeler';
idb.iid(67471).wtype='mac';
idb.iid(67471).ilvl=372;
idb.iid(67471).tooldps=521.9;
idb.iid(67471).swing=2.6;
idb.iid(67471).avgdmg=1357;
idb.iid(67471).sta=248;
idb.iid(67471).agi=165;
idb.iid(67471).crit=110;

idb.iid(70222).name='Ruthless Gladiator''s Bonecracker';
idb.iid(70222).wtype='mac';
idb.iid(70222).ilvl=378;
idb.iid(70222).tooldps=551.7;
idb.iid(70222).swing=2.6;
idb.iid(70222).avgdmg=1434.5;
idb.iid(70222).str=175;
idb.iid(70222).sta=262;
idb.iid(70222).crit=116;

idb.iid(70201).name='Ruthless Gladiator''s Bonecracker';
idb.iid(70201).wtype='mac';
idb.iid(70201).ilvl=391;
idb.iid(70201).tooldps=622.9;
idb.iid(70201).swing=2.6;
idb.iid(70201).avgdmg=1619.5;
idb.iid(70201).str=197;
idb.iid(70201).sta=296;
idb.iid(70201).crit=131;

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

idb.iid(61344).name='Vicious Gladiator''s Slicer';
idb.iid(61344).wtype='swo';
idb.iid(61344).ilvl=359;
idb.iid(61344).tooldps=462.3;
idb.iid(61344).swing=2.6;
idb.iid(61344).avgdmg=1202;
idb.iid(61344).str=146;
idb.iid(61344).sta=219;
idb.iid(61344).crit=97;

idb.iid(61345).name='Vicious Gladiator''s Quickblade';
idb.iid(61345).wtype='swo';
idb.iid(61345).ilvl=359;
idb.iid(61345).tooldps=462.3;
idb.iid(61345).swing=2.6;
idb.iid(61345).avgdmg=1202;
idb.iid(61345).sta=219;
idb.iid(61345).agi=146;
idb.iid(61345).crit=97;

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

idb.iid(67468).name='Vicious Gladiator''s Quickblade';
idb.iid(67468).wtype='swo';
idb.iid(67468).ilvl=372;
idb.iid(67468).tooldps=521.9;
idb.iid(67468).swing=2.6;
idb.iid(67468).avgdmg=1357;
idb.iid(67468).sta=248;
idb.iid(67468).agi=165;
idb.iid(67468).crit=110;

idb.iid(67469).name='Vicious Gladiator''s Slicer';
idb.iid(67469).wtype='swo';
idb.iid(67469).ilvl=372;
idb.iid(67469).tooldps=521.9;
idb.iid(67469).swing=2.6;
idb.iid(67469).avgdmg=1357;
idb.iid(67469).str=165;
idb.iid(67469).sta=248;
idb.iid(67469).crit=110;

idb.iid(70229).name='Ruthless Gladiator''s Slicer';
idb.iid(70229).wtype='swo';
idb.iid(70229).ilvl=378;
idb.iid(70229).tooldps=551.7;
idb.iid(70229).swing=2.6;
idb.iid(70229).avgdmg=1434.5;
idb.iid(70229).str=175;
idb.iid(70229).sta=262;
idb.iid(70229).crit=116;

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

idb.iid(70200).name='Ruthless Gladiator''s Slicer';
idb.iid(70200).wtype='swo';
idb.iid(70200).ilvl=391;
idb.iid(70200).tooldps=622.9;
idb.iid(70200).swing=2.6;
idb.iid(70200).avgdmg=1619.5;
idb.iid(70200).str=197;
idb.iid(70200).sta=296;
idb.iid(70200).crit=131;

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


%% Shields

idb.iid(69629).name='Shield of the Blood God';
idb.iid(69629).ilvl=353;
idb.iid(69629).str=180;
idb.iid(69629).sta=270;
idb.iid(69629).mast=117;
idb.iid(69629).dodge=122;
idb.iid(69629).barmor=11803;

idb.iid(67145).name='Blockade''s Lost Shield';
idb.iid(67145).ilvl=359;
idb.iid(67145).str=190;
idb.iid(67145).sta=286;
idb.iid(67145).mast=134;
idb.iid(67145).parry=114;
idb.iid(67145).barmor=11896;

idb.iid(65023).name='Akmin-Kurai, Dominion''s Shield (Heroic)';
idb.iid(65023).ilvl=372;
idb.iid(65023).str=215;
idb.iid(65023).sta=322;
idb.iid(65023).mast=143;
idb.iid(65023).parry=143;
idb.iid(65023).barmor=12103;

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



%% Librams

idb.iid(64674).name='Relic of Aggramar';
idb.iid(64674).ilvl=359;
idb.iid(64674).str=107;
idb.iid(64674).sta=161;
idb.iid(64674).crit=72;
idb.iid(64674).exp=72;
idb.iid(64674).socket='P';

idb.iid(64676).name='Relic of Khaz''goroth';
idb.iid(64676).ilvl=359;
idb.iid(64676).str=107;
idb.iid(64676).sta=161;
idb.iid(64676).mast=72;
idb.iid(64676).dodge=72;
idb.iid(64676).socket='P';

idb.iid(70939).name='Deathclutch Figurine';
idb.iid(70939).ilvl=378;
idb.iid(70939).str=128;
idb.iid(70939).sta=192;
idb.iid(70939).dodge=90;
idb.iid(70939).parry=77;
idb.iid(70939).socket='P';

idb.iid(71590).name='Deathclutch Figurine (Heroic)';
idb.iid(71590).ilvl=391;
idb.iid(71590).str=145;
idb.iid(71590).sta=217;
idb.iid(71590).dodge=102;
idb.iid(71590).parry=87;
idb.iid(71590).socket='P';



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