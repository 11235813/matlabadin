function [base] = player_model(varargin)
%% PLAYER_MODEL
%This file contains all of the base player stats and formulas.  I.e.
%anything that comes before talents and gear.

%The 'base' structure contains relevant base stats, given below.  We can
%call them later on via 'base.x' (i.e. base.dodge).  

%part of the reason for moving to structures for a large number of
%variables is to obfuscate things we don't frequently vary or care about.
%Stuff we do care about (like the final stats) will probably still get
%their own variables so that it's easy to do matrix operations on them.

%player_model is now a function, having race as input argument :
%race=1/2/3/4, corresponding to human/dwarf/draenai/blood elf (respectively)
%If race is not specified, player_model will default to human.

%% global variables
global base

%% global variables
global base

%% input handling
for i = 1 : 2 : length(varargin)

    name = varargin{i};
    value = varargin{i+1};
    switch name
        case 'race'
            race=value;
    end
end

%% default (human)
if exist('race')==0 race=1; end;

%%racial base stats (lvl 80)
%the format is      STR-STA-AGI-INT-SPI
player_base_stats=[ 151 143  90  98 108;
                    153 146  86  97 104;
                    152 142  87  99 107;
                    148 141  92 102 104];
base.str=player_base_stats(race,1);
base.sta=player_base_stats(race,2);
base.agi=player_base_stats(race,3);
base.int=player_base_stats(race,4);    
base.spi=player_base_stats(race,5);

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
end