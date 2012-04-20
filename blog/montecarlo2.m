clear
dtps0=montecarlo(' ',0,10000);

stats={'dodge','hit','exp','haste','mastery'};

for k=1:length(stats)
    dtps(k,1)=montecarlo(stats{k},600,10000);
end



(dtps0-dtps).*100
    