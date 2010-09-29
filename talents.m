%% Talents and Glyphs
%This file handles and updates a player's talent spec and glyphs.  The
%'tree' array contains matrices representing the talent trees, from which
%values are loaded into the individual talents.  This gives us an easy and
%compact way to store and load default builds.

%TODO: I've stored talents in the tree matrices by absolute position in the
%Nx4 grid of the talent tree.  Does it make more sense to do this, or to
%use relative addressing?  In other words, Sacred Duty is in slot (6,2),
%but it's the first talent of tier 6.  Should it be stored in
%tree.prot(6,2) or tree.prot(6,1)?  The former has the advantage of the
%matrix representation looking like the tree, while the latter puts all of
%the zeros at the end of a row.

%talents are stored in the "talent" structure, in the form
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
if exist('tree')==0 || isfield(tree,'holy')==0
    tree.holy=zeros(2,4);
    tree.holy=[...
        0 0 0 0; ...
        0 0 0 0];
end

talent.ArbiteroftheLight=tree.holy(1,1);
talent.ProtectoroftheInnocent=tree.holy(1,2);
talent.JudgementsofthePure=tree.holy(1,3);

talent.ClarityofPurpose=tree.holy(2,1);
talent.LastWord=tree.holy(2,2);
talent.BlazingLight=tree.holy(2,3);

% holy=zeros(2,3);
% holy(1,1)=talent.ArbiteroftheLight;holy(1,2)=talent.ProtectoroftheInnocent;holy(1,3)=talent.JudgementsofthePure;
% holy(2,1)=talent.ClarityofPurpose;holy(2,2)=talent.LastWord;holy(2,3)=talent.BlazingLight;
talentpoints.holy=sum(sum(tree.holy));

%% Prot
if exist('tree')==0 || isfield(tree,'prot')==0
    tree.prot=zeros(7,4);
    tree.prot=[...
        3 2 0 0; ...
        2 3 0 0; ...
        0 3 1 2; ...
        2 1 2 0; ...
        1 1 0 1; ...
        0 2 3 0; ...
        0 1 0 0];
end
       
talent.Divinity=tree.prot(1,1);
talent.SealsofthePure=tree.prot(1,2);
talent.EternalGlory=tree.prot(1,3);

talent.JudgementsoftheJust=tree.prot(2,1);
talent.Toughness=tree.prot(2,2);
talent.ImprovedHammerofJustice=tree.prot(2,3);

talent.HallowedGround=tree.prot(3,1);
talent.Sanctuary=tree.prot(3,2);
talent.HammeroftheRighteous=tree.prot(3,3);
talent.WrathoftheLightbringer=tree.prot(3,4);

talent.Reckoning=tree.prot(4,1);
talent.ShieldoftheRighteous=tree.prot(4,2);
talent.GrandCrusader=tree.prot(4,3);
talent.DivineGuardian=tree.prot(4,4);

talent.Vindication=tree.prot(5,1);
talent.HolyShield=tree.prot(5,2);
talent.GuardedbytheLight=tree.prot(5,3);

talent.ShieldoftheTemplar=tree.prot(6,2);
talent.SacredDuty=tree.prot(6,3);

talent.ArdentDefender=tree.prot(7,2);

% prot=zeros(7,4);
% prot(1,1)=talent.Divinity;prot(1,2)=talent.SealsofthePure;prot(1,3)=talent.EternalGlory;
% prot(2,1)=talent.JudgementsoftheJust;prot(2,2)=talent.Toughness;prot(2,3)=talent.ImprovedHammerofJustice;
% prot(3,1)=talent.HallowedGround;prot(3,2)=talent.Sanctuary;prot(3,3)=talent.HammeroftheRighteous;prot(3,4)=talent.WrathoftheLightbringer;
% prot(4,1)=talent.Reckoning;prot(4,2)=talent.ShieldoftheRighteous;prot(4,3)=talent.GrandCrusader;prot(4,4)=talent.DivineGuardian;
% prot(5,1)=talent.Vindication;prot(5,2)=talent.HolyShield;prot(5,3)=talent.GuardedbytheLight;
% prot(6,1)=talent.ShieldoftheTemplar;prot(6,2)=talent.SacredDuty;
% prot(7,1)=talent.ArdentDefender;
talentpoints.prot=sum(sum(tree.prot));

%% Ret
if exist('tree')==0 || isfield(tree,'ret')==0
    tree.ret=zeros(2,4);
    tree.ret=[...
        0 3 2 0; ...
        0 3 0 2];
end
       
       
talent.EyeforanEye=tree.ret(1,1);
talent.Crusade=tree.ret(1,2);
talent.ImprovedJudgement=tree.ret(1,3);

talent.GuardiansFavor=tree.ret(2,1);
talent.RuleofLaw=tree.ret(2,2);
talent.PursuitofJustice=tree.ret(2,4);

% ret=zeros(2,3);
% ret(1,1)=talent.EyeforanEye;ret(1,2)=talent.Crusade;ret(1,3)=talent.ImprovedJudgement;
% ret(2,1)=talent.GuardiansFavor;ret(2,2)=talent.RuleofLaw;ret(2,3)=talent.PursuitofJustice;
talentpoints.ret=sum(sum(tree.ret));


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