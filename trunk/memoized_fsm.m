function  [actionPr, avgDuration, metadata] = memoized_fsm(rotation, mehit, rhit, consGlyph, egTalentPoints , sdTalentPoints, gcTalentPoints )
	global fsm_cache_actionPr;
	global fsm_cache_avgDuration;
	global fsm_cache_metadata;
	rotationKey = rotation;
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
	% check memory cache
	if isfield(fsm_cache_actionPr, rotationKey) && isfield(fsm_cache_actionPr.(rotationKey), optionsKey)
		% warning('using cached result');
		actionPr = fsm_cache_actionPr.(rotationKey).(optionsKey);
		avgDuration = fsm_cache_avgDuration.(rotationKey).(optionsKey);
		metadata = fsm_cache_metadata.(rotationKey).(optionsKey);
		return;
	end
	% check disk cache
	if exist(filename) ~= 2
		if exist('RotationCalculator') ~= 7
			pwd
			error('Please set your working directory to the matlabadin root');
		end
		executable = 'RotationCalculator\Matlabadin\bin\Release\Matlabadin.exe';
		if exist(executable) ~= 2
			executable = 'fsm.exe';
			if exist(executable) ~= 2
				% Attempt to compile
				% try 32 bit
				system('%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\csc.exe /o+ /debug- /out:fsm.exe RotationCalculator\Matlabadin\*.cs ')%>nul 2>&1');
				% then overwrite with 64 bit if available
				system('%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\csc.exe /o+ /debug- /out:fsm.exe RotationCalculator\Matlabadin\*.cs >nul 2>&1');
				if exist(executable) ~= 2
					error('Please install version 4 of the .NET framework or mono. .NET 4 can be downloaded from: http://www.microsoft.com/downloads/en/details.aspx?FamilyID=5765d7a8-7722-4888-a970-ac39b33fd8ab&displaylang=en');
				end
			end			
		end
		if exist(dirname) ~= 7
			mkdir(dirname);
		end
		% generate the data file
		egProcRate = 0.15 * egTalentPoints;
		gcProcRate = 0.10 * gcTalentPoints;
		sdProcRate = 0.25 * sdTalentPoints;
		commandToExecute = sprintf('%s "%s" 3 %s %f %f %f %f %f > %s', ...
			executable, rotation, strConsGlyph, mehit, rhit, sdProcRate, gcProcRate, egProcRate, filename);
		system(commandToExecute);
	end
	% read from the data file
	[actionPr, avgDuration, metadata] = load_fsm_csv(filename);
	% TODO: sanity check that file params match our args
	fsm_cache_actionPr.(rotationKey).(optionsKey) = actionPr;
	fsm_cache_avgDuration.(rotationKey).(optionsKey) = avgDuration;
	fsm_cache_metadata.(rotationKey).(optionsKey) = metadata;
end
function [actionPr, avgDuration, metadata] = load_fsm_csv(filename)
	fid = fopen(filename, 'rt');
	i = 1;
	metadata = {};
	while not(feof(fid))
		txt = fgetl(fid);
		rowEntry = strsplit(txt, ',');
		lineAction = rowEntry{1};
		lineTxtPr = rowEntry{2};
		linePr = str2double(lineTxtPr);
		if strcmp(lineAction, 'AvgDuration')
			avgDuration = linePr;
		elseif length(lineAction) > 6 && strcmp('Stats_', lineAction(1:6))
			metadata.(lineAction) = lineTxtPr;
		elseif length(lineAction) > 6 && strcmp('Param_', lineAction(1:6))
			metadata.(lineAction) = lineTxtPr;
		else
			actionPr{1, i} = lineAction;
			actionPr{2, i} = linePr;
			i = i + 1;
		end
	end
    fclose (fid);
end