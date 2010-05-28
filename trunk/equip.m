function [item] = equip(iref)

global idb

if ischar(iref)
    
   gi=1
   while gi<=length(idb) && not(strcmp(idb(gi).name,iref))
       gi=gi+1;
   end 
   if gi<=length(idb)
    item=idb(gi);
   end
   
elseif isnumeric(iref)
   
    item=idb(iref);
    
end