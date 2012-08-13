function  [actionPr, metadata, uptime] = memoized_fsm(rotation, spec, talentString, glyphString, decimalHaste, mehit, sphit, pBuffs)
    global fsm_cache_actionPr;
    global fsm_cache_efUptime;
    global fsm_cache_ssUptime;
    global fsm_cache_wbUptime;
    global fsm_cache_sbUptime;
    global fsm_cache_awUptime;
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
		fsm_cache_awUptime = {};
        fsm_cache_gcdUptime= {};
    end
	
    [rotationKey spectalKey optionsKey]=fsm_key(rotation, spec, talentString, glyphString, decimalHaste, mehit, sphit, pBuffs);
    % check memory cache
    if isfield(fsm_cache_actionPr, rotationKey) && isfield(fsm_cache_actionPr.(rotationKey), spectalKey) && isfield(fsm_cache_actionPr.(rotationKey).(spectalKey), optionsKey)
        % warning('using cached result');
        actionPr = fsm_cache_actionPr.(rotationKey).(spectalKey).(optionsKey);
        metadata = fsm_cache_metadata.(rotationKey).(spectalKey).(optionsKey);
        uptime.ss = fsm_cache_ssUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef = fsm_cache_efUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.wb = fsm_cache_wbUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.sb = fsm_cache_sbUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.aw = fsm_cache_awUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.gcd = fsm_cache_gcdUptime.(rotationKey).(spectalKey).(optionsKey);
        return;
    end
    fileCell = fsm_gen(rotation, spec, talentString, glyphString, decimalHaste, mehit, sphit, pBuffs);
    filename = fileCell{1};
    % read from the data file
    [actionPr, metadata, uptime] = load_fsm_csv(filename);
    % TODO: sanity check that file params match our args
    fsm_cache_actionPr.(rotationKey).(spectalKey).(optionsKey) = actionPr;
    fsm_cache_metadata.(rotationKey).(spectalKey).(optionsKey) = metadata;
    fsm_cache_ssUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ss;
    fsm_cache_efUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef;
    fsm_cache_wbUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.wb;
    fsm_cache_sbUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.sb;
    fsm_cache_awUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.aw;
    fsm_cache_gcdUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.gcd;
end
function [actionPr, metadata, uptime] = load_fsm_csv(filename)
    addpath .\helper_func\
	fid = fopen(filename, 'rt');
	i = 1;
	metadata = {};
    uptime.ss=0;uptime.ef=0;uptime.wb=0;uptime.sb=0;uptime.aw=0;uptime.gcd=0; %initialize, otherwise the field ordering causes errors
	while not(feof(fid))
		txt = fgetl(fid);
		rowEntry = strsplit(txt, ',');
		lineAction = rowEntry{1};
		lineTxtPr = rowEntry{2};
		linePr = str2double(lineTxtPr);
		if strcmp(lineAction, 'Uptime_SacredShield')
            uptime.ss = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame')
            uptime.ef = linePr;
        elseif strcmp(lineAction, 'Uptime_WeakenedBlows')
            uptime.wb = linePr;
        elseif strcmp(lineAction, 'Uptime_SotRShieldBlock')
            uptime.sb = linePr;
        elseif strcmp(lineAction, 'Uptime_AvengingWrath')
            uptime.aw = linePr;
        elseif strcmp(lineAction, 'Uptime_GCD')
            uptime.gcd = linePr;
		elseif length(lineAction) > 6 && strcmp('Stats_', lineAction(1:6))
			metadata.(lineAction) = lineTxtPr;
		elseif length(lineAction) > 6 && strcmp('Param_', lineAction(1:6))
			metadata.(lineAction) = lineTxtPr;
		elseif length(lineAction) > 7 && strcmp('Uptime_', lineAction(1:7))
			metadata.(lineAction) = lineTxtPr;
		elseif length(lineAction) > 9 && strcmp('Warnings_', lineAction(1:9))
			metadata.(lineAction) = lineTxtPr;
		else
			actionPr{1, i} = lineAction;
			actionPr{2, i} = linePr;
			i = i + 1;
		end
    end
    fclose (fid);
end