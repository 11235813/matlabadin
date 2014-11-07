clear all

%% Adjustable Parameters
T= 100; %number of time steps to sim for (excluding t=0)
SDF= 3; %Spike Decade Factor: How much more dangerous (costly) a spike of one decade larger is (arbitrary; typical value is 3, should not be below 1)
MaxH= 100; %Though Health is not actually in this problem, this parameter controls the cost of spikes proportionally 
WindowSize= 4; %number of time steps to measure spikes over.
% Note: Data with different window lengths is not comparable;
% costs will be drastically different

LookAhead= 1; %number of lookahead steps
SimulationCount= 10000; %number of monte carlo trajectories to use

NumberOfStochasticEvents= 3; %quantity of possible stochastic events
avoid= 0.35; %chance to avoid attack
glance= 0.23; %chance to glance attack
fullhit= 50; %amount of Health lost from full attack
glancehit= 36; %amount of Health lost from glancing attack

MaxE= 5; %maximum Energy

RegenPattern=[1 1 0 1 0 1 1 0 0];
RegenE= 1; %Energy regenerated each time step

%--Enumeration of control options--
NumberOfControls= 3; %quantity of control options
ControlWait= 0; % Wait and do nothing
ControlMitigate= 1; % "Mitigate"
ControlRecover= 2; % "Recover"

%--Parameters of control options--
CostMitigate= 3; %Energy cost of "Mitigate"
CostMaxRecover= 3; %Maximum Energy expendable on "Recover"
MitigateAmount= 0.5; %percentage by which to multiply hits taken under "Mitigate"
RecoverAmount= 13.5; %Amount of Health restored by "Recover" (per Energy spent)

%--Initial Conditions--
E0= 5;
P0= 0;
X0= [0;0;0;0]; %must be length WindowSize, in descending state order, i.e. x1[0] on the right, xWindowSize[0] on the left
%% Other Parameters
full= 1-avoid-glance; %chance for full attack

E= zeros(T+1, NumberOfStochasticEvents, NumberOfControls);
u= zeros(T+1, NumberOfStochasticEvents, NumberOfControls);
%Only use one vector to save space, states x2 and beyond can be accessed 
%by going back time steps
x= zeros(T+WindowSize-1, NumberOfStochasticEvents, NumberOfControls);
attackroll= zeros(T+1, 1); %Universal stochastic element of attacks
attack= zeros(T+1, NumberOfStochasticEvents, NumberOfControls); %debug and placeholder calculations, not L[t]

TotalCost= zeros(SimulationCount, NumberOfStochasticEvents, NumberOfControls);
AvgCost= zeros(SimulationCount, NumberOfControls);
ControlComparator= zeros(SimulationCount, 1);

%--additional states added due to control options--
P= zeros(T+1, NumberOfStochasticEvents, NumberOfControls);

%--setting initial conditions--
for i= 1:NumberOfStochasticEvents
    for j= 1:NumberOfControls
        E(1,i,j)= E0;
        P(1,i,j)= P0;
        x(1:WindowSize-1,i,j)= X0(2:WindowSize);
    end
end
%% Start Simulations

    %Note: Since MATLAB variables are 1-indexed,
    %u[0] {paper} is u(1) {simulation}, so indices will be off by 1
    %in a sense. 'x' in the simulation is pre-padded with relevant initial
    %conditions, so t=1 {paper} starts even later, depending on WindowSize.

