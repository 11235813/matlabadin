clear sim
fclose('all');
REGEN_ALL=false; %THIS REGENERATES ALL FILES - SET FALSE FOR CACHING

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Glyph Simulation';
sim.iterations=10;
sim.threads=4;
% sim.paths.exe='d:\simcraft\'
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
glyphpath=[sim.paths.pdb 'glyphs\'];

%% set up the list of things we want to vary
glyph_pool={'empty';'empty';'alabaster_shield';'battle_healer';'divine_protection';'final_wrath';'focused_shield';'word_of_glory'};
glyph_combinations=cellstr('empty/empty/empty');

%this part creates every possible combination of the glyph pool... crudely
cell_index=2;
for i=1:(length(glyph_pool)-2)
    for j=(i+1):(length(glyph_pool)-1)
        for k=(j+1):length(glyph_pool)
            glyph_combinations{cell_index}=...
                strcat(glyph_pool{i},'/',glyph_pool{j},'/',glyph_pool{k}); %#ok<SAGROW>
            cell_index=cell_index+1;
        end
    end
end


%% create the talent .simc files we need
for i=1:length(glyph_combinations)
    glyph_combo_helper{i}=strrep(glyph_combinations{i},'/','_');
    glyph_files{i}=create_simc_component(['glyphs=' glyph_combinations{i}],glyphpath,glyph_combo_helper{i});  %#ok<SAGROW>
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
    sim.simc=strcat('io\glyph_',glyph_combo_helper{i},'.simc');
    
    %set output filenames
    sim.output.html=strcat('io\glyph_',glyph_combo_helper{i},'.html');
    sim.output.output=strcat('io\glyph_',glyph_combo_helper{i},'.txt');
    
    %construct simc fullpath
    fullpath=sf_construct_fullpaths(sim);
    
    %if the txt output doesn't exist or is older than an important file, regenerate
    if ~exist(fullpath.output,'file') || sf_compare_fullpaths(fullpath) || REGEN_ALL
        
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
dt{1,1}='Glyph1';
dt{1,2}='Glyph2';
dt{1,3}='Glyph3';
dt{1,4}='DPS';
dt{1,5}='HPS';
dt{1,6}='DTPS';
dt{1,7}='TMI';
dt{1,8}='SotR';
for i=1:length(glyph_combinations)
   names=regexp(glyph_combinations{i},'(?<g1>\w+)/(?<g2>\w+)/(?<g3>\w+)','names');
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
dt.toText()

%% Compile short table of single-glyph results
dts=DataTable();
dts{1,1}='Glyph';
dts{1,2}='DPS';
dts{1,3}='dDPS';
dts{1,4}='HPS';
dts{1,5}='DTPS';
dts{1,6}='TMI';
dts{1,7}='SotR';
for i=2:length(glyph_pool)
    %special formatting here, want some diffs
    dts{i,1:2}=dt.getData(i,3:4); %Glyph, DPS
    dts{i,3}=str2num(char(dts.getData(i,2)))-str2num(char(dts.getData(2,2))); %#ok<ST2NM>
    dts{i,4:size(dts,2)}=dt.getData(i,5:size(dt,2));
end

disp(' ')
disp('Single-Glyph List')
dts.toText()

%% Top 10 DPS glyph combinations
[dps dpsindex]=sort([results.dps],'descend');
topDPS=dpsindex(1:10);

dpst=DataTable();
dpst{1,1:size(dt,2)}=dt.getData(1,1:size(dt,2));
for i=1:length(topDPS)
    dpst{1+i,1:size(dt,2)}=dt.getData(1+topDPS(i),1:size(dt,2));
end

disp(' ')
disp('Top 10 DPS specs')
dpst.toText()

%% Lowest 10 TMI combinations
[tmi tmiindex]=sort([results.tmi],'ascend');
topTMI=tmiindex(1:10);

tmit=DataTable();
tmit{1,1:size(dt,2)}=dt.getData(1,1:size(dt,2));
for i=1:length(topTMI)
    tmit{1+i,1:size(dt,2)}=dt.getData(1+topTMI(i),1:size(dt,2));
end

disp(' ')
disp('Lowest 10 TMI specs')
tmit.toText()