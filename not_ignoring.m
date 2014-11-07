function [ b ] = not_ignoring( s, ignored )
%NOT_IGNORING Summary of this function goes here
%   Detailed explanation goes here
b=true;
for i=1:length(ignored)
    if strcmp(s,ignored{i})
        b=false;
    end
end

end

