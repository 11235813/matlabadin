function  [meanStacks theoreticalMeanStacks] = proc_model(p0,dp,D,maxStacks,simMins,dt)

if nargin<1
    p0=0.1; %base probability of proc
end
if nargin<2
    dp=0.02;   %bonus probability per stack
end
if nargin<3
    D=10000; %duration of buff in ms
end
if nargin<4
    maxStacks=5; %maximum # of stacks
end
if nargin<5
    simMins=100; %number of minutes to simulate
end
if nargin<6
    dt=100; %time step size in ms
end

timeBetweenProcChances=1500; %time between proc chances, in seconds

numTimeSteps=simMins*60*1000/dt;

% t=zeros(size(numTimeSteps)); %time array
s=zeros(1,numTimeSteps); %stack array, for tracking
d=s;

procChanceTimer=0;
stacks=int32(0);
stackDuration=0;

t=dt.*((1:numTimeSteps)-1);
tic
for q=1:numTimeSteps
    
    %store time
%     t(q)=(q-1).*dt;
    
    %decrement timers
    procChanceTimer=procChanceTimer-dt;
    stackDuration=stackDuration-dt;
    
    %drop stacks if duration has expired
    if stackDuration<=0
        stacks=0;
    end
    
    %see if we should try for another proc
    if procChanceTimer<=0
        
        %roll for a proc
        if rand<(p0+stacks*dp)
            
            %if successful, increment stack size and refresh duration
            stackDuration=D;
            stacks=min([stacks+1;maxStacks]);
            
        end
        
        %set procChanceTimer
        procChanceTimer=timeBetweenProcChances;
        
    end
    
    %store some variables for debugging
    s(q)=stacks;
    d(q)=stackDuration;
    
    
end
toc

meanStacks=mean(s);

%% compare to theory
contribution=zeros(1,maxStacks);
for i=1:maxStacks;
    contribution(i)=(1-exp(-(p0+(i-1)*dp)./timeBetweenProcChances.*D));
end

theoreticalMeanStacks=sum(cumprod(contribution));

end

%  [meanStacks;theoreticalMeanStacks]
 
%  figure(1)
%  plot(t,s)