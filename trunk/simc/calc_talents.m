clear sim

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;


for i=0:2;
    sim.talents=['2021' int2str(i) '1.simc'];
    sim.txt=['2021' int2str(i) '1.txt'];
    sim=run_sim(sim);
    
    pause(0.01);
    
end
