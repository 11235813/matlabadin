clear
fclose('all');
REGEN_ALL=false; %THIS REGENERATES ALL FILES - SET FALSE FOR CACHING

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Rotation Simulation';
sim.iterations=50000; %min 50, lower causes crashes w/ release versions
sim.threads=4;
sim.gear='T16N.simc';
sim.boss='T16N25.simc';
sim.class='paladin';
sim.spec='protection';
% sim.paths.exe='g:\simulationcraft\'
sim.paths.exe='d:\simcraft\simc-542-2-built\';
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
rotationpath=[sim.paths.pdb 'rotation\'];

%get default talents from default.simc
fid=fopen('.\talents\default.simc');
line=fgetl(fid);
default_talents=char(regexp(line,'\d*','match'));

%% set up the list of things we want to vary

%this is arbuably the most complicated automation file. Since there are a
%number of cases where rotation depends on glyph and talent choices, we
%need to be able to change talents and glyphs on-the-fly as well. This
%makes structuring this file somewhat of a pain in the ass.

%the convention I've decided to go with is to split the rotations into
%logical blocks to test different aspects of the rotation. Each block can
%have a different default set of glyphs and talents in order to accommodate
%the aspects we're analyzing. In addition, we can apply contextual tweaks
%based on the rotation in question (for example, a rotation with "ES" in it
%would automatically switch to the Execution Sentence talent).

%this is hilariously awful in terms of complexity, but unfortunately it's
%all but necessary if we want to be thorough. 

% ==================== Part 1 ==========================
% define default/common APL stuff. Anything that we want in every sim goes here.

%define the default header - ideally this would be done via a file
simc_rotation_header={'actions=/auto_attack'
'actions+=/blood_fury'
'actions+=/berserking'
'actions+=/arcane_torrent'
'actions+=/avenging_wrath'
'actions+=/holy_avenger,if=talent.holy_avenger.enabled'
'actions+=/divine_protection'
'actions+=/guardian_of_ancient_kings'};

%define finsihers - will deal with these in another sim
simc_rotation_finishers={'actions+=/eternal_flame,if=talent.eternal_flame.enabled&(buff.eternal_flame.remains<2&buff.bastion_of_glory.react>2&(holy_power>=3|buff.divine_purpose.react))'
'actions+=/shield_of_the_righteous,if=holy_power>=5|buff.divine_purpose.react|incoming_damage_1500ms>=health.max*0.3'};

% ==================== Part 2 ==========================
% define the rotation groups we're interested in. 

%group 1 - basic tests of ability ordering
group.basic.rot={ 'CS>J>AS>Cons>HW';
                  'CS>J>AS>HW>Cons';
                  'CS+W0.3>J>AS>HW>Cons';
                  'CSw>J>AS>Cons>HW';
                  'CSw>Jw>AS>Cons>HW';
                  'CSw>Jw>AS>HW>Cons';
                  'CSw>Jw>AS+W0.35>HW+W0.35>Cons';
                  'CSw>J>HW>AS>Cons';
                  'CSw>HW>J>AS>Cons';
                  'HW>CSw>J>AS>Cons';
                  'CSw>AS>J>HW>Cons';
                  'J>CSw>AS>HW>Cons';
                  'J>AS>CSw>HW>Cons';
                  'AS>J>CSw>HW>Cons';
                  'AS>CSw>J>HW>Cons';
                  'HotR+W0.35>J>AS>HW>Cons';
                  %vary AS+GC
                  'AS+GC>CSw>J>AS>HW>Cons';
                  'CSw>AS+GC>J>AS>HW>Cons';
                  'CSw>AS+GC>J>HW>AS>Cons';
                  'CSw>AS+GC>J>HW>Cons>AS';
                };
%use default glyphs            
group.basic.glyphs='focused_shield/word_of_glory'; %FS/WoG/FW
%use default talents
group.basic.talents=default_talents;
        
%group 2 - Execute Range tests
group.execute.rot={ ... %HoW
                    'CSw>J>AS>HW>Cons>HoW';
                    'CSw>J>AS>HW>HoW>Cons';
                    'CSw>J>AS>HoW>HW>Cons';
                    'CSw>J>HoW>AS>HW>Cons';
                    'CSw>HoW>J>AS>HW>Cons';
                    'HoW>CSw>J>AS>HW>Cons';
                    % Final Wrath glyph
                    'CSw>J>HW+FW>AS>HW>HoW>Cons';
                    'CSw>J>AS+GC>HW+FW>AS>HW>HoW>Cons';
                    'CSw>HW+FW>J>AS>HW>HoW>Cons';
                    'HW+FW>CSw>J>AS>HW>HoW>Cons';
                  };
group.execute.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
group.execute.talents=default_talents;

%group 3 - Defensive stuff (SS mostly)
group.defensive.rot={ ... %SS
                      'CSw>J>AS>HW>HoW>Cons>SS';
                      'CSw>J>AS>HW>HoW>SS+R1>Cons';
                      'CSw>J>AS>HW>HoW>SS+R1>Cons>SS';
                      'CSw>J>AS>HW>SS+R1>HoW>Cons>SS';
                      'CSw>J>AS>SS+R1>HW>HoW>Cons';
                      'CSw>J>AS>SS+R1>HW>HoW>Cons>SS';
                      'CSw>J>AS+GC>SS+R1>AS>HW>HoW>Cons>SS';
                      'CSw>J>AS>SS+R2>HW>HoW>Cons>SS';
                      'CSw>J>AS>SS+R3>HW>HoW>Cons>SS';
                      'CSw>J>AS>SS+R4>HW>HoW>Cons>SS';
                      'CSw>J>AS>SS+R5>HW>HoW>Cons>SS';
                      'CSw>J>AS+GC>SS+R1>AS>HW>HoW>Cons';
                      'CSw>J>SS+R1>AS>HW>HoW>Cons';
                      'CSw>SS+R1>J>AS>HW>HoW>Cons';
                      'SS+R1>CSw>J>AS>HW>HoW>Cons';
                    };  
group.defensive.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
group.defensive.talents=default_talents;group.defensive.talents(3)='3';
                
%group 4 - L90 talents
group.talents.rot={ ... %ES
                    'CSw>J>AS>HW>HoW>Cons>ES';
                    'CSw>J>AS>HW>HoW>ES>Cons';
                    'CSw>J>AS>HW>ES>HoW>Cons';
                    'CSw>J>AS>HW+FW>ES>HW>HoW>Cons';
                    'CSw>J>AS>ES>HW>HoW>Cons';
                    'CSw>J>ES>AS>HW>HoW>Cons';
                    'CSw>ES>J>AS>HW>HoW>Cons';
                    'ES>CSw>J>AS>HW>HoW>Cons';
                    'CSw>J>AS>ES+ex>HW>ES>HoW>Cons';
                    'CSw>J>AS+GC>HW>AS>ES>HoW>Cons';
                    'CSw>J>AS+GC>HW+FW>AS>HW>ES>HoW>Cons';
                    %LH
                    'CSw>J>AS>HW>HoW>Cons>LH';
                    'CSw>J>AS>HW>HoW>LH>Cons';
                    'CSw>J>AS>HW>LH>HoW>Cons';
                    'CSw>J>AS>HW+FW>LH>HW>HoW>Cons';
                    'CSw>J>AS>LH>HW>HoW>Cons';
                    'CSw>J>LH>AS>HW>HoW>Cons';
                    'CSw>LH>J>AS>HW>HoW>Cons';
                    'LH>CSw>J>AS>HW>HoW>Cons';
                    'CSw>J>AS>LH+ex>HW>LH>HoW>Cons';
                    'CSw>J>AS+GC>HW>AS>LH>HoW>Cons';
                    'CSw>J>AS+GC>HW+FW>AS>HW>LH>HoW>Cons';
                    %HPr
                    'CSw>J>AS>HW>HoW>Cons>HPr';
                    'CSw>J>AS>HW>HoW>HPr>Cons';
                    'CSw>J>AS>HW>HPr>HoW>Cons';
                    'CSw>J>AS>HW+FW>HPr>HW>HoW>Cons';
                    'CSw>J>AS>HPr>HW>HoW>Cons';
                    'CSw>J>HPr>AS>HW>HoW>Cons';
                    'CSw>HPr>J>AS>HW>HoW>Cons';
                    'HPr>CSw>J>AS>HW>HoW>Cons';
                    'CSw>J>AS>HPr+ex>HW>HPr>HoW>Cons';
                    'CSw>J>AS+GC>HW>AS>HPr>HoW>Cons';
                    'CSw>J>AS+GC>HW+FW>AS>HW>HPr>HoW>Cons';
                   };  
group.talents.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
group.talents.talents=[default_talents '+custom']; %see simc building stage
          

% ==================== Part 3 ==========================
% Build a single list for each component that we can loop through simply 

%rotation_combinations is a list of shorthands that describe rotations
%collapse for readability
rotation_combinations=[group.basic.rot; ...
                        group.execute.rot; ...
                        group.defensive.rot; ...
                        group.talents.rot;];

%glyph_combinations is the list of glyphs for each rotation
glyph_combinations=[cellstr(repmat(group.basic.glyphs,length(group.basic.rot),1));...
                    cellstr(repmat(group.execute.glyphs,length(group.execute.rot),1));...
                    cellstr(repmat(group.defensive.glyphs,length(group.defensive.rot),1));...
                    cellstr(repmat(group.talents.glyphs,length(group.talents.rot),1));];

%talent_combinatiosn is the talent configuration for each rotation
talent_combinations=[cellstr(repmat(group.basic.talents,length(group.basic.rot),1));...
                     cellstr(repmat(group.execute.talents,length(group.execute.rot),1));...
                     cellstr(repmat(group.defensive.talents,length(group.defensive.rot),1));...
                     cellstr(repmat(group.talents.talents,length(group.talents.rot),1));];                   

%rotation_filenames is the list of corresponding .simc filenames 
for i=1:length(rotation_combinations)
    rotation_filenames{i}=strcat(sim.class,'_',sim.spec,'_',strrep(char(rotation_combinations{i}),'>','_')); %#ok<SAGROW>
end
    

%% create the rotation .simc files we need
for i=1:length(rotation_combinations)
    
    %translate from shorthand to simc APL
    simc_rotation_core=util_translate_rotation(rotation_combinations(i,:),sim.class,sim.spec);
    
    %merge with header and finishers
    simc_rotation_strings=util_merge_simc_apls(simc_rotation_header,simc_rotation_finishers,simc_rotation_core);
    
    %create the rotation file
    rotation_files{i}=create_simc_component(simc_rotation_strings,rotationpath,rotation_filenames{i});  %#ok<SAGROW>
    
end
%replace all 'custom' entries in talent_combinations with numerics
for i=1:length(rotation_combinations)
    term=strfind(talent_combinations{i},'+custom');
    if term>0
        %reset to default
        temp_talents=talent_combinations{i}(1:(term-1));
        if strfind(rotation_combinations{i},'ES')
            temp_talents(6)='3'; %#ok<*SAGROW>
        elseif strfind(rotation_combinations{i},'LH')
            temp_talents(6)='2';
        elseif strfind(rotation_combinations{i},'HPr')
            temp_talents(6)='1';
        end
        if strfind(rotation_combinations{i},'SS')
            temp_talents(3)='3';
        elseif strfind(rotation_combinations{i},'EF')
            temp_talents(3)='2';
        end
        talent_combinations{i}=temp_talents;
    end
end

%% crank through them
clear results tempresults

%preallocate results
results=repmat(sf_extract('dummy'),size(rotation_combinations,1),1);

%waitbar
W=waitbar(0,'Simulating');
tic
for i=1:length(rotation_combinations); 
    
    waitbar(i/length(rotation_combinations),W,['Simulating ' num2str(100*i/length(rotation_combinations),'%2.1f') '%']);
    
    %set rotation file
    sim.rotation=rotation_files{i};
    
    %set talents
    sim.talents=talent_combinations{i};
    
    %set glyphs
    sim.glyphs=glyph_combinations{i};
    
    %rename simc file
    sim.simc=strcat('io\rotation_',rotation_filenames{i},'.simc');
    
    %set output filenames
    sim.output.html=strcat('io\rotation_',rotation_filenames{i},'.html');
    sim.output.output=strcat('io\rotation_',rotation_filenames{i},'.txt');
    
    %construct simc fullpath
    sim=sf_construct_fullpaths(sim);
    
    %if the txt output doesn't exist or is older than an important file, regenerate
    if ~exist(sim.fullpaths.output,'file') || sf_compare_fullpaths(sim.fullpaths) || REGEN_ALL
        
        %create simc file and run sim
        sim=run_sim(sim);
    end
    
    tempresults=sf_extract(sim.output.output);
    if tempresults.success
        results(i)=tempresults;
    else
        error(['Failure of sf_extract on ' sim.output.output])
    end
    pause(0.0001);
    
end
close(W)
toc
fclose all;

%% Compile results into usefully-formatted tables
addpath ./helper_func/


groupfields=fieldnames(group);

Lprev=0;
for j=1:length(groupfields)
    
    L=length(group.(char(groupfields(j))).rot);
    
    dtb=DataTable();
    dtb{1,1}='Rotation';
    dtb{1,2}='DPS';
    dtb{1,3}='HPS';
    dtb{1,4}='DTPS';
    dtb{1,5}='TMI';
    dtb{1,6}='Var';
    dtb{1,7}='SotR';
    dtb{1,8}='Wait';
    for i=1:L
        dtb{1+i,1}=group.(char(groupfields(j))).rot{i};
        r=results(Lprev+i);
        dtb{1+i,2}=num2str(r.dps,'%6.0f');
        dtb{1+i,3}=num2str(r.hps,'%6.0f');
        dtb{1+i,4}=num2str(r.dtps,'%6.0f');
        dtb{1+i,5}=num2str(r.tmi,'%6.0f');
        dtb{1+i,6}=num2str(r.tmi_error,'%6.0f');
        dtb{1+i,7}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
        dtb{1+i,8}=[num2str(r.waiting*100,'%2.1f') '%'];
    end
    
    %store DPS error for later use
    dt_dps_error=max([results(Lprev+[1:L]).dps_error]);
    eval(['dtb' int2str(j) '=dtb;']);
    clear dtb;
    disp(' ')
    disp([char(groupfields(j)) ' Rotations'])
    disp(['Max DPS Error: ' num2str(dt_dps_error,'%5.0f')])
    disp(['Talents: ' group.(char(groupfields(j))).talents])
    disp(['Glyphs: '  group.(char(groupfields(j))).glyphs])
    eval(['dtb' int2str(j) '.toText()'])

    Lprev=Lprev+L;
end


%% Blog Output
for j=1:length(groupfields)
    disp(' ')
    disp([char(groupfields(j)) ' Rotations'])
    disp(['Max DPS Error: ' num2str(dt_dps_error,'%5.0f')])
    disp(['Talents: ' group.(char(groupfields(j))).talents])
    disp(['Glyphs: '  group.(char(groupfields(j))).glyphs])
    eval(['dtb' int2str(j) '.toBlog()']);
end


%% Old group-specific code (depricated)

% %group 1
% dtb1=DataTable();
% dtb1{1,1}='Rotation';
% dtb1{1,2}='DPS';
% dtb1{1,3}='HPS';
% dtb1{1,4}='DTPS';
% dtb1{1,5}='TMI';
% dtb1{1,6}='err';
% dtb1{1,7}='SotR';
% dtb1{1,8}='Wait';
% for i=1:length(block.basic.rot)
%    dtb1{1+i,1}=block.basic.rot{i};
%    r=results(i);
%    dtb1{1+i,2}=num2str(r.dps,'%6.0f');
%    dtb1{1+i,3}=num2str(r.hps,'%6.0f');
%    dtb1{1+i,4}=num2str(r.dtps,'%6.0f');
%    dtb1{1+i,5}=num2str(r.tmi,'%6.1f');
%    dtb1{1+i,6}=num2str(r.tmi_error,'%6.1f');
%    dtb1{1+i,7}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
%    dtb1{1+i,8}=[num2str(r.waiting*100,'%2.1f') '%'];
% end
% 
% disp(' ')
% disp('Basic Rotations')
% disp(['Max DPS Error: ' num2str(max([results(1:length(block.basic.rot)).dps_error]),'%5.1f')])
% dtb1.toText()
% 
% %block 2
% dtb2=DataTable();
% dtb2{1,1}='Rotation';
% dtb2{1,2}='DPS';
% dtb2{1,3}='HPS';
% dtb2{1,4}='DTPS';
% dtb2{1,5}='TMI';
% dtb2{1,6}='err';
% dtb2{1,7}='SotR';
% dtb2{1,8}='Wait';
% for i=1:length(block.execute.rot)
%    dtb2{1+i,1}=block.execute.rot{i};
%    r=results(length(block.basic.rot)+i);
%    dtb2{1+i,2}=num2str(r.dps,'%6.0f');
%    dtb2{1+i,3}=num2str(r.hps,'%6.0f');
%    dtb2{1+i,4}=num2str(r.dtps,'%6.0f');
%    dtb2{1+i,5}=num2str(r.tmi,'%6.1f');
%    dtb2{1+i,6}=num2str(r.tmi_error,'%6.1f');
%    dtb2{1+i,7}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
%    dtb2{1+i,8}=[num2str(r.waiting*100,'%2.1f') '%'];
% end
% 
% disp(' ')
% disp('Execute Rotations')
% dtb2.toText()
% 
% %block 3
% dtb3=DataTable();
% dtb3{1,1}='Rotation';
% dtb3{1,2}='DPS';
% dtb3{1,3}='HPS';
% dtb3{1,4}='DTPS';
% dtb3{1,5}='TMI';
% dtb3{1,6}='err';
% dtb3{1,7}='SotR';
% dtb3{1,8}='Wait';
% for i=1:length(block.defensive.rot)
%    dtb3{1+i,1}=block.defensive.rot{i};
%    r=results(length(block.basic.rot)+length(block.execute.rot)+i);
%    dtb3{1+i,2}=num2str(r.dps,'%6.0f');
%    dtb3{1+i,3}=num2str(r.dps_error,'%6.0f');
%    dtb3{1+i,4}=num2str(r.hps,'%6.0f');
%    dtb3{1+i,5}=num2str(r.dtps,'%6.0f');
%    dtb3{1+i,6}=num2str(r.tmi,'%6.1f');
%    dtb3{1+i,7}=num2str(r.tmi_error,'%6.1f');
%    dtb3{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
%    dtb3{1+i,9}=[num2str(r.waiting*100,'%2.1f') '%'];
% end
% 
% disp(' ')
% disp('Defensive Rotations')
% dtb3.toText()
% 
% %block 4
% dtb4=DataTable();
% dtb4{1,1}='Rotation';
% dtb4{1,2}='DPS';
% dtb4{1,3}='err';
% dtb4{1,4}='HPS';
% dtb4{1,5}='DTPS';
% dtb4{1,6}='TMI';
% dtb4{1,7}='err';
% dtb4{1,8}='SotR';
% dtb4{1,9}='Wait';
% for i=1:length(block.talents.rot)
%    dtb4{1+i,1}=block.talents.rot{i};
%    r=results(length(block.basic.rot)+length(block.defensive.rot)+length(block.execute.rot)+i);
%    dtb4{1+i,2}=num2str(r.dps,'%6.0f');
%    dtb4{1+i,3}=num2str(r.dps_error,'%6.0f');
%    dtb4{1+i,4}=num2str(r.hps,'%6.0f');
%    dtb4{1+i,5}=num2str(r.dtps,'%6.0f');
%    dtb4{1+i,6}=num2str(r.tmi,'%6.1f');
%    dtb4{1+i,7}=num2str(r.tmi_error,'%6.1f');
%    dtb4{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
%    dtb4{1+i,9}=[num2str(r.waiting*100,'%2.1f') '%'];
% end
% 
% disp(' ')
% disp('L90 Talent Rotations')
% dtb4.toText()

%% Old displays for blog (depricated)
% 
% disp(' ')
% disp('Basic Rotations')
% dtb1.toBlog()
% disp(' ')
% disp('Execute Rotations')
% dtb2.toBlog()
% disp(' ')
% disp('Defensive Rotations')
% dtb3.toBlog()
% disp(' ')
% disp('L90 Talent Rotations')
% dtb4.toBlog()

%% Even Older
% 
% disp(' ')
% disp('Single-rotation List')
% dts.toBlog()
% if length(results)>10
%     
%     disp(' ')
%     disp('Top 10 DPS Rotations')
%     dpst.toBlog()
%     
%     disp(' ')
%     disp('Lowest 10 TMI Rotations')
%     tmit.toBlog()
% end

