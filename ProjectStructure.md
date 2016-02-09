# Code Flow Chart #
> ## File Naming Convention ##
  * calc`_``*``.`m is a calculation file, essentially similar to a main() method. It calls other m-files to calculate the answer to a specific question (i.e., "How much DPS is each talent point worth?").
  * `*``_`db.m are database-like files that store useful things we refer to a lot
  * `*``_`model.m are modular components that perform portions of the calculation.
  * prio`_``*``.`m are files specific to the priority simulation
  * others?

> ## Process Flow ##
> ![https://matlabadin.googlecode.com/svn/wiki/images/general_flow_12Apr12.png](https://matlabadin.googlecode.com/svn/wiki/images/general_flow_12Apr12.png)

# Old Stuff Below Here #
# Details #

So for example, a calc`_``*` file will load the databases and then run models to create structures for the player, npc, and "execution" environment, load buffs, apply talent/gear modifiers, and so on. Two of the final steps are usually stat\_model and ability\_model, which calculate in-combat values (mdf.`*`, AP, SP, primary stats, etc.) and ability damage values respectively. rotation\_model then takes those values and converts them to DPS, TPS, HPS outputs by using ability weight coefficients. The details of rotation\_model are thus abstracted; all the calc`_``*` files care about is that rotation\_model gives DPS values.