for s= 1:SimulationCount
    
    %Lookahead portion
    for t= 1:LookAhead
        
        RegenE=RegenPattern(1+mod(t-1,length(RegenPattern)));
        
        %--SPLIT CONTROL PATHS--
        %Set u to -1 if control would not be allowed.
        %-1 marks the control path as invalid.
        for i= 1:NumberOfStochasticEvents
            %Control 1: Wait
            u(t,i,1)= ControlWait;
            %Control 2: Mitigate
            if E(t,i,2) >= CostMitigate
                u(t,i,2)= ControlMitigate;
            else
                u(t,i,2)= -1;
            end
            %Control 3: Recover
            if E(t,i,3) > 0
                u(t,i,3)= ControlRecover;
            else
                u(t,i,3)= -1;
            end
        end
        
        %--SPLIT STOCHASTIC EVENT PATHS--
        for j= 1:NumberOfControls
            %Event 1: Avoid
            attack(t+1,1,j)= 0;
            %Event 2: Glance
            attack(t+1,2,j)= glancehit;
            %Event 3: Full Hit
            attack(t+1,3,j)= fullhit;
        end
        
        %--GENERATE STATE EVOLUTION--
        for i= 1:NumberOfStochasticEvents
            for j= 1:NumberOfControls
                %Check if control path valid:
                if u(t,i,j) == -1
                    u(t+1,i,j)= -1;
                    continue;
                end
                
                %Energy: E[t]
                if u(t,i,j) == ControlMitigate
                    %Mitigate: Spend Energy
                    E(t+1,i,j)= E(t,i,j) - CostMitigate + RegenE;
                elseif (u(t,i,j) == ControlRecover) && (E(t,i,j) <= CostMaxRecover)
                    %Recover with low Energy: Spent it all
                    E(t+1,i,j)= RegenE;
                elseif (u(t,i,j) == ControlRecover) && (E(t,i,j) > CostMaxRecover)
                    %Recover with high Energy: Didn't spend it all
                    E(t+1,i,j)= E(t,i,j) - CostMaxRecover + RegenE;
                elseif u(t,i,j) == ControlWait
                    %Wait: Only regenerate Energy
                    E(t+1,i,j)= E(t,i,j) + RegenE;
                end
                if E(t+1,i,j) > MaxE
                    %if above maximum Energy, set to maximum
                    E(t+1,i,j)= MaxE;
                end
        
                %Time steps left of Mitigation: P[t]
                if u(t,i,j) == ControlMitigate
                    %Mitigate: spend one time step but add two
                    P(t+1,i,j)= P(t,i,j)+1;
                else
                    %Not Mitigate: spend one time step
                    P(t+1,i,j)= P(t,i,j)-1;
                end
                if P(t+1,i,j) < 0
                    %If we had no time steps to spend, set to 0
                    P(t+1,i,j)= 0;
                end
        
                %Health loss state: x[t]
                if (u(t,i,j) == ControlMitigate) || (P(t,i,j) > 0)
                    %Mitigating this attack
                    x(t+WindowSize-1,i,j)= attack(t+1,i,j) * MitigateAmount;
                else
                    %Not Mitigating
                    x(t+WindowSize-1,i,j)= attack(t+1,i,j);
                end
                if u(t,i,j) == ControlRecover
                    %subtract recovered Health from loss
                    x(t+WindowSize-1,i,j)= x(t+WindowSize-1,i,j) - (RecoverAmount * min(CostMaxRecover, E(t,i,j)));
                end
            end
        end
    end
    
%% Continue using Base Policy

    for t= LookAhead+1:T
        
        RegenE=RegenPattern(1+mod(t-1,length(RegenPattern)));
        
        %Generate random elements: Use the same results for all paths
        attackroll(t+1)= random('unif',0,1);
        
        %Compute results for each path
        for i= 1:NumberOfStochasticEvents
            for j= 1:NumberOfControls
                %Check if control path valid:
                if u(t,i,j) == -1
                    u(t+1,i,j)= -1;
                    continue;
                end
                
                %--DECIDE CONTROL FROM POLICY--
                %Note: control is decided based on previous state before attack lands;
                %only calculate control as needed: Actually computing control inputted
                %for last time step
                
%                 % BASE POLICY
%                 % Policy: "Greedy Mitigate"
%                 % Use "Mitigate" whenever possible
%                 if E(t,i,j) >= 3
%                     u(t,i,j)= ControlMitigate;
%                 else
%                     u(t,i,j)= ControlWait;
%                 end
                
                % BASE POLICY
                % Policy: "SH1"
                % Use "Mitigate" at MaxE Energy or if last hit was FullHit,
                % otherwise use "Wait"
                if E(t,i,j) == MaxE
                    u(t,i,j)= ControlMitigate;
                elseif x(t+WindowSize-2,i,j) == fullhit
                    u(t,i,j)= ControlMitigate;
                else
                    u(t,i,j)= ControlWait;
                end
                
                %--COMPUTE RESULTS OF STOCHASTIC ELEMENTS--
                if attackroll(t+1) <= avoid
                    %avoid
                    attack(t+1,i,j)= 0;
                elseif attackroll(t+1) <= avoid+glance
                    %glance
                    attack(t+1,i,j)= glancehit;
                else
                    %full hit
                    attack(t+1,i,j)= fullhit;
                end
                
                %--GENERATE STATE EVOLUTION--
                %Energy: E[t]
                if u(t,i,j) == ControlMitigate
                    %Mitigate: Spend Energy
                    E(t+1,i,j)= E(t,i,j) - CostMitigate + RegenE;
                elseif (u(t,i,j) == ControlRecover) && (E(t,i,j) <= CostMaxRecover)
                    %Recover with low Energy: Spent it all
                    E(t+1,i,j)= RegenE;
                elseif (u(t,i,j) == ControlRecover) && (E(t,i,j) > CostMaxRecover)
                    %Recover with high Energy: Didn't spend it all
                    E(t+1,i,j)= E(t,i,j) - CostRecover + RegenE;
                elseif u(t,i,j) == ControlWait
                    %Wait: Only regenerate Energy
                    E(t+1,i,j)= E(t,i,j) + RegenE;
                end
                if E(t+1,i,j) > MaxE
                    %if above maximum Energy, set to maximum
                    E(t+1,i,j)= MaxE;
                end
        
                %Time steps left of Mitigation: P[t]
                if u(t,i,j) == ControlMitigate
                    %Mitigate: spend one time step but add two
                    P(t+1,i,j)= P(t,i,j)+1;
                else
                    %Not Mitigate: spend one time step
                    P(t+1,i,j)= P(t,i,j)-1;
                end
                if P(t+1,i,j) < 0
                    %If we had no time steps to spend, set to 0
                    P(t+1,i,j)= 0;
                end
        
                %Health loss state: x[t]
                if (u(t,i,j) == ControlMitigate) || (P(t,i,j) > 0)
                    %Mitigating this attack
                    x(t+WindowSize-1,i,j)= attack(t+1,i,j) * MitigateAmount;
                else
                    %Not Mitigating
                    x(t+WindowSize-1,i,j)= attack(t+1,i,j);
                end
                if u(t,i,j) == ControlRecover
                    %subtract recovered Health from loss
                    x(t+WindowSize-1,i,j)= x(t+WindowSize-1,i,j) - (RecoverAmount * min(CostMaxRecover, E(t,i,j)));
                end
            end
        end
    end %End current trajectory simulation


