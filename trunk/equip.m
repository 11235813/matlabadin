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

%input handling
switch nargin
    case 0
        error('Missing iref argument.');
    case 1
        type='i';
    case 2
        switch type
            case {'iid','i','sid','s'}
                %do nothing
            otherwise
                error('Invalid type argument.');
        end
    otherwise
        error('Too many arguments.');
end


global idb
%character input (e.g. iref='Last Laugh')
if ischar(iref)
    switch type
        case {'iid','i'}
            gi=length(idb.iid);
            while gi>0 && ~(strcmp(idb.iid(gi).name,iref))
                gi=gi-1;
            end
            if gi>0 obj=idb.iid(gi);end;
        case {'sid','s'}
            gi=length(idb.sid);
            while gi>0 && ~(strcmp(idb.sid(gi).name,iref))
                gi=gi-1;
            end
            if gi>0 obj=idb.sid(gi);end;
    end
    if gi<1 error('Failed to find item "%s" in the gear database.',iref);end;
%numeric input (e.g. iref=40402)
elseif isnumeric(iref)
    switch type
        case {'iid','i'}
            if iref > length(idb.iid)
                error('The iref argument exceeds the number of entries from idb.iid.');
            else
                obj=idb.iid(iref);
            end
        case {'sid','s'}
            if iref > length(idb.sid)
                error('The iref argument exceeds the number of entries from idb.sid.');
            else
                obj=idb.sid(iref);
            end
    end
    if isempty(obj.name) error('Failed to find item "%u" in the gear database.',iref);end;
end