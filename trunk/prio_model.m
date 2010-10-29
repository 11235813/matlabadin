%prio_model sets up the basic priority queue structures that are then
%executed by the priority simulator module.

%define base cooldowns - this section may be moved to ability recalc
cd.CS=3;cd.Jud=8;cd.AS=15;cd.HW=15;cd.Cons=30.*mdf.glyphCons;cd.HoW=6;

hopo=0;sdflag=0;

%this section sets up the spells we'll be casting.  The order of the
%entries is pretty much irrelevant, the action queue takes care of cast
%order.

%IMPORTANT for proper ShoR handling, the label of ShoR should be 'nShoR'
%where n is the HoPo strength.  This is a temporary fix (I think) for
%handling priority queues where we have both 3ShoR and 2ShoR.
priodefault.name='Default Set';
priodefault.alabel={'3ShoR';'CS';'Jud';'AS';'HW';'Cons';'HotR';'2ShoR';'Inq';'HoW'};
priodefault.cds=[0 cd.CS cd.Jud cd.AS cd.HW cd.Cons cd.CS 0 0 cd.HoW];
%define gcd lengths
priodefault.gcds=[1.5 1.5 1.5 1.5 player.spgcd player.spgcd 1.5 1.5 player.spgcd 1.5];
priodefault.gcds=[1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5];
priodefault.ids=[1 2 3 4 5 6 2 1 7 8];  %id numbers for generating figures - 0 is not plotted
priodefault.adtype=[1 0 1 1 1 1 0 1 0 1];  %1 for Holy, 0 for phys/other

% priodefault.aname={'ShieldoftheRighteous'; ...
%                   'CrusaderStrike'; ...
%                   'Judgement';...
%                   'AvengersShield';...
%                   'HolyWrath';...
%                   'Consecration'; ...
%                   'HammeroftheRighteous';...
%                   'ShieldoftheRighteous'; ...
%                   'Inquisition'};

%damage of each ability - ShoR must always use RAW values since the simulation takes hit/crit into account for us.  
%first row is physical damage, second row is holy
priodefault.admg  =[raw.ShieldoftheRighteous;...
                    dmg.CrusaderStrike;...
                    dmg.Judgement;...
                    dmg.AvengersShield;...
                    dmg.HolyWrath;...
                    dmg.Consecration;...
                    dmg.HammeroftheRighteous;...
                    dmg.ShieldoftheRighteous./2; ...    %fix this later
                    0;...
                    dmg.HammerofWrath];

%procs to watch
priodefault.plabel={exec.seal;'HaNova'};
priodefault.pdmg=[dmg.activeseal;dmg.HammerNova];
priodefault.pdtype=[1 1];
                
%proc triggers
priodefault.ptrig=[1 1 mdf.JotJ>0 0 0 0 1 1 0 0; ...
                   0 0 0          0 0 0 1 0 0 0];
priodefault.phit=[1 mdf.mehit mdf.rahit 0 0 0 mdf.mehit 1 0 1]; %shor misses accounted for in code        


% priodefault.sealdamage=dmg.activeseal;
% priodefault.procsseals=[1 1 mdf.JotJ>1 0 0 0 1 1 1 0];
% priodefault.inqeffect=[1 0 1 1 1 1 0 1 1 0];   
% priodefault.sealhit=[1 mdf.mehit mdf.rahit 0 0 0 mdf.mehit 0 1 0]; %shor misses accounted for in code
         
%action is the structure that contains post-cast actions, including
%resetting spell cooldowns.  
priodefault.action={'0;';...          
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GC.*mdf.mehit ccd.AS=0; end;';...
                'ccd.Jud=cd.Jud;if rand<mdf.SacDut dur.SD=15; end;';...
                'ccd.AS=cd.AS;';...
                'ccd.HW=cd.HW;';...
                'ccd.Cons=cd.Cons;';...
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GC.*mdf.mehit ccd.AS=0; end;';...  %should be identical to CS
                '0;';...         
                'hopo=0;dur.Inq=12;';...
                'ccd.HoW=cd.HoW;'};

clear prio            
%Now we start the rotation-specific priority code.  Note that we invoke
%priodefault to get all of the generic stuff, but we can overwrite specific
%things if we decide we want to.

prio(1)=priodefault;
prio(1).name='SD>ShoR>CS>J>AS>Cons>HW';
          
%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(1).setup={'ccd.AS=13.5;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(1).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0'; ...
              'ccd.HW<=0'};

%cast is the index of the spell that will be cast if the conditional is true
prio(1).cast=[3;1;2;3;4;6;5];
            
