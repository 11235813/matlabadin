function sim = sf_construct_fullpaths( sim )
%CONSTRUCT_FULLPATHS constructs the full paths for the relevant simc file
%names needed to determine whether the data needs to be regenerated.  It
%returns a modified "sim" structure, updating various path entries and
%adding a "fullpaths" structure containing fields:
% .simc   - the simc input file fullpath
% .exe    - the simc executable fullpath
% .output - the text output of the simulation
% .html   - the html output of the simulation
% .default.* - the paths to the default pdb files

% sanity check - make sure that we actually have a filename
if ~isfield(sim,'simc') || isempty(sim.simc)
    error('create_simc_file called on sim object containing no simc file name');
end

% make sure exe path is appropriately terminated
sim.paths.exe = path_terminate(sim.paths.exe);

%check to see if we've defined a custom player database path
sim = util_check_pdb_path(sim);

%if there's no simc (input) path defined, use the pdb path
if ~isfield(sim.paths,'input') || isempty(sim.paths.input) || exist(sim.paths.input,'dir')~=7
    sim.paths.input=sim.paths.pdb;
end

%make sure simc (input) path is appropriately terminated
sim.paths.input=path_terminate(sim.paths.input);

%combine paths.input and simc file name to get full path
fullpath.simc=strcat(sim.paths.input,sim.simc);

%combine paths.exe and exe file name to get full path
fullpath.exe=strcat(sim.paths.exe,sim.exe);

%combine paths.output and output file names
if isempty(sim.paths.output)
    s=what;
    sim.paths.output=path_terminate(s.path);
end
fullpath.output=strcat(sim.paths.output,sim.output.output);

fullpath.html=strcat(sim.paths.output,sim.output.html);

%combine paths.pdb with individual components to get full paths
fullpath.player=strcat(sim.paths.pdb,'player\',sim.player);
fullpath.glyphs=strcat(sim.paths.pdb,'glyphs\',sim.glyphs);
fullpath.talents=strcat(sim.paths.pdb,'talents\',sim.talents);
fullpath.rotation=strcat(sim.paths.pdb,'rotation\',sim.rotation);
fullpath.precombat=strcat(sim.paths.pdb,'rotation\',sim.precombat);

% also construct paths to default pdb files; not sure if needed anymore
fullpath.default.glyphs=strcat(sim.paths.pdb,'glyphs\default.simc');
fullpath.default.player=strcat(sim.paths.pdb,'player\default.simc');
fullpath.default.rotation=strcat(sim.paths.pdb,'rotation\default.simc');
fullpath.default.precombat=strcat(sim.paths.pdb,'rotation\precombat.simc');
fullpath.default.talents=strcat(sim.paths.pdb,'talents\default.simc');

% store the fullpath structure within sim for future reference
sim.fullpaths=fullpath;
end
