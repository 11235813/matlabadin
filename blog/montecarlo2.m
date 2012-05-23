clear
% dtps0=montecarlo(' ',0,10000);

stats={' ','dodge','hit','exp','haste','mastery'};

if matlabpool('size')>0
    matlabpool close
end

matlabpool(3)

parfor k=1:length(stats)
    dtps(k,1)=montecarlo(stats{k},600,10000);
end



(repmat(dtps(1),length(dtps),1)-dtps).*100
    
matlabpool close