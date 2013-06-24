function [fi fiwhole] = fi_calc(histo, cutoff)

%histo = N x M array of histogram data.  M may be singleton.
%bins = health values associated with the bins of histo
%cutoff = can be either the percentage of events to consider bounded by (0,1)
%         or the cutoff index of histo array
%         if not supplied will automatically calculate using a top 5% method

N=size(histo,1);
M=size(histo,2);
totalevents=sum(histo(:,1));
%preallocate for speed
fi=zeros(M,1);
fiwhole=zeros(M,1);

%% if cutoff not supplied, calculate it
if nargin<2
    cutoff=0.05;
end

if cutoff<1
    cutoff_pct=cutoff;
    
    j=length(histo(:,1));
    accumulator=0;
    while accumulator<cutoff_pct
        accumulator=accumulator+histo(j,1)./totalevents;
        j=j-1;
    end
    cutoff=j;
end

%%  for each column, calculate tmi metrics
for i=1:M
    fi(i)=sum(histo(cutoff:N,i));
    fiwhole(i)=sum(histo(:,i));
    
    %normalized versions
    fi(i)=sum(histo(cutoff:N,i))./sum(histo(cutoff:N,1)).*1000;
end




end