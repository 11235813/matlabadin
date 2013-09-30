function [ success ] = sf_addsimc( outputfile, varargin )
%SF_SIMCADD Appends multiple simc component files to a single output file
% arguments: outputfile, inputfile1, inputfile2, inputfile3, ...
% outputs: success - boolean that represents success/failure

outfile = fopen(outputfile,'a');

for i=1:length(varargin)
   
    infile = fopen(varargin{i});
    
    current_line = fgets(infile);
    while ischar(current_line)
%         disp(current_line)
        fprintf(outfile,current_line);
        current_line=fgets(infile);
    end
    fclose(infile);
    
end

% terminate with newline
fprintf(outfile,'\n');

fclose(outfile);
success=true;


end

