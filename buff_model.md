# Function(s) Contained #

`function [buff] =  buff_model(varargin)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| varargin | variable length argument list | comma separated list |

## Input Options ##
values are case insensitive
| variable | description | values | default |
|:---------|:------------|:-------|:--------|
| mode		   | spell-based buff set switch | 0-custom exclusions, 1-none, 2-self, 3-exhaustive, 4-custom inclusions | 3       |
| item		   | spell-based inclusions/exclusions. Individual entries white space separated. | string | '' (empty) |
| flask	   | flask-based option. Name or spell ID (0 if none).  | int or string | 79469 or 'Flask of Steelskin' (same thing) |
| belixir	 | battle elixir option. Name or spell ID (0 if none) | int or string | 0 (none) |
| gelixer	 | guardian elixir option. Name or spell ID (0 if none) | int or string | 0 (none) |
| potion	  | potion option. Name or spell ID (0 if none) | int or string | 79475 or 'Earthen Potion' (same thing) |
| food		   | food option. Name or spell ID (0 if none)	| int or string | 87584 or 'Beer-Basted Crocolisk' (same thing) |

Self buffs (mode == 2) specifies only avenging wrath and righteous fury.
Exhaustive buffs (mode == 3) includes all available player buff spells and boss debuff spells

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| buff		   | structure containing buff names/IDs (must be in gear\_db.m) | structure array |

# Description #
This function takes in a list of buffs applied to be applied to the character in stat\_model.m. The values each buff applies are taken from gear\_db.m.

Note on custom modes: mode==0 is basically a subset of mode==3, where the item argument configures the exclusions.
Likewise, mode==4 is a generalization of mode==2, where the item argument configures the inclusions.

## Examples ##
` buff_model('mode',0) = buff_model('mode',3) = buff_model() `

` buff = buff_model('mode',0,'item','bok thORnS') ` enables all mode==3 environmental buffs, sans Blessing of Kings and Thorns. (example of case-insensitivity)

` buff_model('mode',4) = buff_model('mode',2) `

` buff = buff_model('mode',4,'item','BOK') ` enables all mode==2 buffs, plus Blessing of Kings.

` buff = buff_model('mode',4,'item','BOK', 'food', 'Lavascale Minestone') ` enables all mode==2 buffs, plus Blessing of Kings and specifies Lavascale Minestrone as the food buff.

# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
For these buffs to have an effect, this function must be called prior to stat\_model.m