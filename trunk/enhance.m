function [item] = enhance(original, enhancement)
% The function ehance() takes an item and adds the stats of a second item to
% it.  This can be used to apply gems and/or enchantments to items.

item = original;
item.avgdmg = sum([item.avgdmg enhancement.avgdmg]);
item.str = sum([item.str enhancement.str]);
item.sta = sum([item.sta enhancement.sta]);
item.agi = sum([item.agi enhancement.agi]);
item.int = sum([item.int enhancement.int]);
item.spi = sum([item.spi enhancement.spi]);
item.hit = sum([item.hit enhancement.hit]);
item.crit = sum([item.crit enhancement.crit]);
item.exp = sum([item.exp enhancement.exp]);
item.haste = sum([item.haste enhancement.haste]);
item.mast = sum([item.mast enhancement.mast]);
item.dodge = sum([item.dodge enhancement.dodge]);
item.parry = sum([item.parry enhancement.parry]);
item.barmor = sum([item.barmor enhancement.barmor]);
item.earmor = sum([item.earmor enhancement.earmor]);
item.health = sum([item.health enhancement.health]);
item.socket = [item.socket enhancement.socket];
item.meta = sum([item.meta enhancement.meta]);
item.isproc = sum([item.isproc enhancement.isproc]);