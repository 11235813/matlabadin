%% DON'T FORGET TO SET HIT/EXP TO 0 IN WARR_MC
warning('Don''t forget to set hit/exp to 0 in warr_mc')
%%
clear
% stats={' ','hit'};
simMins=10000; %10000
numSims=50; %50
% statAmount=500;
% hit=[0:1:7.5];
exp=[0:1:15];
% hit=[hit zeros(size(exp))];
% exp=[zeros(size(hit)) exp];

if matlabpool('size')>0
    matlabpool close
end

matlabpool(3)

W=waitbar(0,'Calculating');
tic
for k=1:length(exp)
    
    waitbar((k-1)./length(exp),W,['Calculating ' num2str(exp(k),'%2.2f') '% exp']);
    statAmount=500;
    baseStatAmount=exp(k).*340;
    parfor j=1:numSims
        
        
        [dtps0(j,k) statblock0(j,k)]=warr_mc('exp',baseStatAmount,simMins,'noplot','notoc');
        Rrage0(j,k) = statblock0(j,k).Rrage;
        S0(j,k)      =statblock0(j,k).S;
        Tsb0(j,k)  =statblock0(j,k).Tsb;
        
        [dtps(j,k) statblock(j,k)]=warr_mc('exp',baseStatAmount+statAmount,simMins,'noplot','notoc');
        Rrage(j,k)   =statblock(j,k).Rrage;
        S(j,k)      =statblock(j,k).S;
        Tsb(j,k)  =statblock(j,k).Tsb;
        
    end
    waitbar(k./length(exp),W,['Calculating ' num2str(exp(k),'%2.2f') '% exp']);
end
close(W)
toc

    
matlabpool close
save(['warr_rg_data_' int2str(simMins) '_' int2str(numSims) '_' int2str(statAmount) '.mat'])

%% calculate stats
% mean_dtps=mean(dtps);
% mean_dtps0=mean(dtps0);
% std_dtps=std(dtps);
% normfactor=(mean_dtps0(1)-mean_dtps(1));


mean_rps=mean(Rrage0);
mean_sbu=mean(S);


drps=dtps0-dtps;
mean_drps=mean(drps);
std_drps=std(drps);
std_mean_drps=std_drps./sqrt(numSims);

norm_mean_drps=mean_drps./mean_drps(1);
norm_std_drps=std_drps./mean_drps(1);
norm_std_mean_drps=std_mean_drps./mean_drps(1);

%% Pretty print
addpath('C:\Users\George\Documents\MATLAB\mop\helper_func')
li=DataTable();
L=1+length(mean_drps);

li{1,1:6}={'exp%','mean','std','std_mean','rps','sbu'};
li{2:L,1}=exp';
li{2:L,2}=norm_mean_drps';
li{2:L,3}=norm_std_drps';
li{2:L,4}=norm_std_mean_drps';
li{2:L,5}=mean_rps';
li{2:L,6}=mean_sbu';
% 
% li{6,2:L}=mean_drps(2:length(mean_drps))./mean_drps(length(mean_drps));
% li{7,2:L}=std_drps(2:length(mean_drps))./mean_drps(length(mean_drps));
% li{8,2:L}=std_mean_drps(2:length(mean_drps))./mean_drps(length(mean_drps));
% li{6:8,1}={'mean';'std';'std_mean'};

li.setColumnFormat(1:6, '%2.4f');

['N=' int2str(numSims) ', \tau=' int2str(simMins) ', stat=' int2str(statAmount)]
% [mean_drps;std_drps;std_mean_drps]
% [mean_drps;std_drps;std_mean_drps]./mean_drps(length(mean_drps))

li.toText()
%% output

figure(1)
errorbar(exp,norm_mean_drps,norm_std_mean_drps)
xlabel('expertise (%)')
ylabel('\mu \pm \sigma_{\rm mean}')

figure(2)
% clf
% hold on
[ax,h1,h2]=plotyy(exp,mean_rps,exp,mean_sbu.*100);
xlabel('Expertise (%)')
set(get(ax(1),'Ylabel'),'String','Rage Generation (rps)')
set(get(ax(2),'Ylabel'),'String','Shield Block Uptime (%)')
set(ax(1),'YTick',[6:0.5:8])
set(ax(2),'YTick',[60:2.5:70])

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