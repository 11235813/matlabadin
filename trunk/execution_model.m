function [exec] = execution_model(varargin)
%Inputs [default value]:
%npccount - number of npcs to model, integer [1]
%timein - npc->pc time on-target, float (0 to 1) [1]
%timeout - pc->npc time on-target, float (0 to 1) [1]
%granin NYI
%granout NYI
%fdur NYI
%behind - attacking from behind, logical [0]
%seal - seal choice; 1-SoT,2-SoR,3-SoI,4-SoJ [1]
%Outputs:
%exec - structure containing relevant parameters

%% global variables
global base

%% input handling
for i = 1 : 2 : length(varargin)

    name = varargin{i};
    value = varargin{i+1};
    switch name
        case 'npccount'
            exec.npccount=value;
        case 'timein'
            exec.timein=value;
        case 'timeout'
            exec.timeout=value;
        case 'behind'
            exec.behind=value;
        case 'seal'
            exec.seal=value;
    end
end

%% defaults
if exist('exec.npccount')==0 exec.npccount=1; end;
if exist('exec.timein')==0 exec.timein=1; end;
if exist('exec.timeout')==0 exec.timeout=1; end;
if exist('exec.behind')==0 exec.behind=0; end;
if exist('exec.seal')==0 exec.seal=1; end;