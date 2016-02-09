# Function(s) Contained #

`function [ c ] = build_config(varargin)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| varargin | variable length argument list | comma separated list |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| c		      | config structure | structure array |

# Description #

BUILD\_CONFIG is a function that constructs a configuration and calls all of the
functions required to carry out a calculation. In essence, it exists to allow you to create a number of
configurations quickly and without having to re-type many of the common steps in a new script.

The inputs contained in varargin are defined in detail in the documentation for the particular functions that deal with them.

# Functions Called #
| function |
|:---------|
| [player\_model](player_model.md) |
| [npc\_model](npc_model.md) |
| [exec\_model](exec_model.md) |
| [buff\_model](buff_model.md) |
| [spec\_model](spec_model.md) |
| [talent\_model](talent_model.md)|
| [glyph\_model](glyph_model.md)|
| [stat\_model](stat_model.md)|
| [gear\_stats](gear_stats.md)|
| [ability\_model](ability_model.md)|
| [rotation\_model](rotation_model.md)|

# Caveats #
NONE