function [item] = socket(item, varargin)
% The function socket() takes an item and adds gems to it.  The syntax is
% socket(item, gem1, [gem2, gem3,] bonus)
% item is the slot of the item we're socketing or the item itself
% gemN is the gem we're placing in socket N.  
% bonus is a boolean flag for whether the socket bonus should be activated
%
% note that this function performs very limited error checking at the
% moment.  Without storing the gemming history of the item, or reloading
% the item from the database at the beginning, you can do some weird
% things.  For now, I've kept it from being able to indefinitely add stats
% to a gear by chain-resocketing by marking sockets as full, but that also
% makes it incapable of replacing a gem in a socket.  

%error checking on number of input arguments
if nargin<3
    error('socket() requires 3 or more inputs (slot, gem, and bonus)')
elseif nargin>5
    error('socket() requires 5 or fewer inputs (slot, 3x gem, and bonus)')
end

%load the stats of the item from egs if we're passed a slot
%TODO: would like to be able to call idb directly in
%the future, which would require an "idb(#).iid" field.  As it stands
%currently, there's no way to error-check that we haven't socketed an item
%twice.
if isnumeric(item)
    slot=item;
    clear item;
    item=evalin('base',['egs(' int2str(slot) ');']);
end

%store the last argument as the bonus flag
bonus=varargin{nargin-1}; %last input

%get number of sockets
nsock=length(item.socket);

%for the gem inputs, load the stats and add them to the item
for i=1:(nargin-2)
    
    %if we're not trying to over-socket
    if i<=nsock 
        %and the socket's not already full
        if item.socket(i)~='X'
            %apply the gem's bonuses, could call idb directly, but equip() lets us
            %use gem names later on if we choose to for ease of reading the code.
            item=enhance(item,equip(varargin{i}));
            
            %label socket as full
            item.socket(i)='X';
        
        %if the socket IS full
        elseif item.socket(i)=='X'
            %Here we would put code to subtract the old gem and add the
            %new, if we had any way of figuring out what the old gem was
        end
    end
    
end

%check for socket bonus flag, if true, apply socket bonus
if bonus
    eval(['item.' item.sbstat '=item.' item.sbstat '+item.sbval;'])
end

%if we were passed a slot, we want to go back and store the item in egs in
%the base workspace.  Otherwise the function will just return item.
if exist('slot','var')
    assignin('base','tempitem',item);
    evalin('base',['egs(' int2str(slot) ')=tempitem;'])
    evalin('base','clear tempitem');
end