%spaction is the structure that contains any special actions that should
%occur for specific conditions.  It is run after all of the default actions
%defined in prio.action
prio(1).spaction={'';''; ''; ''; ''; ''; ''; '';};



%% Single-Target Queues
k=1;

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>ShoR>CS>J>AS>HW>Cons';
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';};
prio(k).cast=[3;1;2;3;4;5;6];

% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>ShoR>CS>AS>J8>HW';
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.AS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.HW<=0'};
% prio(k).cast=[3;1;2;4;3;5];

% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>ShoR>CS>AS>J9>HW';
% prio(k).cds(3)=9;
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.AS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.HW<=0'};
% prio(k).cast=[3;1;2;4;3;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>ShoR>CS>AS>J8>HW>Cons';
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0'};
prio(k).cast=[3;1;2;4;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>ShoR>CS>AS>J9>HW>Cons';
prio(k).cds(3)=9;
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0'};
prio(k).cast=[3;1;2;4;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>ShoR>AS>CS>J>HW>Cons';
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0'};
prio(k).cast=[3;1;4;2;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>AS>ShoR>CS>J>HW>Cons';
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0'};
prio(k).cast=[3;4;1;2;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>SD>ShoR>CS>J>HW>Cons';
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0'};
prio(k).cast=[4;3;1;2;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>CS>J>AS>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;2;3;4;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>CS>J>AS>Cons>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;2;3;4;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>CS>AS>J>HW>Cons';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';};
prio(k).cast=[1;2;4;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>AS>CS>J>HW>Cons';
prio(k).cond={'hopo>=3';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';};
prio(k).cast=[1;4;2;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>ShoR>CS>J>HW>Cons';
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';};
prio(k).cast=[4;1;2;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>3ShoR>2SDShor>CS>J>AS>HW';
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'hopo>=2 && dur.SD>0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[3;1;8;2;3;4;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>3ShoR>CS>J>AS>HW ';
prio(k).cond={'hopo>=3 && dur.Inq<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[9;1;2;3;4;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>3ShoR>CS>AS>J>HW>Cons';
prio(k).cond={'hopo>=3 && dur.Inq<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';};
prio(k).cast=[9;1;2;4;3;5;6];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>3ShoR>2SDShoR>CS>J>AS>HW>Cons';
prio(k).cond={'hopo>=3 && dur.Inq<=0';...
              'hopo>=3';...
              'hopo>=2 && dur.SD>0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';};
prio(k).cast=[9;1;8;2;3;4;5;6];

% k=k+1;
% prio(k)=prio(1);
% prio(k).name='Inq>ShoR>HotR>J>AS>HW';
% prio(k).cond={'hopo>=3 && dur.Inq<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.AS<=0';...
%               'ccd.HW<=0'};
% prio(k).cast=[9;1;7;3;4;5];


k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>CS>J>AS>HoW>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HoW<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;2;3;4;10;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>CS>J>HoW>AS>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HoW<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;2;3;10;4;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>CS>HoW>J>AS>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.HoW<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;2;10;3;4;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>HoW>CS>J>AS>HW';
prio(k).cond={'hopo>=3';...
              'ccd.HoW<=0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;10;2;3;4;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='HoW>ShoR>CS>J>AS>HW';
prio(k).cond={'ccd.HoW<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};
prio(k).cast=[10;1;2;3;4;5];

k1=k;
%end Single-Target queues

%% AoE Queues

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>HotR>Cons>AS>HW>J';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;6;4;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>HotR>AS>Cons>HW>J';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;4;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>HotR>AS>Cons>J>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;7;4;6;3;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>HotR>AS>J>Cons>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;7;4;3;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='ShoR>AS>HotR>Cons>HW>J';
prio(k).cond={'hopo>=3';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;4;7;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>ShoR>HotR>Cons>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;1;7;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>HotR>ShoR>Cons>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'ccd.CS<=0';...
              'hopo>=3';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;7;1;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>HotR>Cons>ShoR>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;7;6;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>AS>Cons>ShoR>HW>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[7;4;6;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Cons>AS>ShoR>HW>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[7;6;4;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Cons>HotR>AS>ShoR>HW>J';
prio(k).cond={'ccd.Cons<=0';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[6;7;4;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Cons>AS>HotR>ShoR>HW>J';
prio(k).cond={'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[6;4;7;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>AS>HW>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;6;4;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>AS>Cons>HW>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;4;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>AS>HotR>Cons>HW>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;4;7;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>Inq>HotR>Cons>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;1;7;6;5;3];

%#1 = 3ShoR
%#2 = CS
%#3 = Jud
%#4 = AS
%#5 = HW
%#6 = Cons
%#7 = HotR
%#8 = 2ShoR
%#9 = Inq
%#10= HoW

k2=k;