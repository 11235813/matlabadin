%% stat_conversions
%this m-file contains all of the relevant stat conversions we might want.
%Everything is stored in the "cnv" (conversion) structure
%The default format follows this convention:
%cnv.x_y = X
%where "x" is the name of the source stat (i.e. "haste"), "y" is the name
%of the destination stat, and X is the value in rating that it takes 
%to achieve 1% of the stat.  In general, X should be a value larger than 1.

%Since hit/crit/haste rating have different conversion coefficients
%(physical and spell), we'll append the ph/sp prefixes.


%offensive conversions (x_y instead of x_to_y)
cnv.agi_phcrit=52.0833333;
cnv.int_spcrit=166.6666709;
cnv.int_sp=1;
cnv.crit_phcrit=45.90598679;
cnv.crit_spcrit=45.90598679;

cnv.hit_phhit=32.78998947;
cnv.hit_sphit=26.23199272;

cnv.exp_exp=8.197497368;

cnv.haste_phhaste=25.2231;
cnv.haste_sphaste=25.2231;
% todo : fix arpen later on
cnv.arpen_arpen=13.99572719;

%defensive conversions
cnv.agi_dodge=59.88023952;
cnv.block_block=16.39499474;
cnv.mast_block=100;

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
