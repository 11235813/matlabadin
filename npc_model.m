function [npc] = npc_model(base,varargin)
%NPC_MODEL creates an npc model based on the input arguments.  It accepts
%the following property/value pairs as inputs:
%Inputs [default value]:
%lvl - desired level of npc(s), integer  [88]
%type - type of target, logical (1 for demon/undead, 0 for the rest) [0] 
%swing - swing timer of npc(s), float  [1.5]
%cast - average time between casts, float [5]
%phflag - parry-haste flag, logical [0]
%blockflag - block flag, logical [0]
%outphys - physical output damage event, float [1.5.*10.^5]
%outspell - spell output damage event, float [0.5.*10.^5]
%(Important : outphys/outspell are the raw values, pre-mitigation)

%Outputs:
%npc - structure containing relevant parameters


%% Input handling
%populate all entries with empty arrays
npc.lvl=[];npc.type=[];npc.swing=[];npc.cast=[];npc.phflag=[];npc.blockflag=[];npc.out.phys=[];npc.out.spell=[];
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case {'level','lvl'}
                npc.lvl=value;
            case 'type'
                npc.type=value;
            case 'swing'
                npc.swing=value;
            case 'cast'
                npc.cast=value;
            case 'phflag'
                npc.phflag=value;
            case 'blockflag'
                npc.blockflag=value;
            case 'outphys'
                npc.out.phys=value;
            case 'outspell'
                npc.out.spell=value;
        end
    end
end
%refuse lvl inputs below the player's level cap
if isempty(npc.lvl)==0 && (npc.lvl<base.lvl)
    error('Npc_model failed to initialize : npc.lvl below the level cap.');
end
%default values of the input arguments
if isempty(npc.lvl)==1 npc.lvl=base.lvl+3; end;
if isempty(npc.type)==1 npc.type=0; end;
if isempty(npc.swing)==1 npc.swing=1.5; end;
if isempty(npc.cast)==1 npc.cast=1.5; end;
if isempty(npc.phflag)==1 npc.phflag=0; end; %nil by default
if isempty(npc.blockflag)==1 npc.blockflag=1; end;
if isempty(npc.out.phys)==1 npc.out.phys=1.5.*10.^5; end;
if isempty(npc.out.spell)==1 npc.out.spell=0.5.*10.^5; end;


%% Start building npc structure
%level-based vars
npc.lvlgap=npc.lvl-base.lvl;
npc.skillgap=5.*(npc.lvl-base.lvl); %probably unnecessary now
%runtime flags
lvlflag=npc.lvlgap>2;
skillflag=npc.skillgap>10;

%physical
npc.armor=295.*npc.lvl-13983;
npc.armor=24835; %TODO: FIXME (this is L93 armor)

npc.memiss=3+npc.lvlgap.*1.5;
npc.dodge=3+npc.lvlgap.*1.5;
npc.parry=3+npc.lvlgap.*1.5;
npc.block=3+npc.lvlgap.*1.5;

npc.glance=6.*(1+0.2.*npc.skillgap);
npc.glancerdx=5.*(npc.lvlgap==0||npc.lvlgap==1) ...
    +15.*(npc.lvlgap==2)+25.*(npc.lvlgap==3);   %average damage reduction (5/5/15/25)
npc.critsupp=1.*npc.lvlgap; %physical/spell crit supp

%spell
npc.spmiss=6+npc.lvlgap.*3;             %spell miss
npc.presist=0.*npc.lvlgap;              %level-based partial resists (nil in 4.0)
end