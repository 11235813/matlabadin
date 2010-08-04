function [npc] = npc_model(base, varargin)
%NPC_MODEL creates an npc model based on the input arguments.  It accepts
%the following property/value pairs as inputs:
%Inputs [default value]:
%lvl - desired level of npc(s), integer  [83]
%type - type of target, logical (1 for demon/undead, 0 for the rest) [0] 
%swing - swing timer of npc(s), float  [1.5]
%phflag - parry-haste flag, logical [0]
%blockflag - block flag, logical [0] 
%Outputs:
%npc - structure containing relevant parameters

%% global variables
% global base

%% input handling
for i = 1 : 2 : length(varargin)

    name = varargin{i};
    value = varargin{i+1};
    switch name
        case {'level','lvl'}
            npc.lvl=value;
        case 'type'
            npc.type=value;
        case 'swing'
            npc.swing=value;
        case 'phflag'
            npc.phflag=value;
        case 'blockflag'
            npc.blockflag=value;
    end
end

%% Start building npc structure


%% defaults
if exist('npc.lvl')==0 npc.lvl=83; end;
if exist('npc.type')==0 npc.type=0; end;
if exist('npc.swing')==0 npc.swing=1.5; end;
if exist('npc.phflag')==0 npc.phflag=0; end;  %nil by default (probably redundant)
if exist('npc.blockflag')==0 npc.blockflag=0; end;  %change default to 1 later on when it's implemented

% npc.lvl=lvl;

npc.lvlgap=npc.lvl-base.level;
lvlflag=npc.lvlgap>2;

npc.defskill=5.*npc.lvl;
npc.skillgap=npc.defskill-base.wskill;
skillflag=npc.skillgap>10;

%% physical damage
npc.armor=305.*npc.lvl-14672;

npc.phmiss=5+npc.skillgap.*(0.1+0.1.*skillflag);
npc.dodge=5+npc.skillgap.*(0.1);
npc.parry=(5+npc.skillgap.*(0.1+0.5.*skillflag));
npc.block=(5+npc.skillgap.*(0.1));

npc.glance=6.*(1+0.2.*npc.skillgap);
npc.glancerdx=(npc.glance./100).*(0.05+0.1.*(npc.lvlgap-1));
npc.phcritsupp=0.12.*npc.skillgap+3.*skillflag; %melee crit supp

%% spell
npc.spmiss=4+npc.lvlgap+10.*lvlflag;              %spell miss
npc.presist=2.*npc.lvlgap;                        %resists due to level difference
npc.spcritsupp=0.1525.*npc.skillgap+3.*skillflag; %spell crit supp
