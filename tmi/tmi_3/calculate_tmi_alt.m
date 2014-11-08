function [ tmi ] = calculate_tmi_alt( M, N0 )
%CALCULATE_TMI calculates the TMI value from a moving_average array
%optional second argument N0 allows for change in normalization factor

if nargin<2
    N0=450;
end

F=10;
c1=1e4;

wma=exp(F.*M);
rmsM=sum(M.^2)/length(M);

ama=exp(F.*ones(size(M)).*mean(M));
% ama=exp(F.*ones(size(M)).*sqrt(rmsM));
ama=exp(F.*ones(size(M)).*median(M));

arg=N0*sum(wma)/length(M);
arg=arg-N0*sum(ama)/length(M);

tmi=c1*log(arg);

end

