function  [actionPr, avgDuration, metadata] = memoized_fsm(rotation, mehit, rhit, consGlyph, egProcRate, sdProcRate, gcProcRate)
	global fsm_cache_actionPr;
	global fsm_cache_avgDuration;
	global fsm_cache_metadata;
	if consGlyph
		strConsGlyph = 'true';
	else
		strConsGlyph = 'false';
	end
	key = sprintf('fsmdata_%s_3_%f_%f_%s_%f_%f_%f', rotation, mehit, rhit, strConsGlyph, egProcRate, sdProcRate, gcProcRate);
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
	if exist(filename) != 2
		commandToExecute = sprintf('%s "%s" 3 %s %f %f %f %f %f > %s', ...
			'RotationCalculator\Matlabadin\bin\Release\Matlabadin.exe', ...
			rotation, strConsGlyph, mehit, rhit, egProcRate, sdProcRate, gcProcRate, filename);
		system(commandToExecute);
	end
	[actionPr, avgDuration, metadata] = load_fsm_csv(filename);
	% TODO: sanity check that file params match our args
	fsm_cache_actionPr.(key) = actionPr;
	fsm_cache_avgDuration.(key) = avgDuration;
	fsm_cache_metadata.(key) = metadata;
end
function [actionPr, avgDuration, metadata] = load_fsm_csv(filename)
	fid = fopen(filename, "rt");
	i = 1;
	metadata = {};
	while not(feof(fid))
		txt = fgetl(fid);
		rowEntry = strsplit(txt, ',', true);
		lineAction = rowEntry{1};
		lineTxtPr = rowEntry{2};
		linePr = str2double(lineTxtPr);
		if strcmp(lineAction, 'AvgDuration')
			avgDuration = linePr;
		elseif length(lineAction) > 6 && strcmp('Stats_', substr(lineAction, 1, 6))
			metadata.(lineAction) = lineTxtPr;
		elseif length(lineAction) > 6 && strcmp('Param_', substr(lineAction, 1, 6))
			metadata.(lineAction) = lineTxtPr;
		else
			actionPr{1, i} = lineAction;
			actionPr{2, i} = linePr;
			i = i + 1;
		end
	end
    fclose (fid);
end