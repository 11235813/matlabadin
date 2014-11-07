function [ newValue ] = updateResolve( t, maxHealth, dmgTimeArray, dmgAmountArray )
%UPDATERESOLVE recalculates Resolve
%inputs: t              - current time
%        maxHealth      - player's max health
%        dmgTimeArray   - array of timestamps of damage events
%        dmgAmountArray - array of damage amounts of damage events
%output: newValue       - recalculated Resolve

if nargin<4
    error('Resolve cannot be calculated without all three input arguments')
end

%initialize accumulator
decayedDamage=0;

%walk backward through the time array and add to the accumulator
i=length(dmgTimeArray);
dt=t-dmgTimeArray(i);
while i>0 && dt>=0 && dt<=10
    %calculate resolve contribution from this hit
    %note that dmgAmountArray is already normalized to maxHealth
    contribution=dmgAmountArray(i)*2*(10-dt)/10; 
    
    %sanity checks / caps
    if contribution>0 %&& (any sort of cap calculation)
        decayedDamage=decayedDamage+contribution;
    end
    
    %recalculate dt
    i=i-1;
    if i>0
        dt=t-dmgTimeArray(i);
    end
    
end

newValue=0.25*decayedDamage/maxHealth;

end

