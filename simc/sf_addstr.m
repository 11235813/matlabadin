function [ success ] = sf_addstr( outputfile, varargin )
%SF_STRADD appends strings to the outputfile
% arguments: outputfile, string1, string2, string3, ...
% outputs: success, boolean success return

outfile = fopen(outputfile,'a');

for i=1:length(varargin)
   
    current_line = varargin{i};
    % as long as the line contains characters, 
    if ischar(current_line) && ~isempty(current_line)
        % append line to output file
        fprintf(outfile,current_line);
    end
    
end

% terminate with newline
fprintf(outfile,'\n');

%close file
fclose(outfile);
success=true;

end

