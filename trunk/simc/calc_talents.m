clear sim

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Talent Simulation';
sim.paths.exe='d:\simcraft\'
%fix pdb path - in future may need to set this to "what" if we implement
%\pdb\ in simc and still wish to use matlab path
sim = util_check_pdb_path(sim);
talentpath=[sim.paths.pdb 'talents\'];

%% set up the list of things we want to vary
talent_combinations='';
for L45=1:3 %L45 talent (SH/EF/SS)
    for L60=1:3 %L60 talent (HoP/US/Clemency)
        for L75=1:3 %L75 talent (HA/SW/DP)
            for L90=1:3 %L90 talent (EF/LH/HPr)
                talent_combinations=[talent_combinations;
                    strcat('31',int2str(L45),int2str(L60),int2str(L75),int2str(L90))]; %#ok<AGROW>
            end
        end
    end
end


%% create the talent .simc files we need
for i=1:size(talent_combinations,1)
   talent_files{i}=create_simc_component(['talents=' talent_combinations(i)],talentpath,talent_combinations(i,:)); 
end

%% crank through them
clear results
W=waitbar(0,'Simulating');
tic
for i=1:size(talent_combinations,1); 
    
    waitbar(i/size(talent_combinations,1),W,['Simulating ' num2str(100*i/size(talent_combinations,1),'%2.1f') '%']);
    
    %set talent file
    sim.talents=talent_files{i};
    
    %rename simc file
    
    %create simc file
    create_simc_file(sim);
    %run sim    
    sim=run_sim(sim);
    
    results(i)=sf_extract(sim.output.output);
    pause(0.0001);
    
end
close(W)
toc

%% Compile results into usefully-formatted table
addpath ./helper_func/
dt=DataTable();
dt{1,1}='Talents';
dt{1,2}='DPS';
dt{1,3}='HPS';
dt{1,4}='DTPS';
dt{1,5}='TMI';
dt{1,6}='SotR';
for i=1:length(talent_combinations)
   dt{1+i,1}=talent_combinations(i,:);
   r=results(i);
   dt{1+i,2}=num2str(r.dps,'%6.0f');
   dt{1+i,3}=num2str(r.hps,'%6.0f');
   dt{1+i,4}=num2str(r.dtps,'%6.0f');
   dt{1+i,5}=num2str(r.tmi,'%6.1f');
   dt{1+i,6}=[num2str(r.sotr_uptime*100,'%2.1f') '%'];
end

dt.toText()