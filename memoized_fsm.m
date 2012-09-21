function  [actionPr, metadata, uptime] = memoized_fsm(rotation, spec, talentString, glyphString, mehaste, sphaste, mehit, sphit, pBuffs)
    global fsm_cache_actionPr;
    global fsm_cache_efUptime;
    global fsm_cache_ef0Uptime;
    global fsm_cache_ef1Uptime;
    global fsm_cache_ef2Uptime;
    global fsm_cache_ef3Uptime;
    global fsm_cache_ef4Uptime;
    global fsm_cache_ef5Uptime;
    global fsm_cache_ssUptime;
    global fsm_cache_wbUptime;
%     global fsm_cache_sbUptime;
    global fsm_cache_awUptime;
    global fsm_cache_gowog1Uptime;
    global fsm_cache_gowog2Uptime;
    global fsm_cache_gowog3Uptime;
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
		fsm_cache_ef0Uptime = {};
        fsm_cache_ef1Uptime = {};
        fsm_cache_ef2Uptime = {};
        fsm_cache_ef3Uptime = {};
        fsm_cache_ef4Uptime = {};
        fsm_cache_ef5Uptime = {};
        fsm_cache_wbUptime = {};
% 		fsm_cache_sbUptime = {};
		fsm_cache_awUptime = {};
        fsm_cache_gowog1Uptime = {};
        fsm_cache_gowog2Uptime = {};
        fsm_cache_gowog3Uptime = {};
        fsm_cache_gcdUptime= {};
    end
	
    [rotationKey spectalKey optionsKey]=fsm_key(rotation, spec, talentString, glyphString, mehaste, sphaste, mehit, sphit, pBuffs);
    % check memory cache
    if isfield(fsm_cache_actionPr, rotationKey) && isfield(fsm_cache_actionPr.(rotationKey), spectalKey) && isfield(fsm_cache_actionPr.(rotationKey).(spectalKey), optionsKey)
        % warning('using cached result');
        actionPr = fsm_cache_actionPr.(rotationKey).(spectalKey).(optionsKey);
        metadata = fsm_cache_metadata.(rotationKey).(spectalKey).(optionsKey);
        uptime.ss = fsm_cache_ssUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef = fsm_cache_efUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef0 = fsm_cache_ef0Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef1 = fsm_cache_ef1Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef2 = fsm_cache_ef2Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef3 = fsm_cache_ef3Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef4 = fsm_cache_ef4Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.ef5 = fsm_cache_ef5Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.wb = fsm_cache_wbUptime.(rotationKey).(spectalKey).(optionsKey);
%         uptime.sb = fsm_cache_sbUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.aw = fsm_cache_awUptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.gowog1 = fsm_cache_gowog1Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.gowog2 = fsm_cache_gowog2Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.gowog3 = fsm_cache_gowog3Uptime.(rotationKey).(spectalKey).(optionsKey);
        uptime.gcd = fsm_cache_gcdUptime.(rotationKey).(spectalKey).(optionsKey);
        return;
    end
    fileCell = fsm_gen(rotation, spec, talentString, glyphString, mehaste, sphaste, mehit, sphit, pBuffs);
    filename = fileCell{1};
    % read from the data file
    [actionPr, metadata, uptime] = load_fsm_csv(filename);
    % TODO: sanity check that file params match our args
    fsm_cache_actionPr.(rotationKey).(spectalKey).(optionsKey) = actionPr;
    fsm_cache_metadata.(rotationKey).(spectalKey).(optionsKey) = metadata;
    fsm_cache_ssUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ss;
    fsm_cache_efUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef;
    fsm_cache_ef0Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef0;
    fsm_cache_ef1Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef1;
    fsm_cache_ef2Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef2;
    fsm_cache_ef3Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef3;
    fsm_cache_ef4Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef4;
    fsm_cache_ef5Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.ef5;
    fsm_cache_wbUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.wb;
%     fsm_cache_sbUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.sb;
    fsm_cache_gowog1Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.gowog1;
    fsm_cache_gowog2Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.gowog2;
    fsm_cache_gowog3Uptime.(rotationKey).(spectalKey).(optionsKey) = uptime.gowog3;
    fsm_cache_awUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.aw;
    fsm_cache_gcdUptime.(rotationKey).(spectalKey).(optionsKey) = uptime.gcd;
end
function [actionPr, metadata, uptime] = load_fsm_csv(filename)
    addpath .\helper_func\
	fid = fopen(filename, 'rt');
	i = 1;
	metadata = {};
    uptime.ss=0;uptime.ef=0;uptime.ef0=0;uptime.ef1=0;uptime.ef2=0;uptime.ef3=0;uptime.ef4=0;uptime.ef5=0;
    uptime.wb=0;uptime.aw=0;uptime.gowog1=0;uptime.gowog2=0;uptime.gowog3=0;uptime.gcd=0; %initialize, otherwise the field ordering causes errors
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
        elseif strcmp(lineAction, 'Uptime_EternalFlame_Bog0')
            uptime.ef0 = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame_Bog1')
            uptime.ef1 = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame_Bog2')
            uptime.ef2 = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame_Bog3')
            uptime.ef3 = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame_Bog4')
            uptime.ef4 = linePr;
        elseif strcmp(lineAction, 'Uptime_EternalFlame_Bog5')
            uptime.ef5 = linePr;
        elseif strcmp(lineAction, 'Uptime_WeakenedBlows')
            uptime.wb = linePr;
%         elseif strcmp(lineAction, 'Uptime_SotRShieldBlock')
%             uptime.sb = linePr;
        elseif strcmp(lineAction, 'Uptime_AvengingWrath')
            uptime.aw = linePr;
        elseif strcmp(lineAction, 'Uptime_GlyphofWoG_1')
            uptime.gowog1 = linePr;
        elseif strcmp(lineAction, 'Uptime_GlyphofWoG_2')
            uptime.gowog2 = linePr;
        elseif strcmp(lineAction, 'Uptime_GlyphofWoG_3')
            uptime.gowog3 = linePr;
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