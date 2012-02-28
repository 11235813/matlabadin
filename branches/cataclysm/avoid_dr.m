function [avoiddr] =  avoid_dr(dodge,parry)
%AVOID_DR calculates the amount of avoidance received from all sources
%after diminishing returns.  It takes two inputs, in order:
%dodge = dodge rating from all sources
%parry = parry rating from all sources
%NOTE THAT THIS COMPLETELY IGNORES SOURCES OF AVOIDANCE THAT ARE NOT
%SUBJECT TO DIMINISHING RETURNS.  This includes talents, racials, and base
%(naked) avoidance.  You have to add them in by hand to the output of this
%function.


%%sanity check
switch nargin
    case {0,1}
        error('Insufficient input arguments');
    case 2
        if (min(dodge)<0 || min(parry)<0)
            error('At least one of the input arguments is negative.');
        end
    otherwise
        error('Too many input arguments.');
end

%% Constants
%rating conversions
cnv.dodge_dodge=176.71890258;
cnv.parry_parry=176.71890258;
%DR coefficients (k)
avoiddr.k=0.956;
%Caps (c)
avoiddr.c_dodge=65.631440;  %plate
avoiddr.c_parry=65.631440;  %plate


%% Calculate avoidance values
%Dodge
avoiddr.dodge=dodge./cnv.dodge_dodge;
if avoiddr.dodge==0
    avoiddr.dodgedr=avoiddr.dodge;
else
    avoiddr.dodgedr=1./(1./avoiddr.c_dodge+avoiddr.k./avoiddr.dodge);
end

%Parry
avoiddr.parry=parry./cnv.parry_parry;
if avoiddr.parry==0
    avoiddr.parrydr=avoiddr.parry;
else
    avoiddr.parrydr=1./(1./avoiddr.c_parry+avoiddr.k./avoiddr.parry);
end

%total avoidance
avoiddr.totavoid=avoiddr.dodgedr+avoiddr.parrydr;
end