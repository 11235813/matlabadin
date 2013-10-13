function filename = create_simc_component( str, path, filename )
%CREATE_SIMC_COMPONENT creates a .simc file containing the contents of the
%first argument.  This is for creating components that are swapped in and
%out during a sim.  The resulting simc file is stored in path\filename.

%% sanity checks
%needs 3 args
if nargin<3
    error('create_simc_component called with less than 3 arguments')
end

%make sure the path is properly terminated
path = path_terminate(path);

%make sure filename ends in .simc; if not, fix it
if length(filename)<5 || ~strcmp(filename(length(filename)-[4:-1:0]),'.simc')
    filename = strcat(filename,'.simc');
end

%% File name construction
%combine paths.input and simc file name to get full path
fullpath=[path filename];

%% write file
% open file, clearing existing contents
fid=fopen(fullpath,'w');
sf_addstr(fullpath,'#!./simc');
fclose(fid);

% loop through str input and write each line
for i=1:size(str,1)
    
    if ischar(str)
        sf_addstr(fullpath,str(i,:));
    elseif iscell(str)
        sf_addstr(fullpath,str{i});
    else
        %what else is there?
    end
end

end