function [generatedFile] = fsm_gen(rotation, mehitArray, rhitArray, consGlyph, egTalentPoints , sdTalentPoints, gcTalentPoints)
%fsm_gen calculates fsm for each mehit, rhit
% call memoized_fsm to return the actual fsm data

% check source timestamp
fsmFileMetadata = dir('fsm.exe');
if exist('fsm.exe') == 2 && fsmFileMetadata.datenum <= max(arrayfun(@(x) x.datenum, dir('RotationCalculator\Matlabadin\*.cs')))
	warning('Execuatable out of date: forcing full regeneration');
	delete('fsm.exe');
end
if exist('fsm.exe') ~= 2
	warning('Deleting data directory to ensure invalid data is not cached.');
	rmdir('data', 's');
	if exist('data') == 7
		error('Unable to delete data directory');
	end
	mkdir('data');
end

generatedFile = cell(length(mehitArray),1);
argfile = strcat('data\\fsm_gen_input_', num2str(ceil(rand.*1000000)), '.tmp');
argfid = fopen(argfile, 'w');
generationRequired = 0;
for i=1:length(mehitArray)
    mehit = mehitArray(i);
    if length(rhitArray) > 1
        rhit = rhitArray(i);
    else
        rhit = rhitArray;
    end
    rotationKey = rotation;
    rotationKey = strrep(rotationKey, '[', '');
    rotationKey = strrep(rotationKey, ']', '_');
    rotationKey = strrep(rotationKey, '.', '_');    
    rotationKey = strrep(rotationKey, '>=', 'ge');
    rotationKey = strrep(rotationKey, '<=', 'le');
    rotationKey = strrep(rotationKey, '==', 'eq');
    rotationKey = strrep(rotationKey, '=', 'eq');
    rotationKey = strrep(rotationKey, '<', 'lt');
    rotationKey = strrep(rotationKey, '>', '_');
    rotationKey = strrep(rotationKey, '*', 'star');
    rotationKey = strrep(rotationKey, '''', 'prime');
    rotationKey = strrep(rotationKey, '+', 'plus');
    optionsKey = sprintf('T%g%g%g_%0.5f_%0.5f', egTalentPoints , sdTalentPoints, gcTalentPoints, mehit, rhit);
    optionsKey = strrep(optionsKey,'_1.00000','_1_');
    optionsKey = strrep(optionsKey,'_0.','_');
    if consGlyph
        strConsGlyph = 'true';
        optionsKey = strcat(optionsKey, '_cons');
    else
        strConsGlyph = 'false';
    end
    dirname = strcat('data\\', rotationKey);
    filename = strcat(dirname, '\\', optionsKey, '.csv');
    % skip generation if the file already exists
    if exist(filename) ~= 2
        if exist(dirname) ~= 7
            mkdir(dirname);
        end
        % generate the data args
        egProcRate = 0.15 * egTalentPoints;
        gcProcRate = 0.10 * gcTalentPoints;
        sdProcRate = 0.25 * sdTalentPoints;
        fprintf(argfid, '%s 3 %s %f %f %f %f %f %s\n', ...
            rotation, strConsGlyph, mehit, rhit, sdProcRate, gcProcRate, egProcRate, filename);
        generationRequired = 1;
    end
    generatedFile{i} = filename;
end
fclose(argfid);
if generationRequired
    if exist('RotationCalculator') ~= 7
        pwd
        error('Please set your working directory to the matlabadin root');
    end
	if exist('fsm.exe') ~= 2
		% Attempt to compile
		% try 32 bit
		system('%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\csc.exe /o+ /debug- /out:fsm.exe RotationCalculator\Matlabadin\*.cs ');%>nul 2>&1');
		% then overwrite with 64 bit if available
		system('%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\csc.exe /o+ /debug- /out:fsm.exe RotationCalculator\Matlabadin\*.cs > nul 2>&1');
		if exist('fsm.exe') ~= 2
			error('Please install version 4 of the .NET framework or mono. .NET 4 can be downloaded from: http://www.microsoft.com/downloads/en/details.aspx?FamilyID=5765d7a8-7722-4888-a970-ac39b33fd8ab&displaylang=en');
		end
	end
    system(strcat('fsm.exe', ' < ', argfile));
end
delete(argfile);