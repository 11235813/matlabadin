function [talent] =  talent_model(shortform)
%% Talents and Glyphs
%This file handles and updates a player's talent spec.  The 'talent'
%structure returned contains both shorthand and long forms of the tree
%
%the short form is a 1x6 array of integers (1-3) representing the chosen
%talent.  So for exammple, choosing every talent in the left column would
%give a short form of [1 1 1 1 1 1].
%
%the long form is similar to the old system, where each talent is given by
%name
%
%Inputs [defaults] :
%shortform - 1x6 integer array representing the short form of the talent
%tree [1 1 3 3 3 1];


%% input handling
if nargin<1
    shortform=[1 1 3 3 3 1];
else
    if sum(size(shortform)==[1 6])~=2
        error('talent_model input is not 1x6')
    end    
end


%% Shorthand form
talent.short=shortform;

%% Long form
%first tier
talent.SpeedofLight=talent.short(1)==1;
talent.LongArmoftheLaw=talent.short(1)==2;
talent.PursuitofJustice=talent.short(1)==3;
%second tier
talent.FistofJustice=talent.short(2)==1;
talent.Repentance=talent.short(2)==2;
talent.BurdenofGuilt=talent.short(2)==3;
%third tier
talent.BlessedLife=talent.short(3)==1;
talent.SacredShield=talent.short(3)==2;
talent.ArdentDefender=talent.short(3)==3;
%fourth tier
talent.SelflessHealer=talent.short(4)==1;
talent.EternalGlory=talent.short(4)==2;
talent.HolyShield=talent.short(4)==3;
%fifth tier
talent.Veneration=talent.short(5)==1;
talent.ActsofSacrifice=talent.short(5)==2;
talent.Clemency=talent.short(5)==3;
%sixth tier
talent.HolyAvenger=talent.short(6)==1;
talent.SanctifiedWrath=talent.short(6)==2;
talent.DivinePurpose=talent.short(6)==3;