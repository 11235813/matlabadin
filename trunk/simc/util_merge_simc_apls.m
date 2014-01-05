function [ rotation_cellstr ] = util_merge_simc_apls( varargin )
%UTIL_MERGE_SIMC_APLS combines multiple cellstr arguments that contain APL
%entries into a single cellstr APL

rotation_cellstr='';

for i=1:nargin
    apl_component=varargin{i};
    for j=1:length(apl_component)
        rotation_cellstr{length(rotation_cellstr)+1}=apl_component{j};
    end
end
    
end

