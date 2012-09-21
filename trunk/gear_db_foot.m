%% Special Items

idb.iid(2).name='Kilrak, Jaws of Terror (Raid Finder)';
idb.iid(2).wtype='swo';
idb.iid(2).ilvl=483;
idb.iid(2).tooldps=2935.8;
idb.iid(2).swing=2.6;
idb.iid(2).avgdmg=7633.5;
idb.iid(2).str=964;
idb.iid(2).sta=697;
idb.iid(2).hit=314;
idb.iid(2).mast=302;
idb.iid(2).isreforged=0;

idb.iid(3).name='Kilrak, Jaws of Terror (+Gem)';
idb.iid(3).wtype='swo';
idb.iid(3).ilvl=496;
idb.iid(3).tooldps=3313.9;
idb.iid(3).swing=2.6;
idb.iid(3).avgdmg=8616;
idb.iid(3).str=524+500;
idb.iid(3).sta=786;
idb.iid(3).hit=355;
idb.iid(3).mast=341;
idb.iid(3).isreforged=0;

idb.iid(4).name='Kilrak, Jaws of Terror (Heroic+Gem)';
idb.iid(4).wtype='swo';
idb.iid(4).ilvl=509;
idb.iid(4).tooldps=3740.6;
idb.iid(4).swing=2.6;
idb.iid(4).avgdmg=9725.5;
idb.iid(4).str=592+500;
idb.iid(4).sta=887;
idb.iid(4).hit=400;
idb.iid(4).mast=385;
idb.iid(4).isreforged=0;

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


%% Shoulder
%MoP
idb.sid(126994).name='Greater Ox Horn Inscription';
idb.sid(126994).sta=300;
idb.sid(126994).dodge=100;

idb.sid(126997).name='Greater Tiger Fang Inscription';
idb.sid(126997).str=200;
idb.sid(126997).crit=100;

%% Cloak
idb.sid(74234).name='Enchant Cloak - Protection';
idb.sid(74234).earmor=250;

idb.sid(74247).name='Enchant Cloak - Greater Critical Strike';
idb.sid(74247).crit=65;

%MoP
idb.sid(104401).name='Enchant Cloak - Greater Protection';
idb.sid(104401).sta=200;

idb.sid(104398).name='Enchant Cloak - Accuracy';
idb.sid(104398).hit=180;

idb.sid(104404).name='Enchant Cloak - Superior Critical Strike';
idb.sid(104404).hit=180;

%% Chest
idb.sid(104395).name='Enchant Chest - Glorious Stats';
idb.sid(104395).sta=80;
idb.sid(104395).str=80;
idb.sid(104395).agi=80;
idb.sid(104395).int=80;

idb.sid(104397).name='Enchant Chest - Superior Stamina';
idb.sid(104397).sta=300;

%% Wrists
idb.sid(62256).name='Enchant Bracer - Major Stamina';
idb.sid(62256).sta=40;

idb.sid(124553).name='Fur Lining - Stamina';
idb.sid(124553).sta=750;

idb.sid(124554).name='Fur Lining - Strength';
idb.sid(124554).str=500;

idb.sid(74232).name='Enchant Bracer - Precision';
idb.sid(74232).hit=50;

idb.sid(74239).name='Enchant Bracer - Greater Expertise';
idb.sid(74239).exp=50;

idb.sid(74248).name='Enchant Bracer - Greater Critical Strike';
idb.sid(74248).crit=65;

%MoP
idb.sid(104390).name='Enchant Bracer - Exceptional Strength';
idb.sid(104390).str=170;

idb.sid(104385).name='Enchant Bracer - Superior Dodge';
idb.sid(104385).dodge=170;

idb.sid(104338).name='Enchant Bracer - Mastery';
idb.sid(104338).mast=170;


%% Hands
idb.sid(74220).name='Enchant Gloves - Greater Expertise';
idb.sid(74220).exp=50;

idb.sid(82175).name='Synapse Springs';

idb.sid(82177).name='Quickflip Deflection Plates';

%MoP
idb.sid(104419).name='Enchant Gloves - Super Strength';
idb.sid(104419).str=170;

idb.sid(104420).name='Enchant Gloves - Superior Mastery';
idb.sid(104420).mast=170;

