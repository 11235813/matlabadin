% clear
%setup
% fight_length=500;
damage_steps=150;
window=4;
bin_time=1; %in seconds

%construct timelines
timeline=zeros(fight_length,damage_steps);
for i=1:damage_steps
    timeline(:,i)=repmat(0.00,fight_length,1); %#ok<*SAGROW>
    timeline(37,i)=0.01*i;
end


%% different TMI calculation types

tmi_definitions;

%% Plots
x3=mean(ma)';xlbl3='Mean(MA)';
x2=max(ma)';xlbl2='Max(MA)';
x1=0.01*(1:damage_steps)';xlbl1='Size of spike';
xy1=repmat(x1,1,size(tmic,1));
xy2=repmat(x2,1,size(tmic,1));
xy3=repmat(x3,1,size(tmic,1));

figure(2)
subplot 221
plot(xy1,tmic',x1,log_tmi_old,'k--')
ylabel('TMI')
xlabel(xlbl1)
legend(tmil1,tmil2,tmil3,[int2str(c1) '*log(old)'],'Location','NorthWest')

subplot 222
plot(xy3,tmic',x3,log_tmi_old,'k--')
ylabel('TMI')
xlabel(xlbl3)
legend(tmil1,tmil2,tmil3,[int2str(c1) '*log(old)'],'Location','NorthWest')

subplot 223
xx=repmat(tmi_old',1,size(tmic,1));
semilogx(xx,tmic')
xlabel('Old TMI')
ylabel('New TMI')
legend(tmil1,tmil2,tmil3,'Location','Northwest')

subplot 224
plot(xy2,tmic',x2,log_tmi_old,'k--')
ylabel('TMI')
xlabel(xlbl2)
legend(tmil1,tmil2,tmil3,[int2str(c1) '*log(old)'],'Location','NorthWest')

% figure(5)
% yq=tmic(1,:)';
% plot(x2(1:length(x2)-1),0.1*diff(yq)./diff(x2))
% xlabel('Max(MA)')

%save for later

ss.tmie=tmic(1,:)';
ss.tmi10=tmic(3,:)';
ss.meanma=x3;
ss.maxma=x2;
ss.sizeofspike=x1;