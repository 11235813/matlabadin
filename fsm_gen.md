# Function(s) Contained #

`function [generatedFile] = fsm_gen(rotation, spec, talentString, decimalHaste, mehitArray, sphitArray)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| rotation | rotation queue | string |
| spec     | spec name   | string |
| talentString | string corresponding to talent choices | string |
| decimalHaste | haste effect value (decimal) | float |
| mehitArray | array of melee hit chance (decimal) | float array |
| sphitArray | array of spell hit chance (decimal) | float array |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| generatedFile | FSM input file filename | string |

# Description #

This file itself only generates an output file to be read by the FSM routine,
then calls on the FSM executable to run with the generated file.

fsm\_gen calculates fsm for each mehit, rhit.
Call memoized\_fsm to return the actual fsm data

# Functions Called #

| function |
|:---------|
| NONE     |

# Caveats #

This function attempts to execute the FSM code.
Therefore, the FSM code and its dependencies must be installed.