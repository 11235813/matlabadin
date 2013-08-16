% Repeatability tests
clear
%C/ha gear set
load .\pdata\pally_metric_data_10000_6.mat;

%% Table

li=pally_mc_table(statSetup,statblock,config,gearsets);


%% Test new metric
clear dmg
dmg=[statblock(:).dmg];

ma=zeros([size(dmg) 7]);
ma2=ma;

%% normalize for health
health=[statblock.health];
hsf=repmat(health,[size(ma,1) 1]);
for i=1:7
    ma(:,:,i)=filter(ones(1,i),1,dmg)./hsf;
end

clear ma2 ma3 ma4 ma5 ma6 ma7 statblock hsf 
%% 
N=200;
M=size(ma,2);
temp=linspace(0,2,N+1)';
dbin=temp(2)-temp(1);
bins=temp(2:length(temp))-dbin./2;
histo=zeros(length(bins),M,7);
wf=exp(10.*log(3).*(bins-1));
for k=2:7
    for i=1:M
        histo(:,i,k)=hist(ma(:,i,k),bins)';
    end
    
    tmi(:,k)= tmi_calc(histo(:,:,k),bins,1,3);

    figure(1)
    set(gcf,'Position',[10    50   800   950])
    subplot(3,2,k-1)
    bar(bins,histo(:,:,k)./1e3);
    title(['H-normalized, N_{att}=' int2str(k)])
    xlabel('% health')
    ylabel('num events (thousands)')
%     
    figure(2)
    set(gcf,'Position',[830    50   800   948])
    subplot(3,2,k-1)
    bar(bins,histo(:,:,k).*repmat(wf,1,size(histo,2))./1000)
    title(['H-normalized and weighted, N_{att}=' int2str(k)])
    xlabel('% health')
    ylabel('weight value (thousands)')
%     
end

%% normalize for num swings (time)
for k=2:7
    ma2(:,:,k)=ma(:,:,k).*4./k;
    for i=1:M
        histo2(:,i,k)=hist(ma2(:,i,k),bins)';
    end
        
    tmi2(:,k)= tmi_calc(histo2(:,:,k),bins,1,3);
    
    figure(3)
    set(gcf,'Position',[10    50   800   950])
    subplot(3,2,k-1)
    bar(bins,histo2(:,:,k)./1000);
    title(['HT-normalized, N_{att}=' int2str(k)])
    xlabel('% health')
    ylabel('num events (thousands)')
    
    figure(4)
    set(gcf,'Position',[830    50   800   948])
    subplot(3,2,k-1)
    bar(bins,histo2(:,:,k).*repmat(wf,1,size(histo2,2))./1000);
    title(['HT-normalized, N_{att}=' int2str(k)])
    xlabel('% health')
    ylabel('weight value (thousands)')
end

%% normalize for num events (length)

for k=2:7
    for j=1:size(histo2,2)
        histo3(:,j,k)=histo2(:,j,k)./sum(histo2(:,j,k));
    end
   tmi3(:,k)=tmi_calc(histo3(:,:,k),bins,1,3);
   
   figure(5)
    set(gcf,'Position',[10    50   800   950])
    subplot(3,2,k-1)
    bar(bins,histo3(:,:,k));
    title(['HTE-normalized, N_{att}=' int2str(k)])
    xlabel('% health')
    ylabel('pct of events (%)')
    
   figure(6)
    set(gcf,'Position',[830    50   800   948])
    subplot(3,2,k-1)
    bar(bins,histo3(:,:,k).*repmat(wf,1,size(histo3,2)).*1000);
    title(['HTE-normalized, N_{att}=' int2str(k)])
    xlabel('% health')
    ylabel('weight value (x1000)')
end

%% 
clear ma ma2

%% final tmi calculation 

tmif=tmi_final(dmg,health)

