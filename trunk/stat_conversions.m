%% stat_conversions
%this m-file contains all of the relevant stat conversions we might want.
%The default format follows this convention:
%x_to_y = X
%where "x" is the name of the source stat (i.e. "haste"), "y" is the name
%of the destination stat, and X is the value, in rating, that it takes 
%to achieve 1% of the stat.  In general, X should be a value larger than 1.
%Note that x is assumed to be in rating, hence the word "rating" is
%omitted.

%Since hit rating has two possible conversions (melee and spell), we'll use
%"meleehit" and "spellhit" instead of "hit" as the destination.


%offensive conversions
agi_to_phcrit=52.0833333;
int_to_spcrit=166.6666709;
int_to_sp=1;
crit_to_phcrit=45.90598679;
crit_to_spcrit=45.90598679;

hit_to_meleehit=32.78998947;
hit_to_spellhit=26.23199272;

exp_to_exp=8.197497368;

haste_to_haste=25.2231;
ArPen_to_ArPen=13.99572719;

%defensive conversions
agi_to_dodge=59.88023952;
block_to_block=16.39499474;
mast_to_block=100;   %NYI

%ipoint conversions
ipconv.str = 1;
ipconv.sta = 3/2;
ipconv.agi = 1;
ipconv.int = 1;
ipconv.hit = 1;
ipconv.exp = 1;
ipconv.crit = 1;
ipconv.ap = 2;
ipconv.sp = 7/6;
ipconv.has = 1;
ipconv.mas = 1;
ipconv.blo = 1;
