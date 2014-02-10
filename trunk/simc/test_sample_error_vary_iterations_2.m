clear
num_iterations=[50 100 250 500 1000 2500 5000 10000 25000 50000 100000];
num_iterations=[50 100 1000 10000 25000 50000 100000];
tic
for j=1:length(num_iterations)
    clear sim
    
    N=100;
       
    % initializes the sim structure, setting certain parameters to default
    % values.
    sim=init_sim;
    sim.simc='Paladin_Protection_T15N.simc';
    sim.iterations=num_iterations(j); %min 50, lower causes crashes w/ release versions
    if num_iterations(j)>100
        sim.threads=6;
    else
        sim.threads=4;
    end
    sim.varystr=' ';
    sim.fixedtime=' ';
    sim.fixedhealth=' ';
%     sim.varystr='vary_combat_length=0';
%     sim.fixedtime='fixed_time=1';
%     sim.fixedhealth='target_health=171000000';
    sim.paths.exe='D:\Simcraft\simc-542-2-built';
    sim.paths.input=[sim.paths.exe '\profiles\Tier15N'];
    sim=sf_construct_fullpaths(sim);
    
    call_str=char(strcat(sim.fullpaths.exe,{' '},...
                         sim.fullpaths.simc,{' '},...
                         'threads=',int2str(sim.threads),{' '},...
                         'iterations=',int2str(sim.iterations),{' '},...
                         'output=',sim.output.output,{' '},...
                         sim.varystr,{' '},sim.fixedtime,{' '},...
                         'enemy=FluffyPillow',{' '},...
                         sim.fixedhealth,{' '},...
                         {'  > nul'})...
                  );
                     
    %waitbar
    W=waitbar(0,'Simulating');
%     tic
    for i=1:N
        waitbar(i/N,W,['Simulating N=' int2str(sim.iterations) ', ' num2str(100*i/N,'%2.1f') '%']);
        
        system(call_str);

        results(i)=sf_extract(sim.output.output);
    end
    close(W)
%     toc
    fclose all;
    
    
    %% post-processing
    dps(:,j)=[results.dps]'; %#ok<*SAGROW>
    dps_err(:,j)=[results.dps_error]';
    [metric, CI95(j), pc]=conf_ellipsoid_stats(dps(:,j));
    RCI95(j)=2*max(dps_err(:,j));
    
    disp(['Num Iterations: ' int2str(num_iterations(j)) ])
    disp(['Reported 95% CI: ' num2str(RCI95(j),'%5.1f')])
    disp(['Observed 95% CI: ' num2str(CI95(j),'%5.1f')])
    
end
toc

%% figure
figure(1)
subplot 211
semilogx(num_iterations,RCI95,'o-',num_iterations,CI95,'o-')
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Location','NorthEast')
subplot 212
loglog(num_iterations,RCI95,'o-',num_iterations,CI95,'o-')
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Location','NorthEast')

% figure(2)
% plot(num_iterations,RCI95,'o-',num_iterations,CI95,'o-')
% xlabel('# Iterations')
% ylabel('95% Confidence Interval (DPS)')
% legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Location','NorthEast')
