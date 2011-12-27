function  [actionPr, metadata, inqUptime, jotwUptime] = memoized_fsm(rotation, mehit, rhit, consGlyph, egTalentPoints , sdTalentPoints, gcTalentPoints, t13x2R )
    global fsm_cache_actionPr;
    global fsm_cache_jotwUptime;
    global fsm_cache_inqUptime;
    global fsm_cache_metadata;
	% Check that we're not caching outdated mechanics
    if exist('RotationCalculator') ~= 7
        pwd
        error('Please set your working directory to the matlabadin root');
    end
	fsmFileMetadata = dir('fsm.exe');
    if exist('fsm.exe') == 2 && fsmFileMetadata.datenum <= max(arrayfun(@(x) x.datenum, dir('RotationCalculator\Matlabadin\*.cs')))
		warning('Flushing fsm memory cache');
		fsm_cache_actionPr = {};
        fsm_cache_metadata = {};
		fsm_cache_inqUptime = {};
		fsm_cache_jotwUptime = {};
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
    optionsKey = sprintf('T%g_%g%g%g_%0.5f_%0.5f', fsm_steps_per_gcd(), egTalentPoints , sdTalentPoints, gcTalentPoints, mehit, rhit);
    optionsKey = strrep(optionsKey,'_1.00000','_1_');
    optionsKey = strrep(optionsKey,'_0.','_');
    if consGlyph
        optionsKey = strcat(optionsKey, '_cons');
    end
    if t13x2R
        optionsKey = strcat(optionsKey, '_t13x2R');
    end
    % check memory cache
    if isfield(fsm_cache_actionPr, rotationKey) && isfield(fsm_cache_actionPr.(rotationKey), optionsKey)
        % warning('using cached result');
        actionPr = fsm_cache_actionPr.(rotationKey).(optionsKey);
        metadata = fsm_cache_metadata.(rotationKey).(optionsKey);
        inqUptime = fsm_cache_inqUptime.(rotationKey).(optionsKey);
        jotwUptime = fsm_cache_jotwUptime.(rotationKey).(optionsKey);
        return;
    end
    fileCell = fsm_gen(rotation, mehit, rhit, consGlyph, egTalentPoints, sdTalentPoints, gcTalentPoints, t13x2R);
    filename = fileCell{1};
    % read from the data file
    [actionPr, metadata, inqUptime, jotwUptime] = load_fsm_csv(filename);
    % TODO: sanity check that file params match our args
    fsm_cache_actionPr.(rotationKey).(optionsKey) = actionPr;
    fsm_cache_metadata.(rotationKey).(optionsKey) = metadata;
    fsm_cache_inqUptime.(rotationKey).(optionsKey) = inqUptime;
    fsm_cache_jotwUptime.(rotationKey).(optionsKey) = jotwUptime;
end
function [actionPr, metadata, inqUptime, jotwUptime] = load_fsm_csv(filename)
	fid = fopen(filename, 'rt');
	i = 1;
	metadata = {};
	while not(feof(fid))
		txt = fgetl(fid);
		rowEntry = strsplit(txt, ',');
		lineAction = rowEntry{1};
		lineTxtPr = rowEntry{2};
		linePr = str2double(lineTxtPr);
		if strcmp(lineAction, 'Uptime_Inq')
            inqUptime = linePr;
        elseif strcmp(lineAction, 'Uptime_JotW')
            jotwUptime = linePr;
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