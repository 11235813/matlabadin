clear
%% Player / Boss stuff
%player info
maxHealth=300000;
dmgAmountArray=0; %normalized to MH
dmgTimeArray=0;

%boss info
damage=80000;
damageVariance=30000;
swingTime=1.5;
firstSwing=2.5;

%% Vengeance / Resolve stuff
%Vengeance details
vengeanceTimeline=0;
vengeanceFactor=0.015;
noRamp=0; %set to 1 to disable the ramping mechanism

%Resolve details
resolveTimeline=0;
oldResolveTimeline=0;
resolveFactor=0.25;
resolveRecalcTime=0.5;

%% Sim settings
t=0; %time in seconds
maxT=100;
i=1;

%% Crank
%set the event checkers
nextSwing=firstSwing;
nextRecalc=0.5;

while t(i)<maxT
    %increment index
    i=i+1;
    
    %figure out how much time to step
    dt=min(nextSwing,nextRecalc);
    
    %step and update our trackers
    t(i)=t(i-1)+dt;
    nextSwing=nextSwing-dt;
    nextRecalc=nextRecalc-dt;
    timeSinceLastDmg=t(i)-dmgTimeArray(length(dmgTimeArray));
    
    %handle boss attacks 
    if nextSwing<=0
        %process boss swing
        currentSwingDamage=damage+damageVariance*2*(rand()-0.5);
        %add to arrays
        dmgAmountArray=[dmgAmountArray currentSwingDamage]; %#ok<*AGROW>
        dmgTimeArray=[dmgTimeArray t(i)];
        
        %recalculate Vengeance
        vengeanceTimeline(i) = updateVengeance( timeSinceLastDmg, ...
                                                currentSwingDamage, ...
                                                vengeanceTimeline(i-1), ...
                                                swingTime, noRamp ); %#ok<*SAGROW>
        
        %recalculate Resolve
        resolveTimeline(i) = updateResolve( t(i), maxHealth, dmgTimeArray, dmgAmountArray );
        oldResolveTimeline(i) = updateOldResolve( t(i), maxHealth, dmgTimeArray, dmgAmountArray );
    %if we don't have a boss swing this timestep, just extend/cancel as appropriate
    else
        vengeanceTimeline(i) = updateVengeance( timeSinceLastDmg, ...
                                                NaN, ...
                                                vengeanceTimeline(i-1), ...
                                                swingTime, ...
                                                noRamp );
    end
    
    %periodic resolve updating 
    if nextRecalc<=0 %&& nextSwing>0
        resolveTimeline(i) = updateResolve( t(i), maxHealth, dmgTimeArray, dmgAmountArray );   
        oldResolveTimeline(i) = updateOldResolve( t(i), maxHealth, dmgTimeArray, dmgAmountArray );       
    end
    
    %reset trackers
    if nextSwing<=0
        nextSwing=swingTime;
    end
    if nextRecalc<=0
        nextRecalc=resolveRecalcTime;
    end

end

%% Plot
figure(1)
plot(t,vengeanceTimeline./max(vengeanceTimeline./2),t,oldResolveTimeline,t,resolveTimeline)
plot(t,vengeanceTimeline/10000,t,oldResolveTimeline,t,resolveTimeline)
xlabel('time (sec)')
ylabel('Vengeance (x10k) or Resolve')
legend('Vengeance','Old Resolve', 'New Resolve','Location','NorthEast')
title([' D = ' int2str(damage) ', \DeltaD = ' int2str(damageVariance) ', swing = ' num2str(swingTime, '%1.1f') ', Health = ' int2str(maxHealth)]);
