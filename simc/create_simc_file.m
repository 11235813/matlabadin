function sim = create_simc_file( sim )
%CREATE_SIMC_FILE constructs a complete simc file based on the contents of
%the "sim" structure passed as the sole argument. Returns modified sim
%output argument

%% File-related maintenance stuff
% sanity check - make sure that we actually have a filename
if ~isfield(sim,'simc') || isempty(sim.simc)
    error('create_simc_file called on sim object containing no simc file name');
end

% make sure path is appropriately terminated
sim.exe_path = path_terminate(sim.exe_path);

%check to see if we've defined a custom player database path
if ~isfield(sim,'pdb_path') || exist(sim.pdb_path,'dir')~=7
    %if not, check to see if there's a folder in the simc exe path
    if exist([sim.exe_path '\pdb\'],'dir') == 7
        sim.pdb_path=[sim.exe_path '\pdb\'];
    else
        %otherwise get current path, assume we're in matlab \wow\simc\ 
        s=what;
        sim.pdb_path=s.path;
    end
end

% make sure path is appropriately terminated
sim.pdb_path = path_terminate(sim.pdb_path);

%if there's no simc path defined, use the pdb path
if ~isfield(sim,'in_path') || isempty(sim.in_path) || exist(sim.in_path,'dir')~=7
    sim.in_path=sim.pdb_path;
end

%make sure path is appropriately terminated
sim.in_path=path_terminate(sim.in_path);

%combine in_path and simc file name to get full path
fullpath=[sim.in_path sim.simc];

% open file, clearing existing contents
fid=fopen(fullpath,'w');
fclose(fid);

%% general settings
sf_addstr(fullpath,'#General Simulation Settings');

%% player definition
sf_addstr(fullpath,'#Player Definition');

%% action priority list
sf_addstr(fullpath,'#Action Priority List');

%% gear
sf_addstr(fullpath,'#Gear');


end

