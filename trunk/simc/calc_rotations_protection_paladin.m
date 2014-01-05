clear sim
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
% sim.paths.exe='d:\simcraft\'
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
rotationpath=[sim.paths.pdb 'rotation\'];

%% set up the list of things we want to vary

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


%rotation_combinations is a list of shorthands that describe rotations
%collapsed for readability
rotation_combinations={...
    %basic stuff
    'CS>J>AS>Cons>HW';
    'CS>J>AS>HW>Cons';
    'CS+W0.35>J>AS>HW>Cons';
    'CSw>J>AS>HW>Cons';
    'CSw>AS>J>HW>Cons';
    'J>CSw>AS>HW>Cons';
    'J>AS>CSw>HW>Cons';
    'AS>J>CSw>HW>Cons';
    'AS>CSw>J>HW>Cons';
    'HotR>J>AS>HW>Cons';
    'AS+GC>CSw>J>AS>HW>Cons';
    'CSw>AS+GC>J>AS>HW>Cons';
    'CSw>AS+GC>J>AS>HW>Cons';
    'CSw>AS+GC>J>HW>AS>Cons';
    'CSw>AS+GC>J>HW>Cons>AS';
    %HoW
    'CSw>J>AS>HW>Cons>HoW';
    'CSw>J>AS>HW>HoW>Cons';
    'CSw>J>AS>HoW>HW>Cons';
    'CSw>J>HoW>AS>HW>Cons';
    'CSw>HoW>J>AS>HW>Cons';
    'HoW>CSw>J>AS>HW>Cons';
    %SS
    'CSw>J>AS>HW>HoW>Cons>SS';
    'CSw>J>AS>HW>HoW>SS+R1>Cons';
    'CSw>J>AS>HW>SS+R1>HoW>Cons';
    'CSw>J>AS>SS+R1>HW>HoW>Cons';
    'CSw>J>AS>SS+R1>HW>HoW>Cons>SS';
    'CSw>J>SS+R1>AS>HW>HoW>Cons';
    'CSw>SS+R1>J>AS>HW>HoW>Cons';
    'SS+R1>CSw>J>AS>HW>HoW>Cons';
    %ES
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
    
    %support talents in a hackneyed way    
    talent_combinations{i,:}='312232'; %#ok<SAGROW> %this is the default, necessary to support talent-based abilities
    if strfind(char(rotation_combinations(i,:)),'ES')
        talent_combiantions{i,6}='1';
    elseif strfind(char(rotation_combinations(i,:)),'LH')
        talent_combiantions{i,6}='2';        
    elseif strfind(char(rotation_combinations(i,:)),'HPr')
        talent_combiantions{i,6}='3';
    end
    if strfind(char(rotation_combinations(i,:)),'SS')
        talent_combiantions{i,3}='1';
    elseif strfind(char(rotation_combinations(i,:)),'EF')
        talent_combiantions{i,3}='2';        
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
    
    %rename simc file
    sim.simc=strcat('io\rotation_',rotation_filenames{i},'.simc');
    
    %set output filenames
    sim.output.html=strcat('io\rotation_',rotation_filenames{i},'.html');
    sim.output.output=strcat('io\rotation_',rotation_filenames{i},'.txt');
    
    %construct simc fullpath
    sim=sf_construct_fullpaths(sim);
    
    %if the txt output doesn't exist or is older than an important file, regenerate
    if ~exist(sim.fullpaths.output,'file') || sf_compare_fullpaths(sim.fullpaths) || REGEN_ALL
        
        %create simc file
        create_simc_file(sim);
               
        %run sim
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

%% Compile results into usefully-formatted table
addpath ./helper_func/
dt=DataTable();
dt{1,1}='Rotation';
dt{1,2}='DPS';
dt{1,3}='HPS';
dt{1,4}='DTPS';
dt{1,5}='TMI';
dt{1,6}='SotR';
for i=1:length(rotation_combinations)
   dt{1+i,1}=rotation_combinations{i};
   r=results(i);
   dt{1+i,2}=num2str(r.dps,'%6.0f');
   dt{1+i,3}=num2str(r.hps,'%6.0f');
   dt{1+i,4}=num2str(r.dtps,'%6.0f');
   dt{1+i,5}=num2str(r.tmi,'%6.1f');
   dt{1+i,6}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('Full List')
disp(['Max DPS Err: ' int2str(round(max([results.dps_error]))) ', Max DPS % Err: ' num2str(max([results.dps_pct_error]),'%2.2f') '%'])
disp(['Max TMI Err: ' num2str(max([results.tmi_error]),'%5.2f') ', Max TMI % Err: ' num2str(max([results.tmi_pct_error]),'%2.2f') '%'])
dt.toText()

% %% Compile short table of single-glyph results
% dts=DataTable();
% dts{1,1}='Glyph';
% dts{1,2}='DPS';
% dts{1,3}='Err';
% dts{1,4}='Delta';
% dts{1,5}='HPS';
% dts{1,6}='DTPS';
% dts{1,7}='TMI';
% dts{1,8}='SotR';
% for i=2:(1+length(glyph_pool))
%     %special formatting here, want some diffs
%     dts{i,1:2}=dt.getData(i,3:4); %Glyph, DPS
%     dts{i,3}=round(results(i).dps_error);
%     dts{i,4}=str2num(char(dts.getData(i,2)))-str2num(char(dts.getData(2,2))); %#ok<ST2NM>
%     dts{i,5:size(dts,2)}=dt.getData(i,5:size(dt,2));
% end
% 
% disp(' ')
% disp('Single-Glyph List')
% dts.toText()

if length(results)>10
%% Top 10 DPS rotations
[dps dpsindex]=sort([results.dps],'descend');
topDPS=dpsindex(1:10);

dpst=DataTable();
dpst{1,1:2}=dt.getData(1,1:2);
dpst{1,3}='Err';
dpst{1,4}='%Err';
dpst{1,5}='HPS';
dpst{1,6}='DTPS';
dpst{1,7}='TMI';
dpst{1,8}='SotR';
for i=1:length(topDPS)
    dpst{1+i,1:2}=dt.getData(1+topDPS(i),1:2);
    dpst{1+i,3}=round(results(topDPS(i)).dps_error);
    dpst{1+i,4}=[num2str(results(topDPS(i)).dps_pct_error,'%2.2f') '%'];
    dpst{1+i,5:8}=dt.getData(1+topDPS(i),3:6);
end

disp(' ')
disp('Top 10 DPS Combinations')
dpst.toText()

%% Lowest 10 TMI rotations
[tmi tmiindex]=sort([results.tmi],'ascend');
topTMI=tmiindex(1:10);

tmit=DataTable();
tmit{1,1:5}=dt.getData(1,1:5);
tmit{1,6}='Err';
tmit{1,7}='%Err';
tmit{1,8}='SotR';
for i=1:length(topTMI)
    tmit{1+i,1:5}=dt.getData(1+topTMI(i),1:5);
    tmit{1+i,6}=num2str(results(topTMI(i)).tmi_error,'%5.2f');
    tmit{1+i,7}=[num2str(results(topTMI(i)).tmi_pct_error,'%5.2f') '%'];
    tmit{1+i,8}=dt.getData(1+topTMI(i),6);
end

disp(' ')
disp('Lowest 10 TMI Combinations')
tmit.toText()
end

%% displays for blog

disp(' ')
disp('Full List')
disp(['Max DPS Err: ' int2str(round(max([results.dps_error]))) ', Max DPS % Err: ' num2str(max([results.dps_pct_error]),'%2.2f') '%'])
disp(['Max TMI Err: ' num2str(max([results.tmi_error]),'%5.2f') ', Max TMI % Err: ' num2str(max([results.tmi_pct_error]),'%2.2f') '%'])
dt.toBlog()
% 
% disp(' ')
% disp('Single-rotation List')
% dts.toBlog()
if length(results)>10
    
    disp(' ')
    disp('Top 10 DPS Rotations')
    dpst.toBlog()
    
    disp(' ')
    disp('Lowest 10 TMI Rotations')
    tmit.toBlog()
end