%% Compute Total and Average Costs
%moving average is simpler to do after the simulation has completed but
%could be done on-line as well. Currently separate to keep code cleaner

    %Total up cost over each control path
    for t= 1:T
        for i= 1:NumberOfStochasticEvents
            for j= 1:NumberOfControls
                %Check if control path valid:
                if u(t,i,j) == -1
                    TotalCost(s,i,j)= -1;
                    continue;
                end
                
                %compute window sum
                y= 0;
                for tau=0:(WindowSize-1)
                    y= y + x(t+tau,i,j);
                end
                
                %add window sum's cost to total cost
                TotalCost(s,i,j)= TotalCost(s,i,j)+ 240000/T*exp(10*log(SDF)*(y-MaxH)/MaxH);
            end
        end
    end
    
    %Average over all stochastic events (by Prob. of those events)
    for j= 1:NumberOfControls
        %The following 'if' statement is neccesary because:
        %MATLAB may not compute the weighted average of -1's as exactly -1,
        %thus potentially failing 'if' statements below.
        %(This was actually happening to me.)
        if (TotalCost(s,1,j) == -1)||(TotalCost(s,2,j) == -1)||(TotalCost(s,3,j) == -1)
            AvgCost(s,j)= -1; %exactly!
        else
            AvgCost(s,j)= avoid*TotalCost(s,1,j) + glance*TotalCost(s,2,j) + full*TotalCost(s,3,j);
        end
    end


end %End simulations completely

%% Compute Results

%Set default choice
BestControl= ControlWait;
BestControlConfidence= 1; %If no other options allowed, then 100% confident

if AvgCost(1,2) ~= -1
    %compare this control to proposed optimal control
    for s= 1:SimulationCount
        ControlComparator(s)= AvgCost(s,BestControl+1)-AvgCost(s,2);
    end
    
    %Compute which control is optimal and confidence
    if mean(ControlComparator) > 0
        BestControl= ControlMitigate;
    end
    BestControlConfidence= min(BestControlConfidence, erf(abs(mean(ControlComparator)/(std(ControlComparator)/sqrt(SimulationCount)))/sqrt(2))/2 + 0.5);
end

if AvgCost(1,3) ~= -1
    %compare this control to proposed optimal control
    for s= 1:SimulationCount
        ControlComparator(s)= AvgCost(s,BestControl+1)-AvgCost(s,3);
    end
    
    %Compute which control is optimal and confidence
    if mean(ControlComparator) > 0
        BestControl= ControlRecover;
    end
    BestControlConfidence= min(BestControlConfidence, erf(abs(mean(ControlComparator)/(std(ControlComparator)/sqrt(SimulationCount)))/sqrt(2))/2 + 0.5);
end

%% Print Results

%[E attack x(WindowSize-1:T+WindowSize-1) u P] %#ok<NOPTS>
%AvgCost %#ok<NOPTS>
%ControlComparator %#ok<NOPTS>
BestControl %#ok<NOPTS>
BestControlConfidence %#ok<NOPTS>



