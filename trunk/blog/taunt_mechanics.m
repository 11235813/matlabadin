t=linspace(0,20,101)';
G=1;
gamma=20;

tau=[10 20 30 40];
T0=tau(2).*G;

%% Before, no accel
tx=tau./4.5
T1=T0+G.*t;
T2B=T0+G./2.*t;
figure(1)
% plot(t,T1,t,1.1.*T2)
% legend('T1','1.1*T2')
% ylabel('Threat (1/G_1)')
% xlabel('time since taunt (s)')
% xlim([0 8])

%% After, no accel
tx=tau./4.5+22/3;
T1=T0+G.*t;
T2A=T0+3/2.*G.*min(t,3)+G/2.*max(t-3,0);
% figure(2)
plot(t,T1,t,1.1.*T2B,t,1.1.*T2A)
legend('T1','1.1*T2B','1.1*T2A','Location','Southeast')
ylabel('Threat (1/G_1)')
xlabel('time since taunt (s)')
ylim([20 33])

%% Before, w/accel
figure(3)
a=0;
T2B=T0+G./2.*t + G./2.*max(t-a,0)+G.*gamma./(2.*log(0.1)).*(1-0.1.^(max(t-a,0)./gamma));
a=1;
T2Bu1=T0+G./2.*t + G./2.*max(t-a,0)+G.*gamma./(2.*log(0.1)).*(1-0.1.^(max(t-a,0)./gamma));
a=2;
T2Bu2=T0+G./2.*t + G./2.*max(t-a,0)+G.*gamma./(2.*log(0.1)).*(1-0.1.^(max(t-a,0)./gamma));

plot(t,T1,t,1.1.*T2B,t,1.1.*T2Bu1,t,1.1.*T2Bu2)

legend('T1','1.1*T2B','1.1*T2Bu1','1.1*T2Bu2')
ylabel('Threat (1/G_1)')
xlabel('time since taunt (s)')
% plot(t,t.*(1-0.55.*(2-0.1.^(t./gamma))),repmat(t',size(tau)),ones(size(t'))*tau./10)

%% After, w/accel
figure(4)
a=0;b=max(min(t,3),a);
T2A=T0+ 3.*G./2.*min(t,3) + G./2.*max(t-3,0)+ ...
    3.*G./2.*(b-a)+3.*G.*gamma./(2.*log(0.1)).*(1-0.1.^((b-a)./gamma)) + ...
    G./2.*max(t-b,0) - G.*gamma./(2.*log(0.1)).*(0.1.^(max(t-a,0)./gamma)-0.1.^((b-a)./gamma));

a=1;b=max(min(t,3),a);
T2Au1=T0+ 3.*G./2.*min(t,3) + G./2.*max(t-3,0)+ ...
    3.*G./2.*(b-a)+3.*G.*gamma./(2.*log(0.1)).*(1-0.1.^((b-a)./gamma)) + ...
    G./2.*max(t-b,0) - G.*gamma./(2.*log(0.1)).*(0.1.^(max(t-a,0)./gamma)-0.1.^((b-a)./gamma));

a=2;b=max(min(t,3),a);
T2Au2=T0+ 3.*G./2.*min(t,3) + G./2.*max(t-3,0)+ ...
    3.*G./2.*(b-a)+3.*G.*gamma./(2.*log(0.1)).*(1-0.1.^((b-a)./gamma)) + ...
    G./2.*max(t-b,0) - G.*gamma./(2.*log(0.1)).*(0.1.^(max(t-a,0)./gamma)-0.1.^((b-a)./gamma));

a=5;b=max(min(t,3),a);
T2Au5=T0+ 3.*G./2.*min(t,3) + G./2.*max(t-3,0)+ ...
    3.*G./2.*(b-a)+3.*G.*gamma./(2.*log(0.1)).*(1-0.1.^((b-a)./gamma)) + ...
    G./2.*max(t-b,0) - G.*gamma./(2.*log(0.1)).*(0.1.^(max(t-a,0)./gamma)-0.1.^((b-a)./gamma));
plot(t,T1,t,1.1.*T2A,t,1.1.*T2Au1,t,1.1.*T2Au2,t,1.1*T2Au5)
legend('T1','1.1.*T2A','1.1.*T2Au1','1.1.*T2Au2','1.1*T2Au5')


%% dual plot
figure(2)
plot(t,T1,'k-',t,1.1.*T2B,'--',t,1.1.*T2Bu1,'--',t,1.1.*T2Bu2,'--',t,1.1.*T2A,t,1.1.*T2Au1,t,1.1.*T2Au2,t,1.1.*T2Au5)
legend('T1','1.1*T2B','1.1*T2Bu1','1.1*T2Bu2','1.1.*T2A','1.1.*T2Au1','1.1.*T2Au2','1.1.*T2Au5','Location','Southeast')
ylim([20 33])
ylabel('Threat (1/G_1)')
xlabel('time since taunt (s)')
