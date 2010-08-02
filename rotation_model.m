%% Sample Rotation module
%Assume fixed rotation of CS-HotR-X-CS-Jud-X, where X is filled with HW,
%AS, Cons, or HS.  

%Each cycle is 9 seconds.  We'll want HS cast every other cycle (ever 18s)
%since it has a 20s duration.
%Thus our rotation is roughly:
%CS-HotR-HS
%CS-Jud-X
%CS-HotR-X
%CS-Jud-X (if we're lucky).

%With the current state of abilities, Cons
%isn't even worth casting on a single target (even at 45 seconds, it's less
%than just about everything else).
%              SealofTruth: 986.2226
%                  Censure: 7.2878e+003
%      SealofRighteousness: 475.9103
%            SealofInsight: 0
%            SealofJustice: 0
%           CrusaderStrike: 2.1938e+003
%     HammeroftheRighteous: 1.0196e+004
%                    Melee: 1.6150e+003
%           AvengersShield: 3.6037e+003
%                Judgement: 3.5694e+003
%            HammerofWrath: 4.7941e+003
%             Consecration: 372.4645
%                 Exorcism: 1.1861e+003
%          HandofReckoning: 3.5697e+003
%               HolyShield: 95.7796
%                HolyWrath: 3.5947e+003

%Given this data set, we'd want to fill the X's with:
%  HoW > AS > HW > Cons 
%Note that while AS and HW are slightly better than Judgement, we'll get
%some guaranteed crits due to Sacred Duty that will increase Judgement's
%net damage.  So even when GC procs, it's not worth pushing AS up one slot,
%since it'll still get cast before the next CS.  

%For the moment, we'll assume that we get one GC proc, such that we get one
%HW and two AS's in the rotation above:
%CS-HotR-HS
%CS-Jud-AS
%CS-HotR-HW
%CS-Jud-AS
%Note that since AS is a 20-second cooldown, at worst we end up with one
%"empty" spot in the rotation.

%So, in 18 seconds, we get
%4x CS
%2x HotR
%2x Jud
%1x HW
%2x AS
%Melee damage
%Seal procs
%Censure damage
%Holy Shield damage (ignored for now)

rot1.dmg=   4.*dmg.CrusaderStrike + ...
            2.*dmg.HammeroftheRighteous + ...
            2.*dmg.Judgement + ...
            1.*dmg.HolyWrath + ...
            2.*dmg.AvengersShield + ...
            18.*dps.Melee + ...
            18.*dps.SealofTruth + ...
            18.*dps.Censure;
        
rot1.dps=rot1.dmg./18;
rot1.tps=rot1.dps.*mod.threat;
