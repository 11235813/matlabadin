clear
stats={' ','dodge','hit','exp','haste','mastery'};
simMins=10000;
numSims=10;
statAmount=600;

if matlabpool('size')>0
    matlabpool close
end

matlabpool(3)

W=waitbar(0,'Calculating');
for k=1:length(stats)
    waitbar((k-1)./length(stats),W,['Calculating ' stats{k}]);
    parfor j=1:numSims
        [dtps(j,k) statblock]=montecarlo(stats{k},statAmount,simMins,'noplot','notoc');
        Rhpg(j,k)   =statblock.Rhpg;
        S(j,k)      =statblock.S;
        Tsotr(j,k)  =statblock.Tsotr;
    end
    waitbar(k./length(stats),W,['Calculating ' stats{k}]);
end
close(W)


    
matlabpool close
save(['montecarlo3data_' int2str(simMins) '_' int2str(numSims) '.mat'])

%% calculate stats
mean_dtps=mean(dtps);
std_dtps=std(dtps);
norm_dtps=dtps./mean_dtps(1);


% (repmat(dtps(1),length(dtps),1)-dtps).*100
drps=repmat(dtps(:,1),1,size(dtps,2))-dtps;
mean_drps=mean(drps);
std_drps=std(drps);
norm_mean_drps=mean_drps./max(mean_drps);
norm_std_drps=std_drps./max(mean_drps);

%% plots
figure(2);
hist(normDTPS(:,2));
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
% xlim([0.25 1])
hold on
hist(normDTPS(:,3));
hold off
ylabel(['Number of simulations (out of ' int2str(numSims) ')'])
xlabel('Dodge (blue) or Hit (red)')


figure(3)
hist(Tsotr)
ylabel(['Number of simulations (out of ' int2str(k) ')'])
xlabel('T_{\rm SotR}')
 
figure(4)
hist(Rhpg)
ylabel(['Number of simulations (out of ' int2str(k) ')'])
xlabel('R_{\rm HPG}')

% stdG=std(G)
% stdS=std(S)
% stdT=std(Tsotr)
% stdR=std(Rhpg)