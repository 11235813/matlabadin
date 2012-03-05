function [glyph] =  glyph_model(shortform)
%% Talents and Glyphs
%This file handles and updates a player's glyphs.  The 'glyph' structure
%contains both shorthand and long forms of the glyph configuration.
%
%the short form is a 3x3 array of integers.  Each row represents one type
%of glyph slot (row1=Prime, row2=Major, row3=Minor).  Each integer
%represents a given glyph.  Glyph ID numbers are given in the table below.
%A zero represents an empty glyph slot.
%
%So for exammple, having no glyphs equipped would give a zeros(3) matrix.
%Adding glyph of Crusader Strike in the first Prime slot would give a short
%form of [1 0 0; 0 0 0; 0 0 0]
%
%the long form is similar to the old system, where each glyph is given by
%name and represented as a boolean value.
%
%Inputs [defaults] :
%shortform - 3x3 integer array representing the short form of the glyph
%tree [1 1 3 3 3 1];
%
%Glyph ID numbers (TODO: Alphabetize, or order according to usefulness?):
%
%Prime
%1 - Crusader Strike 
%2 - Exorcism 
%3 - HotR
%4 - Judgement
%5 - SoT
%6 - SotR
%7 - SoI
%8 - WoG
%
%Major
%1 - Ascetic Crusader
%2 - Consecration
%3 - Dazing Shield
%4 - Divine Protection
%5 - Divinity
%6 - Focused Shield
%7 - Hammer of Justice
%8 - Hammer of Wrath
%9 - Holy Wrath
%10 - Hand of Salvation
%11 - Turn Evil
%12 - Long Word
%
%Minor
%1 - Blessing of Kings
%2 - Blesing of MIght
%3 - Insight
%4 - Righteousness
%5 - Justice
%6 - Truth


%% Input Handling

if nargin<1 || (nargin==1 && isempty(shortform))
    shortform=[1 4 5; 1 2 6; 0 0 0];
else
    if sum(size(shortform)==[3 3])~=2
        error('glyph_model input is not 1x6')
    end
end

%% Glyphs (shorthand)
glyph.short=shortform;

%% Glyphs (logical)
% Prime
glyph.CrusaderStrike=sum(glyph.short(1,:)==1);
glyph.Exorcism=sum(glyph.short(1,:)==2);
glyph.HammeroftheRighteous=sum(glyph.short(1,:)==3);
glyph.Judgement=sum(glyph.short(1,:)==4);
glyph.SealofTruth=sum(glyph.short(1,:)==5);
glyph.ShieldoftheRighteous=sum(glyph.short(1,:)==6);
glyph.SealofInsight=sum(glyph.short(1,:)==7);
glyph.WordofGlory=sum(glyph.short(1,:)==8);

% Major
glyph.AsceticCrusader=sum(glyph.short(2,:)==1);
glyph.Consecration=sum(glyph.short(2,:)==2);
glyph.DazingShield=sum(glyph.short(2,:)==3);
glyph.DivineProtection=sum(glyph.short(2,:)==4);
glyph.Divinity=sum(glyph.short(2,:)==5);
glyph.FocusedShield=sum(glyph.short(2,:)==6);
glyph.HammerofJustice=sum(glyph.short(2,:)==7);
glyph.HammerofWrath=sum(glyph.short(2,:)==8);
glyph.HolyWrath=sum(glyph.short(2,:)==9);
glyph.HandofSalvation=sum(glyph.short(2,:)==10);
glyph.TurnEvil=sum(glyph.short(2,:)==11);
glyph.LongWord=sum(glyph.short(2,:)==12);

% Minor
glyph.BlessingofKings=sum(glyph.short(3,:)==1);
glyph.BlessingofMight=sum(glyph.short(3,:)==2);
glyph.Righteousness=sum(glyph.short(3,:)==3);
glyph.Insight=sum(glyph.short(3,:)==4);
glyph.Justice=sum(glyph.short(3,:)==5);
glyph.Truth=sum(glyph.short(3,:)==6);