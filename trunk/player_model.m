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

%Inputs [default value] :
%race=1/2/3/4/5, corresponding to human/dwarf/draenai/blood elf/tauren (respectively) [1]
%prof1=0/1/2 (1-mining, 2-skinning, 0-anything else) [0]
%prof2=0/1/2 (1-mining, 2-skinning, 0-anything else) [0]


%% Input handling
%populate all entries with empty arrays
base.race=[];base.prof1=[];base.prof2=[];
%start filling entries with inputs
if nargin>0
    for i=1:2:length(varargin)
        name=varargin{i};
        value=varargin{i+1};
        switch name
            case 'race'
                base.race=value;
            case 'prof1'
                base.prof1=value;
            case 'prof2'
                base.prof2=value;
        end
    end
end
%default values of the input arguments
if isempty(base.race)==1 base.race=1; end;
if isempty(base.prof1)==1 base.prof1=0; end;
if isempty(base.prof2)==1 base.prof2=0; end;


%% Start building base structure
%racial base stats (lvl 80)
%the format is STR-STA-AGI-INT-SPI
primary_stats=[151 143  90  98 108;
               153 146  86  97 104;
               152 142  87  99 107;
               148 141  92 102 104;
               100 100 100 100 100];
base.stats.str=primary_stats(base.race,1);
base.stats.sta=primary_stats(base.race,2);
base.stats.agi=primary_stats(base.race,3);
base.stats.int=primary_stats(base.race,4);    
base.stats.spi=primary_stats(base.race,5);

base.lvl=80;
base.ap=3.*base.lvl;       %class specific
base.sp=0;                 %TODO: look up
base.mast=0;               %TODO: look up
base.miss=5;               %TODO: look up (~5?)
base.dodge=3.4943;         %class and level dependent
base.parry=5;              %TODO: look up (~5?)
base.block=5;              %TODO: look up (~5?)
base.spcrit=3.34;          %class and level dependent
base.phcrit=3.27;          %class and level dependent
base.health=6934;          %class and level dependent
base.mana=4394;            %class and level dependent
base.exp=0;                %overridden in stats_recalc based on weapon type
end