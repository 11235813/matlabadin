function fixed_str = sf_double_backslashes( input_str )

bs=find(input_str=='\');
bs=[bs length(input_str)];

fixed_str=input_str(1:bs(1));

for i=1:(length(bs)-1)
    fixed_str=strcat(fixed_str,input_str(bs(i):bs(i+1)));    
end


end