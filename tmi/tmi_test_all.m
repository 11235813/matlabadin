clear
fight_length=500;

%Define constants
H=5000; %"handle" - this determines the value for uniform MA=1
DF=H/10; %500 per 0.1

D=10; %

c1=10*DF/D;
c2=exp(H/c1);
c210=10^(H/c1);


% 
% tmi_old=10000*window^2/fight_length*swma0;
% tmic(1,:)=c1*log(c2+c3*swmae/fight_length);
% tmic(2,:)=c1*log10(c2+c3*swmae/fight_length);
% tmic(3,:)=c1*log(c3*swmae/fight_length);
% tmic(4,:)=c1*log10(c3*swmae/fight_length);


tmi_normalization_test_random
tmi_normalization_test_single_spike
tmi_normalization_test_uniform


figure(5)
subplot 211
plot(ss.maxma,ss.tmie,rd.maxma,rd.tmie,uf.maxma,uf.tmie)
xlabel('max(MA)')
ylabel('New TMI')
legend('SS','RD','UF')
title(['exponential forms, D=' int2str(D)])


subplot 212
plot(ss.maxma,ss.tmi10,rd.maxma,rd.tmi10,uf.maxma,uf.tmi10)
xlabel('max(MA)')
ylabel('New TMI')
legend('SS','RD','UF')
title(['base-10 forms, D=' int2str(D)])