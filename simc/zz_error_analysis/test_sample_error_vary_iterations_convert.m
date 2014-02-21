%load the file first

clear n rci oci pci

%convert to new variable names
n=num_iterations;
rci=RCI95;

for j=1:size(dps,2)
   
    [metric, oci(j), pc]=conf_ellipsoid_stats(dps(:,j));
    pci(j)=diff(prctile(dps(:,j),[2.5 97.5]));
    
end

%fix vector lengths
maxlength=min([length(rci) length(oci) length(pci) length(n)]);
n=n(1:maxlength);
rci=rci(1:maxlength);
pci=pci(1:maxlength);
oci=oci(1:maxlength);

%% plot
figure(i)
set(gcf,'Position',[580   200   560   760])
subplot 211
semilogx(n,rci,'o-',n,oci,'o-',n,pci,'o-')
xlim([min(n)-1 max(n)+1])
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Observed (percentile)','Location','NorthEast')

title('EA-default Ret Pal T16H R323885c7b4d1')

subplot 212
loglog(n,rci,'o-',n,oci,'o-',n,pci,'o-')
xlim([min(n)-1 max(n)+1])
xlabel('# Iterations')
ylabel('95% Confidence Interval (DPS)')
legend('Reported (2*DPS\_Error)','Observed (conf\_ellipsoid)','Observed (percentile)','Location','NorthEast')
