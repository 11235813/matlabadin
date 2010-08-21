function [avoiddr] =  avoid_dr(dodge,parry,agi,class)
%AVOID_DR calculates the amount of avoidance received from all sources
%after diminishing returns.  It takes four inputs, in order:
%dodge  = dodge rating from gear
%parry  = parry rating from gear
%agi = agility from all sources EXCEPT base agility
%class = (optional) a string representing the class.  Default is 'paladin',
%        but the code can handle 'warrior', 'deathknight', 'druid', and 'rogue' as
%        well as some other variations on those ('warr', 'dk', etc).
%NOTE THAT THIS COMPLETELY IGNORES SOURCES OF AVOIDANCE THAT ARE NOT
%SUBJECT TO DIMINISHING RETURNS.  This includes talents, racials, and base
%(naked) avoidance.  You have to add them in by hand to the output of this
%function.

%%sanity check
if (dodge<0 || parry<0 || agi<0) error('At least one of the input arguments is negative. Please recheck them.'); end;

%% Constants
%rating conversions
avoiddr.cnv.dodge_dodge=45.25018635;
avoiddr.cnv.parry_parry=45.25018722;
%DR coefficients (k)
avoiddr.drcoeff.plate=0.956;
avoiddr.drcoeff.druid=0.972;
avoiddr.drcoeff.rogue=0.988;
%Caps (c)
avoiddr.drcap.Pdodge=88.129021;  %plate
avoiddr.drcap.Pparry=47.003525;  %plate
avoiddr.drcap.Ddodge=116.890707; %druid
avoiddr.drcap.Rdodge=145.560408; %rogue
avoiddr.drcap.Rparry=145.560408; %rogue
%Agility to dodge conversions (without! BoK)
avoiddr.cnv.agi_dodge(1)=59.88023952; %paladin
avoiddr.cnv.agi_dodge(2)=84.74576271; %deathknight, warrior
avoiddr.cnv.agi_dodge(3)=47.84688995; %druid, rogue


%% Class choice
%by default, this simulation assumes a paladin.  A fourth, optional argument
%allows for other classes to be specified.  
if nargin<4 || (nargin==4 && (strcmp(class,'Paladin') || strcmp(class,'paladin') || strcmp(class,'pally') || strcmp(class,'pal')))
    avoiddr.k=avoiddr.drcoeff.plate;
    avoiddr.c_dodge=avoiddr.drcap.Pdodge;
    avoiddr.c_parry=avoiddr.drcap.Pparry;
    avoiddr.agi_dodge=avoiddr.cnv.agi_dodge(1);
elseif nargin==4 && (strcmp(class,'Warrior') || strcmp(class,'warrior') || strcmp(class,'warr') || strcmp(class,'war') || ...
                      strcmp(class,'Death Knight') || strcmp(class,'death knight') || strcmp(class,'DeathKnight') || strcmp(class,'deathknight') || strcmp(class,'dk')) || strcmp(class,'dwdk')
    avoiddr.k=avoiddr.drcoeff.plate;
    avoiddr.c_dodge=avoiddr.drcap.Pdodge;
    avoiddr.c_parry=avoiddr.drcap.Pparry;
    avoiddr.agi_dodge=avoiddr.cnv.agi_dodge(2);
elseif nargin==4 && (strcmp(class,'Druid') || strcmp(class,'druid') || strcmp(class,'dru') || strcmp(class,'drood'))
    avoiddr.k=avoiddr.drcoeff.druid;
    avoiddr.c_dodge=avoiddr.drcap.Ddodge;
    avoiddr.c_parry=[];
    avoiddr.agi_dodge=avoiddr.cnv.agi_dodge(3);
elseif nargin==4 && (strcmp(class,'Rogue') || strcmp(class,'rogue') || strcmp(class,'rog'))
    avoiddr.k=avoiddr.drcoeff.rogue;
    avoiddr.c_dodge=avoiddr.drcap.Rdodge;
    avoiddr.c_parry=avoiddr.drcap.Rparry;
    avoiddr.agi_dodge=avoiddr.cnv.agi_dodge(3);
else
    error('Class string not understood!  Please use the full name of the class (e.g. paladin).')
end

%% Calculate avoidance values
%Dodge
avoiddr.dodge=dodge./avoiddr.cnv.dodge_dodge+agi./avoiddr.agi_dodge;
if avoiddr.dodge==0
    avoiddr.dodgedr=avoiddr.dodge;
else
    avoiddr.dodgedr=1./(1./avoiddr.c_dodge+avoiddr.k./avoiddr.dodge);
end
%Parry
avoiddr.parry=parry./avoiddr.cnv.parry_parry;
if avoiddr.parry==0
    avoiddr.parrydr=avoiddr.parry;
else
    if isempty(avoiddr.c_parry)==0
        avoiddr.parrydr=1./(1./avoiddr.c_parry+avoiddr.k./avoiddr.parry);
    else
        avoiddr.parrydr=0; %druid
    end
end
%total avoidance
avoiddr.totavoid=avoiddr.dodgedr+avoiddr.parrydr;
end