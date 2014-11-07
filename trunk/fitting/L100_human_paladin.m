%% 6.0
clear

set = parseChatLog( 'wodbeta\L100_human_paladin.txt', 'SL1');
base.agi=891;
base.raceStr=0;
base.raceAgi=0;
base.str=1455;
base.dodge=5; % 2% free from spec
base.parry=3; 
base.block=3+10; % 10% free from Bastion of Defense
base.mastery=17.6; %with 0 mastery rating
base.mast2block = 1;
base.agi2dodge=0;
base.str2parry=1/176.3760684;
%from Celestalon, warrior values
base.hs=0.886;
base.df=2.259;
base.pf=0.634;
base.bf=1;
base.vs=0.00665;

%%
disp('###### Human Paladin #####')

disp(' ');
% disp('##### Dodge Fit #####')
% dodgeFit
[dfit, dgof] = dodgeFit( set, base )

printFitValues(dfit,dgof);

disp(' ');
% disp('##### Parry Fit #####')
[pfit, pgof] = parryFit( set, base)


printFitValues(pfit,pgof);
disp(' ');

% disp('##### Block Fit #####')
[bfit, bgof] = blockFit( set, base )

printFitValues(bfit,bgof);
disp(' ');disp(' ');

