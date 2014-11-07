%% 6.0
clear

set = parseChatLog( 'wodbeta\L100_nightelf_monk.txt', 'SL1');
base.agi=1284;
base.raceStr=-4;
base.raceAgi=4;
base.str=622;
base.dodge=5; 
base.parry=3; 
base.block=0; 
base.mastery=17.6; %with 0 mastery rating
base.mast2block = 1;
base.agi2dodge=1/176.3760684;
base.str2parry=0;
%from Celestalon, warrior values
base.df=0.3;
base.pf=1.659;
base.bf=1;
base.vs=0.00665;
base.hs=1.422;

%%
disp(' ');
disp('##### Dodge Fit #####')
% dodgeFit
[dfit, dgof] = dodgeFit( set, base )

printFitValues(dfit,dgof);

disp(' ');
disp('##### Parry Fit #####')
[pfit, pgof] = parryFit( set, base)


printFitValues(pfit,pgof);
disp(' ');
