%prio_model sets up the basic priority queue structures that are then
%executed by the priority simulator module.

%define base cooldowns - this section may be moved to ability recalc
cd.CS=3;cd.Jud=8;cd.AS=15;cd.HW=15;cd.Cons=30.*mdf.glyphCons;cd.HoW=6;

hopo=0;sdflag=0;

%this section sets up the spells we'll be casting.  The order of the
%entries is pretty much irrelevant, the action queue takes care of cast
%order.

%IMPORTANT for proper SotR handling, the label of SotR should be:
%  3  Holy Power: 'SotR'
% 1,2 Holy Power: 'nSotR'
%where n is the HoPo strength.  This is for handling priority queues 
%where we have both 3SotR and 2SotR.
priodefault.name='Default Set';
priodefault.alabel={'SotR';'CS';'J';'AS';'HW';'Cons';'HotR';'2SotR';'Inq';'HoW'};
priodefault.cds=[0 cd.CS cd.Jud cd.AS cd.HW cd.Cons cd.CS 0 0 cd.HoW];
%define gcd lengths - first line is for if we ever want to include gcd haste
% priodefault.gcds=[1.5 1.5 1.5 1.5 player.spgcd player.spgcd 1.5 1.5 player.spgcd 1.5]; 
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

%damage of each ability - SotR must always use RAW values since the simulation takes hit/crit into account for us.  
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
priodefault.ptrig=[1 1 mdf.jseals 0 0 0 0 1 0 0; ...
                   0 0          0 0 0 0 1 0 0 0];
priodefault.phit=[1 mdf.mehit mdf.rahit 0 0 0 1 1 0 1]; %sotr misses accounted for in code        


% priodefault.sealdamage=dmg.activeseal;
% priodefault.procsseals=[1 1 mdf.JotJ>1 0 0 0 1 1 1 0];
% priodefault.inqeffect=[1 0 1 1 1 1 0 1 1 0];   
% priodefault.sealhit=[1 mdf.mehit mdf.rahit 0 0 0 mdf.mehit 0 1 0]; %SotR misses accounted for in code
         
%action is the structure that contains post-cast actions, including
%resetting spell cooldowns.  
priodefault.action={'0;';...          
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GrCr.*mdf.mehit ccd.AS=0; end;';...
                'ccd.Jud=cd.Jud;if rand<mdf.SacDut*mdf.rahit dur.SD=15; end;';...
                'ccd.AS=cd.AS;';...
                'ccd.HW=cd.HW;';...
                'ccd.Cons=cd.Cons;';...
                'ccd.CS=cd.CS;hopo=min([3 hopo+1]);if rand<mdf.GrCr ccd.AS=0; end;';...  %should be identical to CS
                '0;';...         
                'hopo=0;dur.Inq=12;';...
                'ccd.HoW=cd.HoW;'};

clear prio            
%Now we start the rotation-specific priority code.  Note that we invoke
%priodefault to get all of the generic stuff, but we can overwrite specific
%things if we decide we want to.

prio(1)=priodefault;
k=1;
prio(k).name='SotR>CS>J>AS>HW';
          
%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(k).setup={'ccd.AS=13.5;'};

%cond is the structure that contains the conditionals which will be
%evaluated.  Each string should give a logical 1 or 0 when evaluated.
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};

%cast is the index of the spell that will be cast if the conditional is true
prio(k).cast=[1;2;3;4;5];
            
%spaction is the structure that contains any special actions that should
%occur for specific conditions.  It is run after all of the default actions
%defined in prio.action
prio(1).spaction={'';''; ''; ''; ''; ''; ''; '';};



%% Single-Target Queues

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>J>AS>HW';
prio(k).cast=[1;7;3;4;5];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>CS>J>AS>Cons>HW';
prio(k).cast=[1;2;3;4;6;5];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>CS>AS>J>Cons>HW';
prio(k).cast=[1;2;4;3;6;5];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>AS>CS>J>Cons>HW';
prio(k).cast=[1;4;2;3;6;5];
prio(k).cond={'hopo>=3';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';};

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>SotR>CS>J>Cons>HW';
prio(k).cast=[4;1;2;3;6;5];
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';};

k=k+1;
prio(k)=prio(1);
prio(k).name='SD>SotR>CS>J>AS>Cons>HW';
prio(k).cast=[3;1;2;3;4;6;5];
prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0'; ...
              'ccd.HW<=0'};
