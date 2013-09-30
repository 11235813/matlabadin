function [ sim ] = init_sim
%INIT_SIM initializes the sim structure by populating all fields.  

% SimC path/exe information
sim.exe='simc64.exe';
sim.paths.exe='G:\simcraft\';

% sim parameters
sim.iterations=100;
sim.ptr=0; 
sim.argstr='';

% player parameters
sim.paths.pdb='';
sim.playerstr='';
sim.player='default.simc';
sim.glyphs='default.simc';
sim.talents='default.simc';
sim.gear='T16H.simc';
sim.precombat='precombat.simc';
sim.rotation='default.simc';

%file parameters
sim.paths.input='';
sim.simc='test.simc';
sim.header='';

% output parameters
sim.outputstr='';
sim.paths.output='';
sim.output.html='last_sim.html';
sim.output.output='last_sim.txt';
sim.output.xml='';
sim.output.csv='';

end

