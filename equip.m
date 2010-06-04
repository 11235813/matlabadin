function [item] = equip(iref)
%The equip() function is the intermediary between the item database and the
%equipped gear set.  Proper use would be something like:
% egs.mainhand=equip('Last Laugh');
%or
% egs.mainhand=equip(40402);
%Which would equip Last Laugh in the mainhand slot.
%
%equip() first checks for the type of input argument.  For a numeric input,
%it loads idb(iref) and returns the structure (the stats) as item.  For a
%text input, it searches through idb until it finds the item number with
%a name string that matches iref, and then returns the stats.
%IMPORTANT : Note that it is much faster to reference an item
%by inum (item_id, as parsed by armory) than by its name. /IMPORTANT

global idb

%character input (i.e. iref='Last Laugh')
if ischar(iref)
    
   gi=length(idb)
   while gi>0 && not(strcmp(idb(gi).name,iref))
       gi=gi+1;
   end 
   if gi>0
    item=idb(gi);
   else
       %Oops, we typed 'Last Laff'
       error(['equip_call failed to find item ' iref ' in gear database'])
   end
   
%numeric input (iref=40402)   
elseif isnumeric(iref)
   
    item=idb(iref);
    
end