%
% baseline=histo(:,1,4);
% totalevents=sum(baseline);
% 
% pct_param=0.05;
% hdf=3;
% 
% %find 5% of data cutoff
% j=length(baseline);
% accumulator=baseline(j)./totalevents;
% while accumulator<=pct_param
%    j=j-1;
%    accumulator=accumulator+baseline(j)./totalevents;
% end
% cutoff=bins(j);
% cutoffj=j;
% 
% %% calculate metric
% tmi=zeros(M,7);
% tmiwhole=tmi;
% for k=2:7
%     [tmi(:,k) tmiwhole(:,k)] = tmi_calc(histo(:,:,k),bins,pct_param,hdf);
% end
% 
% %weight function 
% wf=exp(10.*log(hdf).*(bins-1));
% 
% %quick numerical analysis
% meantmi=mean(tmi);
% stdtmi=std(tmi);
% stdmtmi=std(tmi)./20;
% pctvar=stdmtmi./meantmi.*100;
% 
% 
% %% test scaling with pct_param for hdf=2
% hdf=3;
% pct_param_list=[0.01 0.05 0.1 1];
% clear tmi_data tmiw_data
% for i=1:length(pct_param_list)
%     k=4;
%     [tmi tmiwhole] = tmi_calc(histo(:,:,k),bins,pct_param_list(i),hdf);
%     tmi_data(:,i)=tmi;
% end
% tmiw_data=tmiwhole;
% 
% li=DataTable();
% li{1,1}='trial';
% for j=1:length(pct_param_list)
%     li{1,1+j}=[int2str(round(100.*pct_param_list(j))) '%'];
% end
% for j=1:length(gearsets)
%     li{1+j,1}=['#' int2str(j)];
% end
% roundlevel=ceil(log10(min(min(tmi_data)))-4);
% li{1+(1:size(tmi_data,1)),1+(1:length(pct_param_list))}=roundn(tmi_data,roundlevel);
% li{2+size(tmi_data,1),1}='mean';
% li{2+size(tmi_data,1),1+(1:length(pct_param_list))}=roundn(mean(tmi_data),roundlevel);
% li{3+size(tmi_data,1),1}='std';
%     li{4+size(tmi_data,1),1}='std_mean';
%     li{5+size(tmi_data,1),1}='pct_var';
% for j=1:length(pct_param_list)
%     li{3+size(tmi_data,1),1+j}=num2str(std(tmi_data(:,j)),'%5.2f');
%     li{4+size(tmi_data,1),1+j}=num2str(std(tmi_data(:,j))./size(tmi_data,1),'%5.2f');
%     li{5+size(tmi_data,1),1+j}=num2str(std(tmi_data(:,j))./size(tmi_data,1)./mean(tmi_data(:,j)).*100,'%5.2f');
% end
% % li.setColumnFormat(1,'%1.3f')
% % li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
% disp('<pre>')
% disp(['hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', vary pct' ])
% li.toText()
% disp('</pre>')
% 
% 
% %% test scaling with hdf, fix pct_param=0.05
% hdf_list=1.5:0.1:4.5;
% pct_param=0.05;
% 
% for i=1:length(hdf_list)
%     k=4;
%     [tmi tmiwhole] = tmi_calc(histo(:,:,k),bins,pct_param,hdf_list(i));
%     tmi_data(:,i)=tmi;
%     tmiw_data(:,i)=tmiwhole;
% end
% roundlevel=ceil(log10(min(min(tmi_data)))-5);
% 
% li=DataTable();
% li{1,1}='hdf';
% li{1+(1:length(hdf_list)),1}=hdf_list';
% li{1,2:5}=cellstr({'mean' 'std' 'std_mean' 'pct_var'});
% for j=1:length(hdf_list)
%     li{1+j,2}=roundn(mean(tmi_data(:,j)),roundlevel)';
%     li{1+j,3}=num2str(std(tmi_data(:,j)),'%5.2f')';
%     li{1+j,4}=num2str(std(tmi_data(:,j))./size(tmi_data,1),'%5.2f')';  
%     li{1+j,5}=num2str(std(tmi_data(:,j))./size(tmi_data,1)./mean(tmi_data(:,j)).*100,'%5.2f')';  
% end
% li.setColumnFormat(1,'%1.1f')
% % li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
% disp('<pre>')
% disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
% li.toText()
% disp('</pre>')
% 
% %% repeat for 0.1
% pct_param=0.1;
% 
% for i=1:length(hdf_list)
%     k=4;
%     [tmi tmiwhole] = tmi_calc(histo(:,:,k),bins,pct_param,hdf_list(i));
%     tmi_data(:,i)=tmi;
%     tmiw_data(:,i)=tmiwhole;
% end
% roundlevel=ceil(log10(min(min(tmi_data)))-5);
% 
% li=DataTable();
% li{1,1}='hdf';
% li{1+(1:length(hdf_list)),1}=hdf_list';
% li{1,2:5}=cellstr({'mean' 'std' 'std_mean' 'pct_var'});
% for j=1:length(hdf_list)
%     li{1+j,2}=roundn(mean(tmi_data(:,j)),roundlevel)';
%     li{1+j,3}=num2str(std(tmi_data(:,j)),'%5.2f')';
%     li{1+j,4}=num2str(std(tmi_data(:,j))./size(tmi_data,1),'%5.2f')';  
%     li{1+j,5}=num2str(std(tmi_data(:,j))./size(tmi_data,1)./mean(tmi_data(:,j)).*100,'%5.2f')';  
% end
% li.setColumnFormat(1,'%1.1f')
% % li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
% disp('<pre>')
% disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
% li.toText()
% disp('</pre>')
% 
% % and for 100%
% li=DataTable();
% li{1,1}='hdf';
% li{1+(1:length(hdf_list)),1}=hdf_list';
% li{1,2:5}=cellstr({'mean' 'std' 'std_mean' 'pct_var'});
% for j=1:length(hdf_list)
%     li{1+j,2}=roundn(mean(tmiw_data(:,j)),roundlevel)';
%     li{1+j,3}=num2str(std(tmiw_data(:,j)),'%5.2f')';
%     li{1+j,4}=num2str(std(tmiw_data(:,j))./size(tmiw_data,1),'%5.2f')';  
%     li{1+j,5}=num2str(std(tmiw_data(:,j))./size(tmiw_data,1)./mean(tmiw_data(:,j)).*100,'%5.2f')';  
% end
% li.setColumnFormat(1,'%1.1f')
% % li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
% disp('<pre>')
% disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
% li.toText()
% disp('</pre>')
