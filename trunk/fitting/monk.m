%% 5.4 PTR data provided by Taser

set = parseChatLog( 'data\Monk_54ptr_001.txt', 'monkstats');
base.agi=111;
base.str=95;
base.dodge=3;
base.parry=3+2+3; % 2% free from spec
base.agi2dodge=951.158596;
base.str2parry=10000;

%%
disp('##### Dodge Fit #####')
[dfit, dgof] = dodgeSurfaceFit( set, base )

printFitValues(dfit,dgof);

disp(' ');disp(' ');
disp('##### Parry Fit #####')
[pfit, pgof] = parrySurfaceFit( set, base )

printFitValues(pfit,pgof);
disp(' ');disp(' ');