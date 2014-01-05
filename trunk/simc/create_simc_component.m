function filename = create_simc_component( str, path, filename, force_replace )
%CREATE_SIMC_COMPONENT creates a .simc file containing the contents of the
%first argument.  This is for creating components that are swapped in and
%out during a sim.  The resulting simc file is stored in path\filename.

%% sanity checks
%needs 3 args
if nargin<3
    error('create_simc_component called with less than 3 arguments')
end
if nargin<4
    force_replace=false;
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

%% check to see if the file needs to be replaced
if ~force_replace
    replace=false;
    fid=fopen(fullpath,'r');
    if fid<0
        replace=true;
    else
        current_line=fgetl(fid); %purge simc header
        current_line=fgetl(fid);
        line_index=1;
        while ischar(current_line) || line_index<=length(str)
            if ( ischar(str) && ~strcmp(current_line,str(line_index,:)) ) || ...
                    ( iscell(str) && ~strcmp(current_line,str{line_index}) )
                replace=true;
                break
            end
            current_line=fgetl(fid);
            line_index=line_index+1;
        end
    end
end

if ~replace
    return
end


%% write file
% open file, clearing existing contents
fid=fopen(fullpath,'w');
sf_addstr(fullpath,'#!./simc');
fclose(fid);

% loop through str input and write each line
if ischar(str)    
    for i=1:size(str,1)
        sf_addstr(fullpath,str(i,:));
    end
    
elseif iscell(str)
    for i=1:length(str)
        sf_addstr(fullpath,str{i});
    end
    
else
    %what else is there?
end

end