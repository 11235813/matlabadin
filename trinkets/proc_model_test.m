clear

proc.p0=0; %base probability of proc
proc.dp=0;   %bonus probability per stack
proc.D=10000; %duration of buff in ms
proc.maxStacks=5; %maximum # of stacks
proc.boostEnabled=1; %enable boost mechanism
proc.icd=5000;
proc.hastePerStack=1627/425/100;
proc.rppm=3.5;
proc.rppmHasted=0;

sim.simMins=1000; %minutes of simulation
sim.dt=100; %time step in ms
sim.baseHaste=0.25; %base haste
sim.baseTimeBetweenProcChances=1000; %base time between proc chances in ms


[meanStacks meanTime s] = proc_model_icd(proc, sim);

proc.icd=0;

[meanStacks(2) meanTime(2) s(:,2)] = proc_model_icd(proc,sim);


meanStacks
meanTime
% 
% 
% %% test base proc scaling
% p=linspace(0,0.3,25);
% mu_p=zeros(1,length(p));
% thmu_p=zeros(1,length(p));
% 
% for i=1:length(p)
%     [mu_p(i) thmu_p(i) thmu2_p(i)] = proc_model(p(i),dp0,D0,maxStacks,simMins,dt);
% end
% 
% %% plot
% figure(1)
% plot(p,mu_p,'o',p,thmu_p,'-')
% xlabel('proc per event chance "p"')
% ylabel('mean stack size')
% legend('Simulation','Model','Model2','Location','SouthEast')
% ylim([0 1.04.*max(max([mu_p,thmu_p]))])
% 
% %% test dp scaling
% dp=linspace(0,p0/5,25);
% mu_dp=zeros(1,length(p));
% thmu_dp=zeros(1,length(p));
% 
% for i=1:length(dp)
%     [mu_dp(i) thmu_dp(i) thmu2_dp(i)] = proc_model(p0,dp(i),D0,maxStacks,simMins,dt);
% end
% 
% %% plot
% figure(2)
% plot(dp,mu_dp,'o',dp,thmu_dp,'-',dp,thmu2_dp)
% xlabel('stack-based proc per event chance "dp"')
% ylabel('mean stack size')
% legend('Simulation','Model','Model2','Location','SouthEast')
% ylim([0 1.04.*ceil(max(max([mu_dp;dp])))])
% 
