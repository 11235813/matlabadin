function  [meanStacks meanTime theoreticalMeanStacks] = proc_model_new(p0,dp,D,maxStacks,interval,simMins,dt)

if nargin<1
    p0=0.1; %base probability of proc (per event)
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
    timeBetweenProcChances=500;
else
    timeBetweenProcChances=interval;
end
if nargin<6
    simMins=500; %number of minutes to simulate
end
if nargin<7
    dt=100; %time step size in ms
end

% timeBetweenProcChances=500; %time between proc chances, in seconds

numTimeSteps=simMins*60*1000/dt;

% t=zeros(size(numTimeSteps)); %time array
s=zeros(1,numTimeSteps); %stack array, for tracking
d=s;
procTrack=s;

%tracking values
procChanceTimer=0;
stacks=int32(0);
stackDuration=0;
lastProcTime=-1000*1000;%1000 seconds ago, in ms
meanProcTime=timeBetweenProcChances./p0;

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
        
        %determine "boost" to proc chance
        boost=max([1 1+3.*(min([(t(q)-lastProcTime) 1000*1000])./meanProcTime-1.5)]);
        
        %roll for a proc
        if rand<=((p0+stacks*dp).*boost)
            
            %if successful, increment stack size and refresh duration
            stackDuration=D;
            stacks=min([stacks+1;maxStacks]);
            
            %and set lastProcTime
            lastProcTime=t(q);
            
            %store proc for meanProcTime calculation
            procTrack(q)=1;
            
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
meanTime=simMins./sum(procTrack);

%% compare to theory
contribution=zeros(1,maxStacks);
contribution2=zeros(1,maxStacks);

for i=1:maxStacks;
%     contribution(i)=(1-exp(-(p0+(i-1)*dp)./timeBetweenProcChances.*D)); %poisson approximation
    contribution(i)=(1-(1-(p0+(i-1)*dp)).^(D./timeBetweenProcChances)); %exact value (1-q^N)
    contribution2(i)=(1-(1-(p0+(i)*dp)).^(D./timeBetweenProcChances)); %tweaking to find model improvements
end

theoreticalMeanStacks=sum(cumprod(contribution));
theo2=sum(cumprod(contribution2));

end

%  [meanStacks;theoreticalMeanStacks]
 
%  figure(1)
%  plot(t,s)