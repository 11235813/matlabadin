clear
%% define fight/TMI parameters
fight_length=650;
window=6;
N0=1;
% N0=fight_length;
c1mod=1.3;

%% create single-spike data
damage_steps=(-0.20:0.02:3.5);
for i=1:length(damage_steps)
    D = generate_single_spike_timeline(fight_length,window,damage_steps(i));
    M = calculate_moving_sum_timeline(D, window);
    tmi=calculate_tmi( M, N0);
    
    %store results
    ss.tmi(i)=tmi./1e3;
    ss.msd(i)=max(M);
end

%% create uniform-damage data
damage_steps=(-0.40:0.02:3.5);
for i=1:length(damage_steps)
    D = generate_uniform_damage_timeline(fight_length,window,damage_steps(i));
    M = calculate_moving_sum_timeline(D, window);
    tmi=calculate_tmi( M, N0);
    
    %store results
    uf.tmi(i)=tmi./1e3;
    uf.msd(i)=max(M);
end

%% create randomized test data
damage_mean=0:0.01:0.8;
damage_range=0.2;
swing_timer=1;
num_samples=10;
k=0;
for i=1:length(damage_mean)
    for j=1:num_samples
        D = generate_random_damage_timeline(fight_length,damage_mean(i),damage_range,swing_timer);
        M = calculate_moving_sum_timeline(D, window);
        tmi=calculate_tmi( M, N0);
       
        %store results
        k=k+1;
        rd.tmi(k)=tmi./1e3;
        rd.msd(k)=max(M);
    end
end

%% create randomized test data with zero-capping
damage_mean=0:0.01:0.8;
damage_var=0.1;
swing_timer=1;
num_samples=10;
k=0;
for i=1:length(damage_mean)
    for j=1:num_samples
        D = generate_random_damage_alt_timeline(fight_length,damage_mean(i),damage_var,swing_timer);
        M = calculate_moving_sum_timeline(D, window);
        tmi=calculate_tmi( M, N0);
       
        %store results
        k=k+1;
        rz.tmi(k)=tmi./1e3*c1mod;
        rz.msd(k)=max(M);
    end
end

%% plot results

figure(1)
plot(ss.msd,ss.tmi,rd.msd,rd.tmi,'.',uf.msd,uf.tmi,rz.msd,rz.tmi,'.')
xlabel('MSD')
ylabel('TMI (k)');
xlim([-0.5 4]);
legend('single-spike','random','uniform','random scaled','Location','NorthWest')
title(['Calculations using c_1 = ' num2str(c1mod,'%1.2f') '\times 10^4, c_2 = ' int2str(N0) 'e^F'])