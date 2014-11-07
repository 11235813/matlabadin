D=linspace(0,100,50); %damageMod
q=exp(-0.045.*D);    
r1=0.4*(100+100*(max(8.5*(1-q)-1,0)));
r2=100+100*(max(3.4*(1-q)-1,0));
r3=100+100*(max(3.4*(1-q)-0.4,0));

figure(1)
plot(D,r1./100,'.-',D,r2./100,'.-')
legend('Old 0.4*(1+(8.5q-1))','New 1+(3.4q-1)','Location','Best')
title('Old vs. New Resolve, q=1-exp(-0.045*x)')
xlabel('DamageMod')
ylabel('Resolve Multiplier')