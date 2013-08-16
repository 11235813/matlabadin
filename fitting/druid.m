%% 5.4 PTR data provided by Taser

set = parseChatLog( 'data\Druid_54ptr_001.txt', 'clreport');
base.agi=99;
base.str=100;
base.dodge=5; % 2% free from NE racial
base.parry=0; 
base.agi2dodge=951.158596;
base.str2parry=10000; %irrelevant for Druid

%%
disp('##### Dodge Fit #####')
[dfit, dgof] = dodgeSurfaceFit( set, base )

printFitValues(dfit,dgof);

disp(' ');disp(' ');
% disp('##### Parry Fit #####')
% [pfit, pgof] = parrySurfaceFit( set, base )
% 
% printFitValues(pfit,pgof);
% disp(' ');disp(' ');