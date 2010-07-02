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

%% Holy
talent.SealsOfThePure=0;
talent.SpiritualFocus=0;

%% Prot
talent.DivineStrength=5;
talent.Divinity=0;

talent.Anticipation=5;
talent.Stoicism=0;
talent.GuardiansFavor=0;

talent.ImprovedRighteousFury=3;
talent.Toughness=5;
talent.DivineSacrifice=1;

talent.DivineGuardian=2;
talent.ImprovedHammerOfJustice=0;
talent.ImprovedDevotionAura=3;

talent.Sanctuary=1;
talent.Reckoning=0;

talent.SacredDuty=2;
talent.OneHandedWeaponSpecialization=3;

talent.SpiritualAttunement=1;
talent.HolyShield=1;
talent.ArdentDefender=3;

talent.Redoubt=3;
talent.CombatExpertise=3;

talent.TouchedByTheLight=3;
talent.AvengersShield=1;
talent.GuardedByTheLight=2;

talent.ShieldOfTheTemplar=3;
talent.JudgementsOfTheJust=2;

talent.HammerOfTheRighteous=1;

%% Ret
%tier 1
talent.Deflection=5;
talent.Benediction=0;
%tier 2
talent.ImprovedJudgement=2;   
talent.HeartOfTheCrusader=3;     
talent.ImprovedBlessingOfMight=0;

talent.Vindication=2;
talent.Conviction=0;
talent.SealOfCommand=1;
talent.PursuitOfJustice=2;
%tier 4
talent.EyeForAnEye=0;
talent.SanctityOfBattle=0;
talent.Crusade=3;
%tier 5
talent.TwoHandedWeaponSpecialization=0;
talent.SanctifiedRetribution=0;

talent.Vengeance=0;
talent.DivinePurpose=0;

talent.TheArtOfWar=0;
talent.Repentance=0;
talent.JudgementsOfTheWise=0;


%% Glyphs
%Coming soon