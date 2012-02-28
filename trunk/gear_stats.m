function [gear] = gear_stats(egs);
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
gear.barmor=sum([egs.barmor]);
gear.earmor=sum([egs.earmor]);

%For stats that are item-specific (e.g. weapons), we can just reference the
%field directly, since [egs.x] will return only one member

gear.avgdmg = egs(15).avgdmg;
gear.swing=egs(15).swing;
gear.wtype=egs(15).wtype;
gear.tooldps=egs(15).tooldps;

%meta gems
gear.meta=egs(1).meta;

%plate spec
gear.isplate=(sum([egs.atype])==8);

%tier bonus
gear.istierP=sum(reshape([egs.istierP],3,length([egs.istierP])/3)');
gear.istierR=sum(reshape([egs.istierR],3,length([egs.istierR])/3)');
gear.tierbonusP=zeros(2,3); %t11-t13 for now
gear.tierbonusR=zeros(2,3); %t11-t13 for now
%format :
% t11 t12 t13
%[  0   0   0; %2p
%   0   0   0] %4p

%check for presence of tier gear, if none, skip this section
if numel(gear.istierP)==3
    if gear.istierP(1)>=4             %4p t11
        gear.tierbonusP(1)=1;
        gear.tierbonusP(2)=1;
    elseif gear.istierP(2)>=4         %4p t12
        gear.tierbonusP(3)=1;
        gear.tierbonusP(4)=1;
    elseif gear.istierP(3)>=4         %4p t13
        gear.tierbonusP(5)=1;
        gear.tierbonusP(6)=1;
    else
        if gear.istierP(1)>=2         %2p t11
            gear.tierbonusP(1)=1;
            if gear.istierP(2)>=2     %2p t11,t12
                gear.tierbonusP(3)=1;
            elseif gear.istierP(3)>=2 %2p t11,t13
                gear.tierbonusP(5)=1;
            end
        elseif gear.istierP(2)>=2     %2p t12
            gear.tierbonusP(3)=1;
            if gear.istierP(3)>=2     %2p t12,t13
                gear.tierbonusP(5)=1;
            end
        elseif gear.istierP(3)>=2     %2p t13
            gear.tierbonusP(5)=1;
        end
    end
end
if numel(gear.istierR)==3
    if gear.istierR(1)>=4             %4p t11
        gear.tierbonusR(1)=1;
        gear.tierbonusR(2)=1;
    elseif gear.istierR(2)>=4         %4p t12
        gear.tierbonusR(3)=1;
        gear.tierbonusR(4)=1;
    elseif gear.istierR(3)>=4         %4p t13
        gear.tierbonusR(5)=1;
        gear.tierbonusR(6)=1;
    else
        if gear.istierR(1)>=2         %2p t11
            gear.tierbonusR(1)=1;
            if gear.istierR(2)>=2     %2p t11,t12
                gear.tierbonusR(3)=1;
            elseif gear.istierR(3)>=2 %2p t11,t13
                gear.tierbonusR(5)=1;
            end
        elseif gear.istierR(2)>=2     %2p t12
            gear.tierbonusR(3)=1;
            if gear.istierR(3)>=2     %2p t12,t13
                gear.tierbonusR(5)=1;
            end
        elseif gear.istierR(3)>=2     %2p t13
            gear.tierbonusR(5)=1;
        end
    end
end

%pvp hands (CS bonus)
switch egs(7).name
    case {'Bloodthirsty Gladiator''s Scaled Gauntlets','Vicious Gladiator''s Scaled Gauntlets',...
            'Ruthless Gladiator''s Scaled Gauntlets','Cataclysmic Gladiator''s Scaled Gauntlets'}
        gear.pvphands=1;
    otherwise
        gear.pvphands=0;
end

%souldrinker
gear.souldrinker=zeros(3,1);
switch egs(15).name
    case 'Souldrinker (Raid Finder)'
        gear.souldrinker(1)=1;
    case 'Souldrinker'
        gear.souldrinker(2)=1;
    case 'Souldrinker (Heroic)'
        gear.souldrinker(3)=1;
end

%no'kaled
gear.nokaled=zeros(3,1);
switch egs(15).name
    case 'No''Kaled, the Elements of Death'
        gear.nokaled(2)=1;
    case 'No''Kaled, the Elements of Death (Heroic)'
        gear.nokaled(3)=1;
end
end