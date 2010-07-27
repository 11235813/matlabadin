function [dodgedr parrydr missdr totavoid] =  avoid_dr(dodge,parry,defense,agi,class)
%AVOID_DR calculates the amount of avoidance received from all sources
%after diminishing returns.  It takes five inputs, in order:
%dodge  = dodge rating from gear
%parry  = parry rating from gear
%defense = defense rating from gear
%agi = agility from all sources EXCEPT base agility
%class = (optional) a string representing the class.  Default is 'paladin',
%        but the code can handle 'warrior', 'deathknight', and 'druid' as
%        well as some other variations on those ('warr', 'dk', etc).
%NOTE THAT THIS COMPLETELY IGNORES SOURCES OF AVOIDANCE THAT ARE NOT
%SUBJECT TO DIMINISHING RETURNS.  This includes talents, racials, and base
%(naked) avoidance.  You have to add them in by hand to the output of this
%function.


%% Constants
%rating conversions
defense_rating_to_skill=1./4.91850;
defense_skill_to_percent=0.04;
dodge_rating_to_percent=1./45.25018635;
parry_rating_to_percent=1./45.25018722;
defense_rating_to_percent=1./40.98748366;

%class constants - notation from
%http://www.tankspot.com/forums/f63/40003-diminishing-returns-avoidance.html

%DR bounds (k)
k_plate=0.956;        %k for plate
k_druid=0.972;  %k for druids

%Caps (c)
c_dodge_plate=88.129021; %c_dodge for plate
c_parry_plate=47.003525;  %c_parry for plate
c_miss_plate =16;         %c_miss for plate

c_dodge_druid=116.890707; %c_dodge for druids

%Agility to dodge conversions
agi_to_dodge_percent_pally =1./59.88023952;     %new dodge percent from agi for paladins (without! kings)
% agi_to_dodge_percent_pally = 0.019200;    %old dodge percent from agi for paladins
agi_to_dodge_percent_warr_dk=0.01180;      %old dodge percent from agi for warriors/dk
agi_to_dodge_percent_druid=0.02090;        %old dodge percent from agi for druids

%% Class choice
%by default, this simulation assumes a paladin.  A fifth, optional argument
%allows for other classes to be specified.  

if nargin < 5 || ( nargin==5 && ( strcmp(class,'Paladin') || strcmp(class,'paladin') || strcmp(class,'pally') || strcmp(class,'pal') ) )
    k=k_plate;
    c_dodge=c_dodge_plate;
    c_parry=c_parry_plate;
    c_miss=c_miss_plate;
    agi_to_dodge_percent=agi_to_dodge_percent_pally;
elseif nargin == 5 && (strcmp(class,'Warrior') || strcmp(class,'warrior') || strcmp(class,'warr') || strcmp(class,'war') || ...
                      strcmp(class,'Death Knight') || strcmp(class,'death knight') || strcmp(class,'DeathKnight') || strcmp(class,'deathknight') || strcmp(class,'dk')) || strcmp(class,'dwdk')
    k=k_plate;
    c_dodge=c_dodge_plate;
    c_parry=c_parry_plate;
    c_miss=c_miss_plate;
    agi_to_dodge_percent=agi_to_dodge_percent_warr_dk;
elseif nargin ==5 && (strcmp(class,'Druid') || strcmp(class,'druid') || strcmp(class,'dru') || strcmp(class,'drood'))
    k=k_druid;
    c_dodge=c_dodge_druid;
    c_parry=0;
    c_miss=c_miss_plate;   %probably not worth bothering with?  Not sure if the druid value is 16
    agi_to_dodge_percent=agi_to_dodge_percent_druid;
else
    error('Class string not understood!  Please use the full name of the class for best results (e.g. warrior, paladin, deathknight, druid)')
end

%% Calculate avoidance values

%quick conversions
def_skill = floor(defense.*defense_rating_to_skill);   %convert def rating to skill


%Dodge
total_dodge = def_skill.*defense_skill_to_percent + ...  %dodge from defense
              dodge.*dodge_rating_to_percent + ...       %dodge from dodge rating
              agi.*agi_to_dodge_percent;

dodgedr = 1./(1./c_dodge + k./total_dodge);     %Dodge after DR

%Parry
total_parry = def_skill.*defense_skill_to_percent + ... %parry from def
              parry.*parry_rating_to_percent;           %parry from parry rating
          
parrydr = 1./(1./c_parry + k./total_parry);     %parry after DR   

%Miss
total_miss = def_skill.*defense_skill_to_percent;   %miss from defense

missdr = 1./(1./c_miss + k./total_miss);        %miss after DR


%total avoidance
totavoid=dodgedr+parrydr+missdr;
end
