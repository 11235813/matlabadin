function [npc] = npc_model(varargin)
%NPC_MODEL creates an npc model based on the input arguments.  It accepts
%the following property/value pairs as inputs:
%Inputs [default value]:
%lvl - desired level of npc(s), integer  [83]
%type - type of target, logical (1 for demon/undead, 0 for the rest) [0] 
%swing - swing timer of npc(s), float  [1.5]
%ontarget - time on-target, float (0 to 1) [1]
%npccount - number of npcs to model, integer [1]
%phflag - parry-haste flag, logical [0]
%behind - attacking from behind, logical [0]
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
        case 'type'
            npc.type=value;
        case 'swing'
            swing=value;
        case 'ontarget'
            ontarget=value;
        case 'npccount'
            npccount=value;
        case 'phflag'
            phflag=value;
        case 'behind'
            behind=value;
    end
end

%% defaults
if exist('lvl')==0 lvl=83; end;
if exist('type')==0 npc.type=0; end;
if exist('swing')==0 swing=1.5; end;
if exist('ontarget')==0 ontarget=1; end;
if exist('npccount')==0 npccount=1; end;
if exist('phflag')==0 phflag=0; end;  %nil by default (probably redundant)
if exist('behind')==0 behind=0; end;


%% Start building npc structure
npc.lvl=lvl;

npc.lvlgap=lvl-base.level;
lvlflag=npc.lvlgap>2;

npc.defskill=5*lvl;
npc.skillgap=npc.defskill-base.wskill;
skillflag=npc.skillgap>10;

%% physical damage
npc.armor=305.*lvl-14672;
npc.phflag=phflag;
npc.blockflag=0;        %this should probably be an input, defaulted to 1?

npc.swing=swing;
npc.phmiss=5+npc.skillgap.*(0.1+0.1.*skillflag);
npc.dodge=5+npc.skillgap.*(0.1);
npc.parry=(5+npc.skillgap.*(0.1+0.5.*skillflag)).*(1-behind);
npc.block=(5+npc.skillgap.*(0.1)).*(1-behind);

npc.glance=6.*(1+0.2.*npc.skillgap);
npc.glancerdx=(npc.glance./100).*(0.05+0.1.*(npc.lvlgap-1));
npc.phcritsupp=0.12.*npc.skillgap+3.*skillflag; %melee crit supp

%% spell
npc.spmiss=4+npc.lvlgap+10.*lvlflag;              %spell miss
npc.presist=2.*npc.lvlgap;                        %resists due to level difference
npc.spcritsupp=0.1525.*npc.skillgap+3.*skillflag; %spell crit supp
