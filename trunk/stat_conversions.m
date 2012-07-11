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


%offensive stats
cnv.agi_phcrit=1259.51806640;
cnv.int_spcrit=2533.66357421;
cnv.str_ap=2;
cnv.int_sp=1;
cnv.crit_phcrit=600;
cnv.crit_spcrit=600;
cnv.hit_hit=340;
cnv.exp_exp=340;
cnv.haste_phhaste=425;
cnv.haste_sphaste=425;

%defensive stats
cnv.dodge_dodge=885;
% cnv.agi_dodge=0;
cnv.parry_parry=885;
cnv.mast_mast=600;
cnv.mast_block=1;
cnv.mast_bog=1;

%ipoint conversions
ipconv.str=1;
ipconv.sta=3/2;
ipconv.agi=1;
ipconv.int=1;
ipconv.hit=1;
ipconv.exp=1;
ipconv.crit=1;
ipconv.ap=2;
ipconv.sp=7/6;
ipconv.haste=1;
ipconv.mas=1;
ipconv.dodge=1;
ipconv.parry=1;