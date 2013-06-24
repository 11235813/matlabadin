function [tmi tmiwhole] = tmi_calc(histo, bins , cutoff, health_decade_factor)

%histo = N x M array of histogram data.  M may be singleton.
%bins = health values associated with the bins of histo
%cutoff = can be either the percentage of events to consider bounded by (0,1)
%         or the cutoff index of histo array
%         if not supplied will automatically calculate using a top 5% method

N=size(histo,1);
M=size(histo,2);
totalevents=sum(histo(:,1));
%preallocate for speed
tmi=zeros(M,1);
tmiwhole=zeros(M,1);

%% if cutoff not supplied, calculate it
if nargin<3
    cutoff=0.05;
end

if cutoff<1
    cutoff_pct=cutoff;
    
    j=length(histo(:,1));
    accumulator=histo(j,1)./totalevents;
    while accumulator<cutoff_pct
        j=j-1;
        accumulator=accumulator+histo(j,1)./totalevents;
    end
    cutoff=j;
end

%% if health decade factor isn't supplied, default to 2
if nargin<4
    health_decade_factor = 2;
end

%weight function
wf=exp(10.*log(health_decade_factor).*(bins-1));

%% for each column, calculate tmi metrics
for i=1:M
    tmi(i)=sum(histo(cutoff:N,i).*wf(cutoff:N));
    tmiwhole(i)=sum(histo(:,i).*wf);    
    
    %normalized versions
    tmi(i)=sum(histo(cutoff:N,i).*wf(cutoff:N));
    tmiwhole(i)=sum(histo(:,i).*wf);    
end




end