idb.sid(104417).name='Enchant Gloves - Superior Expertise';
idb.sid(104417).exp=170;

idb.sid(104416).name='Enchant Gloves - Greater Haste';
idb.sid(104416).haste=170;

%% Waist
idb.sid(90046).name='Living Steel Belt Buckle';
idb.sid(90046).socket='P';

%% Legs

idb.sid(78171).name='Dragonscale Leg Armor';
idb.sid(78171).ap=190;
idb.sid(78171).crit=55;

idb.sid(78172).name='Charscale Leg Armor';
idb.sid(78172).sta=145;
idb.sid(78172).agi=55;

%MoP
idb.sid(124128).name='Ironscale Leg Armor';
idb.sid(124128).sta=430;
idb.sid(124128).dodge=165;

idb.sid(124129).name='Shadowleather Leg Armor';
idb.sid(124129).agi=285;
idb.sid(124129).crit=165;

idb.sid(124127).name='Angerhide Leg Armor';
idb.sid(124127).str=285;
idb.sid(124127).crit=165;

idb.sid(124125).name='Toughened Leg Armor';
idb.sid(124125).sta=250;
idb.sid(124125).dodge=100;

idb.sid(124126).name='Brutal Leg Armor';
idb.sid(124126).str=170;
idb.sid(124126).crit=100;

idb.sid(124124).name='Sha-Touched Leg Armor';
idb.sid(124124).agi=170;
idb.sid(124124).crit=100;

%% Feet
idb.sid(74189).name='Enchant Boots - Earthen Vitality';
idb.sid(74189).sta=30;

%MoP
idb.sid(104414).name='Enchant Boots - Pandaren''s Step';
idb.sid(104414).mast=140;

idb.sid(104409).name='Enchant Boots - Blurred Speed';
idb.sid(104409).agi=140;

idb.sid(104407).name='Enchant Boots - Greater Haste';
idb.sid(104407).haste=175;

idb.sid(104408).name='Enchant Boots - Greater Precision';
idb.sid(104408).hit=175;

%% Rings
idb.sid(103463).name='Enchant Ring - Greater Stamina';
idb.sid(103463).sta=160;

idb.sid(103465).name='Enchant Ring - Strength';
idb.sid(103465).str=160;

%% Weapon
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

idb.sid(55057).name='Pyrium Weapon Chain';
idb.sid(55057).hit=40;

%MoP enchants
idb.sid(104434).name='Enchant Weapon - Dancing Steel';
idb.sid(104434).procid=0; %PH

idb.sid(104442).name='Enchant Weapon - River''s Song';
idb.sid(104442).procid=0; %PH

idb.sid(104440).name='Enchant Weapon - Colossus';
idb.sid(104440).procid=0; %PH

idb.sid(104425).name='Enchant Weapon - Windsong';
idb.sid(104425).procid=0; %PH

idb.sid(104430).name='Enchant Weapon - Elemental Force';
idb.sid(104430).procid=0; %PH

%% Shield
%Cata
idb.sid(34009).name='Enchant Shield - Major Stamina';
idb.sid(34009).sta=18;

idb.sid(74207).name='Enchant Shield - Protection';
idb.sid(74207).earmor=160;

idb.sid(74226).name='Enchant Shield - Mastery';
idb.sid(74226).mast=50;

%MoP
idb.sid(130758).name='Enchant Shield - Greater Parry';
idb.sid(130758).parry=170;


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
idb.iid(76696).name='Bold Primordial Ruby';
idb.iid(76696).str=160;
idb.iid(76696).socket='R';

idb.iid(76692).name='Delicate Primordial Ruby';
idb.iid(76692).agi=160;
idb.iid(76692).socket='R';

idb.iid(76695).name='Flashing Primordial Ruby';
idb.iid(76695).parry=320;
idb.iid(76695).socket='R';

idb.iid(76693).name='Precise Primordial Ruby';
idb.iid(76693).exp=160;
idb.iid(76693).socket='R';

idb.iid(83141).name='Bold Serpent''s Eye';
idb.iid(83141).str=320;
idb.iid(83141).socket='R';

