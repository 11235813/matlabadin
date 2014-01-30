function [ simc_str ] = util_translate_rotation_element( shorthand, class, spec )
%UTIL_TRANSLATE_ROTATION_ELEMENT translates between rotation shorthand
%elements and simc action priority list entries

%% Split base from options
base_expr='(\w+)';
base_match=regexp(shorthand,base_expr,'tokens','once');
base=char(base_match{1});

opt_expr='(?<operator>[-\+])(?<options>[a-zA-Z]*)(?<numeric>\d*\.?\d*)';
opt_match=regexp(shorthand,opt_expr,'names');

operators={opt_match.operator};
options={opt_match.options};
numerics={opt_match.numeric};

talent=false; %flag for talent.X.enabled auto-option; set by base switch.

%% Paladin
if strcmp(class,'paladin')
    
    % Protection
    if strcmp(spec,'protection')
        
        % Abilities
        switch base
            
            case 'CS'
                ability_str='crusader_strike';
            case 'CSw'
                ability_str='crusader_strike';
                options{length(options)+1}='W';
                operators{length(operators)+1}='+';
                numerics{length(numerics)+1}='0.35';
            case 'HotR'
                ability_str='hammer_of_the_righteous';
            case 'J'
                ability_str='judgment';
            case 'AS'
                ability_str='avengers_shield';
            case 'HW'
                ability_str='holy_wrath';
            case 'HoW'
                ability_str='hammer_of_wrath';
            case 'Cons'
                ability_str='consecration';
            case 'SS'
                ability_str='sacred_shield';
                talent=true;
            case 'HPr'
                ability_str='holy_prism';
                talent=true;
            case 'ES'
                ability_str='execution_sentence';
                talent=true;
            case 'LH'
                ability_str='lights_hammer';
                talent=true;
            case 'SotR'
                ability_str='shield_of_the_righteous';
            case 'EF'
                ability_str='eternal_flame';
                talent=true;
            case 'WoG'
                ability_str='word_of_glory';
                
        end
        
        % Options
        opt_str='';
        wait_opt_str=''; %special, wait adds a separate line
        
        %automatically validate talents
        if talent
            opt_str=strcat(',if=talent.',ability_str,'.enabled');
        end
        
        for i=1:length(options)
            
            temp_opt_str='';    
            
            switch options{i}
                case 'W'
                    if isempty(numerics{i})
                        numerics{i}='0.2';
                    end
                    wait_opt_str=strcat('actions+=/wait,sec=cooldown.',ability_str,'.remains,if=cooldown.',ability_str,'.remains>0&cooldown.',ability_str,'.remains<=',numerics{i});

                case 'GC'
                    if isempty(numerics{i})
                        temp_opt_str='buff.grand_crusader.up';
                    else
                        temp_opt_str=strcat(temp_opt_str,'buff.grand_crusader.remains<',numerics{i});
                    end
                    temp_opt_str='target.health.pct<20';
                case 'DP'
                    temp_opt_str='buff.divine_purpose.react';
                case 'DPHP'
                    temp_opt_str=strcat('(buff.divine_purpose.react|holy_power>=',numerics{i},')');
                case 'EX'
                case 'ex'
                    temp_opt_str=strcat('target.health.pct<=20');
                case 'FW'
                    temp_opt_str=strcat('glyph.final_wrath.enabled&target.health.pct<=20');
                case 'HP'
                    temp_opt_str=strcat('holy_power>=',numerics{i});
                case 'nt'
                    temp_opt_str='!ticking';
                case 'nF'
                    temp_opt_str='target.debuff.flying.down';
                case 'SW'
                    temp_opt_str='talent.sanctified_wrath.enabled&buff.avenging_wrath.react';
                case 'T'
                    temp_opt_str=strcat('active_enemies>=',numerics{i});
                case 'R'
                    temp_opt_str=strcat('buff.',ability_str,'.remains<',numerics{i});
            end
            
            %append to options list
            if ~isempty(temp_opt_str)
                %add preceding operators
                if isempty(opt_str)
                    opt_str=',if=';
                elseif operators{i}=='+'
                    opt_str=strcat(opt_str,'&');
                elseif operators{i}=='-'
                    opt_str=strcat(opt_str,'|');
                else
                    error('This should not happen')
                end
                opt_str=strcat(opt_str,temp_opt_str); 
                
            end
            
        end
        
    end

    
    simc_str=cellstr(strcat('actions+=/',ability_str,opt_str));
    if ~isempty(wait_opt_str)
        simc_str{2}=wait_opt_str;
    end

end

