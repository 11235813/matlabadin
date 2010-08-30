%prio_model sets up the basic priority queue structures that are then
%executed by the priority simulator module.

%define base cooldowns - this section may be moved to ability recalc
cd.CS=4.5;cd.Jud=8;cd.AS=15;cd.HoWr=15;

prio(1).name='Sample FCFS';
prio(1).labels={'3ShoR';'CS';'Jud';'AS';'HoWr'};
prio(1).cds=[0 cd.CS cd.Jud cd.AS cd.HoWr];

%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(1).setup={'ccd.AS=0;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(1).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HoWr<=0'};

%cast is the spell that will be cast if the conditional is true
prio(1).cast={'ShieldoftheRighteous'; ...
              'CrusaderStrike'; ...
              'Judgement';...
              'AvengersShield';...
              'HolyWrath'};

%action is the structure that contains post-cast actions, including
%resetting spell cooldowns
prio(1).action={'hopo=0;';...
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);';...
                'ccd.Jud=cd.Jud;';...
                'ccd.AS=cd.AS;';...
                'ccd.HoWr=cd.HoWr;'};

%define gcd lengths
prio(1).gcds=[1.5 1.5 1.5 1.5 player.spgcd];

%id numbers for generating figures
prio(1).ids=[5 1 2 3 4];



%% 2 and 3 model HP generation
k=2;
prio(k).name='AS>CS HP sim';
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