idb.iid(83151).name='Delicate Serpent''s Eye';
idb.iid(83151).agi=320;
idb.iid(83151).socket='R';

idb.iid(83152).name='Flashing Serpent''s Eye';
idb.iid(83152).parry=480;
idb.iid(83152).socket='R';

idb.iid(83147).name='Precise Serpent''s Eye';
idb.iid(83147).exp=480;
idb.iid(83147).socket='R';

% Orange
idb.iid(76670).name='Adept Vermilion Onyx';
idb.iid(76670).agi=80;
idb.iid(76670).mast=160;
idb.iid(76670).socket='RY';

idb.iid(76659).name='Crafty Vermilion Onyx';
idb.iid(76659).exp=160;
idb.iid(76659).crit=160;
idb.iid(76659).socket='RY';

idb.iid(76673).name='Fine Vermilion Onyx';
idb.iid(76673).parry=160;
idb.iid(76673).mast=160;
idb.iid(76673).socket='RY';

idb.iid(76661).name='Inscribed Vermilion Onyx';
idb.iid(76661).str=80;
idb.iid(76661).crit=160;
idb.iid(76661).socket='RY';

idb.iid(76671).name='Keen Vermilion Onyx';
idb.iid(76671).exp=160;
idb.iid(76671).mast=160;
idb.iid(76671).socket='RY';

idb.iid(76662).name='Polished Vermilion Onyx';
idb.iid(76662).agi=80;
idb.iid(76662).dodge=160;
idb.iid(76662).socket='RY';

idb.iid(76674).name='Skillful Vermilion Onyx';
idb.iid(76674).str=80;
idb.iid(76674).mast=160;
idb.iid(76674).socket='RY';

idb.iid(76663).name='Resolute Vermilion Onyx';
idb.iid(76663).exp=160;
idb.iid(76663).dodge=160;
idb.iid(76663).socket='RY';

idb.iid(88933).name='Crafty Sardonyx';
idb.iid(88933).exp=200;
idb.iid(88933).crit=200;
idb.iid(88933).socket='RY';

idb.iid(88937).name='Fine Sardonyx';
idb.iid(88937).parry=200;
idb.iid(88937).mast=200;
idb.iid(88937).socket='RY';

idb.iid(88938).name='Inscribed Sardonyx';
idb.iid(88938).str=100;
idb.iid(88938).crit=200;
idb.iid(88938).socket='RY';

idb.iid(88939).name='Keen Sardonyx';
idb.iid(88939).exp=200;
idb.iid(88939).mast=200;
idb.iid(88939).socket='RY';

idb.iid(88946).name='Skillful Sardonyx';
idb.iid(88946).str=100;
idb.iid(88946).mast=200;
idb.iid(88946).socket='RY';

% Yellow
idb.iid(76700).name='Fractured Sun''s Radiance';
idb.iid(76700).mast=320;
idb.iid(76700).socket='Y';

idb.iid(76698).name='Subtle Sun''s Radiance';
idb.iid(76698).dodge=320;
idb.iid(76698).socket='Y';

idb.iid(83145).name='Subtle Serpent''s Eye';
idb.iid(83145).dodge=480;
idb.iid(83145).socket='Y';

idb.iid(83143).name='Fractured Serpent''s Eye';
idb.iid(83143).mast=480;
idb.iid(83143).socket='Y';

% Green
idb.iid(76655).name='Nimble Wild Jade';
idb.iid(76655).sta=120;
idb.iid(76655).hit=160;
idb.iid(76655).socket='YB';

idb.iid(76656).name='Puissant Wild Jade';
idb.iid(76656).mast=160;
idb.iid(76656).sta=120;
idb.iid(76656).socket='YB';

idb.iid(76653).name='Regal Wild Jade';
idb.iid(76653).dodge=160;
idb.iid(76653).sta=120;
idb.iid(76653).socket='YB';

idb.iid(76643).name='Sensei''s Wild Jade';
idb.iid(76643).mast=160;
idb.iid(76643).hit=160;
idb.iid(76643).socket='YB';

idb.iid(88920).name='Puissant Adventurine';
idb.iid(88920).mast=200;
idb.iid(88920).sta=150;
idb.iid(88920).socket='YB';

