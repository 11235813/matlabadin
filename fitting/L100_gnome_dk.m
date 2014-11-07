%% 6.0
clear

set = parseChatLog( 'wodbeta\L100_gnome_dk.txt', 'SL1');
base.agi=891;
base.raceStr=-5;
base.raceAgi=2;
base.str=1455;
base.dodge=5; % 2% free from spec
base.parry=3; 
base.block=3+10; % 10% free from Bastion of Defense
base.mastery=17.6; %with 0 mastery rating
base.mast2block = 0.5/2.2;
base.agi2dodge=0;
base.str2parry=1/176.3760684;
%from Celestalon, warrior values
base.hs=0.956;
base.df=1.659;
base.pf=0.634;
base.bf=1;
base.vs=0.00665;

%%
disp('###### Gnome Death Knight #####')
% disp('##### Dodge Fit #####')
[dfit, dgof] = dodgeFit( set, base )

printFitValues(dfit,dgof);

disp(' ');disp(' ');
% disp('##### Parry Fit #####')
[pfit, pgof] = parryFit( set, base )

printFitValues(pfit,pgof);