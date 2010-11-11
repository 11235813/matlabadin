function [item] = enhance(original, enhancement)
% The function ehance() takes an item and adds the stats of a second item to
% it.  This can be used to apply gems and/or enchantments to items.
% I am not very good with matlab, so I'm certain there is a better way to do 
% this than what I am doing.

item = original;
item.str = item.str + enhancement.str;
item.sta = item.sta + enhancement.sta;
item.agi = item.agi + enhancement.agi;
item.int = item.int + enhancement.int;
item.spi = item.spi + enhancement.spi;
item.hit = item.hit + enhancement.hit;
item.crit = item.crit + enhancement.crit;
item.exp = item.exp + enhancement.exp;
item.haste = item.haste + enhancement.haste;
item.mast = item.mast + enhancement.mast;
item.dodge = item.dodge + enhancement.dodge;
item.parry = item.parry + enhancement.parry;
item.block = item.block + enhancement.block;
item.barmor = item.barmor + enhancement.barmor;
item.earmor = item.earmor + enhancement.earmor;
item.health = item.health + enhancement.health;
item.armormeta = item.armormeta + enhancement.armormeta
item.critmeta = item.critmeta + enhancement.critmeta