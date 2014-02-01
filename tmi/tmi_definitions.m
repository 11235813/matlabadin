%% Construct Moving Averages
%input is assumed to be "timeline" an NxM array where
%N=fight_length/bin_time and 
%M=number of realizations of the fight

clear ma wma0 wmae swma0 swmae tmi_old tmic
%construct moving average 
moving_average=filter(ones(4,1),1,timeline);
ma=moving_average;

%construct weighted moving average
wma0=3.^(10.*(ma-1));
wmae=exp(D.*(ma-1));
wma10=10.^(D.*(ma-1));

%sum the weighted moving averages
swma0=sum(wma0);
swmae=sum(wmae);
swma10=sum(wma10);
% swa0_avg=swa0/fight_length

%% TMI Definitions

tmi_old=10000*window^2/fight_length*swma0;
log_tmi_old=c1*log(tmi_old);
tmic(1,:)=c1*log(1+c2.*swmae./fight_length);
tmic(2,:)=c1*log(1+c2.*450.*swmae./fight_length);
tmic(3,:)=c1*log10(1+c210.*swma10./fight_length);
tmil1='A*log(1+C*SWMAE/FL)';
tmil2='A*log(1+C*450*SWMAE/FL)';
tmil3='A*log10(1+C_{10}*SWMAE/FL)';