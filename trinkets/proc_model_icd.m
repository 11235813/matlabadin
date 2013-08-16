function  [meanStacks meanTime s] = proc_model_icd(proc, sim)

%check for inputs
if ~exist('proc','var')
    proc.p0=0.1;
end
if ~exist('sim','var')
    sim.simMins=500;
end
   
%% unpack input structures
fields=fieldnames(proc);
for i=1:length(fields)
    eval([ fields{i} '=getfield(proc,fields{' int2str(i) '});']);
end

fields=fieldnames(sim);
for i=1:length(fields)
    eval([ fields{i} '=getfield(sim,fields{' int2str(i) '});']);
end

%% check for nonexistent inputs
if ~exist('p0','var')
    p0=0; %base probability of proc (per event)
end
if ~exist('dp','var')
    dp=0;   %bonus probability per stack
end
if ~exist('D','var')
    D=10000; %duration of buff in ms
end
if ~exist('maxStacks','var')
    maxStacks=5; %maximum # of stacks
end
if ~exist('icd','var')
    icd=0;
end
if ~exist('rppm','var')
    rppm=0;
end
if ~exist('rppmHasted','var')
    rppmHasted=0;
end
if ~exist('hastePerStack','var')
    hastePerStack=0;
end

if ~exist('baseTimeBetweenProcChances','var')
    baseTimeBetweenProcChances=500;
end
if ~exist('simMins','var')
    simMins=500; %number of minutes to simulate
end
if ~exist('stepSize','var')
    stepSize=10; %time step size in ms
end
if ~exist('boostEnabled','var')
    boostEnabled=1;
end
if ~exist('baseHaste','var')
    baseHaste=0;
end

%% Set up Sim
numTimeSteps=simMins*60*1000/stepSize;

% t=zeros(size(numTimeSteps)); %time array
s=zeros(numTimeSteps,1); %stack array, for tracking
d=s;
procTrack=s;

%tracking values
procChanceTimer=0;
icdTimer=0;
stacks=int32(0);
stackDuration=0;
lastProcTime=-90*1000;%1000 seconds ago, in ms
lastProcTrigger=-baseTimeBetweenProcChances/(1+baseHaste);
if p0>0
    meanProcTime=baseTimeBetweenProcChances./p0;
elseif rppm>0
    meanProcTime=60000/rppm/(1+rppmHasted*baseHaste);
else
    error('No proc rate information provided')
end
   
%% Crank
t=stepSize.*((1:numTimeSteps)-1);
tic
for q=1:numTimeSteps
        
    %decrement timers
    procChanceTimer=procChanceTimer-stepSize;
    stackDuration=stackDuration-stepSize;
    icdTimer=icdTimer-stepSize;
    
    %drop stacks if duration has expired
    if stackDuration<=0
        stacks=0;
    end
    
    %see if we should try for another proc
    if procChanceTimer<=0
        
        %if the ICD is up, then we can proc
        if icdTimer<=0
            currentTime=t(q);
            
            %determine "boost" to proc chance
            if boostEnabled==1
                boost=max([1 1+3.*(min([(currentTime-lastProcTime) 1000*1000])./meanProcTime-1.5)]);
            else
                boost=1;
            end
            
            %determine proc chance
            if p0>0
                procChance = p0+stacks*dp;
            elseif rppm>0
                procChance = rppm*(currentTime-lastProcTrigger)/60000*(1+rppmHasted*(baseHaste+stacks*hastePerStack));
            end
            %roll for a proc
            if rand<=(procChance*boost)
                
                %if successful, increment stack size and refresh duration
                stackDuration=D;
                stacks=min([stacks+1;maxStacks]);
                
                %and set lastProcTime
                lastProcTime=currentTime;
                
                %store proc for meanProcTime calculation
                procTrack(q)=1;
                
                %set icd timer
                icdTimer=icd;
                
            end           
            
            %set last proc trigger timer, since attacks that occur during
            %the ICD don't cost RPPM
            lastProcTrigger=t(q);
        end
        
        %set procChanceTimer either way
        procChanceTimer=baseTimeBetweenProcChances/(1+baseHaste+stacks*hastePerStack);
        
    end
    
    %store some variables for debugging
    s(q)=stacks;
    d(q)=stackDuration;
    
end
toc

meanStacks=mean(s);
meanTime=simMins./sum(procTrack)*60;

% %% compare to theory
% contribution=zeros(1,maxStacks);
% contribution2=zeros(1,maxStacks);
% 
% for i=1:maxStacks;
% %     contribution(i)=(1-exp(-(p0+(i-1)*dp)./timeBetweenProcChances.*D)); %poisson approximation
%     contribution(i)=(1-(1-(p0+(i-1)*dp)).^(D./timeBetweenProcChances)); %exact value (1-q^N)
%     contribution2(i)=(1-(1-(p0+(i)*dp)).^(D./timeBetweenProcChances)); %tweaking to find model improvements
% end
% 
% theoreticalMeanStacks=sum(cumprod(contribution));
% theo2=sum(cumprod(contribution2));

end
