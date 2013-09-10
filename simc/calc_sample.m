clear sim
%SimC path/exe
sim.exe='simc64.exe';
sim.path='G:\simcraft\';

%sim parameters
sim.iterations=10;
sim.ptr=0;

%player parameters
sim.player='default.simc';
sim.glyphs='default.simc';
sim.talents='default.simc';
sim.gear='T16N.simc';
sim.rotation='test_rotation.simc';

%output paremeters
sim.html='Test_Sim.html';

run_sim(sim)