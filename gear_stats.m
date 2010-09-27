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

%plate spec
gear.isplate=sum([egs.atype])==8;

%tier bonus
gear.istier=sum(reshape([egs.istier],4,length([egs.istier])/4)');
gear.tierbonus=zeros(2,4); %t10-t13 for now
%format :
% t10 t11 t12 t13
%[  0   0   0   0; %2p
%   0   0   0   0] %4p
if gear.istier(1)>=4             %4p t10
    gear.tierbonus(1)=1;
    gear.tierbonus(2)=1;
elseif gear.istier(2)>=4         %4p t11
    gear.tierbonus(3)=1;
    gear.tierbonus(4)=1;
elseif gear.istier(3)>=4         %4p t12
    gear.tierbonus(5)=1;
    gear.tierbonus(6)=1;
elseif gear.istier(4)>=4         %4p t13
    gear.tierbonus(7)=1;
    gear.tierbonus(8)=1;
else
    if gear.istier(1)>=2         %2p t10
        gear.tierbonus(1)=1;
        if gear.istier(2)>=2     %2p t10,11
            gear.tierbonus(3)=1;
        elseif gear.istier(3)>=2 %2p t10,t12
            gear.tierbonus(5)=1;
        elseif gear.istier(4)>=2 %2p t10,t13
            gear.tierbonus(7)=1;
        end
    elseif gear.istier(2)>=2     %2p t11
        gear.tierbonus(3)=1;
        if gear.istier(3)>=2     %2p t11,t12
            gear.tierbonus(5)=1;
        elseif gear.istier(4)>=2 %2p t11,t13
            gear.tierbonus(7)=1;
        end
    elseif gear.istier(3)>=2     %2p t12
        gear.tierbonus(5)=1;
        if gear.istier(4)>=2     %2p t12,t13
            gear.tierbonus(7)=1;
        end
    elseif gear.istier(4)>=2     %2p t13
        gear.tierbonus(7)=1;
    end
end