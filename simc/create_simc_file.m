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
sim.paths.exe = path_terminate(sim.paths.exe);

%check to see if we've defined a custom player database path
sim = util_check_pdb_path(sim);

%if there's no simc path defined, use the pdb path
if ~isfield(sim.paths,'input') || isempty(sim.paths.input) || exist(sim.paths.input,'dir')~=7
    sim.paths.input=sim.paths.pdb;
end

%make sure path is appropriately terminated
sim.paths.input=path_terminate(sim.paths.input);

%combine paths.input and simc file name to get full path
fullpath=[sim.paths.input sim.simc];

% open file, clearing existing contents
fid=fopen(fullpath,'w');
sf_addstr(fullpath,'#!./simc');
sf_addstr(fullpath,sim.header);
fclose(fid);

%% general settings
sf_addstr(fullpath,'#General Simulation Settings');
sf_addstr(fullpath,'iterations=',int2str(sim.iterations));
sf_addstr(fullpath,'threads=',int2str(sim.threads));
if sim.ptr>0
    sf_addstr(fullpath,'ptr=',int2str(sim.ptr));
end

%% player definition
sf_addstr(fullpath,'#Player Definition');
% if the player field is a string
if ischar(sim.player)
    %figure out if it's a simc file definition 
    if length(sim.player)>5 && strcmp(sim.player(length(sim.player)-[4:-1:0]),'.simc')
        % if so, add the entire contents
        sf_addsimc(fullpath,[sim.paths.pdb 'player\' sim.player]);
    else
       % otherwise, just add the string normally
       sf_addstr(fullpath,sim.player);
    end
else
   %otherwise we have a structure containing the information we want
   %cycle through it and write each field as field=content
   for i=fields(sim.player)'
      sf_addstr(fullpath,i{1},'=',sim.player.(i{1}));
   end
end

%glyphs
if ischar(sim.glyphs)
    %figure out if it's a simc file definition 
    if length(sim.glyphs)>5 && strcmp(sim.glyphs(length(sim.glyphs)-[4:-1:0]),'.simc')
        % if so, add the entire contents
        sf_addsimc(fullpath,[sim.paths.pdb 'glyphs\' sim.glyphs]);
    else
       % otherwise, just add the string normally
       sf_addstr(fullpath,'glyphs=',sim.glyphs);
    end
else
   %otherwise we have a structure containing the information we want
   %cycle through it and write each field as field=content
   for i=fields(sim.glyphs)'
      sf_addstr(fullpath,i{1},'=',sim.glyphs.(i{1}));
   end
end

%talents
if ischar(sim.talents)
    %figure out if it's a simc file definition 
    if length(sim.talents)>5 && strcmp(sim.talents(length(sim.talents)-[4:-1:0]),'.simc')
        % if so, add the entire contents
        sf_addsimc(fullpath,[sim.paths.pdb 'talents\' sim.talents]);
    else
       % otherwise, just add the string normally
       sf_addstr(fullpath,'talents=',sim.talents);
    end
elseif isnumeric(sim.talents)
    sf_addstr(fullpath,'talents=',in2str(sim.talents));
else
    error('Unknown talent format in create_simc_file')
end

%% action priority list
sf_addstr(fullpath,'#Action Priority List');
% precombat field
if ischar(sim.precombat)
   if length(sim.precombat)>5 && strcmp(sim.precombat(length(sim.precombat)-[4:-1:0]),'.simc')
       sf_addsimc(fullpath,[sim.paths.pdb 'rotation\' sim.precombat]);
   else
       sf_addstr(fullpath,sim.precombat);
   end
else
    for i=fields(sim.precombat)'
        sf_addstr(fullpath,i{1},'=',sim.precombat.(i{1}));
    end
end

% APL field
if ischar(sim.rotation)
   if length(sim.rotation)>5 && strcmp(sim.rotation(length(sim.rotation)-[4:-1:0]),'.simc')
       sf_addsimc(fullpath,[sim.paths.pdb 'rotation\' sim.rotation]);
   else
       sf_addstr(fullpath,sim.rotation);
   end
else
    for i=fields(sim.rotation)'
        sf_addstr(fullpath,i{1},'=',sim.rotation.(i{1}));
    end
end

%% gear
sf_addstr(fullpath,'#Gear');
if ischar(sim.gear)
   if length(sim.gear)>5 && strcmp(sim.gear(length(sim.gear)-[4:-1:0]),'.simc')
       sf_addsimc(fullpath,[sim.paths.pdb 'gear\' sim.gear]);
   else
       sf_addstr(fullpath,sim.gear);
   end
else
    for i=fields(sim.gear)'
        sf_addstr(fullpath,i{1},'=',sim.gear.(i{1}));
    end
end

%% boss
sf_addstr(fullpath,'#Boss');
if ischar(sim.boss)
    if length(sim.boss)>5 && strcmp(sim.boss(length(sim.boss)-[4:-1:0]),'.simc')
       sf_addsimc(fullpath,[sim.paths.pdb 'boss\' sim.boss]);
   else
       sf_addstr(fullpath,sim.boss);
    end
else
    for i=fields(sim.boss)'
        sf_addstr(fullpath,i{1},'=',sim.boss.(i{1}));
    end    
end
%handles the optional target_health definition
if sim.target_health>0
    sf_addstr(fullpath,'target_health=',int2str(sim.target_health));
end

%% output
sf_addstr(fullpath,'#Outputs');
for i=fields(sim.output)'
    if ~isempty(sim.output.(i{1}))
        sf_addstr(fullpath,i{1},'=',sim.paths.output,sim.output.(i{1}));
    end
end

end

