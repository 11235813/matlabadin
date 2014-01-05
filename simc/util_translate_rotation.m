function [ rotation_cellstr ] = util_translate_rotation( rotation_shorthand, class, spec )
%UTIL_TRANSLATE_ROTATION translates between rotation shorthands and simc
%action priority list lines. It does this by repeatedly calling
%UTIL_TRANSLATE_ROTATION_ELEMENT, which contains all of the definitions and
%syntax details. Rotation elements are separated by '>' characters.

rotation_cellstr='';

%adjust for cellstr input
if iscell(rotation_shorthand)
    rotation_shorthand=rotation_shorthand{:};
end

expr='([\w\+-\.]+)>?';
elements=regexp(rotation_shorthand,expr,'tokens');

for i=1:length(elements)
    
    result=util_translate_rotation_element(char(elements{i}),class,spec);
    for j=1:length(result)
        rotation_cellstr{length(rotation_cellstr)+1}=result{j};
    end
end
    
end

