function [glyph] =  glyph_model(shortform)
%% Talents and Glyphs
% This file handles and updates a player's glyphs.  The 'glyph' structure
% contains both shorthand and long forms of the glyph configuration.
%
% the short form is a 1x3 array of integers.  Each integer
% represents a given major glyph.  Glyph ID numbers are given in the table below.
% A zero represents an empty glyph slot.  Note that minors are ignored.
%
% So for exammple, having no glyphs equipped would give a [0 0 0] matrix.
% Adding glyph of Crusader Strike in the first Prime slot would give a short
% form of [1 0 0]
%
% the long form is similar to the old system, where each glyph is given by
% name and represented as a boolean value.
%
% Inputs [defaults] :
%  shortform - 1x3 integer array representing the short form of the glyph
%              tree [8 5 6];
%
% Glyph ID numbers (TODO: Alphabetize, or order according to usefulness?):
%
% Major
% 1 - Alabaster Shield
% 2 - Ascetic Crusader
% 3 - Avenging Wrath
% 4 - Battle Healer
% 5 - Blessed Life
% 6 - Divine Storm
% 7 - Double Jeapordy
% 8 - Flash of Light
% 9 - Focused Shield
% 10- Focused Wrath
% 11- Hammer of the Righteous
% 12- Immediate Truth
% 13- Inquisition
% 14- Word of Glory

%% Input Handling

if nargin<1 || (nargin==1 && isempty(shortform))
    shortform=[9 11 14];
else
    if size(shortform,1)~=1 || size(shortform,2)~=3
        error('glyph_model input is not 1x3')
    end
end

%% Glyphs (shorthand)
glyph.short=shortform;

%% Glyphs (logical)

% Major
q=1;
glyph.AlabasterShield=sum(glyph.short==q);q=q+1;
glyph.AsceticCrusader=sum(glyph.short==q);q=q+1;
glyph.AvengingWrath=sum(glyph.short==q);q=q+1;
glyph.BattleHealer=sum(glyph.short==q);q=q+1;
glyph.BlessedLife=sum(glyph.short==q);q=q+1;
glyph.DivineStorm=sum(glyph.short==q);q=q+1;
glyph.DoubleJeopardy=sum(glyph.short==q);q=q+1;
glyph.FlashofLight=sum(glyph.short==q);q=q+1;
glyph.FocusedShield=sum(glyph.short==q);q=q+1;
glyph.FocusedWrath=sum(glyph.short==q);q=q+1;
glyph.HammeroftheRighteous=sum(glyph.short==q);q=q+1;
glyph.ImmediateTruth=sum(glyph.short==q);q=q+1;
glyph.Inquisition=sum(glyph.short==q);q=q+1;
glyph.WordofGlory=sum(glyph.short==q);

glyph.labels={  'AlabasterShield';...
                'Ascetic Crusader';...
                'Avenging Wrath';...
                'Battle Healer'; ...
                'Blessed Life';...
                'Divine Storm';...
                'Double Jeopardy';...
                'Flash of Light';...
                'Focused Shield';...
                'Focused Wrath';...
                'Hammer of the Righteous';...
                'Immediate Truth';...
                'Inquisition';...
                'Word of Glory';};
