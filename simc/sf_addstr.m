function [ success ] = sf_addstr( outputfile, varargin )
%SF_STRADD appends strings to the outputfile
% arguments: outputfile, string1, string2, string3, ...
% outputs: success, boolean success return

outfile = fopen(outputfile,'a');

for i=1:length(varargin)
   
    current_line = varargin{i};
    % as long as the line contains characters, 
    if ischar(current_line)
        % make sure all strings are newline terminated
        if ~strcmp(current_line(length(current_line)-[1 0]),'\n')
            current_line=strcat(current_line,'\n');
        end
        % append line to output file
        fprintf(outfile,current_line);
    end
    
end

fclose(outfile);
success=true;

end

