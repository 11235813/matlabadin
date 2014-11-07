function [ moving_sum ] = calculate_moving_sum_timeline( D, window )

if nargin<2
    window=6;
end

temp=filter(ones(window,1),1,repmat(D,3,1));
moving_sum=temp((size(D,1)+1):(2*size(D,1)),:);

end