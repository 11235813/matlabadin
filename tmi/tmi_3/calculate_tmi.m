function [ tmi ] = calculate_tmi( M, N0 )
%CALCULATE_TMI calculates the TMI value from a moving_average array
%optional second argument N0 allows for change in normalization factor

if nargin<2
    N0=450;
end

F=10;
c1=1e4;

wma=exp(F.*M);

tmi=c1*log(sum(wma)*N0/length(M));

end

