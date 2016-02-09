# Function(s) Contained #

NONE

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| NONE     |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| NONE     |

# Description #

This file serves as a master gear database.

## Contributions from gear ##
Item stats and effects are stored in the global databases "idb.iid", respectively "idb.sid".
Items are referenced by IIDs (as can be found from the wowhead link), effects by SIDs.
The databases are structure arrays with fields that correspond to the item's stats.

# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
Must be loaded prior to use by calling it at the beginning of a script (see calc\_sample.m for an example).