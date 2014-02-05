clear
fight_length=500;
% 
% %Define constants
% H=5000; %"handle" - this determines the value for uniform MA=1
% DF=H/10; %500 per 0.1
% 
% D=10; %
% 
% c1=20*DF/D;
% c2=exp(H/c1);
% c210=10^(H/c1);
% 
% fudge=50;
% c2=c2*fudge;
% c210=c2*fudge;
% 

D=20;
% b=10e3;
m=500;
c1=10*m/D
c2=exp(D);
% c2=fight_length/100*exp(D)
c210=10.^D;
% 
% tmi_old=10000*window^2/fight_length*swma0;
% tmic(1,:)=c1*log(c2+c3*swmae/fight_length);
% tmic(2,:)=c1*log10(c2+c3*swmae/fight_length);
% tmic(3,:)=c1*log(c3*swmae/fight_length);
% tmic(4,:)=c1*log10(c3*swmae/fight_length);

tmi_normalization_test_random
rdc=rd;
for j=1:24;
    tmi_normalization_test_random
    rdc.maxma=[rdc.maxma; rd.maxma];
    rdc.tmie=[rdc.tmie;rd.tmie];
    rdc.tmi10=[rdc.tmi10;rd.tmi10];
    rdc.meanma=[rdc.meanma;rd.meanma];
end
tmi_normalization_test_single_spike
tmi_normalization_test_uniform

%% plots
figure(5)
subplot 211
plot(ss.maxma,ss.tmie,rdc.maxma,rdc.tmie,'.',uf.maxma,uf.tmie)
xlabel('max(MA)')
ylabel('New TMI')
legend('SS','RD','UF','Location','NorthWest')
title(['exponential forms, D=' int2str(D)])
minx=min([min(ss.maxma) min(rdc.maxma) min(uf.maxma)]);
maxx=max([max(ss.maxma) max(rdc.maxma) max(uf.maxma)]);
miny=min([min(ss.tmie) min(rdc.tmie) min(uf.tmie)]);
maxy=max([max(ss.tmie) max(rdc.tmie) max(uf.tmie)]);
xlim([minx maxx])
ylim([miny maxy])


subplot 212
plot(ss.maxma,ss.tmi10,rdc.maxma,rdc.tmi10,'.',uf.maxma,uf.tmi10)
xlabel('max(MA)')
ylabel('New TMI')
legend('SS','RD','UF','Location','NorthWest')
title(['base-10 forms, D=' int2str(D)])
xlim([0 max(ss.maxma)])