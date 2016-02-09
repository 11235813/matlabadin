# Introduction #

matlabadin is a mechanics simulation and testing (theorycrafting) package for the Paladin class in World of Warcraft. It is a combined matlab/C# code that uses a [Finite State Machine](http://en.wikipedia.org/wiki/Finite-state_machine) (FSM) approach to model spell rotations, effects of glyph and talent choices, etc.

This Wiki is currently a work in progress, so please pardon the dust and unpolished edges.

# History #

This program was originally developed in MATLAB by Theck based on [Jonesy's Prot DPS/TPS spreadsheet](http://www.failsafedesign.com/maintankadin/viewtopic.php?t=20085), during the Wrath of the Lich King expansion (WoW 3.X, 2009) to investigate Paladin class mechanics. The code and Theck's findings were posted on the [Maintankadin](http://maintankadin.failsafedesign.com/forum/) forum, as a resource to all tankadins.

The program was upgraded and refined during the course of the Cataclysm expansion (WoW 4.X, 2010) and is currently being updated for the upcoming Mists of Pandaria expansion (WoW 5.X). The program now uses both MATLAB and C# with the FSM implementation being mainly C# code, implemented originally by Iminmmnni.

# How Can I Help? #
Here's where the community comes in. The project need volunteers willing to help flesh out the code base and get it up and running. There are a number of ways that you can contribute. Contact one of the project owners if you'd like to help. For example:
  * **Code Monkey** - someone with a basic knowledge of MATLAB who's interested/willing to help maintain the code base. Stuff like making minor corrections to different modules or writing calculation files. Prerequisites would be that you know enough not to screw up the code, and have a passing familiarity with how to do SVN checkouts/commits or are willing to learn how to do so.
  * **Error checkers** - People who will look through the code and try and spot mistakes. Things like, "You missed the Seals of the Pure modifier for Seal of Awesomeness" or "I ran the code in Octave and got an error on line x of module y, here's how I fixed it." If you don't want to mess around with SVN commits but can read MATLAB code, this could be the job for you!
  * **Wikinators** - Eventually we want this wiki to include a page for each module describing what it does and how it's used.
  * **Data Miner** - Willing to do simple fetch/retrieve operations. Things like "Here's a list of all of the spell coefficients and base damages for our abilities at level 85, according to wowhead." Beta access isn't even necessary for this. If you're able to read MATLAB code and willing to check these sorts of things against the code and post about possible errors, that's even better.
  * **Tester** - The project needs people to go in and test things in the Beta from time to time. Things like "Does Talent X affects the damage of Ability Y or not" or "What's the proc rate on Talent Z?" This would probably require Beta access.