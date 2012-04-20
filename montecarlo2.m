
stats={'dodge','hit','exp','haste','mastery'};

for k=1:length(stats)
    dtps(k,1)=montecarlo(stats{k});
end

dtps0=montecarlo;


(dtps0-dtps).*1000
    