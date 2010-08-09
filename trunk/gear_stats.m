%% GEAR_STATS
% This module takes the equipped gear set (egs) and calculates the total
% stat contributions of the gear set.  This module may not see very
% frequent use in the final code base, but it will demonstrate the proper
% way to reference the gear contributions.

%A note on notation: [egs.str] will return an array containing all of the
%STR contributions from individual gear items.  Empty cells in the egs
%array are ignored - If only 6 items have STR on them, then [egs.str] will
%be a 1x6 array.

%For stats that can be on any item, simply sum the contributions from all
%items
gear.str = sum([egs.str]);
gear.sta = sum([egs.sta]);
gear.agi = sum([egs.agi]);
gear.int = sum([egs.int]);

gear.hit = sum([egs.hit]);
gear.crit= sum([egs.crit]);
gear.exp = sum([egs.exp]);
gear.haste=sum([egs.haste]);
gear.mast =sum([egs.mast]);

gear.ap  = sum([egs.ap]);
gear.sp  = sum([egs.sp]);

gear.health=sum([egs.health]);

gear.dodge=sum([egs.dodge]);
gear.parry=sum([egs.parry]);
gear.block=sum([egs.block]);
gear.barmor=sum([egs.barmor]);
gear.earmor=sum([egs.earmor]);

%For stats that are item-specific (e.g. weapons), we can just reference the
%field directly, since [egs.x] will return only one member

gear.avgdmg = egs(15).avgdmg;
gear.swing=egs(15).swing;
gear.wtype=egs(15).wtype;
gear.tooldps=egs(15).tooldps;

%meta gems
gear.armormeta= egs(1).armormeta;
gear.critmeta = egs(1).critmeta;