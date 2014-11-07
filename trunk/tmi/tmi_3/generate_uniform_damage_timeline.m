function [ damage_timeline ] = generate_uniform_damage_timeline( fight_length, window, damage_of_spike )

damage_timeline = repmat(damage_of_spike/window,fight_length,1);

end

