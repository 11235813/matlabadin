% clear
%setup
% damage_mean=0.30; %in units of player health
damage_mean=0.01:0.01:0.50;
damage_range=0.2; %in units of damage_mean; i.e. 0.2 means +/-20% of mean dmg
swing_timer=1.5; %in seconds

% fight_length=500; %in seconds
window=6; %in seconds
bin_time=1; %in seconds

avoidance=0.3;
sotr_chance=0.0;
sotr_value=0.5;

%% construct arrays
num_swings=floor(fight_length/swing_timer);

timeline=zeros(fight_length/bin_time,length(damage_mean));


%% generate crazy fake example data set
for j=1:length(damage_mean)
    for i=1:num_swings
        
        if rand>avoidance
            if rand<sotr_chance
                DRmod=1-sotr_value;
            else
                DRmod=1;
            end
            
            damage=DRmod*damage_mean(j)*(1+2*damage_range*(rand()-0.5));
            
            timeline_bin_number=1+floor(swing_timer*(i-1)/bin_time);
            timeline(timeline_bin_number,j)=damage;
        end
    end
end

%% calculate moving average array, don't worry about endpoints

tmi_definitions

% figure(1)
% hist(moving_average(:,1))
x=mean(ma)';
xy=repmat(x,1,size(tmic,1));
xz=repmat(max(ma)',1,size(tmic,1));

figure(3)
subplot 221
plot(x,tmi_old,'k',xy,tmic')
ylabel('TMI')
xlabel('Mean(MA)')
legend('old',tmil1,tmil2,tmil3,'Location','NorthWest')
title('Randomly Fluctuating Damage')

subplot 222
plot(xy,tmic',x,log_tmi_old,'k--')
ylabel('TMI')
xlabel('Mean(MA)')
legend(tmil1,tmil2,tmil3,[int2str(c1) '*log(old)'],'Location','NorthWest')


subplot 223
xx=repmat(tmi_old',1,size(tmic,1));
semilogx(xx,tmic')
xlabel('Old TMI')
ylabel('New TMI')
legend(tmil1,tmil2,tmil3,'Location','Northwest')

subplot 224
plot(xz,tmic',x,log_tmi_old,'k--')
xlabel('Max(MA)')
ylabel('New TMI')
legend(tmil1,tmil2,tmil3,[int2str(c1) '*log(old)'],'Location','NorthWest')

% figure(6)
% yq=tmic(1,:)';
% plot(x(1:length(x)-1),0.1*diff(yq)./diff(x))
% xlabel('Mean(MA)')

rd.tmie=tmic(1,:)';
rd.tmi10=tmic(3,:)';
rd.meanma=x;
rd.maxma=max(ma)';