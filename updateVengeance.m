function [ newValue ] = updateVengeance( timeDiff, damage, oldValue, swingTime, noRamp)
%UPDATEVENGEANCE recalculates Vengeance
%inputs: timeDiff - time since last damage event
%        damage   - amount of damage taken (optional; default=NaN (no attack))
%        oldValue - old Vengeance value (optional; default=0)
%output: newValue - recalculated Vengeance

%default input arguments
if nargin<1
    error('updateVengeance needs at least one input argument')
end
if nargin<2
    damage=NaN;
end
if nargin<3
    oldValue=0;
end
if nargin<4
    swingTime=1.5;
end
if nargin<5
    noRamp=0;
end

veng_pct=0.015;
%% Perform the calculation
%check for Vengeance drop-off
if timeDiff>=20
    newValue=0;
%otherwise record the old value if there's no attack
elseif isnan(damage)
    newValue=oldValue;
%otherwise, update using the usual formula if damage>0 and timeDiff>=0
elseif timeDiff>=0 && damage>=0
    newValue=veng_pct*damage+(20-timeDiff)/20*oldValue; %#ok<*SAGROW>
else
    error(['WTF is up with timeDiff=' num2str(timeDiff) ' and damage=' int2str(damage)]);
end

%ramp-up mechanism
if noRamp==0
    vengeance_equil=veng_pct*damage/swingTime*20;
    if newValue<vengeance_equil/2
        newValue=vengeance_equil/2;
    end
end

end

