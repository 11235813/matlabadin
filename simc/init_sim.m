function [ sim ] = init_sim
%INIT_SIM initializes the sim structure by populating all fields.  

% SimC path/exe information
sim.exe='simc64.exe';
sim.exe_path='G:\simcraft\';

% sim parameters
sim.iterations=100;
sim.ptr=0; 
sim.argstr='';

% player parameters
sim.pdb_path='';
sim.playerstr='';
sim.player='default.simc';
sim.glyphs='default.simc';
sim.talents='default.simc';
sim.gear='T16H.simc';
sim.precombat='precombat.simc';
sim.rotation='default.simc';

%file parameters
sim.in_path='';
sim.simc='';

% output parameters
sim.outputstr='';
sim.out_path='';
sim.html='last_sim.html';
sim.txt='last_sim.txt';
sim.xml='';
sim.csv='';

end

