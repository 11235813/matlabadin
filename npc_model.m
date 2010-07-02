function [npc] = npc_model(varargin)
%NPC_MODEL creates an npc model based on the input arguments.  It accepts
%the following property/value pairs as inputs:
%Inputs [default value]:
%lvl - desired level of npc(s).  [83]
%swing - swing time of npc(s).  [1.5]
%ontarget - time on-target, in decimal proportion notation (0 to 1) [1]
%npccount - number of npcs to model [1]
%phaste - parry-haste flag, logical [0]
%Outputs:
%npc - structure containing relevant parameters

%% global variables
global base

%% input handling
for i = 1 : 2 : length(varargin)

    name = varargin{i};
    value = varargin{i+1};
    switch name
        case {'level','lvl'}
            lvl=value;
        case 'swing'
            swing=value;
        case 'ontarget'
            ontarget=value;
        case 'npccount'
            npccount=value;
        case 'phaste'
            phaste=value;
    end
end

%% defaults
if exist('lvl')==0 lvl=83; end;
if exist('swing')==0 swing=1.5; end;
if exist('ontarget')==0 ontarget=1; end;
if exist('npccount')==0 npccount=1; end;
if exist('phaste')==0 phaste=0; end;  %probably redundant now?


%% Start building npc structure
npc.lvl=lvl;

lvlgap=lvl-base.level;
lvlflag=lvlgap>2;

npc.defskill=5*lvl;
skillgap=npc.defskill-base.wskill;
skillflag=skillgap>10;

%% physical damage
npc.armor=305.*lvl-14672;
npc.phflag=phaste;
npc.blockflag=0;

npc.swing=swing;
npc.miss=5+skillgap.*(0.1+0.1.*skillflag);
npc.dodge=5+skillgap.*(0.1);
npc.parry=5+skillgap.*(0.1+0.5.*skillflag);
npc.block=5+skillgap.*(0.1);

npc.glancing=6.*(1+0.2.*skillgap);
npc.pcritsupp=0.12.*skillgap+3.*skillflag; %melee crit supp

%% spell
npc.spellresist=4+lvlgap+10.*lvlflag; %spell miss
npc.partialresist=2.*lvlgap; %resists due to level difference
npc.scritsupp=0.1525.*skillgap+3.*skillflag;    %spell crit supp
