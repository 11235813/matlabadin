function [avoiddr] =  avoid_dr(dodge,parry,block)
%AVOID_DR calculates the amount of avoidance received from all sources
%after diminishing returns.  It takes three inputs:
%dodge = pre-DR dodge pct 
%parry = pre-DR parry pct
%block = pre-DR block pct
%NOTE THAT THIS COMPLETELY IGNORES SOURCES OF AVOIDANCE THAT ARE NOT
%SUBJECT TO DIMINISHING RETURNS.  This includes talents, racials, and base
%(naked) avoidance.  You have to add them to the output of this
%function by hand .


%%sanity check
switch nargin
    case {0,1,2}
        error('Insufficient input arguments');
    case 3
        if (min(dodge)<0 || min(parry)<0 || min(block)<0)
            error('At least one of the input arguments is negative.');
        end
    otherwise
        error('Too many input arguments.');
end

%% Constants
%DR coefficients (k)
avoiddr.k=0.886;
%Caps (c)
avoiddr.c_dodge=66.56744;  %plate
avoiddr.c_parry=237.1860;  %plate, approximate
avoiddr.c_block=150.3759;  %plate, approximate


%% Calculate avoidance values
%Dodge
avoiddr.dodge=dodge;
if avoiddr.dodge==0
    avoiddr.dodgedr=avoiddr.dodge;
else
    avoiddr.dodgedr=1./(1./avoiddr.c_dodge+avoiddr.k./avoiddr.dodge);
end

%Parry
avoiddr.parry=parry;
if avoiddr.parry==0
    avoiddr.parrydr=avoiddr.parry;
else
    avoiddr.parrydr=1./(1./avoiddr.c_parry+avoiddr.k./avoiddr.parry);
end

%total avoidance
avoiddr.totavoid=avoiddr.dodgedr+avoiddr.parrydr;

%Block
avoiddr.block=block;
if avoiddr.block==0
    avoiddr.blockdr=avoiddr.block;
else
    avoiddr.blockdr=1./(1./avoiddr.c_block+avoiddr.k./avoiddr.block);
end
avoiddr.blockdr=avoiddr.block;

end