function [obj]=equip(iref,type)
%The equip() function is the intermediary between the item database and the
%equipped gear set.  Proper use would be something like:
% egs.mainhand=equip('Last Laugh');
%or
% egs.mainhand=equip(40402,'iid');
%Which would equip Last Laugh in the mainhand slot.
%
%equip() first checks for the type of input argument. If the input is numeric,
%it then checks for 'iid'/'sid' input types, then loads iid(iref) or sid(iref).
%For a text input, it searches through idb until it finds the item number with
%a name string that matches iref, and then returns the stats.
%IMPORTANT : Note that it is much faster to reference an item
%by inum (item_id, as parsed by armory) than by its name.

global idb
if nargin<2 type='i'; end;

%character input (i.e. iref='Last Laugh')
if ischar(iref)
    gi=length(idb.iid);gj=length(idb.sid);
    while gi>0 && not(strcmp(idb.iid(gi).name,iref))
        gi=gi-1;
    end
    while gj>0 && not(strcmp(idb.sid(gj).name,iref))
        gj=gj-1;
    end
    if gi>0 && (strcmp(type,'iid')||strcmp(type,'i'))
        obj=idb.iid(gi);       
    elseif gj>0 && (strcmp(type,'sid')||strcmp(type,'s'))
        obj=idb.sid(gj);  
    else
       %Oops, we typed 'Last Laff'
       error(['equip_call failed to find item ''iref'' in gear database']);
    end
%numeric input (iref=40402)   
elseif isnumeric(iref) && (strcmp(type,'iid')||strcmp(type,'i'))
    obj=idb.iid(iref);
elseif isnumeric(iref) && (strcmp(type,'sid')||strcmp(type,'s'))
    obj=idb.sid(iref);
end