# Function(s) Contained #

`function [obj]=equip(iref,type)`

# Input(s) #

| variable | description | type |
|:---------|:------------|:-----|
| iref		   | item/spell ID (as in idb) for an item to equip | string or int |
| type		   | item id ('iid') or spell id ('sid') identifier for above | string |

# Output(s) #

| variable | description | type |
|:---------|:------------|:-----|
| obj		    | object corresponding to desired item slot| matlab structure array|

# Description #

The equip() function is the intermediary between the item database and the
equipped gear set.  Proper use would be something like:

`egs.mainhand=equip('Last Laugh');`

or

`egs.mainhand=equip(40402,'iid');`

Which would equip Last Laugh in the mainhand slot.

equip() first checks for the type of input argument. If the input is numeric,
it then checks for 'iid'/'sid' input types, then loads iid(iref) or sid(iref).
For a text input, it searches through idb until it finds the item number with
a name string that matches iref, and then returns the stats.

**IMPORTANT** : it is much faster to reference an item by inum (item\_id, as parsed by armory) than by its name.

# Functions Called #
| function |
|:---------|
| NONE     |

# Caveats #
idb database must be loaded prior to use of this function.