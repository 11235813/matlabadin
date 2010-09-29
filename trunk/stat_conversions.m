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
cnv.agi_phcrit=203.08; %TODO : fix (85)
cnv.agi_phcrit=52.0833333;
cnv.int_spcrit=648.91; %TODO : fix (85)
cnv.int_spcrit=166.6666709;
cnv.int_sp=1;
cnv.crit_phcrit=179.27999877; %85
cnv.crit_phcrit=45.90599822;
cnv.crit_spcrit=179.27999877; %85
cnv.crit_spcrit=45.90599822;

cnv.hit_phhit=120.10900115; %85
cnv.hit_phhit=30.75480079;
cnv.hit_sphit=102.44599914; %85
cnv.hit_sphit=26.23200035;

cnv.exp_exp=30.02720069; %85
cnv.exp_exp=7.68869018;

cnv.haste_phhaste=128.05700683; %85
cnv.haste_phhaste=32.79000091;
cnv.haste_sphaste=128.05700683; %85
cnv.haste_sphaste=32.79000091;
% todo : fix arpen later on
cnv.arpen_arpen=13.99572719;

%defensive conversions
cnv.dodge_dodge=176.71899414; %85
cnv.dodge_dodge=45.25019836;
cnv.agi_dodge=317.9; %TODO : fix (85)
cnv.agi_dodge=59.88023952;
cnv.parry_parry=176.71899414; %85
cnv.parry_parry=45.25019836;
cnv.block_block=88.35939788; %85
cnv.block_block=22.62509918;
cnv.mast_mast=179.27999877; %85
cnv.mast_mast=45.90599822;

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
ipconv.has=1;
ipconv.mas=1;
ipconv.blo=1;