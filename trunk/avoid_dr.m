function [avoiddr] =  avoid_dr(base,dodge,parry,agi,class)
%AVOID_DR calculates the amount of avoidance received from all sources
%after diminishing returns.  It takes four inputs, in order:
%dodge  = dodge rating from gear
%parry  = parry rating from gear
%agi = agility from all sources EXCEPT base agility (optional)
%class = (optional) a string representing the class.  Default is 'paladin',
%        but the code can handle 'warrior', 'deathknight', 'druid', and 'rogue' as
%        well as some other variations on those ('warr', 'dk', etc).
%NOTE THAT THIS COMPLETELY IGNORES SOURCES OF AVOIDANCE THAT ARE NOT
%SUBJECT TO DIMINISHING RETURNS.  This includes talents, racials, and base
%(naked) avoidance.  You have to add them in by hand to the output of this
%function.

%%sanity check
switch nargin
    case {1,2}
        error('Insufficient input arguments');
    case 3
        if (min(dodge)<0||min(parry)<0)
            error('All input arguments must be nonnegative.');
        end
    case {4,5}
        if (min(dodge)<0||min(parry)<0||min(agi)<0)
            error('All input arguments must be nonnegative.');
        end
    otherwise
        error('Too many input arguments.');
end

%% Constants
%rating conversions
cnv.dodge_dodge=176.71890258.*(base.lvl==85);
cnv.parry_parry=176.71890258.*(base.lvl==85);
%DR coefficients (k)
drcoeff.plate=0.956;
drcoeff.druid=0.972;
drcoeff.rogue=0.988;
%Caps (c)
drcap.Pdodge=65.631440;  %plate
drcap.Pparry=65.631440;  %plate
drcap.Ddodge=116.890707; %druid
drcap.Rdodge=145.560408; %rogue
drcap.Rparry=145.560408; %rogue
%Agility to dodge conversions (without! BoK)
cnv.agi_dodge(1)=243.58281085.*(base.lvl==85);  %druid
cnv.agi_dodge(2)=243.51637648.*(base.lvl==85);  %rogue


%% Class choice
%Paladin by default, use the optional argument to load other classes
if nargin<5 || (nargin==5 && (strcmp(class,'Paladin') || strcmp(class,'paladin') || strcmp(class,'pally') || strcmp(class,'pal') ...
        || strcmp(class,'Warrior') || strcmp(class,'warrior') || strcmp(class,'warr') || strcmp(class,'war') ...
        || strcmp(class,'Death Knight') || strcmp(class,'death knight') || strcmp(class,'DeathKnight') || strcmp(class,'deathknight') || strcmp(class,'dk')) || strcmp(class,'dwdk'))
    avoiddr.k=drcoeff.plate;
    avoiddr.c_dodge=drcap.Pdodge;
    avoiddr.c_parry=drcap.Pparry;
    avoiddr.agi_dodge=[];
elseif nargin==5 && (strcmp(class,'Druid') || strcmp(class,'druid') || strcmp(class,'dru') || strcmp(class,'drood'))
    avoiddr.k=drcoeff.druid;
    avoiddr.c_dodge=drcap.Ddodge;
    avoiddr.c_parry=[];
    avoiddr.agi_dodge=cnv.agi_dodge(1);
elseif nargin==5 && (strcmp(class,'Rogue') || strcmp(class,'rogue') || strcmp(class,'rog'))
    avoiddr.k=drcoeff.rogue;
    avoiddr.c_dodge=drcap.Rdodge;
    avoiddr.c_parry=drcap.Rparry;
    avoiddr.agi_dodge=cnv.agi_dodge(2);
else
    error('Class string not understood!  Please use the full name of the class (e.g. paladin).')
end

%% Calculate avoidance values
%Dodge
avoiddr.dodge=dodge./cnv.dodge_dodge;
if ~isempty(avoiddr.agi_dodge) avoiddr.dodge=avoiddr.dodge+agi./avoiddr.agi_dodge;end;
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
    if ~isempty(avoiddr.c_parry)
        avoiddr.parrydr=1./(1./avoiddr.c_parry+avoiddr.k./avoiddr.parry);
    else                   %druid
        avoiddr.parry=0;
        avoiddr.parrydr=0;
    end
end
%total avoidance
avoiddr.totavoid=avoiddr.dodgedr+avoiddr.parrydr;
end