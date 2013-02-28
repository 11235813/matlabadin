clear

p0=0.1; %base probability of proc
dp0=0;   %bonus probability per stack
D0=15000; %duration of buff in ms
maxStacks=5; %maximum # of stacks
simMins=1000; %minutes of simulation
dt=100; %time step in ms


%% test base proc scaling
p=linspace(0,0.3,25);
mu_p=zeros(1,length(p));
thmu_p=zeros(1,length(p));

for i=1:length(p)
    [mu_p(i) thmu_p(i) thmu2_p(i)] = proc_model(p(i),dp0,D0,maxStacks,simMins,dt);
end

%% plot
figure(1)
plot(p,mu_p,'o',p,thmu_p,'-')
xlabel('proc per event chance "p"')
ylabel('mean stack size')
legend('Simulation','Model','Model2','Location','SouthEast')
ylim([0 1.04.*max(max([mu_p,thmu_p]))])

%% test dp scaling
dp=linspace(0,p0/5,25);
mu_dp=zeros(1,length(p));
thmu_dp=zeros(1,length(p));

for i=1:length(dp)
    [mu_dp(i) thmu_dp(i) thmu2_dp(i)] = proc_model(p0,dp(i),D0,maxStacks,simMins,dt);
end

%% plot
figure(2)
plot(dp,mu_dp,'o',dp,thmu_dp,'-',dp,thmu2_dp)
xlabel('stack-based proc per event chance "dp"')
ylabel('mean stack size')
legend('Simulation','Model','Model2','Location','SouthEast')
ylim([0 1.04.*ceil(max(max([mu_dp;dp])))])