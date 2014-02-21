clear sim

N=100;

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Statistics Test';
sim.iterations=50000; %min 50, lower causes crashes w/ release versions
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
dps=[results.dps]';
dps_err=[results.dps_error]';
[metric, CI95, pc]=conf_ellipsoid_stats(dps);

disp(['Reported 95% CI: ' num2str(2*max(dps_err),'%5.1f')])
disp(['Observed 95% CI: ' num2str(CI95,'%5.1f')])

%% figure
figure(1)
hist(dps./1e3,(floor(min(dps./1e2))./10):0.05:(ceil(max(dps./1e2))./10))
xlabel('DPS (k)')
ylabel('Number of iterations')

