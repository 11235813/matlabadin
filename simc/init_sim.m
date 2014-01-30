function [ sim ] = init_sim
%INIT_SIM initializes the sim structure by populating all fields.  

% SimC path/exe information
sim.exe='simc64.exe';
sim.paths.exe='G:\simcraft\';
sim.paths.exe='D:\Simcraft\simc-542-1-win64\';

% sim parameters
sim.iterations=100;
sim.ptr=0; 
sim.argstr='';
sim.threads=4;

% player parameters
sim.paths.pdb='';
sim.class='paladin';
sim.spec='protection';
sim.playerstr='';
sim.player='default.simc';
sim.glyphs='default.simc';
sim.talents='default.simc';
sim.gear='T16H.simc';
sim.precombat='paladin_protection_precombat_default.simc';
sim.rotation='paladin_protection_default.simc';

% boss parameters
sim.boss='T16N25.simc';
sim.target_health=0;

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

