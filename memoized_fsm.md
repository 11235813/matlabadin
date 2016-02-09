# Function(s) Contained #

`function  [actionPr, metadata, uptime] = memoized_fsm(rotation, spec, talentString, glyphString, decimalHaste, mehit, sphit, pBuffs)`

`function [actionPr, metadata, uptime] = load_fsm_csv(filename) `

# Input(s) #

memoized\_fsm:
| variable | description | type |
|:---------|:------------|:-----|
| rotation | rotation queue | string      |
| spec     | spec name   | string |
| talentString | string corresponding to talent choices | string |
| glyphString | string corresponding to player major glyphs | string |
| decimalHaste | haste effect value (decimal) | float |
| mehit    | melee hit chance (decimal) | float |
| sphit    | spell hit chance (decimal) | float |
| pBuffs   | player buffs |  string array |

load\_fsm\_csv
| variable | description | type |
|:---------|:------------|:-----|
| filename | FSM output file name | string |

# Output(s) #
memoized\_fsm, load\_fsm\_csv:
| variable | description | type |
|:---------|:------------|:-----|
| actionPr | action pointer | matlab structure array |
| metadata | FSM metadata | matlab structure array |
| uptime   | uptime for a given action | matlab structure array |

# Description #

This file defines functions used to call the FSM simulation and return the results

# Functions Called #
| function |
|:---------|
| fsm\_key |
| fsm\_gen |

# Caveats #
This function attempts to execute the FSM code.
Therefore, the FSM code and its dependencies must be installed.