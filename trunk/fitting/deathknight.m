%% 5.4 PTR data provided by Taser

set = parseChatLog( 'data\DeathKnight_54ptr_002.txt', 'dkreport');
base.agi=131;
base.str=209;
base.dodge=5; % 2% free from spec
base.parry=3; 
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