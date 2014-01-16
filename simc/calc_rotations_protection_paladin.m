clear sim
fclose('all');
REGEN_ALL=true; %THIS REGENERATES ALL FILES - SET FALSE FOR CACHING

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
sim.paths.exe='g:\simulationcraft\'
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
rotationpath=[sim.paths.pdb 'rotation\'];

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
% define the rotation blocks we're interested in. 

%block 1 - basic tests of ability ordering
block.basic.rot={ 'CS>J>AS>Cons>HW';
                  'CS>J>AS>HW>Cons';
                  'CS+W0.35>J>AS>HW>Cons';
                  'CSw>J>AS>HW>Cons';
                  'CSw>AS>J>HW>Cons';
                  'J>CSw>AS>HW>Cons';
                  'J>AS>CSw>HW>Cons';
                  'AS>J>CSw>HW>Cons';
                  'AS>CSw>J>HW>Cons';
                  'HotR>J>AS>HW>Cons';
                  %vary AS+GC
                  'AS+GC>CSw>J>AS>HW>Cons';
                  'CSw>AS+GC>J>AS>HW>Cons';
                  'CSw>AS+GC>J>HW>AS>Cons';
                  'CSw>AS+GC>J>HW>Cons>AS';
                };
%use default glyphs            
block.basic.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
%use default talents
block.basic.talents='default.simc';
        
%block 2 - Execute Range tests
block.execute.rot={ ... %HoW
                    'CSw>J>AS>HW>Cons>HoW';
                    'CSw>J>AS>HW>HoW>Cons';
                    'CSw>J>AS>HoW>HW>Cons';
                    'CSw>J>HoW>AS>HW>Cons';
                    'CSw>HoW>J>AS>HW>Cons';
                    'HoW>CSw>J>AS>HW>Cons';
                    % Final Wrath glyph
                    'CSw>J>HW+FW>AS>HW>HoW>Cons';
                    'CSw>HW+FW>J>AS>HW>HoW>Cons';
                    'HW+FW>CSw>J>AS>HW>HoW>Cons';
                  };
block.execute.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
block.execute.talents='default.simc';

%block 3 - Defensive stuff (SS mostly)
block.defensive.rot={ ... %SS
                      'CSw>J>AS>HW>HoW>Cons>SS';
                      'CSw>J>AS>HW>HoW>SS+R1>Cons';
                      'CSw>J>AS>HW>SS+R1>HoW>Cons';
                      'CSw>J>AS>SS+R1>HW>HoW>Cons';
                      'CSw>J>AS>SS+R1>HW>HoW>Cons>SS';
                      'CSw>J>SS+R1>AS>HW>HoW>Cons';
                      'CSw>SS+R1>J>AS>HW>HoW>Cons';
                      'SS+R1>CSw>J>AS>HW>HoW>Cons';
                    };  
block.defensive.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
block.defensive.talents='custom'; %see simc building stage
                
%block 4 - L90 talents
block.talents.rot={ ... %ES
                    'CSw>J>AS>HW>HoW>Cons>ES';
                    'CSw>J>AS>HW>HoW>ES>Cons';
                    'CSw>J>AS>HW>ES>HoW>Cons';
                    'CSw>J>AS>ES>HW>HoW>Cons';
                    'CSw>J>ES>AS>HW>HoW>Cons';
                    'CSw>ES>J>AS>HW>HoW>Cons';
                    'ES>CSw>J>AS>HW>HoW>Cons';
                    %LH
                    'CSw>J>AS>HW>HoW>Cons>LH';
                    'CSw>J>AS>HW>HoW>LH>Cons';
                    'CSw>J>AS>HW>LH>HoW>Cons';
                    'CSw>J>AS>LH>HW>HoW>Cons';
                    'CSw>J>LH>AS>HW>HoW>Cons';
                    'CSw>LH>J>AS>HW>HoW>Cons';
                    'LH>CSw>J>AS>HW>HoW>Cons';
                    %HPr
                    'CSw>J>AS>HW>HoW>Cons>HPr';
                    'CSw>J>AS>HW>HoW>HPr>Cons';
                    'CSw>J>AS>HW>HPr>HoW>Cons';
                    'CSw>J>AS>HPr>HW>HoW>Cons';
                    'CSw>J>HPr>AS>HW>HoW>Cons';
                    'CSw>HPr>J>AS>HW>HoW>Cons';
                    'HPr>CSw>J>AS>HW>HoW>Cons';
                   };  
block.talents.glyphs='focused_shield/word_of_glory/final_wrath'; %FS/WoG/FW
block.talents.talents='custom'; %see simc building stage
          

% ==================== Part 3 ==========================
% Build a single list for each component that we can loop through simply 

%rotation_combinations is a list of shorthands that describe rotations
%collapse for readability
rotation_combinations=[block.basic.rot; ...
                        block.execute.rot; ...
                        block.defensive.rot; ...
                        block.talents.rot;];

%glyph_combinations is the list of glyphs for each rotation
glyph_combinations=[cellstr(repmat(block.basic.glyphs,length(block.basic.rot),1));...
                    cellstr(repmat(block.execute.glyphs,length(block.execute.rot),1));...
                    cellstr(repmat(block.defensive.glyphs,length(block.defensive.rot),1));...
                    cellstr(repmat(block.talents.glyphs,length(block.talents.rot),1));];

%talent_combinatiosn is the talent configuration for each rotation
talent_combinations=[cellstr(repmat(block.basic.talents,length(block.basic.rot),1));...
                     cellstr(repmat(block.execute.talents,length(block.execute.rot),1));...
                     cellstr(repmat(block.defensive.talents,length(block.defensive.rot),1));...
                     cellstr(repmat(block.talents.talents,length(block.talents.rot),1));];                   

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
    if strcmp(talent_combinations{i},'custom')
        %reset to default
        temp_talents='312232'; %TODO: grab this from default?
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

%block 1
dtb1=DataTable();
dtb1{1,1}='Rotation';
dtb1{1,2}='DPS';
dtb1{1,3}='err';
dtb1{1,4}='HPS';
dtb1{1,5}='DTPS';
dtb1{1,6}='TMI';
dtb1{1,7}='err';
dtb1{1,8}='SotR';
for i=1:length(block.basic.rot)
   dtb1{1+i,1}=block.basic.rot{i};
   r=results(i);
   dtb1{1+i,2}=num2str(r.dps,'%6.0f');
   dtb1{1+i,3}=num2str(r.dps_error,'%6.0f');
   dtb1{1+i,4}=num2str(r.hps,'%6.0f');
   dtb1{1+i,5}=num2str(r.dtps,'%6.0f');
   dtb1{1+i,6}=num2str(r.tmi,'%6.1f');
   dtb1{1+i,7}=num2str(r.tmi_error,'%6.1f');
   dtb1{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('Basic Rotations')
dtb1.toText()

%block 2
dtb2=DataTable();
dtb2{1,1}='Rotation';
dtb2{1,2}='DPS';
dtb2{1,3}='err';
dtb2{1,4}='HPS';
dtb2{1,5}='DTPS';
dtb2{1,6}='TMI';
dtb2{1,7}='err';
dtb2{1,8}='SotR';
for i=1:length(block.execute.rot)
   dtb2{1+i,1}=block.execute.rot{i};
   r=results(length(block.basic.rot)+i);
   dtb2{1+i,2}=num2str(r.dps,'%6.0f');
   dtb2{1+i,3}=num2str(r.dps_error,'%6.0f');
   dtb2{1+i,4}=num2str(r.hps,'%6.0f');
   dtb2{1+i,5}=num2str(r.dtps,'%6.0f');
   dtb2{1+i,6}=num2str(r.tmi,'%6.1f');
   dtb2{1+i,7}=num2str(r.tmi_error,'%6.1f');
   dtb2{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('Execute Rotations')
dtb2.toText()

%block 3
dtb3=DataTable();
dtb3{1,1}='Rotation';
dtb3{1,2}='DPS';
dtb3{1,3}='err';
dtb3{1,4}='HPS';
dtb3{1,5}='DTPS';
dtb3{1,6}='TMI';
dtb3{1,7}='err';
dtb3{1,8}='SotR';
for i=1:length(block.defensive.rot)
   dtb3{1+i,1}=block.defensive.rot{i};
   r=results(length(block.basic.rot)+length(block.defensive.rot)+i);
   dtb3{1+i,2}=num2str(r.dps,'%6.0f');
   dtb3{1+i,3}=num2str(r.dps_error,'%6.0f');
   dtb3{1+i,4}=num2str(r.hps,'%6.0f');
   dtb3{1+i,5}=num2str(r.dtps,'%6.0f');
   dtb3{1+i,6}=num2str(r.tmi,'%6.1f');
   dtb3{1+i,7}=num2str(r.tmi_error,'%6.1f');
   dtb3{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('Defensive Rotations')
dtb3.toText()

%block 4
dtb4=DataTable();
dtb4{1,1}='Rotation';
dtb4{1,2}='DPS';
dtb4{1,3}='err';
dtb4{1,4}='HPS';
dtb4{1,5}='DTPS';
dtb4{1,6}='TMI';
dtb4{1,7}='err';
dtb4{1,8}='SotR';
for i=1:length(block.talents.rot)
   dtb4{1+i,1}=block.talents.rot{i};
   r=results(length(block.basic.rot)+length(block.defensive.rot)+length(block.execute.rot)+i);
   dtb4{1+i,2}=num2str(r.dps,'%6.0f');
   dtb4{1+i,3}=num2str(r.dps_error,'%6.0f');
   dtb4{1+i,4}=num2str(r.hps,'%6.0f');
   dtb4{1+i,5}=num2str(r.dtps,'%6.0f');
   dtb4{1+i,6}=num2str(r.tmi,'%6.1f');
   dtb4{1+i,7}=num2str(r.tmi_error,'%6.1f');
   dtb4{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('L90 Talent Rotations')
dtb4.toText()

%% displays for blog

disp(' ')
disp('Basic Rotations')
dtb1.toBlog()
disp(' ')
disp('Execute Rotations')
dtb2.toBlog()
disp(' ')
disp('Defensive Rotations')
dtb3.toBlog()
disp(' ')
disp('L90 Talent Rotations')
dtb4.toBlog()
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

