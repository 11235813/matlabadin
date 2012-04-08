function [spec] =  spec_model(tree,level)
%% Specialization Choice
%This file handles all the spec-specific abilities one gains.  It takes two
%Inputs [default value]:
%tree = flag for which specialization tree is chosen.  ['prot']|'ret'
%level = player level, in integer format [90]

%right now, only 'prot' and level 90 are supported.  It's not clear we'll
%ever make use of the level-dependent code, so we may just eliminate that
%portion later.

%% input handling

if nargin<1 || isempty(tree)
    tree='prot';
end
if nargin<2 || isempty(level)
    level=90;
end

%class-specific abilities, by level

spec.CrusaderStrike=(level>1);
spec.Judgement=(level>5);
spec.WordofGlory=(level>9);
spec.RighteousFury=(level>12);
spec.Consecration=(level>24);
spec.SealofTruth=(level>26);
spec.BlessingofKings=(level>32);
spec.SealofInsight=(level>33);
spec.SealofRighteousness=(level>42);
spec.AvengingWrath=(level>72);
spec.BlessingofMight=(level>81);
spec.GuardianofAncientKings=(level>85);
spec.BlindingLight=(level>87);

%% prot
if strcmp(tree,'prot')
    spec.name='Prot';
    %Base bonuses for choosing prot (inherent @ level 10)
    spec.Vengeance=1;
    spec.GuardedbytheLight=1;
    spec.AvengersShield=1;
    
    %Spec bonuses, by level
    spec.HammeroftheRighteous=(level>20);
    spec.JudgementsoftheWise=(level>30);
    spec.ShieldoftheRighteous=(level>40);
    spec.GrandCrusader=(level>50);
    spec.Sanctuary=(level>60);
    spec.DivineBulwark=(level>80);
    
%% ret    
elseif strcmp(tree,'ret')
    spec.name='Ret';
    %Base bonuses for choosing ret (inherent @ level 10)
    spec.TemplarsVerdict=1;
    spec.Sheathoflight=1;
    
    %Spec bonuses, by level
    spec.HammeroftheRighteous=(level>20);
    spec.JudgementsoftheBold=(level>30);
    spec.CrusadersZeal=(level>34);
    spec.DivineStorm=(level>38);
    spec.HammerofWrath=(level>40);
    spec.SealofJustice=(level>46);
    spec.Exorcism=(level>50);
    spec.SanctityofBattle=(level>56);
    spec.HandofLight=(level>80);
    spec.Inquisition=(level>81);
   
end



end
