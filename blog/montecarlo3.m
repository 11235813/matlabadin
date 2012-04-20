clear

for k=1:500
    [dtps(k,1) statblock]=montecarlo(' ',0,5,'noplot');
    G(k,1)=statblock.G;
    S(k,1)=statblock.S;
    Tsotr(k,1)=statblock.Tsotr;
    Rhpg(k,1)=statblock.Rhpg;
end

%% plots
figure(2);
hist(S);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
xlim([0.25 1])
hold on
hist(G);
hold off
ylabel(['Number of simulations (out of ' int2str(k) ')'])
xlabel('G (blue) or S (red)')


figure(3)
hist(Tsotr)
ylabel(['Number of simulations (out of ' int2str(k) ')'])
xlabel('T_{\rm SotR}')
 
figure(4)
hist(Rhpg)
ylabel(['Number of simulations (out of ' int2str(k) ')'])
xlabel('R_{\rm HPG}')

stdG=std(G)
stdS=std(S)
stdT=std(Tsotr)
stdR=std(Rhpg)