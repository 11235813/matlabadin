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
%level - player's level [80]
%race - player's race ['Human']
%prof - primary professions; individual entries are separated by whitespaces ['BS JC']
%List of profession entries :
%'' (professionless)
%'Alchemy','Alch'
%'Blacksmiting','BS'
%'Enchanting','Ench'
%'Engineering','Eng'
%'Herbalism','Herb'
%'Inscription','Insc'
%'Jewelcrafting','JC'
%'Leatherworking','LW'
%'Mining','Min'
%'Skinning','Skin'
%'Tailoring','Tail'
%Race/profession arguments are case-insenstive.


%% Input handling
%populate all entries with empty arrays
base.race=[];base.prof=0;base.lvl=[];
%start filling entries with inputs
if nargin>0
    for i=1:2:length(varargin)
        name=varargin{i};
        value=varargin{i+1};
        switch name
            case 'race'
                base.race=value;
            case 'prof'
                base.prof=value;
            case {'level','lvl'}
                base.lvl=value;
        end
    end
end
%default values of the input arguments
if isempty(base.lvl)==1 base.lvl=85; end;
if isempty(base.race)==1 base.race='Human'; end;
if isnumeric(base.prof)==1 base.prof='BS JC'; end; %workaround for prof=='' 


%% Start building base structure
if base.lvl==80
%racial base stats (lvl 80)
%the format is STR-STA-AGI-INT-SPI
primary_stats=[151 143  90  98 108;
               153 146  86  97 104;
               152 142  87  99 107;
               148 141  92 102 104;
               100 100 100 100 100]; %TODO: UPDATE
else
%racial base stats (lvl 85)
%the format is STR-STA-AGI-INT-SPI  
%ONLY HUMAN/DWARF VALUES UPDATED TO 85 SO FAR
primary_stats=[164 179  97 106 117;  %updated
               169 180  93 105 113;  %updated
               152 142  87  99 107;  %TODO: UPDATE
               148 141  92 102 104;  %TODO: UPDATE
               100 100 100 100 100]; %TODO: UPDATE
end
%runtime string-numerical conversion
if strcmpi('Human',base.race)||strcmpi('Hum',base.race)
    race=1;
elseif strcmpi('Dwarf',base.race)||strcmpi('Dwa',base.race)
    race=2;
elseif strcmpi('Draenei',base.race)||strcmpi('Drae',base.race)
    race=3;
elseif strcmpi('Blood Elf',base.race)||strcmpi('Belf',base.race)
    race=4;
elseif strcmpi('Tauren',base.race)||strcmpi('Taur',base.race)
    race=5;
else
    error('Invalid race input.');
end
base.stats.str=primary_stats(race,1);
base.stats.sta=primary_stats(race,2);
base.stats.agi=primary_stats(race,3);
base.stats.int=primary_stats(race,4);    
base.stats.spi=primary_stats(race,5);

base.ap=3.*base.lvl;       %class specific
base.sp=0;
base.mast=0;
base.miss=5;               %TODO : fix
base.dodge=3.4943;         %TODO : fix
base.parry=5;
base.block=5;
base.phcrit=0.652;         %class dependent
base.spcrit=3.3355;        %class dependent
base.health=6934;          %class and level dependent
base.mana=4394;            %class and level dependent
base.exp=0;                %overridden in stats_recalc based on weapon type
end