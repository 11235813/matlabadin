function  [actionPr, avgDuration, metadata] = memoized_fsm(rotation, mehit, rhit, consGlyph, egProcRate, sdProcRate, gcProcRate)
	global fsm_cache_actionPr;
	global fsm_cache_avgDuration;
	global fsm_cache_metadata;
	if consGlyph
		strConsGlyph = 'true';
	else
		strConsGlyph = 'false';
	end
	key = sprintf('fsmdata_%s_3_%0.4f_%0.4f_%s_%g_%g_%g', rotation, mehit, rhit, strConsGlyph(1), round(egProcRate./0.15), round(sdProcRate./0.25), round(gcProcRate./0.10));
    key = strrep(key,'_0.','_');
    key = strrep(key,'_1.0000','_0000');
	key = strrep(key, '.', '_');
	key = strrep(key, '>', '_');
	key = strrep(key, '*', 'star');
	key = strrep(key, '''', 'prime');
	if isfield(fsm_cache_actionPr, key)
		% warning('using cached result');
		actionPr = fsm_cache_actionPr.(key);
		avgDuration = fsm_cache_avgDuration.(key);
		metadata = fsm_cache_metadata.(key);
		return;
	end
	filename = strcat('data\\', key, '.csv');
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
				system('%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\csc.exe /o+ /debug- /out:fsm.exe RotationCalculator\Matlabadin\*.cs >nul 2>&1');
				% then overwrite with 64 bit if available
				system('%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\csc.exe /o+ /debug- /out:fsm.exe RotationCalculator\Matlabadin\*.cs >nul 2>&1');
				if exist(executable) ~= 2
					error('Please install version 4 of the .NET framework or mono. .NET 4 can be downloaded from: http://www.microsoft.com/downloads/en/details.aspx?FamilyID=5765d7a8-7722-4888-a970-ac39b33fd8ab&displaylang=en');
				end
			end			
		end
		commandToExecute = sprintf('%s "%s" 3 %s %f %f %f %f %f > %s', ...
			executable, rotation, strConsGlyph, mehit, rhit, egProcRate, sdProcRate, gcProcRate, filename);
		system(commandToExecute);
	end
	[actionPr, avgDuration, metadata] = load_fsm_csv(filename);
	% TODO: sanity check that file params match our args
	fsm_cache_actionPr.(key) = actionPr;
	fsm_cache_avgDuration.(key) = avgDuration;
	fsm_cache_metadata.(key) = metadata;
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