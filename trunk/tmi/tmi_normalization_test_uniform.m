% clear
%setup
damage_steps=-0.1:0.01:0.6;
window=4;
bin_time=1; %in seconds
padding=10;

%construct timelines
timeline=zeros(fight_length+padding,length(damage_steps));
for i=1:length(damage_steps)
    timeline(:,i)=repmat(damage_steps(i),fight_length+padding,1); %#ok<*SAGROW>
%     timeline(37,i)=0.01*i;
end


%% different TMI calculation types

%construct moving average 
temp_moving_average=filter(ones(4,1),1,timeline);
%cheat a bit by fixing end points
moving_average=temp_moving_average(window:(window+fight_length-1),:);

tmi_definitions;


%% Plots
x=mean(ma)';
xx=repmat(tmi_old',1,size(tmic,1));
xy=repmat(x,1,size(tmic,1));
xz=repmat(max(ma)',1,size(tmic,1));
% 
% figure(4)
% subplot 221
% plot(x,tmi_old,'k',xy,tmic')
% ylabel('TMI')
% xlabel('Mean(MA)')
% legend('old',tmil1,tmil2,tmil3,'Location','NorthWest')
% title('Uniform Damage Intake')
% 
% subplot 222
% plot(xy,tmic',x,log_tmi_old,'k--')
% xlabel('Mean(MA)')
% ylabel('TMI')
% legend(tmil1,tmil2,tmil3,[int2str(c1) '*log(old)'],'Location','NorthWest')
% 
% subplot 223
% semilogx(xx,tmic')
% xlabel('Old TMI')
% ylabel('New TMI')
% legend(tmil1,tmil2,tmil3,'Location','Northwest')
% 
% subplot 224
% plot(xz,tmic')
% xlabel('Mean(MA)')
% ylabel('New TMI')
% legend(tmil1,tmil2,tmil3,'Location','Northwest')


% figure(7)
% xq=mean(ma)';
% yq=tmic(1,:)';
% plot(xq(1:length(xq)-1),0.1*diff(yq)./diff(xq))
% xlabel('Mean(MA)')
% ylabel('0.1*Diff(New TMI)/Diff(Mean(MA))')

uf.tmie=tmic(1,:)';
uf.tmi10=tmic(3,:)';
uf.meanma=x;
uf.maxma=max(ma)';