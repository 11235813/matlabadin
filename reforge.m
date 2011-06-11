function [ item ] = reforge( item, stat1, stat2)
% The function reforge() takes an item and reforges it.  The syntax is
% socket(item, stat1 stat2).
% Inputs :
% item - the equipped item or its corresponding slot
% stat1 - the field name corresponding to the stat to be reforged from
% stat2 - the field name corresponding to the stat being reforged into
% 
% Note : the equipped item is defined by its corresponding egs.

%check the arguments
if nargin~=3
    error('reforge() requires 3 arguments (item, stat1, stat2).');
end

%check for numeric inputs
if isnumeric(item)
    slot=item;
    clear item;
    if ~(exist('egs','var'))
        item=evalin('base',['tempegs(' int2str(slot) ');']);
    else
        item=evalin('base',['egs(' int2str(slot) ');']);
    end
end

%check that the item hasn't already been reforged, if it has punt
if isfield(item,'isreforged') && ~isempty(item.isreforged) && item.isreforged==1
    warning('Item is already reforged, reforge operation aborted.')
    return
end

%check that the item hasn't been gemmed, order of operations is reforge
%before gem to avoid reforging gemmed contributions
%track available sockets - lowercase = filled, uppercase = empty
strack=isstrprop(item.socket,'lower');
if max(strack)>0
    warning('Item is already gemmed, reforge operation aborted (reforges must be applied before gems).')
    return
end

%check that the first stat exists on the item
if ~isfield(item,stat1) 
    warning('First stat not recognized, reforge operation aborted.')
    return
else
    if isempty(getfield(item, stat1)) ||  getfield(item, stat1)<=0
    warning('Item does not contain stat to be reforged, reforge operation aborted.')
    return
end

%check that the second stat does not exist on the item already
if isfield(item, stat2)
    if ~isempty(getfield(item, stat2)) && getfield(item, stat2)>0
        warning('Item already contains stat to be reforged into, reforge operation aborted.')
        return
    else
        %perform the reforge
        item=setfield(item,stat1,round(0.6.*getfield(item,stat1)));
        item=setfield(item,stat2,round(0.4.*getfield(item,stat1)));
        item.isreforged=1;
    end
else
    warning('Second stat not recognized, reforge operation aborted.')
end
end

