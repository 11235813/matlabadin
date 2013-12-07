clear sim
fclose('all');
REGEN_ALL=false; %THIS REGENERATES ALL FILES - SET FALSE FOR CACHING

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Talent Simulation';
sim.iterations=50000;
sim.threads=4;
sim.gear='T16N.simc';
sim.boss='T16N25.simc';
% sim.paths.exe='d:\simcraft\'
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
talentpath=[sim.paths.pdb 'talents\'];

%% set up the list of things we want to vary
label_L45={'SH';'EF';'SS'};
label_L60={'HoP';'US';'Clem'};
label_L75={'HA';'SW';'DP'};
label_L90={'ES';'LH';'HPr'};
talent_combinations='';
talent_L45='';talent_L60='';talent_L75='';talent_L90='';

for L60=1:3 %L60 talent (HoP/US/Clemency)
    for L90=1:3 %L90 talent (EF/LH/HPr)
        for L45=1:3 %L45 talent (SH/EF/SS)
            for L75=1:3 %L75 talent (HA/SW/DP)
                talent_combinations=[talent_combinations;
                    strcat('31',int2str(L45),int2str(L60),int2str(L75),int2str(L90))]; %#ok<AGROW>
                talent_L45=strvcat(talent_L45, label_L45{L45});  %#ok<*REMFF1>
                talent_L60=strvcat(talent_L60, label_L60{L60}); 
                talent_L75=strvcat(talent_L75, label_L75{L75}); 
                talent_L90=strvcat(talent_L90, label_L90{L90}); 
            end
        end
    end
end


%% create the talent .simc files we need
for i=1:size(talent_combinations,1)
   talent_files{i}=create_simc_component(['talents=' talent_combinations(i,:)],talentpath,talent_combinations(i,:));  %#ok<SAGROW>
end

%% crank through them
clear results tempresults

%preallocate results
results=repmat(sf_extract('dummy'),size(talent_combinations,1),1);

%waitbar
W=waitbar(0,'Simulating');
tic
for i=1:size(talent_combinations,1); 
    
    waitbar(i/size(talent_combinations,1),W,['Simulating ' num2str(100*i/size(talent_combinations,1),'%2.1f') '%']);
    
    %set talent file
    sim.talents=talent_files{i};
    
    %rename simc file
    sim.simc=strcat('io\talent_',talent_combinations(i,:),'.simc');
    
    %set output filenames
    sim.output.html=strcat('io\talent_',talent_combinations(i,:),'.html');
    sim.output.output=strcat('io\talent_',talent_combinations(i,:),'.txt');
    
    %construct simc fullpath
    sim=sf_construct_fullpaths(sim);
    
    %if the txt output doesn't exist or is older than an important file, regenerate
    if ~exist(fullpath.output,'file') || sf_compare_fullpaths(fullpath)
        
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
dt{1,1}='Talents';
dt{1,2}='L45';
dt{1,3}='L60';
dt{1,4}='L75';
dt{1,5}='L90';
dt{1,6}='DPS';
dt{1,7}='HPS';
dt{1,8}='DTPS';
dt{1,9}='TMI';
dt{1,10}='SotR';
for i=1:length(talent_combinations)
   dt{1+i,1}=talent_combinations(i,:);
   r=results(i);
   dt{1+i,2}=talent_L45(i,:);
   dt{1+i,3}=talent_L60(i,:);
   dt{1+i,4}=talent_L75(i,:);
   dt{1+i,5}=talent_L90(i,:);
   dt{1+i,6}=num2str(r.dps,'%6.0f');
   dt{1+i,7}=num2str(r.hps,'%6.0f');
   dt{1+i,8}=num2str(r.dtps,'%6.0f');
   dt{1+i,9}=num2str(r.tmi,'%6.1f');
   dt{1+i,10}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

disp(' ')
disp('Full List')
dt.toText()

%% Compile short table of select results
useful_talents={'311212';'311222';'311232';'312212';'312222';'312232';'313212';'313222';'313232'};
for i=1:length(talent_combinations)
    
end
dts=DataTable();
dts{1,1:size(dt,2)}=dt.getData(1,1:size(dt,2));
for i=1:length(useful_talents)
    j=find(strcmp(useful_talents{i},cellstr(talent_combinations)));
    dts{1+i,1:size(dt,2)}=dt.getData(1+j,1:size(dt,2));
end

disp(' ')
disp('Short List')
dts.toText()

%% Top 10 DPS specs
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

%% Lowest 10 TMI specs
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