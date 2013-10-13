function [ sim ] = run_sim( sim )
%RUN_SIM constructs the command-line simc.exe call using the information
%passed in the "sim" structure

%% create simc file
% this creates the file passed to simc.exe and does some sanity checks on
% path names
sim = create_simc_file( sim );

% check that we're in the correct folder and that simc exists
if exist(sim.paths.exe,'dir') ~= 7 || exist(strcat(sim.paths.exe,sim.exe),'file') ~= 2
    error('SimC directory or executable cannot be found');
end

%% execute
system(char(strcat(sim.paths.exe,sim.exe,{' '},sim.simc,{'  > nul'})));

end

