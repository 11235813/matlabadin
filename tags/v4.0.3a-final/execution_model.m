function [exec] = execution_model(varargin)
%Inputs [default value]:
%npccount - number of npcs to model, integer [1]
%timein - npc->pc time on-target, float (0 to 1) [1]
%timeout - pc->npc time on-target, float (0 to 1) [1]
%granin NYI
%granout NYI
%fdur NYI
%behind - attacking from behind, logical [0]
%seal - seal choice ['Truth']
%veng - average strength of Vengeance; float (0 to 1) [0.5]
%overh - average WoG overheal; float (0 to 1) [0]
%Outputs:
%exec - structure containing relevant parameters
%List of seal entries :
%'' (no active seal)
%'Insight','SoI'
%'Justice','SoJ'
%'Righteousness','SoR'
%'Truth','SoT'
%All seal arguments are case-insenstive.


%% Input handling
%populate all entries with empty arrays
exec.npccount=[];exec.timein=[];exec.timeout=[];exec.behind=[];exec.seal=0;exec.veng=[];exec.overh=[];
%start filling entries with inputs
if nargin>0
    for i=1:2:length(varargin)
        name=varargin{i};
        value=varargin{i+1};
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
            case 'veng'
               exec.veng=value;
            case 'overh'
               exec.overh=value;
        end
    end
end
%default values of the input arguments
if isempty(exec.npccount)==1 exec.npccount=1; end;
if isempty(exec.timein)==1 exec.timein=1; end;
if isempty(exec.timeout)==1 exec.timeout=1; end;
if isempty(exec.behind)==1 exec.behind=0; end;
if isnumeric(exec.seal)==1 exec.seal='Truth'; end; %workaround for seal==''
if isempty(exec.veng)==1 exec.veng=0.5; end;
if isempty(exec.overh)==1 exec.overh=0; end;
end