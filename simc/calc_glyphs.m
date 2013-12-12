clear sim
fclose('all');
REGEN_ALL=false; %THIS REGENERATES ALL FILES - SET FALSE FOR CACHING

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Glyph Simulation';
sim.iterations=50000; %min 50, lower causes crashes w/ release versions
sim.threads=4;
sim.gear='T16N.simc';
sim.boss='T16N25.simc';
% sim.paths.exe='d:\simcraft\'
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
glyphpath=[sim.paths.pdb 'glyphs\'];

%% set up the list of things we want to vary
glyph_pool={'';'alabaster_shield';'avenging_wrath';'battle_healer';'devotion_aura';'divine_protection';'final_wrath';'focused_shield';'harsh_words';'immediate_truth';'word_of_glory'};
glyph_abbr={'E';'AS';'AW';'BH';'DA';'DP';'FW';'FS';'HW';'IT';'WoG'};
glyph_combinations=cellstr('');
glyph_abbreviated=cellstr('E_E_E');

%this part creates every possible combination of the glyph pool
cell_index=2;
%first, single glyph combos
for i=2:(length(glyph_pool))
       %glyph combinations is the string that gets fed to simc
       glyph_combinations{cell_index}=glyph_pool{i};
       %glyph_abbreviated is the short version
       glyph_abbreviated{cell_index}=strcat('E_E_',glyph_abbr{i});
       %increment cell index
       cell_index=cell_index+1;   
end
%then multiple glyph combos
for i=1:(length(glyph_pool)-1)
    for j=(i+1):(length(glyph_pool))
        for k=(j+1):length(glyph_pool)
            %glyph_combinations is the string that gets fed to simc
            glyph_combinations{cell_index}=...
                strcat(glyph_pool{i},'/',glyph_pool{j},'/',glyph_pool{k}); 
            %glyph_abbreviated is the short version
            glyph_abbreviated{cell_index}=strcat(glyph_abbr{i},'_',glyph_abbr{j},'_',glyph_abbr{k});
            %increment cell index
            cell_index=cell_index+1;
        end
    end
end


%% create the talent .simc files we need
for i=1:length(glyph_combinations)
    glyph_files{i}=create_simc_component(['glyphs=' glyph_combinations{i}],glyphpath,glyph_abbreviated{i});  %#ok<SAGROW>
end

%% crank through them
clear results tempresults

%preallocate results
results=repmat(sf_extract('dummy'),size(glyph_combinations,1),1);

%waitbar
W=waitbar(0,'Simulating');
tic
for i=1:length(glyph_combinations); 
    
    waitbar(i/length(glyph_combinations),W,['Simulating ' num2str(100*i/length(glyph_combinations),'%2.1f') '%']);
    
    %set talent file
    sim.glyphs=glyph_files{i};
    
    %rename simc file
    sim.simc=strcat('io\glyph_',glyph_abbreviated{i},'.simc');
    
    %set output filenames
    sim.output.html=strcat('io\glyph_',glyph_abbreviated{i},'.html');
    sim.output.output=strcat('io\glyph_',glyph_abbreviated{i},'.txt');
    
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
dt{1,1}='G1';
dt{1,2}='G2';
dt{1,3}='G3';
dt{1,4}='DPS';
dt{1,5}='HPS';
dt{1,6}='DTPS';
dt{1,7}='TMI';
dt{1,8}='SotR';
for i=1:length(glyph_combinations)
   names=regexp(glyph_abbreviated{i},'(?<g1>\w+)_(?<g2>\w+)_(?<g3>\w+)','names');
   dt{1+i,1}=names.g1;
   dt{1+i,2}=names.g2;
   dt{1+i,3}=names.g3;
   r=results(i);
   dt{1+i,4}=num2str(r.dps,'%6.0f');
   dt{1+i,5}=num2str(r.hps,'%6.0f');
   dt{1+i,6}=num2str(r.dtps,'%6.0f');
   dt{1+i,7}=num2str(r.tmi,'%6.1f');
   dt{1+i,8}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('Full List')
disp(['Max DPS Err: ' int2str(round(max([results.dps_error]))) ', Max DPS % Err: ' num2str(max([results.dps_pct_error]),'%2.2f') '%'])
disp(['Max TMI Err: ' num2str(max([results.tmi_error]),'%5.2f') ', Max TMI % Err: ' num2str(max([results.tmi_pct_error]),'%2.2f') '%'])
dt.toText()

%% Compile short table of single-glyph results
dts=DataTable();
dts{1,1}='Glyph';
dts{1,2}='DPS';
dts{1,3}='Err';
dts{1,4}='Delta';
dts{1,5}='HPS';
dts{1,6}='DTPS';
dts{1,7}='TMI';
dts{1,8}='SotR';
for i=2:(1+length(glyph_pool))
    %special formatting here, want some diffs
    dts{i,1:2}=dt.getData(i,3:4); %Glyph, DPS
    dts{i,3}=round(results(i).dps_error);
    dts{i,4}=str2num(char(dts.getData(i,2)))-str2num(char(dts.getData(2,2))); %#ok<ST2NM>
    dts{i,5:size(dts,2)}=dt.getData(i,5:size(dt,2));
end

disp(' ')
disp('Single-Glyph List')
dts.toText()

%% Top 10 DPS glyph combinations
[dps dpsindex]=sort([results.dps],'descend');
topDPS=dpsindex(1:10);

dpst=DataTable();
dpst{1,1:4}=dt.getData(1,1:4);
dpst{1,5}='Err';
dpst{1,6}='%Err';
dpst{1,7}='HPS';
dpst{1,8}='DTPS';
dpst{1,9}='TMI';
dpst{1,10}='SotR';
for i=1:length(topDPS)
    dpst{1+i,1:4}=dt.getData(1+topDPS(i),1:4);
    dpst{1+i,5}=round(results(topDPS(i)).dps_error);
    dpst{1+i,6}=[num2str(results(topDPS(i)).dps_pct_error,'%2.2f') '%'];
    dpst{1+i,7:10}=dt.getData(1+topDPS(i),5:8);
end

disp(' ')
disp('Top 10 DPS Combinations')
dpst.toText()

%% Lowest 10 TMI combinations
[tmi tmiindex]=sort([results.tmi],'ascend');
topTMI=tmiindex(1:10);

tmit=DataTable();
tmit{1,1:7}=dt.getData(1,1:7);
tmit{1,8}='Err';
tmit{1,9}='%Err';
tmit{1,10}='SotR';
for i=1:length(topTMI)
    tmit{1+i,1:7}=dt.getData(1+topTMI(i),1:7);
    tmit{1+i,8}=num2str(results(topTMI(i)).tmi_error,'%5.2f');
    tmit{1+i,9}=[num2str(results(topTMI(i)).tmi_pct_error,'%5.2f') '%'];
    tmit{1+i,10}=dt.getData(1+topTMI(i),8);
end

disp(' ')
disp('Lowest 10 TMI Combinations')
tmit.toText()


%% displays for blog

disp(' ')
disp('Full List')
disp(['Max DPS Err: ' int2str(round(max([results.dps_error]))) ', Max DPS % Err: ' num2str(max([results.dps_pct_error]),'%2.2f') '%'])
disp(['Max TMI Err: ' num2str(max([results.tmi_error]),'%5.2f') ', Max TMI % Err: ' num2str(max([results.tmi_pct_error]),'%2.2f') '%'])
dt.toBlog()

disp(' ')
disp('Single-Glyph List')
dts.toBlog()

disp(' ')
disp('Top 10 DPS Combinations')
dpst.toBlog()

disp(' ')
disp('Lowest 10 TMI Combinations')
tmit.toBlog()

