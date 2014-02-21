clear

filenames{1}='confidence_measurement_sc_dampening_exponent_2.csv';
filenames{2}='confidence_measurement_sc_dampening_exponent_05.csv';
filenames{3}='confidence_measurement_sc_dampening_exponent_10.csv';

expo=[2 5 10];

for i=1:length(filenames)
    %import the data
    util_import_CSV(filenames{i});
    %initialize index
    j=1;
    clear n k rci oci pci
    %Analyze the results    
    while length(N)>0
        %find the minimum N value
        tempVal=min(N);
        %identify all of the elements that have that value
        indx=(N==tempVal);
        %record num iterations
        n(j)=tempVal;
        %record size of sample
        k(j)=length(N(indx));
        %find actual confidence interval
        tempM=sampleMean(indx);
        [metric, oci(j), pc]=conf_ellipsoid_stats(tempM)
        %find the reported CI
        rci(j)=2*max(sampleError(indx));
        
        %find the percentile-based Interval
        pci(j)=diff(prctile(tempM,[2.5 97.5]));
        
        %remove those elements from N, sampleError, and sampleMean
        N=N(~indx);
        sampleMean=sampleMean(~indx);
        sampleError=sampleError(~indx);
        %increment
        j=j+1;
    end
    
    %plot
    figure(i)
    set(gcf,'Position',[580   200   560   760])
    subplot 211
    semilogx(n,rci,'o-',n,oci,'o-',n,pci,'o-')
    xlim([min(n)-1 max(n)+1])
    xlabel('# Iterations')
    ylabel('95% Confidence Interval (DPS)')
    legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Observed (percentile)','Location','NorthEast')
    title(['Damping Exponent = ' int2str(expo(i))])
    subplot 212
    loglog(n,rci,'o-',n,oci,'o-',n,pci,'o-')
    xlim([min(n)-1 max(n)+1])
    xlabel('# Iterations')
    ylabel('95% Confidence Interval (DPS)')
    legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Observed (percentile)','Location','NorthEast')
       
end