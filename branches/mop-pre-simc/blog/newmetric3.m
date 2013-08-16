% Repeatability tests
clear
%C/ha gear set
% load .\pdata\pally_metric_data_10000_6.mat;

%Av gear set
load .\pdata\pally_metric_data_10000_7.mat

%% Table

li=pally_mc_table(statSetup,statblock,config,gearsets);


%% Test new metric
clear dmg
dmg=[statblock(:).dmg];

ma=zeros([size(dmg) 7]);
health=[statblock.health];
hsf=repmat(health,[size(ma,1) 1]);
for i=1:7
    ma(:,:,i)=filter(ones(1,i),1,dmg)./hsf;
end

clear ma2 ma3 ma4 ma5 ma6 ma7 hsf dmg statblock
%% 
N=200;
M=size(ma,2);
temp=linspace(0,2,N+1)';
dbin=temp(2)-temp(1);
bins=temp(2:length(temp))-dbin./2;
histo=zeros(length(bins),M,7);
for k=2:7
    for i=1:M
        histo(:,i,k)=hist(ma(:,i,k),bins)';
    end
end

baseline=histo(:,1,4);
totalevents=sum(baseline);

pct_param=0.05;
hdf=3;

%find 5% of data cutoff
j=length(baseline);
accumulator=baseline(j)./totalevents;
while accumulator<=pct_param
   j=j-1;
   accumulator=accumulator+baseline(j)./totalevents;
end
cutoff=bins(j);
cutoffj=j;

%% calculate metric
tmi=zeros(M,7);
tmiwhole=tmi;
for k=2:7
    [tmi(:,k) tmiwhole(:,k)] = tmi_calc(histo(:,:,k),bins,pct_param,hdf);
end

%weight function 
wf=exp(10.*log(hdf).*(bins-1));

%quick numerical analysis
meantmi=mean(tmi);
stdtmi=std(tmi);
stdmtmi=std(tmi)./20;
pctvar=stdmtmi./meantmi.*100;


%% test scaling with pct_param for hdf=2
hdf=3;
pct_param_list=[0.01 0.05 0.1 1];
clear tmi_data tmiw_data
for i=1:length(pct_param_list)
    k=4;
    [tmi tmiwhole] = tmi_calc(histo(:,:,k),bins,pct_param_list(i),hdf);
    tmi_data(:,i)=tmi;
end
tmiw_data=tmiwhole;

li=DataTable();
li{1,1}='trial';
for j=1:length(pct_param_list)
    li{1,1+j}=[int2str(round(100.*pct_param_list(j))) '%'];
end
for j=1:length(gearsets)
    li{1+j,1}=['#' int2str(j)];
end
roundlevel=ceil(log10(min(min(tmi_data)))-4);
li{1+(1:size(tmi_data,1)),1+(1:length(pct_param_list))}=roundn(tmi_data,roundlevel);
li{2+size(tmi_data,1),1}='mean';
li{2+size(tmi_data,1),1+(1:length(pct_param_list))}=roundn(mean(tmi_data),roundlevel);
li{3+size(tmi_data,1),1}='std';
    li{4+size(tmi_data,1),1}='std_mean';
    li{5+size(tmi_data,1),1}='pct_var';
for j=1:length(pct_param_list)
    li{3+size(tmi_data,1),1+j}=num2str(std(tmi_data(:,j)),'%5.2f');
    li{4+size(tmi_data,1),1+j}=num2str(std(tmi_data(:,j))./size(tmi_data,1),'%5.2f');
    li{5+size(tmi_data,1),1+j}=num2str(std(tmi_data(:,j))./size(tmi_data,1)./mean(tmi_data(:,j)).*100,'%5.2f');
end
% li.setColumnFormat(1,'%1.3f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', vary pct' ])
li.toText()
disp('</pre>')


%% test scaling with hdf, fix pct_param=0.05
hdf_list=1.5:0.1:4.5;
pct_param=0.05;

for i=1:length(hdf_list)
    k=4;
    [tmi tmiwhole] = tmi_calc(histo(:,:,k),bins,pct_param,hdf_list(i));
    tmi_data(:,i)=tmi;
    tmiw_data(:,i)=tmiwhole;
end
roundlevel=ceil(log10(min(min(tmi_data)))-5);

li=DataTable();
li{1,1}='hdf';
li{1+(1:length(hdf_list)),1}=hdf_list';
li{1,2:5}=cellstr({'mean' 'std' 'std_mean' 'pct_var'});
for j=1:length(hdf_list)
    li{1+j,2}=roundn(mean(tmi_data(:,j)),roundlevel)';
    li{1+j,3}=num2str(std(tmi_data(:,j)),'%5.2f')';
    li{1+j,4}=num2str(std(tmi_data(:,j))./size(tmi_data,1),'%5.2f')';  
    li{1+j,5}=num2str(std(tmi_data(:,j))./size(tmi_data,1)./mean(tmi_data(:,j)).*100,'%5.2f')';  
end
li.setColumnFormat(1,'%1.1f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')

%% repeat for 0.1
pct_param=0.1;

for i=1:length(hdf_list)
    k=4;
    [tmi tmiwhole] = tmi_calc(histo(:,:,k),bins,pct_param,hdf_list(i));
    tmi_data(:,i)=tmi;
    tmiw_data(:,i)=tmiwhole;
end
roundlevel=ceil(log10(min(min(tmi_data)))-5);

li=DataTable();
li{1,1}='hdf';
li{1+(1:length(hdf_list)),1}=hdf_list';
li{1,2:5}=cellstr({'mean' 'std' 'std_mean' 'pct_var'});
for j=1:length(hdf_list)
    li{1+j,2}=roundn(mean(tmi_data(:,j)),roundlevel)';
    li{1+j,3}=num2str(std(tmi_data(:,j)),'%5.2f')';
    li{1+j,4}=num2str(std(tmi_data(:,j))./size(tmi_data,1),'%5.2f')';  
    li{1+j,5}=num2str(std(tmi_data(:,j))./size(tmi_data,1)./mean(tmi_data(:,j)).*100,'%5.2f')';  
end
li.setColumnFormat(1,'%1.1f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')

% and for 100%
li=DataTable();
li{1,1}='hdf';
li{1+(1:length(hdf_list)),1}=hdf_list';
li{1,2:5}=cellstr({'mean' 'std' 'std_mean' 'pct_var'});
for j=1:length(hdf_list)
    li{1+j,2}=roundn(mean(tmiw_data(:,j)),roundlevel)';
    li{1+j,3}=num2str(std(tmiw_data(:,j)),'%5.2f')';
    li{1+j,4}=num2str(std(tmiw_data(:,j))./size(tmiw_data,1),'%5.2f')';  
    li{1+j,5}=num2str(std(tmiw_data(:,j))./size(tmiw_data,1)./mean(tmiw_data(:,j)).*100,'%5.2f')';  
end
li.setColumnFormat(1,'%1.1f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')

