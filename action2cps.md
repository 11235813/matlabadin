# Function(s) Contained #

`function [cps hpg] = action2cps(c,j)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| c		      | configuration structure | structure array |
| j		      | (optional) iteration number | integer |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| cps		    | standardized cast-per-second array | float array |
| hpg		    | Holy Power generation rate | float |

# Description #

ACTION2CPS takes the action priority returned by memoized\_fsm and converts them
into a standardized "cast per second" array, including both active and
passive sources.

ACTION2CPS takes one required input ("c", the configuration structure) and one
optional input ("j", the iteration number for calculations where mdf.mehit
or mdf.sphit or player.wswing are not singleton).

ACTION2CPS returns the cast-per-second array and Holy Power generation rate for the given input conditions.

# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
NONE