clear
% Comparative gear sets
% load .\pdata\pally_smooth_data_10000_0.mat;

% lower boss damage
load .\pdata\pally_smooth_data_10000_1.mat;

%% Table

li=pally_mc_table(statSetup,statblock,config,gearsets);

%% Gear sets

gl=DataTable();
gl{1+(1:length(gearsets)),1}=cellstr({statSetup(gearsets).name})';
gl{1,1:9}={'Set:';'Str';'Sta';'Parry';'Dodge';'Mastery';'Hit';'Exp';'Haste'}';
for j=1:length(gearsets)
    i=gearsets(j);
    gl{1+j,2:9}={statSetup(i).buffedStr...
        statSetup(i).stamina...
        statSetup(i).parryRating...
        statSetup(i).dodgeRating...
        statSetup(i).masteryRating...
        statSetup(i).hitRating...
        statSetup(i).expRating...
        statSetup(i).hasteRating};
end
disp('<pre>')
gl.toText()
disp('</pre>')


%% Test new metric
clear dmg
dmg=[statblock(:).dmg];

ma=zeros([size(dmg) 7]);

health=[statblock.health];
hsf=repmat(health,[size(ma,1) 1]);
for i=1:7
    ma(:,:,i)=filter(ones(1,i),1,dmg)./hsf;
end

clear ma2 ma3 ma4 ma5 ma6 ma7 hsf statblock

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

%% bunches of plots
 
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
% hdf=2;
% pct_param_list=[0.01:0.01:0.1 1];
% clear tmi_data tmiw_data
% for i=1:length(pct_param_list)
%     [tmi tmiwhole] = tmi_calc(histo,bins,pct_param_list(i),hdf);
%     tmi_data(:,i)=tmi;
% end
% tmiw_data=tmiwhole;
% 
% li=DataTable();
% li{1,1}='pct';
% li{1+(1:length(pct_param_list)),1}=pct_param_list';
% li{1,1+(1:size(tmi_data,1))}=cellstr({statSetup(1:length(statSetup)).name});
% li{1+(1:length(pct_param_list)),1+(1:size(tmi_data,1))}=roundn(tmi_data(1:size(tmi_data,1),:),ceil(log10(min(min(tmi_data)))-4))';
% li.setColumnFormat(1,'%1.3f')
% % li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
% disp('<pre>')
% disp(['hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', vary pct' ])
% li.toText()
% disp('</pre>')

%% repeat for hdf=3
hdf=3;
pct_param_list=[0.01 0.05 0.1 1];
clear tmi_data tmiw_data
for i=1:length(pct_param_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param_list(i),hdf);
    tmi_data(:,i)=tmi;
end
tmiw_data=tmiwhole;

li=DataTable();
li{1,1}='pct->';
for j=1:length(pct_param_list)
    li{1,1+j}=[int2str(round(pct_param_list(j).*100)) '%'];
end
li{1+(1:size(tmi_data,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmi_data,1)),1+(1:length(pct_param_list))}=roundn(tmi_data,ceil(log10(min(min(tmi_data)))-4));
% li.setColumnFormat(1,'%1.3f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['hdf=' num2str(hdf,'%2.2f') ', N=' int2str(N) ', vary pct' ])
li.toText()
disp('</pre>')

%% test scaling with hdf, fix pct_param=0.05
hdf_list=2.5:0.1:3.5;
pct_param=0.05;
clear tmi_data tmiw_data
for i=1:length(hdf_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param,hdf_list(i));
    tmi_data(:,i)=tmi;
    tmiw_data(:,i)=tmiwhole;
end

li=DataTable();
li{1,1}='hdf->';
for j=1:length(hdf_list)
    li{1,1+j}=num2str(hdf_list(j),'%1.1f');
end
li{1+(1:size(tmi_data,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmi_data,1)),1+(1:length(hdf_list))}=roundn(tmi_data,ceil(log10(min(min(tmi_data))))-4);
% li.setColumnFormat(1,'%1.1f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')

%repeat for 0.1
pct_param=0.1;

for i=1:length(hdf_list)
    [tmi tmiwhole] = tmi_calc(histo,bins,pct_param,hdf_list(i));
    tmi_data(:,i)=tmi;
end

li=DataTable();
li{1,1}='hdf->';
for j=1:length(hdf_list)
    li{1,1+j}=num2str(hdf_list(j),'%1.1f');
end
li{1+(1:size(tmi_data,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmi_data,1)),1+(1:length(hdf_list))}=roundn(tmi_data,ceil(log10(min(min(tmi_data))))-4);
% li.setColumnFormat(1,'%1.1f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(pct_param,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')


li=DataTable();
li{1,1}='hdf->';
for j=1:length(hdf_list)
    li{1,1+j}=num2str(hdf_list(j),'%1.1f');
end
li{1+(1:size(tmiw_data,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmiw_data,1)),1+(1:length(hdf_list))}=roundn(tmiw_data,ceil(log10(min(min(tmiw_data))))-4);
% li.setColumnFormat(1,'%1.1f')
% li.setColumnFormat(2:size(tmi_data,1),'%4.2f')
disp('<pre>')
disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')

%% 
li=DataTable();
li{1,1}='Set';
li{1,2}='TMI';
li{1+(1:size(tmiw_data,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmiw_data,1)),2}=roundn(tmiw_data(:,6),ceil(log10(min(min(tmiw_data(:,6)))))-4);
disp('<pre>')
disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')


%% final form
tmif=tmi_final(dmg,health);

li=DataTable();
li{1,1}='Set';
li{1,2:6}={'TMI-3' 'TMI' 'TMI-5' 'TMI-6' 'TMI-7'};
li{1+(1:size(tmif,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmif,1)),2:6}=roundn(tmif(:,1:5),ceil(log10(min(min(tmif(:,1:5)))))-4);
disp('<pre>')
disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')


li=DataTable();
li{1,1}='Set';
li{1,2}='TMI';
li{1+(1:size(tmif,1)),1}=cellstr({statSetup(1:length(statSetup)).name})';
li{1+(1:size(tmif,1)),2}=roundn(tmif(:,2),ceil(log10(min(min(tmif(:,2)))))-4);
li.setColumnFormat(2,'%3.1f')
disp('<pre>')
disp(['pct=' num2str(100,'%2.2f') ', N=' int2str(N) ', vary hdf' ])
li.toText()
disp('</pre>')
