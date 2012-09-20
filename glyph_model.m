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
% 2 - Avenging Wrath
% 3 - Battle Healer
% 4 - Blessed Life
% 5 - Divine Storm
% 6 - Double Jeapordy
% 7 - Final Wrath
% 8 - Flash of Light
% 9- Focused Shield
% 10- Focused Wrath
% 11- Hammer of the Righteous
% 12- Harsh Words
% 13- Immediate Truth
% 14- Inquisition
% 15- Word of Glory

%% Input Handling

if nargin<1 || (nargin==1 && isempty(shortform))
    shortform=[1 9 0];
else
    if size(shortform,1)~=1 || size(shortform,2)~=3
        error('glyph_model input is not 1x3')
    end
end

%Sanity check on shortform - no double glyphs


%% Glyphs (shorthand)
glyph.short=shortform;

%% Glyphs (logical)

% Major
q=1;
glyph.AlabasterShield=sum(glyph.short==q);q=q+1;
glyph.AvengingWrath=sum(glyph.short==q);q=q+1;
glyph.BattleHealer=sum(glyph.short==q);q=q+1;
glyph.BlessedLife=sum(glyph.short==q);q=q+1;
glyph.DivineStorm=sum(glyph.short==q);q=q+1;
glyph.DoubleJeopardy=sum(glyph.short==q);q=q+1;
glyph.FinalWrath=sum(glyph.short==q);q=q+1;
glyph.FlashofLight=sum(glyph.short==q);q=q+1;
glyph.FocusedShield=sum(glyph.short==q);q=q+1;
glyph.FocusedWrath=sum(glyph.short==q);q=q+1;
glyph.HammeroftheRighteous=sum(glyph.short==q);q=q+1;
glyph.HarshWords=sum(glyph.short==q);q=q+1;
glyph.ImmediateTruth=sum(glyph.short==q);q=q+1;
glyph.Inquisition=sum(glyph.short==q);q=q+1;
glyph.WordofGlory=sum(glyph.short==q);

glyph.labels={  'Alabaster Shield';...
                'Avenging Wrath';...
                'Battle Healer'; ...
                'Blessed Life';...
                'Divine Storm';...
                'Double Jeopardy';...
                'Final Wrath';...
                'Flash of Light';...
                'Focused Shield';...
                'Focused Wrath';...
                'Hammer of the Righteous';...
                'Harsh Words';...
                'Immediate Truth';...
                'Inquisition';...
                'Word of Glory';};

glyph.string='';
if glyph.HammeroftheRighteous
    glyph.string=[glyph.string 'GoHotR,'];
end
if glyph.WordofGlory
    glyph.string=[glyph.string 'GoWoG,'];
end
% if glyph.HarshWords
%     glyph.string=[glyph.string 'GoHaWo,'];
% end
