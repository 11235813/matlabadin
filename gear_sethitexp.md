# Function(s) Contained #

`function [c] = gear_sethitexp(c, hit, exp)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| c	       | configuration to reference | matlab structure array |
| hit	     | hit percentage | int  |
| expertise | expertise percentage | int  |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| c	       | updated configuration | matlab structure array |

# Description #

GEAR\_SETHITEXP Sets the hit and expertise of a gear set to the specified
values (in percent) by modifying the shirt armor slot

# Functions Called #
| function |
|:---------|
| stat\_conversions |
| gear\_stats |
| stat\_model |