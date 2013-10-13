function sim = util_check_pdb_path( sim )
%UTIL_CHECK_PDB_PATH checks for the default pdb path and replaces it with
%something sensible if it hasn't been defined yet


%check to see if we've defined a custom player database path
if ~isfield(sim.paths,'pdb') || exist(sim.paths.pdb,'dir')~=7
    %if not, check to see if there's a folder in the simc exe path
    if exist([sim.paths.exe '\pdb\'],'dir') == 7
        sim.paths.pdb=[sim.paths.exe '\pdb\'];
    else
        %otherwise get current path, assume we're in matlab \wow\simc\ 
        s=what;
        sim.paths.pdb=s.path;
    end
end

% make sure path is appropriately terminated
sim.paths.pdb = path_terminate(sim.paths.pdb);

end