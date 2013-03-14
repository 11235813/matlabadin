clear

%input parameters
p0=0.1; %base probability of proc
dp0=0;   %bonus probability per stack
D0=15000; %duration of buff in ms
maxStacks=1; %maximum # of stacks
triggerInterval=500; %proc trigger event interval
simMins=1000; %minutes of simulation
dt=100; %time step in ms


%% test base proc scaling
p=linspace(0,0.1,50);
mu_p=zeros(2,length(p));
thmu_p=zeros(2,length(p));

for i=1:length(p)
    [mu_p(1,i) thmu_p(1,i)] = proc_model(p(i),dp0,D0,maxStacks,triggerInterval,simMins,dt);
    [mu_p(2,i) thmu_p(2,i)] = proc_model_new(p(i),dp0,D0,maxStacks,triggerInterval,simMins,dt);

end

%% plot
R=60.*p./(triggerInterval/1000);
figure(1)
plot(p,mu_p(1,:),'o',p,mu_p(2,:),'-')
xlabel('proc per event chance "p"')
ylabel('mean stack size')
title(['Analysis of new vs. old RPPM mechanics for \Delta t = ' num2str(triggerInterval./1000,'%2.2f')])
legend('Old version','New version','Location','SouthEast')
ylim([0 1.05.*maxStacks]);

figure(2)
plot(R,mu_p(1,:),'o',R,mu_p(2,:),'-')
ylim([0 1.05.*maxStacks]);
xlabel('RPPM value')
ylabel('mean stack size')
legend('Old version','New version','Location','SouthEast')

figure(3)
plot(p,mu_p(2,:)./mu_p(1,:))
xlabel('proc per event chance "p"')
ylabel('Relative improvement in uptime')
