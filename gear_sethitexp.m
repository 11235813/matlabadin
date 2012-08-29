function [ c ] = gear_sethitexp(c, hit, exp)
%GEAR_SETHITEXP Sets the hit and expertise of a gear set to the specified
%values (in percent) by modifying the shirt armor slot
%   Detailed explanation goes here

if ~isfield(c,'egs')
    warning('No gear set defined in gear_sethitexp')
end

stat_conversions

if isempty(hit); hit=-1; end
if isempty(exp); exp=-1; end


%clear shirt slot (in case we've run this previously)
c.egs(18).hit=0;
c.egs(18).exp=0;
c.gear=gear_stats(c.egs);

%calculate the net hit/exp stats based on gear alone
temp=stat_model(c);

%set the hit and expertise rating of the shirt slot to account for the
%difference
if hit>0
    hr_diff=(hit-temp.player.mehit).*cnv.hit_hit;
    c.egs(18).hit=hr_diff;
end
if exp>0
    exp_diff=(exp-temp.player.exp).*cnv.exp_exp;
    c.egs(18).exp=exp_diff;
end

c.gear=gear_stats(c.egs);
c=stat_model(c);
end