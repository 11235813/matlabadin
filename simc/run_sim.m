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

%check for fullpaths field; if it doesn't exist, go find it.
if isfield(sim,'fullpaths')==0
    %construct simc fullpath
    sim=sf_construct_fullpaths(sim);
end
%% execute
system(char(strcat(sim.fullpaths.exe,{' '},sim.fullpaths.simc,{' '},sim.argstr,{'  > nul'})));

end