idb.iid(88923).name='Sensei''s Adventurine';
idb.iid(88923).mast=200;
idb.iid(88923).hit=200;
idb.iid(88923).socket='YB';

idb.iid(88918).name='Nimble Adventurine';
idb.iid(88918).sta=150;
idb.iid(88918).hit=200;
idb.iid(88918).socket='YB';

% Blue
idb.iid(76636).name='Rigid River''s Heart';
idb.iid(76636).hit=320;
idb.iid(76636).socket='B';

idb.iid(76639).name='Solid River''s Heart';
idb.iid(76639).sta=240;
idb.iid(76639).socket='B';

idb.iid(83148).name='Solid Serpent''s Eye';
idb.iid(83148).sta=480;
idb.iid(83148).socket='B';

idb.iid(83144).name='Rigid Serpent''s Eye';
idb.iid(83144).hit=480;
idb.iid(83144).socket='B';

% Purple
idb.iid(76681).name='Accurate Imperial Amethyst';
idb.iid(76681).exp=160;
idb.iid(76681).hit=160;
idb.iid(76681).socket='RB';

idb.iid(76690).name='Defender''s Imperial Amethyst';
idb.iid(76690).parry=160;
idb.iid(76690).sta=120;
idb.iid(76690).socket='RB';

idb.iid(76684).name='Etched Imperial Amethyst';
idb.iid(76684).str=80;
idb.iid(76684).hit=160;
idb.iid(76684).socket='RB';

idb.iid(76680).name='Glinting Imperial Amethyst';
idb.iid(76680).agi=80;
idb.iid(76680).hit=160;
idb.iid(76680).socket='RB';

idb.iid(76688).name='Guardian''s Imperial Amethyst';
idb.iid(76688).exp=160;
idb.iid(76688).sta=120;
idb.iid(76688).socket='RB';

idb.iid(76683).name='Retaliating Imperial Amethyst';
idb.iid(76683).parry=160;
idb.iid(76683).hit=160;
idb.iid(76683).socket='RB';

idb.iid(76687).name='Shifting Imperial Amethyst';
idb.iid(76687).agi=80;
idb.iid(76687).sta=120;
idb.iid(76687).socket='RB';

idb.iid(76691).name='Sovereign Imperial Amethyst';
idb.iid(76691).str=80;
idb.iid(76691).sta=120;
idb.iid(76691).socket='RB';

idb.iid(88952).name='Accurate Zyanite';
idb.iid(88952).exp=200;
idb.iid(88952).hit=200;
idb.iid(88952).socket='RB';

idb.iid(88953).name='Defender''s Zyanite';
idb.iid(88953).parry=200;
idb.iid(88953).sta=150;
idb.iid(88953).socket='RB';

idb.iid(88954).name='Etched Zyanite';
idb.iid(88954).str=100;
idb.iid(88954).hit=200;
idb.iid(88954).socket='RB';

idb.iid(88956).name='Guardian''s Zyanite';
idb.iid(88956).sta=150;
idb.iid(88956).exp=200;
idb.iid(88956).socket='RB';

% Prismatic /TODO check for lvl85 homologue
idb.iid(49110).name='Nightmare Tear';
idb.iid(49110).str=10;
idb.iid(49110).sta=10;
idb.iid(49110).agi=10;
idb.iid(49110).socket='P';

% Meta
idb.iid(68779).name='Reverberating Primal Diamond';
idb.iid(68779).str=216;
idb.iid(68779).meta=3;
idb.iid(68779).socket='M';

idb.iid(76896).name='Eternal Primal Diamond';
idb.iid(76896).dodge=432;
idb.iid(76896).meta=2;
idb.iid(76896).socket='M';

idb.iid(76895).name='Austere Primal Diamond';
idb.iid(76895).sta=324;
idb.iid(76895).meta=1;
idb.iid(76895).socket='M';

idb.iid(76897).name='Effulgent Primal Diamond';
idb.iid(76897).sta=324;
idb.iid(76897).meta=4;
idb.iid(76897).socket='M';

idb.iid(76891).name='Powerful Primal Diamond';
idb.iid(76891).sta=324;
idb.iid(76891).meta=5;
idb.iid(76891).socket='M';