%           
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>SotR>CS>J>AS>HW>Cons';
% prio(k).cast=[3;1;2;3;4;5;6];
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.AS<=0';...
%               'ccd.HW<=0';...
%               'ccd.Cons<=0';};
% 
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>SotR>CS>AS>J8>Cons>HW';
% prio(k).cast=[3;1;2;4;3;6;5];
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.AS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.Cons<=0';...
%               'ccd.HW<=0';};
% 
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>SotR>CS>AS>J9>Cons>HW';
% prio(k).cds(3)=9;
% prio(k).cast=[3;1;2;4;3;6;5];
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.AS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.Cons<=0';...
%               'ccd.HW<=0';};
% 
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>SotR>AS>CS>J>Cons>HW';
% prio(k).cast=[3;1;4;2;3;6;5];
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.AS<=0';...
%               'ccd.CS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.Cons<=0';...
%               'ccd.HW<=0';};
% 
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>AS>SotR>CS>J>Cons>HW';
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'ccd.AS<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.Cons<=0';...
%               'ccd.HW<=0';};
% prio(k).cast=[3;4;1;2;3;6;5];
% 
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='AS>SD>SotR>CS>J>Cons>HW';
% prio(k).cast=[4;3;1;2;3;6;5];
% prio(k).cond={'ccd.AS<=0';...
%               'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'ccd.CS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.Cons<=0';...
%               'ccd.HW<=0';};
% 
% 
% k=k+1;
% prio(k)=prio(1);
% prio(k).name='SD>SotR>2SDSotR>CS>J>AS>Cons>HW';
% prio(k).cast=[3;1;8;2;3;4;6;5];
% prio(k).cond={'hopo>=3 && ccd.Jud<=0 && dur.SD<=0';...
%               'hopo>=3';...
%               'hopo>=2 && dur.SD>0';...
%               'ccd.CS<=0';...
%               'ccd.Jud<=0';...
%               'ccd.AS<=0';...
%               'ccd.Cons<=0';...
%               'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>CS>J>AS>Cons>HW';
prio(k).cast=[9;2;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='2SotR*>Inq>CS>AS>J>Cons>HW';
prio(k).cast=[8;9;2;4;3;6;5];
prio(k).cond={'hopo>=2 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>J>AS>Cons>HW';
prio(k).cast=[1;9;2;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>J2>AS>Cons>HW';
prio(k).cast=[1;9;2;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>Inq>HotR>J2>AS>Cons>HW';
prio(k).cast=[1;9;7;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SDSotR*>Inq>HotR>J2>AS>Cons>HW';
prio(k).cast=[1;9;7;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0 && dur.SD>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SDSotR*>Inq*>HotR>J2>AS>Cons>HW';
prio(k).cast=[1;9;7;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0 && dur.SD>0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>SDSotR>Inq*>HotR>J2>AS>Cons>HW';
prio(k).cast=[1;1;9;7;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.SD>0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>AS>J>Cons>HW';
prio(k).cast=[1;9;2;4;3;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>AS*>J>Cons>HW';
prio(k).cast=[1;9;2;4;3;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.AS<=0 && dur.Inq>0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR*>Inq>HotR>AS>J>Cons>HW';
prio(k).cast=[1;9;7;4;3;6;5];
prio(k).cond={'hopo>=3 && dur.Inq>0';...
              'hopo>=3 && dur.Inq<=1';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>SotR>2SDSotR>CS>J>AS>Cons>HW';
prio(k).cast=[9;1;8;2;3;4;6;5];
prio(k).cond={'hopo>=3 && dur.Inq<=1';...
              'hopo>=3';...
              'hopo>=2 && dur.SD>0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

        
k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>CS>J>AS>HoW>Cons>HW';
prio(k).cast=[1;2;3;4;10;6;5];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.HoW<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>CS>J>HoW>AS';
prio(k).cast=[1;2;3;10;4];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.HoW<=0';...
              'ccd.AS<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>CS>HoW>J>AS';
prio(k).cast=[1;2;10;3;4];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.HoW<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>CS>HoW>AS>J>Cons>HW';
prio(k).cast=[1;2;10;4;3;6;5];
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.HoW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>SotR*>CS>HoW>J2>AS';
prio(k).cast=[9;1;2;10;3;4];
prio(k).cond={'hopo>=3 && dur.Inq<=1';...
              'hopo>=3 && dur.Inq>0';...
              'ccd.CS<=0';...
              'ccd.HoW<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>SotR*>HotR>HoW>J2>AS';
prio(k).cast=[9;1;7;10;3;4];
prio(k).cond={'hopo>=3 && dur.Inq<=1';...
              'hopo>=3 && dur.Inq>0';...
              'ccd.CS<=0';...
              'ccd.HoW<=0';...
              'ccd.Jud<=0 && hopo>1';...
              'ccd.AS<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HoW>CS>J>AS>Cons>HW';
prio(k).cast=[1;10;2;3;4;6;5];
prio(k).cond={'hopo>=3';...
              'ccd.HoW<=0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};

k=k+1;
prio(k)=prio(1);
prio(k).name='HoW>SotR>CS>J>AS>Cons>HW';
prio(k).cond={'ccd.HoW<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[10;1;2;3;4;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='HoW>Inq>SotR*>CS>J>AS>Cons>HW';
prio(k).cond={'ccd.HoW<=0';...
              'hopo>=3 && dur.Inq<=1';...
              'hopo>=3 && dur.Inq>0';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[10;9;1;2;3;4;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='HoW>CS>SotR>J>AS';
prio(k).cast=[10;2;1;3;4];
prio(k).cond={'ccd.HoW<=0';...
              'ccd.CS<=0';...
              'hopo>=3';...
              'ccd.Jud<=0';...
              'ccd.AS<=0'};

k1=k;
%end Single-Target queues

%% AoE Queues

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>J>AS>Cons>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;7;3;4;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>AS>J>Cons>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;7;4;3;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>AS>Cons>J>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.Jud<=0';...
              'ccd.HW<=0'};
prio(k).cast=[1;7;4;6;3;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>AS>Cons>HW>J';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;4;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>Cons>AS>HW>J';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;6;4;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>Cons>HW>AS>J';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;6;5;4;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>HotR>HW>Cons>AS>J';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;7;5;6;4;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='SotR>AS>HotR>Cons>HW>J';
prio(k).cond={'hopo>=3';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[1;4;7;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>SotR>HotR>Cons>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;1;7;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>HotR>SotR>Cons>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'ccd.CS<=0';...
              'hopo>=3';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;7;1;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>HotR>Cons>SotR>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;7;6;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>AS>Cons>SotR>HW>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[7;4;6;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Cons>AS>SotR>HW>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[7;6;4;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Cons>HW>AS>SotR>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.Jud<=0'};
prio(k).cast=[7;6;5;4;1;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Cons>HotR>AS>SotR>HW>J';
prio(k).cond={'ccd.Cons<=0';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[6;7;4;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Cons>AS>HotR>SotR>HW>J';
prio(k).cond={'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'hopo>=3';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[6;4;7;1;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Cons>HW>AS>HotR>SotR>J';
prio(k).cond={'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'hopo>=3';...
              'ccd.Jud<=0'};
prio(k).cast=[6;5;4;7;1;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq*>HotR>J>AS>Cons>HW';
prio(k).cond={'hopo>=3';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[9;7;3;4;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>J>AS>Cons>HW';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Jud<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0'};
prio(k).cast=[9;7;3;4;6;5];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>AS>Cons>HW>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[9;7;4;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>AS>HW>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[9;7;6;4;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>HW>AS>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[9;7;6;5;4;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>HW>Cons>AS>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.HW<=0';...
              'ccd.Cons<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[9;7;5;6;4;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>HW>AS>J>Inq*';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'hopo>=3'};
prio(k).cast=[9;7;6;5;4;3;9];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>HW>AS>J>Inq**';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'hopo>=1'};
prio(k).cast=[9;7;6;5;4;3;9];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Inq>Cons>HW>AS>J';
prio(k).cond={'ccd.CS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[7;9;6;5;4;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Inq>Cons>HW>AS>J>Inq*';
prio(k).cond={'ccd.CS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'hopo>=3'};
prio(k).cast=[7;9;6;5;4;3;9];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Inq>Cons>HW>AS>J>Inq**';
prio(k).cond={'ccd.CS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'ccd.Jud<=0';...
              'hopo>=1'};
prio(k).cast=[7;9;6;5;4;3;9];


k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Inq>AS>Cons>HW>J>Inq*';
prio(k).cond={'ccd.CS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0';...
              'hopo>=3'};
prio(k).cast=[7;9;4;6;5;3;9];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Inq>AS>Cons>HW>J>Inq**';
prio(k).cond={'ccd.CS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0';...
              'hopo>=1'};
prio(k).cast=[7;9;4;6;5;3;9];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Cons>HW>AS>Inq>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.Jud<=0'};
prio(k).cast=[7;6;5;4;9;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>Cons>HW>AS>Inq>J>Inq**';
prio(k).cond={'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.AS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.Jud<=0';...
              'hopo>=1'};
prio(k).cast=[7;6;5;4;9;3;9];

k=k+1;
prio(k)=prio(1);
prio(k).name='HotR>AS>Cons>HW>Inq>J';
prio(k).cond={'ccd.CS<=0';...
              'ccd.AS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.Jud<=0'};
prio(k).cast=[7;4;6;5;9;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='Inq>AS>HotR>Cons>HW>J';
prio(k).cond={'hopo>=3 && dur.Inq<1.5';...
              'ccd.AS<=0';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[9;4;7;6;5;3];

k=k+1;
prio(k)=prio(1);
prio(k).name='AS>Inq>HotR>Cons>HW>J';
prio(k).cond={'ccd.AS<=0';...
              'hopo>=3 && dur.Inq<1.5';...
              'ccd.CS<=0';...
              'ccd.Cons<=0';...
              'ccd.HW<=0';...
              'ccd.Jud<=0'};
prio(k).cast=[4;9;7;6;5;3];

%#1 = SotR
%#2 = CS
%#3 = Jud
%#4 = AS
%#5 = HW
%#6 = Cons
%#7 = HotR
%#8 = 2SotR
%#9 = Inq
%#10= HoW

k2=k;

%create cast field from name field
for m=1:k2
    %find the '>' signs in the queue names, these are delimiters
    ind=[0 find(prio(m).name=='>') length(prio(m).name)+1];
    
    %for each spell name
    for l=1:length(ind)-1
        %get spell name
        tempstr=prio(m).name((ind(l)+1):(ind(l+1)-1));
        
        %check against the strings in prio.alabel
        prio(m).castbuild(l)=sum(strcmp(tempstr,prio(m).alabel).*(1:length(prio(m).alabel))');
        
        %if the spell isn't found, we'll have a zero here
        if prio(m).castbuild(l)==0
            %check against special identifiers
            if sum(strcmp(tempstr,{'SD','J8','J9','J2'}))
                prio(m).castbuild(l)=3; %Judgement
            elseif sum(strcmp(tempstr,{'2SDSotR','2SotR*'}))
                prio(m).castbuild(l)=8; %2ShoR
            elseif sum(strcmp(tempstr,{'Inq*','Inq**'}))
                prio(m).castbuild(l)=9; %Inq
            elseif sum(strcmp(tempstr,{'SotR*','SDSotR*','SDSotR'}))
                prio(m).castbuild(l)=1; %ShoR
            elseif sum(strcmp(tempstr,{'AS*'}))
                prio(m).castbuild(l)=4; %AS
            end
        end

        %if it's *still* zero, we have a problem
        if prio(m).castbuild(l)==0
            error(['Spell identifier check failed on ''' tempstr ''''])
        end

    end
    
    %debug check, this can be commented and/or removed once we're sure the
    %algorithm works properly
    if sum(prio(m).cast-prio(m).castbuild')~=0
        error('Mismatch between cast and castbuild')
    end
    
    prio(m).cast=prio(m).castbuild';
end

%pretty output for troubleshooting
clear prilist*
for m=1:k1
    prilist(m,:)=[ num2str(m,'%03.0f') ' ' prio(m).name repmat(' ',1,40-length(prio(m).name)-4)];
end

for m=(k1+1):k2
    prilist2(m+1-k1,:)=[ num2str(m,'%03.0f') ' ' prio(m).name repmat(' ',1,40-length(prio(m).name)-4)];
end