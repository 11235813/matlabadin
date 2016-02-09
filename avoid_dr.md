# Function(s) Contained #

`function [avoiddr] =  avoid_dr(dodge,parry,block)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| dodge	   | dodge percentage before diminishing returns (i.e. 0-100%) | float |
| parry	   | parry percentage before diminishing returns (i.e. 0-100%) | float |
| block	   | block percentage before diminishing returns (i.e. 0-100%) | float |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| avoiddr	 | structure containing post-dimishing returns dodge/parry/block percentages | structure array |

# Description #
AVOID\_DR calculates the amount of avoidance received from all sources after diminishing returns.

Avoidance sources not subject to diminishing returns are not included. This means things such as
talents, racials, and base(naked) avoidance are not included.  You have to add them to the output of this function by hand.

# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
**THIS FUNCTION COMPLETELY IGNORES SOURCES OF AVOIDANCE THAT ARE NOT SUBJECT TO DIMINISHING RETURNS.**