function [ damage_timeline ] = generate_single_spike_timeline( fight_length, window, damage_of_spike, damage_outside_spike)

if nargin<4
    damage_outside_spike=-0.4;
end

damage_timeline = repmat(damage_outside_spike,fight_length,1);

spike_indices=floor(fight_length/2)+(0:window)-floor(window/2);

damage_timeline(spike_indices)=damage_of_spike/window;

end