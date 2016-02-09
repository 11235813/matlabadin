# Function(s) Contained #

`function [c]=ability_model(c) `

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| c		      | config structure | structure array |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| c		      | updated config structure | structure array |

# Description #

ABILITY\_MODEL calculates the damage each ability does when used.  For
DOT-like effects, it calculates either the total damage done over the
period of interest (i.e. Consecration) or the damage per tick (Censure)
depending on how each ability is modeled (Cons is generally DPC, Censure
is usually added in post-processing as a passive effect occuring with
frequency 1/player.wswing).

ability\_model takes one input argument "c", which is the configuration
structure for the simulation.  "c" contains the standard fields returned by
stat\_model.

ability\_model returns an updated "c" that includes an
"abil" field containing the ability  values introduced in this module.

# Functions Called #
| function |
|:---------|
| NONE		   |

# Caveats #
Must be called after stat\_model