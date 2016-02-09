# Function(s) Contained #

`function [gear] = gear_stats(egs)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| egs	     | equipped gear set | matlab structure array |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| gear     | stats from gear | matlab structure array |

# Description #
This module takes the equipped gear set (egs) and calculates the total
stat contributions of the gear set.  This module may not see very
frequent use in the final code base, but it will demonstrate the proper
way to reference the gear contributions.

A note on notation: [egs.str] will return an array containing all of the
STR contributions from individual gear items.  Empty cells in the egs
array are ignored - If only 6 items have STR on them, then [egs.str] will
be a 1x6 array.

For stats that can be on any item, simply sum the contributions from all
items

# Functions Called #
| function |
|:---------|
| NONE     |