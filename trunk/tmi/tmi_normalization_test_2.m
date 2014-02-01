clear
fight_length=500;
damage_steps=150;
window=4

%construct timelines
timeline=zeros(fight_length,damage_steps);
for i=1:damage_steps
    timeline(:,i)=repmat(0.15,fight_length,1); %#ok<*SAGROW>
    timeline(37,i)=0.01*i;
end

%construct moving average (artificial)
moving_average=filter(ones(4,1),1,timeline);
ma=moving_average;
% ma=repmat(0.5,fight_length,1);

%construct weighted moving average
wma0=3.^(10.*(ma-1));
wmae=exp(10.*(ma-1));

%sum the weighted moving averages
disp('----- SWMA ------' )
swma0=sum(wma0);
swmae=sum(wmae);
% swa0_avg=swa0/fight_length

%% different TMI calculation types

disp('----- TMI -----')
tmi_old=10000*window^2/fight_length*swma0;
tmic(1,:)=10*log(1+swma0/fight_length);
tmic(2,:)=10*log10(1+swma0/fight_length);
tmic(3,:)=10*log(1+swmae/fight_length);
tmic(4,:)=10*log10(1+swmae/fight_length);
tmic(5,:)=10*log(1+1000*swmae/fight_length);
tmic(6,:)=10*log10(1+1000*swmae/fight_length);


x=1:damage_steps;x=x';
xc=repmat(x,1,size(tmic,1));
% 
figure(1)
for i=1:damage_steps
hist(moving_average(:,i),0:0.05:2.5)
xlim([0 2.5])
pause(0.001)
end

figure(2)
plot(x,tmi_old,xc,tmic')
legend('old','c1','c2','c3','c4','c5','c6')

figure(3)
plot(x,log(tmi_old),x,log10(tmi_old),xc,tmic')
legend('log(old)','log10(old)','c1','c2','c3','c4','c5','c6')