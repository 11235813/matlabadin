%% Talents and Glyphs
%This file handles a player's talent spec and glyphs

%talents are stored in the "talent" structure, in the form
%talent.TalentName, which would return the number of points spent in
%TalentName

%Example:  talent.HolyShield=1 would allocate one point in HolyShield.

%resetting talents is as simple as clearing the talent variable and
%defining a random empty field, e.g. "clear talent; talent.empty=0;"

%this file will contain a default talent spec as an example.  We can decide
%later whether we want to have a separate file for different specs or
%whether we want to do something more elegant (maybe a "setTalent" function
%that can take a wowhead URL as an argument?)

%% Base bonuses for choosing prot (inherent)
talent.Vengeance=1;
talent.TouchedbytheLight=1;
talent.JudgementsoftheWise=1;

%% Holy
talent.ArbiteroftheLight=0;
talent.Divinity=0;
talent.JudgementsofthePure=0;

%potential integer matrix for later use
holy=zeros(2,3);
holy(1,1)=talent.ArbiteroftheLight;holy(1,2)=talent.Divinity;holy(1,3)=talent.JudgementsofthePure;


%% Prot
talent.ProtectoroftheInnocent=3;
talent.SealsofthePure=3;
talent.ImprovedHammerofJustice=0;

talent.JudgementsoftheJust=2;
talent.Toughness=3;
talent.GuardiansFavor=0;

talent.HallowedGround=0;
talent.Sanctuary=3;
talent.HammeroftheRighteous=1;
talent.WrathoftheLightbringer=2;

talent.Reckoning=2;
talent.ShieldoftheRighteous=1;
talent.GrandCrusader=2;
talent.DivineGuardian=1;

talent.Vindication=2;
talent.HolyShield=1;
talent.GuardedbytheLight=0;

talent.ShieldoftheTemplar=3;
talent.SacredDuty=2;

talent.ArdentDefender=1;


prot=zeros(7,4);
prot(1,1)=talent.ProtectoroftheInnocent;prot(1,2)=talent.SealsofthePure;prot(1,3)=talent.ImprovedHammerofJustice;
prot(2,1)=talent.JudgementsoftheJust;prot(2,2)=talent.Toughness;prot(2,3)=talent.GuardiansFavor;
prot(3,1)=talent.HallowedGround;prot(3,2)=talent.Sanctuary;prot(3,3)=talent.HammeroftheRighteous;prot(3,4)=talent.WrathoftheLightbringer;
prot(4,1)=talent.Reckoning;prot(4,2)=talent.ShieldoftheRighteous;prot(4,3)=talent.GrandCrusader;prot(4,4)=talent.DivineGuardian;
prot(5,1)=talent.Vindication;prot(5,2)=talent.HolyShield;prot(5,3)=talent.GuardedbytheLight;
prot(6,1)=talent.ShieldoftheTemplar;prot(6,2)=talent.SacredDuty;
prot(7,1)=talent.ArdentDefender;
protpoints=sum(sum(prot));

%% Ret
%tier 1
talent.EyeforanEye=0;
talent.Crusade=3;
talent.ImprovedJudgement=0;

%tier 2
talent.EternalGlory=0;
talent.RuleofLaw=2;
talent.PursuitofJustice=2;

ret=zeros(2,3);
ret(1,1)=talent.EyeforanEye;ret(1,2)=talent.Crusade;ret(1,3)=talent.ImprovedJudgement;
ret(2,1)=talent.EternalGlory;ret(2,2)=talent.RuleofLaw;ret(2,3)=talent.PursuitofJustice;


%% Glyphs
%Coming soon