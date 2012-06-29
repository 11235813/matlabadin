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
