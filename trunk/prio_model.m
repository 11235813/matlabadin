%prio_model sets up the basic priority queue structures that are then
%executed by the priority simulator module.

%define base cooldowns - this section may be moved to ability recalc
cd.CS=4.5;cd.Jud=8;cd.AS=15;cd.HoWr=15;cd.Cons=30.*mdf.glyphCons;

hopo=0;sdflag=0;

%this section sets up the spells we'll be casting.  The order of the
%entries is pretty much irrelevant, the action queue takes care of cast
%order.

%IMPORTANT for proper ShoR handling, the label of ShoR should be 'nShoR'
%where n is the HoPo strength.  This is a temporary fix (I think) for
%handling priority queues where we have both 3ShoR and 2ShoR.
priodefault.name='Default Set';
priodefault.labels={'3ShoR';'CS';'Jud';'AS';'HoWr';'Cons';'HotR';'2ShoR'};
priodefault.cds=[0 cd.CS cd.Jud cd.AS cd.HoWr cd.Cons cd.CS 0];
%define gcd lengths
priodefault.gcds=[1.5 1.5 1.5 1.5 player.spgcd player.spgcd 1.5 1.5];
priodefault.ids=[1 2 3 4 5 6 0 0];  %id numbers for generating figures - 0 is not plotted
priodefault.castname={'ShieldoftheRighteous'; ...
                  'CrusaderStrike'; ...
                  'Judgement';...
                  'AvengersShield';...
                  'HolyWrath';...
                  'Consecration'; ...
                  'HammeroftheRighteous';...
                  'ShieldoftheRighteous'};

%damage of each ability - ShoR must always use RAW values since the simulation takes hit/crit into account for us.              
priodefault.damage=[raw.ShieldoftheRighteous...
                    dmg.CrusaderStrike...
                    dmg.Judgement...
                    dmg.AvengersShield...
                    dmg.HolyWrath...
                    dmg.Consecration...
                    dmg.HammeroftheRighteous+net.HammerNova...
                    raw.ShieldoftheRighteous./2];    %fix this later

%Seal handling for ShoR  - extra stuff included for later              
priodefault.sealdamage=dmg.seals(exec.seal);
priodefault.procsseals=[1 1 mdf.JotJ>1 0 0 0 1 1];
priodefault.sealhit=[1 mdf.mehit mdf.rahit 0 0 0 mdf.mehit 1]; %shor misses accounted for in code
         
%action is the structure that contains post-cast actions, including
%resetting spell cooldowns.  
priodefault.action={'hopo=0;dur.SD=0;';...          %todo: Does a missed ShoR reset SD?
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GC ccd.AS=0; end;';...
                'ccd.Jud=cd.Jud;if rand<mdf.SacDut dur.SD=15; end;';...
                'ccd.AS=cd.AS;';...
                'ccd.HoWr=cd.HoWr;';...
                'ccd.Cons=cd.Cons;';...
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GC ccd.AS=0; end;';...
                'hopo=0;dur.SD=0;';...          %todo: Does a missed ShoR reset SD?
                };

clear prio            
%Now we start the rotation-specific priority code.  Note that we invoke
%priodefault to get all of the generic stuff, but we can overwrite specific
%things if we decide we want to.

prio(1)=priodefault;
prio(1).name='Sample Queue';
          
%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(1).setup={'ccd.AS=13.5;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(1).cond={'hopo>=3 && ccd.CS>1.5 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HoWr<=0'; ...
              'ccd.Cons<=0'};

%cast is the index of the spell that will be cast if the conditional is true
prio(1).cast=[3;1;2;3;4;5;6];
            
%spaction is the structure that contains any special actions that should
%occur for specific conditions.  It is run after all of the default actions
%defined in prio.action
prio(1).spaction={'';''; ''; ''; ''; ''; ''; '';};



%% 2 and 3 model HP generation
k=2;
prio(k).name='AS>CS HP pushback sim';