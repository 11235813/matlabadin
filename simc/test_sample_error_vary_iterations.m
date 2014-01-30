num_iterations=[50 100 250 500 1000 2500 5000 10000 25000 50000 100000 250000];
for j=1:length(num_iterations)
    clear sim
    
    N=100;
    
    % initializes the sim structure, setting certain parameters to default
    % values.
    sim=init_sim;
    sim.header='#Statistics Test';
    sim.iterations=num_iterations(j); %min 50, lower causes crashes w/ release versions
    sim.threads=4;
    sim.argstr='vary_combat_length=0';
    sim.gear='T16N.simc';
    sim.boss='T16N25.simc';
    % sim.target_health=100;
    sim.class='paladin';
    sim.spec='protection';
    
    create_simc_file(sim);
    
    
    %waitbar
    W=waitbar(0,'Simulating');
    tic
    for i=1:N
        waitbar(i/N,W,['Simulating ' num2str(100*i/N,'%2.1f') '%']);
        
        sim=run_sim(sim);
        results(i)=sf_extract(sim.output.output);
    end
    close(W)
    toc
    fclose all;
    
    
    %% post-processing
    dps(:,j)=[results.dps]';
    dps_err(:,j)=[results.dps_error]';
    [metric, CI95(j), pc]=conf_ellipsoid_stats(dps(:,j));
    reported_CI95(j)=2*max(dps_err(:,j));
    
    disp(['Num Iterations: ' int2str(num_iterations(j)) ])
    disp(['Reported 95% CI: ' num2str(reported_CI95(j)),'%5.1f')])
    disp(['Observed 95% CI: ' num2str(CI95(j),'%5.1f')])
    
end

%% figure
figure(1)
subplot 211
semilogx(num_iterations,reported_CI95,'o-',num_iterations,CI95,'o-')
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Location','NorthEast')
subplot 212
loglog(num_iterations,reported_CI95,'o-',num_iterations,CI95,'o-')
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Location','NorthEast')

figure(2)
plot(num_iterations,reported_CI95,'o-',num_iterations,CI95,'o-')
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Location','NorthEast')
