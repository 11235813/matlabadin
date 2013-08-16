function run_sim( sim )
%RUN_SIM constructs the command-line simc.exe call using the information
%passed in the "sim" structure

%% Unpack sim structure
simc_path = sim.path;
if simc_path(length(simc_path)) ~= '\'; simc_path = [ simc_path '\' ]; end


%% arguments 
sim.arguments = create_argument_string( sim );

%% outputs
sim.outputs = create_output_string( sim );

%%


% check that we're in the correct folder and that simc exists
if exist(simc_path,'dir') ~= 7 || exist(strcat(simc_path,sim.exe),'file') ~= 2
    error('SimC directory or executable cannot be found');
end

%% execute
system(strcat(sim.path,sim.exe,sim.arguments,sim.outputs));

end

