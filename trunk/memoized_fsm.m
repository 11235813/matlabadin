function  [actionPr, metadata, ssUptime, efUptime, wbUptime, sbUptime, gcdUptime] = memoized_fsm(rotation, mehit, sphit)
    global fsm_cache_actionPr;
    global fsm_cache_efUptime;
    global fsm_cache_ssUptime;
    global fsm_cache_wbUptime;
    global fsm_cache_sbUptime;
    global fsm_cache_gcdUptime;
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
		fsm_cache_ssUptime = {};
		fsm_cache_efUptime = {};
        fsm_cache_wbUptime = {};
		fsm_cache_sbUptime = {};
        fsm_cache_gcdUptime= {};
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
    rotationKey = strrep(rotationKey, '^', 'up');
    optionsKey = sprintf('T%g_%0.5f_%0.5f', fsm_steps_per_gcd(), mehit, sphit);
    optionsKey = strrep(optionsKey,'_1.00000','_1_');
    optionsKey = strrep(optionsKey,'_0.','_');
    % check memory cache
    if isfield(fsm_cache_actionPr, rotationKey) && isfield(fsm_cache_actionPr.(rotationKey), optionsKey)
        % warning('using cached result');
        actionPr = fsm_cache_actionPr.(rotationKey).(optionsKey);
        metadata = fsm_cache_metadata.(rotationKey).(optionsKey);
        ssUptime = fsm_cache_ssUptime.(rotationKey).(optionsKey);
        efUptime = fsm_cache_efUptime.(rotationKey).(optionsKey);
        wbUptime = fsm_cache_wbUptime.(rotationKey).(optionsKey);
        sbUptime = fsm_cache_sbUptime.(rotationKey).(optionsKey);
        gcdUptime = fsm_cache_gcdUptime.(rotationKey).(optionsKey);
        return;
    end
    fileCell = fsm_gen(rotation, mehit, sphit);
    filename = fileCell{1};
    % read from the data file
    [actionPr, metadata, ssUptime, efUptime, wbUptime, sbUptime, gcdUptime] = load_fsm_csv(filename);
    % TODO: sanity check that file params match our args
    fsm_cache_actionPr.(rotationKey).(optionsKey) = actionPr;
    fsm_cache_metadata.(rotationKey).(optionsKey) = metadata;
    fsm_cache_ssUptime.(rotationKey).(optionsKey) = ssUptime;
    fsm_cache_efUptime.(rotationKey).(optionsKey) = efUptime;
    fsm_cache_wbUptime.(rotationKey).(optionsKey) = wbUptime;
    fsm_cache_sbUptime.(rotationKey).(optionsKey) = sbUptime;
    fsm_cache_gcdUptime.(rotationKey).(optionsKey) = gcdUptime;
end
function [actionPr, metadata, ssUptime, efUptime, wbUptime, sbUptime, gcdUptime] = load_fsm_csv(filename)
    addpath .\helper_func\
	fid = fopen(filename, 'rt');
	i = 1;
	metadata = {};
	while not(feof(fid))
		txt = fgetl(fid);
		rowEntry = strsplit(txt, ',');
		lineAction = rowEntry{1};
		lineTxtPr = rowEntry{2};
		linePr = str2double(lineTxtPr);
		if strcmp(lineAction, 'Uptime_SacredShield')
            ssUptime = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame')
            efUptime = linePr;
        elseif strcmp(lineAction, 'Uptime_WeakenedBlows')
            wbUptime = linePr;
        elseif strcmp(lineAction, 'Uptime_SotRShieldBlock')
            sbUptime = linePr;
        elseif strcmp(lineAction, 'Uptime_GCD')
            gcdUptime = linePr;
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