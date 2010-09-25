%prio_model sets up the basic priority queue structures that are then
%executed by the priority simulator module.

%define base cooldowns - this section may be moved to ability recalc
cd.CS=4.5;cd.Jud=8;cd.AS=15;cd.HoWr=15;cd.Cons=30;

hopo=0;sdflag=0;

%this section sets up the spells we'll be casting.  The order of the
%entries is pretty much irrelevant, the action queue takes care of cast
%order.
%IMPORTANT for proper ShoR handling, the label of ShoR should be 'nShoR'
%where n is the HoPo strength.  This is a temporary fix (I think) for
%handling priority queues where we have both 3ShoR and 2ShoR.
prio(1).name='Sample FCFS';
prio(1).labels={'3ShoR';'CS';'Jud';'AS';'HoWr';'Cons'};
prio(1).cds=[0 cd.CS cd.Jud cd.AS cd.HoWr cd.Cons ];
%define gcd lengths
prio(1).gcds=[1.5 1.5 1.5 1.5 player.spgcd player.spgcd];
prio(1).ids=[1 2 3 4 5 6];  %id numbers for generating figures
prio(1).castname={'ShieldoftheRighteous'; ...
                  'CrusaderStrike'; ...
                  'Judgement';...
                  'AvengersShield';...
                  'HolyWrath';...
                  'Consecration'};

%damage of each ability - ShoR must always use RAW values since the simulation takes hit/crit into account for us.              
prio(1).damage=[raw.ShieldoftheRighteous...
                dmg.CrusaderStrike...
                dmg.Judgement...
                dmg.AvengersShield...
                dmg.HolyWrath...
                dmg.Consecration];
         
%action is the structure that contains post-cast actions, including
%resetting spell cooldowns.  
prio(1).action={'hopo=0;';...          %todo: Does a missed ShoR reset SD?
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GC ccd.AS=0; end;';...
                'ccd.Jud=cd.Jud;if rand<mdf.SacDut dur.SD=15; end;';...
                'ccd.AS=cd.AS;';...
                'ccd.HoWr=cd.HoWr;';...
                'ccd.Cons=cd.Cons;'};
            
%Now we start the priority code
          
%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(1).setup={'ccd.AS=13.5;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(1).cond={'hopo>=3 && ccd.CS<=1.5';...
              'hopo>=3 && ccd.CS>1.5 && ccd.Jud<=0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HoWr<=0'; ...
              'ccd.Cons<=0'};

%cast is the index of the spell that will be cast if the conditional is true
prio(1).cast=[1;3;2;3;4;5;6];
            
%spaction is the structure that contains any special actions that should
%occur for specific conditions.  It is run after all of the default actions
%defined in prio.action
prio(1).spaction={'';''; ''; ''; ''; ''; ''; '';};



%% 2 and 3 model HP generation
k=2;
prio(k).name='AS>CS HP pushback sim';
prio(k).labels={'ShoR';'AS';'CS'};
prio(k).cds=[0 cd.AS cd.CS];

%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(k).setup={'ccd.AS=13.5;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(k).cond={'hopo>=3';...
              'ccd.AS<=0';...
              'ccd.CS<=0'};

%cast is the spell that will be cast if the conditional is true
prio(k).cast={'ShieldoftheRighteous'; ...
              'AvengersShield';...
              'CrusaderStrike'};

%action is the structure that contains post-cast actions, including
%resetting spell cooldowns
prio(k).action={'hopo=0;';...
                'ccd.AS=cd.AS;hopo=min([3 hopo+1]);';...
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<0.2 ccd.AS=0; end;'};

%define gcd lengths
prio(k).gcds=[1.5 1.5 1.5];

%id numbers for generating figures
prio(k).ids=[3 2 1];


k=3;
prio(k).name='CS>AS HP sim';
prio(k).labels={'ShoR';'CS';'AS'};
prio(k).cds=[0 cd.CS cd.AS];

%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(k).setup={'ccd.AS=13.5;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0'};

%cast is the spell that will be cast if the conditional is true
prio(k).cast={'ShieldoftheRighteous'; ...
              'CrusaderStrike';...
              'AvengersShield'};

%action is the structure that contains post-cast actions, including
%resetting spell cooldowns
prio(k).action={'hopo=0;';...
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<0.2 ccd.AS=0; end;';...
                'ccd.AS=cd.AS;hopo=min([3 hopo+1]);'};

%define gcd lengths
prio(k).gcds=[1.5 1.5 1.5];

%id numbers for generating figures
prio(k).ids=[3 1 2];