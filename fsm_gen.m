function [generatedFile] = fsm_gen(rotation, mehitArray, rhitArray)
%fsm_gen calculates fsm for each mehit, rhit
% call memoized_fsm to return the actual fsm data

% check source timestamp
if exist('RotationCalculator') ~= 7
    pwd
    error('Please set your working directory to the matlabadin root');
end
fsmFileMetadata = dir('fsm.exe');
if exist('fsm.exe') == 2 && fsmFileMetadata.datenum <= max(arrayfun(@(x) x.datenum, dir('RotationCalculator\Matlabadin\*.cs')))
	warning('Execuatable out of date: forcing full regeneration');
	delete('fsm.exe');
end
if exist('fsm.exe') ~= 2 && exist('data') == 7
	warning('Deleting data directory to ensure invalid data is not cached.');
	rmdir('data', 's');
	if exist('data') == 7
		error('Unable to delete data directory');
    end
end
if exist('data') ~= 7
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
    optionsKey = sprintf('T%g_%0.5f_%0.5f', fsm_steps_per_gcd(), mehit, rhit);
    optionsKey = strrep(optionsKey,'_1.00000','_1_');
    optionsKey = strrep(optionsKey,'_0.','_');
    dirname = strcat('data\\', rotationKey);
    filename = strcat(dirname, '\\', optionsKey, '.csv');
    % skip generation if the file already exists
    if exist(filename) ~= 2
        if exist(dirname) ~= 7
            mkdir(dirname);
        end
                
        fprintf(argfid, '%s %g %f %f %s\n', ...
            rotation, fsm_steps_per_gcd(), mehit, rhit, filename);
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
    system(strcat('fsm.exe < ', argfile));
end
delete(argfile);