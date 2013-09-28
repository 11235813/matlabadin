function [ str ] = path_terminate( str )
%PATH_TERMINATE makes sure the string is properly terminated with a '\'

if str(length(str)) ~= '\'
    str = [ str '\' ]; 
end


end

