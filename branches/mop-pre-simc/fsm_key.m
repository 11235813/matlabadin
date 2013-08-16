function [ rotationKey spectalKey optionsKey ] = fsm_key( rotation, spec, talentString, glyphString, mehaste, sphaste, mehit, sphit, pBuffs, gcProcsPerSecond)
%FSM_KEY Generates keys from the simulation inputs
%   Replaces identical sections in memoized_fsm and fsm_gen

    rotationKey = rotation;
    rotationKey = strrep(rotationKey, '[', '');
    rotationKey = strrep(rotationKey, ']', '_');
    rotationKey = strrep(rotationKey, '.', '_');    
    rotationKey = strrep(rotationKey, '>=', 'ge');
    rotationKey = strrep(rotationKey, '<=', 'le');
    rotationKey = strrep(rotationKey, '==', 'eq');
    rotationKey = strrep(rotationKey, '=', 'eq');
    rotationKey = strrep(rotationKey, '<', 'lt');
    rotationKey = strrep(rotationKey, '>', '_');
    rotationKey = strrep(rotationKey, '*', 'star');
    rotationKey = strrep(rotationKey, '''', 'prime');
    rotationKey = strrep(rotationKey, '+', 'plus');
    rotationKey = strrep(rotationKey, '^', 'up');
    rotationKey = strrep(rotationKey, '#', 'num');
    
    spectalKey = [spec '_' talentString '_' glyphString];
    if spectalKey(length(spectalKey))==','
        spectalKey=spectalKey(1:(length(spectalKey)-1));
    end
    
    optionsKey = sprintf('T%g_%0.5f_%0.5f_%0.5f_%0.5f', fsm_steps_per_gcd(), mehaste, sphaste, mehit, sphit);
    optionsKey = [optionsKey '_' pBuffs];
    optionsKey = [optionsKey '_' sprintf('%1.5f',gcProcsPerSecond)];
    optionsKey = strrep(optionsKey,'_1.00000','_1_');
    optionsKey = strrep(optionsKey,'_0.','_');
    optionsKey = strrep(optionsKey, ',', '_');

end

