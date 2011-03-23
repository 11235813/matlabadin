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
cnv.agi_phcrit=203.08.*(base.lvl==85);
cnv.int_spcrit=648.91.*(base.lvl==85);
cnv.str_ap=2;
cnv.int_sp=1;
cnv.crit_phcrit=179.28004455.*(base.lvl==85);
cnv.crit_spcrit=179.28004455.*(base.lvl==85);
cnv.hit_phhit=120.10880279.*(base.lvl==85);
cnv.hit_sphit=102.44573974.*(base.lvl==85);
cnv.exp_exp=30.02719688.*(base.lvl==85);
cnv.haste_phhaste=128.05715942.*(base.lvl==85);
cnv.haste_sphaste=128.05715942.*(base.lvl==85);

%defensive stats
cnv.dodge_dodge=176.71890258.*(base.lvl==85);
cnv.agi_dodge=304.50769251.*(base.lvl==85);
cnv.parry_parry=176.71890258.*(base.lvl==85);
cnv.mast_mast=179.28004455.*(base.lvl==85);

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