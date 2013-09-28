function [ sim ] = run_sim( sim )
%RUN_SIM constructs the command-line simc.exe call using the information
%passed in the "sim" structure

%% Simulation setup
% make sure path is appropriately terminated
if sim.exe_path(length(sim.exe_path)) ~= '\' 
    sim.exe_path = [ sim.exe_path '\' ]; 
end

% find current path so that player simc files can be loaded
% \mdb\ is a potential matlab database path for the simc directory for
% later use. For now, it probably won't exist, so we wan tto grab the
% current directory, assuming that all of our files are in subfolders.
if exist([sim.exe_path '\mdb\'],'dir') ~= 7
    %get current path
    s=what;
    sim.pdb_path=s.path;
end

%% arguments 
sim.argstr = create_argument_string( sim );

%% player parameters
sim.playerstr = create_player_string( sim );

%% outputs
sim.outputstr = create_output_string( sim );

%%


% check that we're in the correct folder and that simc exists
if exist(sim.exe_path,'dir') ~= 7 || exist(strcat(sim.exe_path,sim.exe),'file') ~= 2
    error('SimC directory or executable cannot be found');
end

%% execute
system(strcat(sim.exe_path,sim.exe,sim.argstr,sim.playerstr,sim.outputstr));

end

