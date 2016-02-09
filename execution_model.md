# Function(s) Contained #

`function [exec] = execution_model(varargin)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| varargin | variable length argument list | comma separated list |

## Input Options ##
values are case insensitive
| variable | description | values | default |
|:---------|:------------|:-------|:--------|
| npccount | number of npcs to model | integer | 1       |
| timein   | npc->pc time on-target (fraction) | float (0 to 1) | 1       |
|timeout   | pc->npc time on-target (fraction) | float (0 to 1) | 1       |
|granin    || NYI|
|granout   || NYI|
|fdur      || NYI|
|behind    | attacking from behind | logical | 0 (false) |
|seal      | seal choice | '' (no active seal), 'Insight' ('SoI'), 'Justice' ('SoJ'), 'Righteousness'('SoR'), 'Truth'('SoT') | 'Truth' |
|veng      | average strength of Vengeance (fraction) | float (0 to 1) | 0.5     |
|overh     | average WoG overheal (fraction) | float (0 to 1) | 0       |


# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| exec     | structure containing relevant rotation execution parameters | matlab structure array |

# Description #

This function defines a structure containing parameters relevant to the calculations for a given rotation queue,
such as if you are in front of the target, how many targets there are, what seal you have active, vengence level, etc.


# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
Needs to be called before stat\_model.