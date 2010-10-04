%CALC_STATSCALING calculates the scaling of our abilites with different
%stats


%first, generate coefficients via prio_calc or load from saved data

% load prio_data.mat
prio_calc;


%The construction of this module is that we have a coefficient matrix
%(cmat) which is an NxM matrix of ability coefficients Cij for each of the
%M abilities in N different rotations.  We thus want to construct an MxL
%matrix (adam) of damage values for the M abilities as they scale with a
%particular stat (L different values).  If we matrix multiply cmat*adam, we
%get an NxL matrix containing the DPS values for each rotation as it scales
%with that stat.


%% construct adam

extra.itm.str=1:500;
stat_model
ability_model

%default ability order in prio_model is {'3ShoR';'CS';'Jud';'AS';'HoWr';'Cons';'HotR';'2ShoR'};

adam=[raw.ShieldoftheRighteous; ...
      dmg.CrusaderStrike; ...
      dmg.Judgement; ...
      dmg.AvengersShield; ...
      dmg.HolyWrath; ...
      net.Consecration; ...
      dmg.HammeroftheRighteous+net.HammerNova; ...
      raw.ShieldoftheRighteous; ...
      0; ...  %Inquisition
      dmg.activeseal];



%this matrix contains the scaling of each rotation with different stats
rotscale=cmat*adam;  

