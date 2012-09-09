clear
stats={' ','dodge','parry','hit','exp','mastery'};
simMins=10000;
numSims=50;
statAmount=500;

if matlabpool('size')>0
    matlabpool close
end

matlabpool(3)

W=waitbar(0,'Calculating');
tic
for k=1:length(stats)
    waitbar((k-1)./length(stats),W,['Calculating ' stats{k}]);
    parfor j=1:numSims
%     for j=1:numSims
%         tic
        [dtps(j,k) statblock(j,k)]=warr_mc(stats{k},statAmount,simMins,'noplot','notoc');
        Rrage(j,k)   =statblock(j,k).Rrage;
        S(j,k)      =statblock(j,k).S;
        Tsb(j,k)  =statblock(j,k).Tsb;
        MAmean(j,k) =statblock(j,k).meanma;
        MAstd(j,k)  =statblock(j,k).stdma;
%         toc
    end
    waitbar(k./length(stats),W,['Calculating ' stats{k}]);
end
close(W)
toc

    
matlabpool close
save(['warr_sw_data_' int2str(simMins) '_' int2str(numSims) '_' int2str(statAmount) '.mat'])

%% calculate stats
mean_dtps=mean(dtps);
std_dtps=std(dtps);
norm_dtps=dtps./mean_dtps(1);


% (repmat(dtps(1),length(dtps),1)-dtps).*100
drps=repmat(dtps(:,1),1,size(dtps,2))-dtps;
mean_drps=mean(drps);
std_drps=std(drps);
std_mean_drps=std_drps./sqrt(numSims);
norm_mean_drps=mean_drps./max(mean_drps);
norm_std_drps=std_drps./max(mean_drps);

%% Pretty print
addpath('C:\Users\George\Documents\MATLAB\mop\helper_func')
li=DataTable();
L=length(mean_drps);

li{1,2:L}=stats(2:length(stats));
li{2,2:L}=mean_drps(2:length(mean_drps));
li{3,2:L}=std_drps(2:length(mean_drps));
li{4,2:L}=std_mean_drps(2:length(mean_drps));
li{2:4,1}={'mean';'std';'std_mean'};

li{6,2:L}=mean_drps(2:length(mean_drps))./mean_drps(length(mean_drps));
li{7,2:L}=std_drps(2:length(mean_drps))./mean_drps(length(mean_drps));
li{8,2:L}=std_mean_drps(2:length(mean_drps))./mean_drps(length(mean_drps));
li{6:8,1}={'mean';'std';'std_mean'};

li.setColumnFormat(2:L, '%1.4f');

['N=' int2str(numSims) ', \tau=' int2str(simMins) ', stat=' int2str(statAmount)]
% [mean_drps;std_drps;std_mean_drps]
% [mean_drps;std_drps;std_mean_drps]./mean_drps(length(mean_drps))

li.toText()
%% output
% figure(2);
% hist(normDTPS(:,2));
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','r','EdgeColor','w')
% % xlim([0.25 1])
% hold on
% hist(normDTPS(:,3));
% hold off
% ylabel(['Number of simulations (out of ' int2str(numSims) ')'])
% xlabel('Dodge (blue) or Hit (red)')
% 
% 
% figure(3)
% hist(Tsotr)
% ylabel(['Number of simulations (out of ' int2str(k) ')'])
% xlabel('T_{\rm SotR}')
%  
% figure(4)
% hist(Rhpg)
% ylabel(['Number of simulations (out of ' int2str(k) ')'])
% xlabel('R_{\rm HPG}')

% stdG=std(G)
% stdS=std(S)
% stdT=std(Tsotr)
% stdR=std(Rhpg)