clear

t=1:100:120e3;
omega=2*pi/40e3;
phi=t.*omega;
A=105;
phi_lunar=asin(100/105);
phi_solar=phi_lunar+pi;


new_phi=mod(phi,2*pi);
L=phi_lunar-new_phi;
S=phi_solar-new_phi;

time_to_next_lunar=mod(L+2*pi,2*pi)./omega;
time_to_next_solar=mod(S+2*pi,2*pi)./omega;

time_to_next_zero = pi - mod(phi,pi)./omega;

eclipse_direction = sign( cos( phi ));

figure(1)
subplot 311
plot(t,A.*sin(phi),t,100.*ones(size(t)),'k-',t,-100.*ones(size(t)),'k-');

subplot 312
plot(t,zeros(size(t)),'k-',t,time_to_next_lunar,t,time_to_next_solar,t,time_to_next_zero)

subplot 313
plot(phi./pi,eclipse_direction)