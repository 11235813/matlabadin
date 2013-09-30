clear sim

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;
sim.header='#Talent Simulation';

for i=0:2; %TODO: use 1-3 or add blizz link here
    sim.talents=['2021' int2str(i) '1.simc'];
    sim.output.output=['2021' int2str(i) '1.txt'];
    sim=run_sim(sim);
    
    results=sf_extract(sim.output.output)
    pause(0.01);
    
end
