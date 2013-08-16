%% 5.4 PTR data provided by Taser

set = parseChatLog( 'data\Warrior_54ptr_001.txt', 'warrreport');
base.agi=133;
base.str=206;
base.dodge=5; % 2% free from spec
base.parry=3; 
base.block=3+10; % 10% free from Bastion of Defense
base.mastery=17.6; %with 0 mastery rating
base.mast2block = 0.5/2.2;
base.agi2dodge=10000;
base.str2parry=951.158596;

%%
disp('##### Dodge Fit #####')
[dfit, dgof] = dodgeSurfaceFit( set, base )

printFitValues(dfit,dgof);

disp(' ');disp(' ');
disp('##### Parry Fit #####')
[pfit, pgof] = parrySurfaceFit( set, base )

printFitValues(pfit,pgof);
disp(' ');disp(' ');

disp('##### Block Fit #####')
[pfit, pgof] = blockFit( set, base )

printFitValues(pfit,pgof);
disp(' ');disp(' ');