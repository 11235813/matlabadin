# Function(s) Contained #

`function [glyph] =  glyph_model(shortform)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| shortform | 1x3 array of major glyphs identified by number | integer array|

## Input Options ##
| Number | Name |
|:-------|:-----|
| 1	     | Alabaster Shield |
| 2      | Ascetic Crusader |
| 3      | Avenging Wrath |
| 4      | Battle Healer |
| 5      | Blessed Life |
| 6      | Divine Storm |
| 7      | Double Jeapordy |
| 8      | Final Wrath |
| 9      | Flash of Light |
| 10     | Focused Shield |
| 11     | Focused Wrath |
| 12     | Hammer of the Righteous |
| 13     | Harsh Words |
| 14     | Immediate Truth |
| 15     | Inquisition |
| 16     | Word of Glory |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| glyph	   | short and long form of player's glyphs | matlab structure array |

# Description #

This file handles and updates a player's glyphs.  The 'glyph' structure
contains both shorthand and long forms of the glyph configuration.

The short form is a 1x3 array of integers.  Each integer
represents a given major glyph.  Glyph ID numbers are given in the table below.
A zero represents an empty glyph slot.  Note that minors are ignored.

So for exammple, having no glyphs equipped would give a [0 0](0.md) matrix.
Adding glyph of Alabaster Shield in the first Major slot would give a short
form of [0 0](1.md)

The long form is similar to the old system, where each glyph is given by
name and represented as a boolean value.

# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
NONE