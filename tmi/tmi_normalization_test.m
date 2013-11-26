damage_mean=0.5; %in units of player health
damage_range=0.2; %in units of damage_mean; i.e. 0.2 means +/-20% of mean dmg
swing_timer=1.5; %in seconds

fight_length=500; %in seconds
window=6; %in seconds
bin_time=1; %in seconds

avoidance=0.3;
sotr_chance=0.0;
sotr_value=0.45;

hdf=3;

%% construct arrays
num_swings=floor(fight_length/swing_timer);

timeline=zeros(fight_length/bin_time,1);


%% generate crazy fake example data set

for i=1:num_swings
    
    if rand>avoidance 
        if rand<sotr_chance
            DRmod=1-sotr_value;
        else
            DRmod=1;
        end
        
        damage=DRmod*damage_mean*(1+2*damage_range*(rand()-0.5));
        
        timeline_bin_number=1+floor(swing_timer*(i-1)/bin_time);
        timeline(timeline_bin_number)=damage;        
    end    
end

%% calculate moving average array, don't worry about endpoints
disp('-------')
moving_average=filter(ones(floor(window/bin_time),1),1,timeline);

weighted_average=hdf.^(10.*(moving_average-1));
wa2=exp(10.*(moving_average-1));

swa=sum(weighted_average)
swaofl=swa/fight_length
tmi_old=10000*window^2/fight_length*swa
tmi_c1=10*log(10+swa/fight_length)
tmi_c2=10*log10(10+swa/fight_length)
tmi_c3=10*log(10+sum(wa2)/fight_length)
tmi_c4=10*log10(10+sum(wa2)/fight_length)

figure(1)
hist(moving_average)