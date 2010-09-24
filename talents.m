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
talent.ProtectoroftheInnocent=0;
talent.JudgementsofthePure=0;

talent.ClarityofPurpose=0;
talent.LastWord=0;
talent.BlazingLight=0;

holy=zeros(2,3);
holy(1,1)=talent.ArbiteroftheLight;holy(1,2)=talent.ProtectoroftheInnocent;holy(1,3)=talent.JudgementsofthePure;
holy(2,1)=talent.ClarityofPurpose;holy(2,2)=talent.LastWord;holy(2,3)=talent.BlazingLight;
talentpoints.holy=sum(sum(holy));

%% Prot
talent.Divinity=0;
talent.SealsofthePure=3;
talent.EternalGlory=2;

talent.JudgementsoftheJust=2;
talent.Toughness=3;
talent.ImprovedHammerofJustice=0;

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
prot(1,1)=talent.Divinity;prot(1,2)=talent.SealsofthePure;prot(1,3)=talent.EternalGlory;
prot(2,1)=talent.JudgementsoftheJust;prot(2,2)=talent.Toughness;prot(2,3)=talent.ImprovedHammerofJustice;
prot(3,1)=talent.HallowedGround;prot(3,2)=talent.Sanctuary;prot(3,3)=talent.HammeroftheRighteous;prot(3,4)=talent.WrathoftheLightbringer;
prot(4,1)=talent.Reckoning;prot(4,2)=talent.ShieldoftheRighteous;prot(4,3)=talent.GrandCrusader;prot(4,4)=talent.DivineGuardian;
prot(5,1)=talent.Vindication;prot(5,2)=talent.HolyShield;prot(5,3)=talent.GuardedbytheLight;
prot(6,1)=talent.ShieldoftheTemplar;prot(6,2)=talent.SacredDuty;
prot(7,1)=talent.ArdentDefender;
talentpoints.prot=sum(sum(prot));

%% Ret
talent.EyeforanEye=0;
talent.Crusade=3;
talent.ImprovedJudgement=2;

talent.GuardiansFavor=0;
talent.RuleofLaw=3;
talent.PursuitofJustice=2;

ret=zeros(2,3);
ret(1,1)=talent.EyeforanEye;ret(1,2)=talent.Crusade;ret(1,3)=talent.ImprovedJudgement;
ret(2,1)=talent.GuardiansFavor;ret(2,2)=talent.RuleofLaw;ret(2,3)=talent.PursuitofJustice;
talentpoints.ret=sum(sum(ret));


%% Glyphs (logical)
% Prime
glyph.CrusaderStrike=0;
glyph.Exorcism=0;
glyph.HammeroftheRighteous=0;
glyph.Judgement=0;
glyph.SealofTruth=0;
glyph.ShieldoftheRighteous=0;
glyph.WordofGlory=0;
% Major
glyph.AsceticCrusader=0;
glyph.Consecration=0;
glyph.DazingShield=0;
glyph.DivineProtection=0;
glyph.FocusedShield=0;
glyph.HammerofJustice=0;
glyph.HammerofWrath=0;
glyph.HolyWrath=0;
glyph.HandofSalvation=0;
glyph.TurnEvil=0;
% Minor
glyph.BlessingofKings=0;
glyph.BlessingofMight=0;
glyph.Insight=0;
glyph.Justice=0;
glyph.LayonHands=0;
glyph.Righteousness=0;
glyph.Truth=0;