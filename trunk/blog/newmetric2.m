% Comparative gear sets
load .\pdata\pally_smooth_data_10000_0.mat;

%% Table

li=pally_mc_table(statSetup,statblock,config,gearsets);

%% Gear sets

gl=DataTable();
gl{1,1+(1:length(gearsets))}={statSetup(gearsets).name};
gl{1:9,1}={'Set:';'Str';'Sta';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste'};
for j=1:length(gearsets)
    i=gearsets(j);
    gl{2:9,1+j}={statSetup(i).buffedStr;...
        statSetup(i).stamina;...
        statSetup(i).parryRating;...
        statSetup(i).dodgeRating;...
        statSetup(i).masteryRating;...
        statSetup(i).hitRating;...
        statSetup(i).expRating;...
        statSetup(i).hasteRating};
end
disp('<pre>')
gl.toText()
disp('</pre>')


%% Test new metric
ma=zeros([size(dmg) 7]);
hsf=repmat([statblock.health],[size(ma,1) 1]);
for i=1:7
    ma(:,:,i)=filter(ones(1,i),1,dmg)./hsf;
end

clear ma2 ma3 ma4 ma5 ma6 ma7 hsf dmg

k=4;
N=200;
M=length(statSetup);
temp=linspace(0,2,N+1)';
dbin=temp(2)-temp(1);
bins=temp(2:length(temp))-dbin./2;
histo=zeros(length(bins),M);
for i=1:M
    histo(:,i)=hist(ma(:,i,k),bins)';
end

baseline=histo(:,1);
totalevents=sum(baseline);

pct_param=0.05;
hdf=4;

%find 5% of data cutoff
j=length(baseline);
accumulator=baseline(j)./totalevents;
while accumulator<=pct_param
   j=j-1;
   accumulator=accumulator+baseline(j)./totalevents;
end
cutoff=bins(j);
cutoffj=j;
% 
% figure(1)
% bar(bins,histo(:,1:2),'stacked')
% legend('baseline','stam')
% 
% figure(2)
% bar(bins,histo(:,3)-baseline)
% xlim([cutoff 1.1*max(ma(:,1,i))])

[tmi tmiwhole] = tmi_calc(histo,bins,pct_param,hdf);
fi = fi_calc(histo,pct_param);

% 
% score=round([tmi tmiwhole fi]');
% 
% relative=round([tmi(1)-tmi tmiwhole(1)-tmiwhole fi(1)-fi]')

%weight function 
wf=exp(10.*log(hdf).*(bins-1));

% bunches of plots


figure(1);
subplot 221
bar(bins,histo(:,5:6));
legend('haste','mastery')
title(['Raw histogram, hdf=0, N=' int2str(N) ', pct=' num2str(pct_param,'%1.3f') ])
ylabel('# of events')
xlabel('% of health')
% figure(2)
subplot 222
bar(bins,histo(:,5:6));
xlim([cutoff-dbin/2 max(ma(:,6,4))]+dbin/2);
legend('haste','mastery')
title(['Raw histogram, hdf=0, N=' int2str(N) ', pct=' num2str(pct_param,'%1.3f') ])
ylabel('# of events')
xlabel('% of health')
% figure(3)
subplot 223
bar(bins,histo(:,5:6).*repmat(wf,1,2));
legend('haste','mastery')
title(['Weighted histogram, hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', pct=' num2str(pct_param,'%1.3f') ])
ylabel('weighted value')
xlabel('% of health')
% figure(4)
subplot 224
bar(bins,histo(:,5:6).*repmat(wf,1,2));
xlim([cutoff-dbin/2 max(ma(:,6,4))+dbin/2]);
legend('haste','mastery')
title(['Weighted histogram, hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', pct=' num2str(pct_param,'%1.3f') ])
ylabel('weighted value')
xlabel('% of health')

figure(10);
bar(bins,histo(:,5)-histo(:,6));
xlim([cutoff-dbin/2 max(ma(:,6,4))+dbin/2]);
legend('has-mas')
title(['Raw histogram, hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', pct=' num2str(pct_param,'%1.3f') ])
ylabel('# of events')
xlabel('% of health')

%% test scaling with pct_param for hdf=2
hdf=2;
pct_param_list=[0.01:0.01:0.1 1];
clear tmi_data tmiw_data
for i=1:length(pct_param_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param_list(i),hdf);
    tmi_data(:,i)=tmi(1)-tmi;
end
tmiw_data=tmiwhole(1)-tmiwhole;

li=DataTable();
li{1,1}='pct';
li{1+(1:length(pct_param_list)),1}=pct_param_list';
li{1,2:size(tmi_data,1)}=cellstr({statSetup(2:length(statSetup)).name});
li{1+(1:length(pct_param_list)),2:size(tmi_data,1)}=roundn(tmi_data(2:size(tmi_data,1),:),-2)';
li.setColumnFormat(1,'%1.3f')
li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', vary pct' ])
li.toText()
disp('</pre>')

%% repeat for hdf=3
hdf=3;
pct_param_list=[0.01:0.01:0.1 1];
clear tmi_data tmiw_data
for i=1:length(pct_param_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param_list(i),hdf);
    tmi_data(:,i)=tmi(1)-tmi;
end
tmiw_data=tmiwhole(1)-tmiwhole;

li=DataTable();
li{1,1}='pct';
li{1+(1:length(pct_param_list)),1}=pct_param_list';
li{1,2:size(tmi_data,1)}=cellstr({statSetup(2:length(statSetup)).name});
li{1+(1:length(pct_param_list)),2:size(tmi_data,1)}=roundn(tmi_data(2:size(tmi_data,1),:),-2)';
li.setColumnFormat(1,'%1.3f')
li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', vary pct' ])
li.toText()
disp('</pre>')

%% test scaling with hdf, fix pct_param=0.05
hdf_list=1.5:0.1:4.5;
pct_param=0.05;

for i=1:length(hdf_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param,hdf_list(i));
    tmi_data(:,i)=tmi(1)-tmi;
    tmiw_data(:,i)=tmiwhole(1)-tmiwhole;
end

li=DataTable();
li{1,1}='hdf';
li{1+(1:length(hdf_list)),1}=hdf_list';
li{1,2:size(tmi_data,1)}=cellstr({statSetup(2:length(statSetup)).name});
li{1+(1:length(hdf_list)),2:size(tmi_data,1)}=roundn(tmi_data(2:size(tmi_data,1),:),-2)';
li.setColumnFormat(1,'%1.1f')
li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')
%repeat for 0.1
pct_param=0.1;

for i=1:length(hdf_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param,hdf_list(i));
    tmi_data(:,i)=tmi(1)-tmi;
end

li=DataTable();
li{1,1}='hdf';
li{1+(1:length(hdf_list)),1}=hdf_list';
li{1,2:size(tmi_data,1)}=cellstr({statSetup(2:length(statSetup)).name});
li{1+(1:length(hdf_list)),2:size(tmi_data,1)}=roundn(tmi_data(2:size(tmi_data,1),:),-2)';
li.setColumnFormat(1,'%1.1f')
li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')

li=DataTable();
li{1,1}='hdf';
li{1+(1:length(hdf_list)),1}=hdf_list';
li{1,2:size(tmi_data,1)}=cellstr({statSetup(2:length(statSetup)).name});
li{1+(1:length(hdf_list)),2:size(tmi_data,1)}=roundn(tmiw_data(2:size(tmi_data,1),:),-2)';
li.setColumnFormat(1,'%1.1f')
li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')
