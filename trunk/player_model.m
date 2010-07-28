%% PLAYER_MODEL
%This file contains all of the base player stats and formulas.  I.e.
%anything that comes before talents and gear.

%The 'base' structure contains relevant base stats, given below.  We can
%call them later on via 'base.x' (i.e. base.dodge).  

%part of the reason for moving to structures for a large number of
%variables is to obfuscate things we don't frequently vary or care about.
%Stuff we do care about (like the final stats) will probably still get
%their own variables so that it's easy to do matrix operations on them.
%% global variables
global base

base.level=80;
base.wskill=5.*base.level; %inherent
base.ap=3.*base.level;     %class specific
base.sp=0;                 %TODO: look up
base.mast=0;               %TODO: look up
base.miss=0;               %TODO: look up (~5?)
base.dodge=3.4943;         %class and level dependent
base.parry=0;              %TODO: look up (~5?)
base.block=0;              %TODO: look up (~5?)
base.spcrit=3.34;          %class and level dependent
base.phcrit=3.27;          %class and level dependent
base.health=6934;          %class and level dependent
base.mana=4394;            %class and level dependent
base.exp=0;                %overridden in stats_recalc based on weapon type

%% race master switch
base.race=1; %human by default (1-human, 2-dwarf, 3-draenai, 4-blood elf)

%%base stats block (for lvl 80 paladins, duh)
%the format is      STR-STA-AGI-INT-SPI
player_base_stats=[ 151 143  90  98 108;
                    153 146  86  97 104;
                    152 142  87  99 107;
                    148 141  92 102 104];

base.str=player_base_stats(base.race,1);
base.sta=player_base_stats(base.race,2);
base.agi=player_base_stats(base.race,3);
base.int=player_base_stats(base.race,4);    
base.spi=player_base_stats(base.race,5);

