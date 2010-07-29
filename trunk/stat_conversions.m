%% stat_conversions
%this m-file contains all of the relevant stat conversions we might want.
%The default format follows this convention:
%x_to_y = X
%where "x" is the name of the source stat (i.e. "haste"), "y" is the name
%of the destination stat, and X is the value, in rating, that it takes 
%to achieve 1% of the stat.  In general, X should be a value larger than 1.
%Note that x is assumed to be in rating, hence the word "rating" is
%omitted.

%Since hit/crit/haste rating have different conversion coefficients
%(physical and spell), we'll append the ph/sp prefixes.


%offensive conversions (x_y instead of x_to_y)
agi_phcrit=52.0833333;
int_spcrit=166.6666709;
int_sp=1;
crit_phcrit=45.90598679;
crit_spcrit=45.90598679;

hit_phhit=32.78998947;
hit_sphit=26.23199272;

exp_exp=8.197497368;

haste_phhaste=25.2231;
haste_sphaste=0;
% todo : fix arpen later on
arpen_arpen=13.99572719;

%defensive conversions
agi_dodge=59.88023952;
block_block=16.39499474;
mast_block=100;

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
