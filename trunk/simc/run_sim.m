function run_sim( sim )
%RUN_SIM constructs the command-line simc.exe call using the information
%passed in the "sim" structure

%% Simulation setup
% make sure path is appropriately terminated
if sim.path(length(sim.path)) ~= '\'; sim.path = [ sim.path '\' ]; end

%find current path so that player simc files can be loaded
if exist([sim.path 'rd\'],'dir') ~= 7
    %get current path
    s=what;
    sim.playerpath=s.path;
end

%% arguments 
sim.argstr = create_argument_string( sim );

%% player parameters
sim.playerstr = create_player_string( sim );

%% outputs
sim.outputstr = create_output_string( sim );

%%


% check that we're in the correct folder and that simc exists
if exist(sim.path,'dir') ~= 7 || exist(strcat(sim.path,sim.exe),'file') ~= 2
    error('SimC directory or executable cannot be found');
end

%% execute
system(strcat(sim.path,sim.exe,sim.argstr,sim.playerstr,sim.outputstr));

end

