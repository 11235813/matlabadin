clear sim

% initializes the sim structure, setting certain parameters to default
% values.
sim=init_sim;

create_simc_file(sim);

sim=run_sim(sim);


results=sf_extract(sim.output.output)