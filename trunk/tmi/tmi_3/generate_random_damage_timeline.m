function [ damage_timeline ] = generate_random_damage_timeline( fight_length,damage_mean,damage_range,swing_timer )

avoidance=0.3;
sotr_chance=0.3;
block_chance=0.3;
sotr_value=0.4;

num_swings=floor(fight_length/swing_timer);
damage_timeline=zeros(fight_length,1);

    for i=1:num_swings
        
        damage=-0.2; %baseline, from healing
            
        if rand>avoidance
          
            base_damage=damage_mean+2*damage_range*(rand()-0.5);
            
            if rand<block_chance
                base_damage=base_damage*0.7;
            end
            
            if rand<sotr_chance
                base_damage=base_damage*(1-sotr_value);
            end
            
            damage=damage+base_damage;
        end
        
        timeline_bin_number=1+floor(swing_timer*(i-1));
        damage_timeline(timeline_bin_number)=damage;
        
    end

end

