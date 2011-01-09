%% Talents and Glyphs
%This file handles and updates a player's talent spec and glyphs.  The
%'tree' array contains matrices representing the talent trees, from which
%values are loaded into the individual talents.  This gives us an easy and
%compact way to store and load default builds.

%Talents are stored in the tree matrices by absolute position in the
%Nx4 grid of the talent tree.
%Individual talents entries are stored in the "talent" structure, in the form
%talent.TalentName, which would return the number of points spent in
%TalentName.  

%One can edit talent.X directly in m-files if desired for a certain
%simulation.  Example:  talent.HolyShield=1 would allocate one point in
%HolyShield.  Note however that re-running the "talents" m-file will undo
%this change and revert to whatever build is stored in "tree"

%Once we have a definite "default build", we'll update the inherent tree
%structure to match it.  Other sample builds will be stored in def_db and
%invoked by "tree=ddb.talentset{n};talents;"

%% Base bonuses for choosing prot (inherent)
talent.Vengeance=1;
talent.TouchedbytheLight=1;
talent.JudgementsoftheWise=1;

%% Holy
if exist('talent')==0||isfield(talent,'holy')==0
    talent.holy=zeros(2,4);
    talent.holy=[0 0 0 0; ...
                 0 0 0 0];
end
talent.ArbiteroftheLight=talent.holy(1,1);
talent.ProtectoroftheInnocent=talent.holy(1,2);
talent.JudgementsofthePure=talent.holy(1,3);

talent.ClarityofPurpose=talent.holy(2,1);
talent.LastWord=talent.holy(2,2);
talent.BlazingLight=talent.holy(2,3);

talent.holypoints=sum(sum(talent.holy));

%% Prot
if exist('talent')==0||isfield(talent,'prot')==0
    talent.prot=zeros(7,4);
    talent.prot=[3 2 0 0; ...
                 2 3 0 0; ...
                 0 3 1 2; ...
                 2 1 2 0; ...
                 1 1 0 1; ...
                 0 2 3 0; ...
                 0 1 0 0];
end
talent.Divinity=talent.prot(1,1);
talent.SealsofthePure=talent.prot(1,2);
talent.EternalGlory=talent.prot(1,3);

talent.JudgementsoftheJust=talent.prot(2,1);
talent.Toughness=talent.prot(2,2);
talent.ImprovedHammerofJustice=talent.prot(2,3);

talent.HallowedGround=talent.prot(3,1);
talent.Sanctuary=talent.prot(3,2);
talent.HammeroftheRighteous=talent.prot(3,3);
talent.WrathoftheLightbringer=talent.prot(3,4);

talent.Reckoning=talent.prot(4,1);
talent.ShieldoftheRighteous=talent.prot(4,2);
talent.GrandCrusader=talent.prot(4,3);
talent.DivineGuardian=talent.prot(4,4);

talent.Vindication=talent.prot(5,1);
talent.HolyShield=talent.prot(5,2);
talent.GuardedbytheLight=talent.prot(5,3);

talent.SacredDuty=talent.prot(6,2);
talent.ShieldoftheTemplar=talent.prot(6,3);

talent.ArdentDefender=talent.prot(7,2);

talent.protpoints=sum(sum(talent.prot));

%% Ret
if exist('talent')==0 || isfield(talent,'ret')==0
    talent.ret=zeros(2,4);
    talent.ret=[0 3 2 0; ...
                0 3 0 2];
end
talent.EyeforanEye=talent.ret(1,1);
talent.Crusade=talent.ret(1,2);
talent.ImprovedJudgement=talent.ret(1,3);

talent.GuardiansFavor=talent.ret(2,1);
talent.RuleofLaw=talent.ret(2,2);
talent.PursuitofJustice=talent.ret(2,4);

talent.retpoints=sum(sum(talent.ret));


%% Glyphs (logical)
% Prime
if exist('glyph')==0 || isfield(glyph,'prime')==0
    glyph.prime=[0 0 1 0 1 1 0 0];
end
glyph.CrusaderStrike=glyph.prime(1);
glyph.Exorcism=glyph.prime(2);
glyph.HammeroftheRighteous=glyph.prime(3);
glyph.Judgement=glyph.prime(4);
glyph.SealofTruth=glyph.prime(5);
glyph.ShieldoftheRighteous=glyph.prime(6);
glyph.WordofGlory=glyph.prime(7);
glyph.SealofInsight=glyph.prime(8);

% Major
if exist('glyph')==0 || isfield(glyph,'major')==0
    glyph.major=[0 1 0 0 1 0 0 0 0 0 0];
end
glyph.AsceticCrusader=glyph.major(1);
glyph.Consecration=glyph.major(2);
glyph.DazingShield=glyph.major(3);
glyph.DivineProtection=glyph.major(4);
glyph.FocusedShield=glyph.major(5);
glyph.HammerofJustice=glyph.major(6);
glyph.HammerofWrath=glyph.major(7);
glyph.HolyWrath=glyph.major(8);
glyph.HandofSalvation=glyph.major(9);
glyph.TurnEvil=glyph.major(10);
glyph.LongWord=glyph.major(11);

% Minor
if exist('glyph')==0 || isfield(glyph,'minor')==0
    glyph.minor=[0 0 0 0 0 0 0];
end
glyph.BlessingofKings=glyph.minor(1);
glyph.BlessingofMight=glyph.minor(2);
glyph.Insight=glyph.minor(3);
glyph.Justice=glyph.minor(4);
glyph.LayonHands=glyph.minor(5);
glyph.Righteousness=glyph.minor(6);
glyph.Truth=glyph.minor(7);