clear
e=exp(1);
%% import data
import_tmi_xlsx('tmi_beta_test_export.xlsx');

%% possible transformations
c1=500;
c2=e.^10;
maxma=1+(tmi./c1+log(450)-log(c2))./10;

c1p=2000 %default c1=500
c2p=e.^10 %default c1=exp(10)
tmi=c1p.*log(1+c2p./c2.*(e.^(tmi./c1)-1));
swf=c1p./c1;
str=swf.*str;agi=swf.*agi;sta=swf.*sta;exp=swf.*exp;hit=swf.*hit;
crit=swf.*crit;haste=swf.*haste;mast=swf.*mast;dodge=swf.*dodge;parry=swf.*parry;


maxma=1+(tmi./c1p+log(450)-log(c2p))./10;

%% Preprocessing
%Construct index arrays for use in filtering
dk=strcmp('Death Knight',class);
pal=strcmp('Paladin',class);
war=strcmp('Warrior',class);
dru=strcmp('Druid',class);
monk=strcmp('Monk',class);

%construct numeric boss array
numboss=zeros(size(boss,1),1);
for i=1:length(numboss)
    temp=boss{i};
    numboss(strcmp('T15N25',boss))=1;
    numboss(strcmp('T15H25',boss))=2;
    numboss(strcmp('T16N10',boss))=3;
    numboss(strcmp('T16N25',boss))=4;
    numboss(strcmp('T16H10',boss))=5;
    numboss(strcmp('T16H25',boss))=6;
    numboss(strcmp('T17Q',boss))=7;
end

%index arrays for spec/boss filtering
for i=1:7
    eval(['pal' int2str(i) '=and(pal,logical(numboss==' int2str(i) '));' ]);
    eval(['war' int2str(i) '=and(war,logical(numboss==' int2str(i) '));' ]);
    eval(['dru' int2str(i) '=and(dru,logical(numboss==' int2str(i) '));' ]);
    eval(['dk' int2str(i) '=and(dk,logical(numboss==' int2str(i) '));' ]);
    eval(['monk' int2str(i) '=and(monk,logical(numboss==' int2str(i) '));' ]);
end

%% Plots & Analysis
%Figure 1 - ilvl distribution of submissions

figure(1)
subplot(2,2,1)
hist(ilvl,20)
xlabel('average ilvl')
ylabel('number of submissions')

%Figure 2 - TMI distribution of submissions
% figure(2)
subplot(2,2,2)
hist(tmi,50)
xlabel('TMI')
ylabel('number of submissions')

%Figure 3 - Boss distribution
% figure(3)
subplot(2,2,3)
y=hist(numboss,7);
bar(1:7,y)
xlim([0.5 7.5])
xlabel('Boss')
ylabel('number of submissions')
set(gca,'XTickLabel',{'T15N25';'T15H25';'T16N10';'T16N25';'T16H10';'T16H25';'T17Q'})

% subplot(2,2,4)
% plot(ilvl,maxma,'o')

%% TMI vs. ilvl plots
%Figure 10 - TMI vs. ilvl
% figure(10)
subplot(2,2,4)
plot(ilvl,tmi,'o')
xlabel('average ilvl')
ylabel('TMI')

%Figure 11 - TMi vs. ilvl broken down by class
figure(11)
subplot(2,2,1)
plot(ilvl(pal),tmi(pal),'*',...
     ilvl(war),tmi(war),'s',...
     ilvl(dk),tmi(dk),'x',...
     ilvl(monk),tmi(monk),'o',...
     ilvl(dru),tmi(dru),'d')
xlabel('average ilvl')
ylabel('TMI')
legend('Paladin','Warrior','DK','Monk','Druid','Location','NorthEastOutside')

%Figure 12 - TMI vs. ilvl broken down by boss
% figure(12)
subplot(2,2,2)
plot(ilvl(pal1),tmi(pal1),'.',...
     ilvl(pal3),tmi(pal3),'o',...
     ilvl(pal4),tmi(pal4),'x',...
     ilvl(pal5),tmi(pal5),'^',...
     ilvl(pal6),tmi(pal6),'s',...
     ilvl(pal7),tmi(pal7),'p'...
     )
xlabel('average ilvl')
ylabel('TMI')
title('Paladins only')
legend('T15N25','T16N10','T16N25','T16H10','T16H25','T17Q','Location','NorthEastOutside')

%Figure 13 - TMI vs. ilvl broken down by boss
% figure(13)
subplot(2,2,3)
plot(ilvl(war1),tmi(war1),'.',...
     ilvl(war2),tmi(war2),'*',...
     ilvl(war3),tmi(war3),'o',...
     ilvl(war4),tmi(war4),'x',...
     ilvl(war5),tmi(war5),'^',...
     ilvl(war6),tmi(war6),'s',...
     ilvl(war7),tmi(war7),'p'...
     )
xlabel('average ilvl')
ylabel('TMI')
title('Warriors only')
legend('T15N25','T15H25','T16N10','T16N25','T16H10','T16H25','T17Q','Location','NorthEastOutside')

%Figure 14 - TMI vs. ilvl broken down by boss
% figure(14)
subplot(2,2,4)
plot(ilvl(dk1),tmi(dk1),'.',...
     ilvl(dk3),tmi(dk3),'o',...
     ilvl(dk4),tmi(dk4),'x',...
     ilvl(dk5),tmi(dk5),'^',...
     ilvl(dk6),tmi(dk6),'s',...
     ilvl(dk7),tmi(dk7),'p'...
     )
xlabel('average ilvl')
ylabel('TMI')
title('Death Knights only')
legend('T15N25','T16N10','T16N25','T16H10','T16H25','T17Q','Location','NorthEastOutside')

%Figure 15 - TMI vs. ilvl broken down by boss
figure(12)
subplot(2,1,1)
plot(ilvl(dru1),tmi(dru1),'.',...
     ilvl(dru2),tmi(dru2),'*',...
     ilvl(dru3),tmi(dru3),'o',...
     ilvl(dru4),tmi(dru4),'x',...
     ilvl(dru5),tmi(dru5),'^'...
     )
xlabel('average ilvl')
ylabel('TMI')
title('Druids only')
legend('T15N25','T15H25','T16N10','T16N25','T16H10','Location','NorthEastOutside')

%Figure 16 - TMI vs. ilvl broken down by boss
% figure(16)
subplot(2,1,2)
plot(ilvl(monk1),tmi(monk1),'.',...
     ilvl(monk2),tmi(monk2),'*',...
     ilvl(monk3),tmi(monk3),'o',...
     ilvl(monk4),tmi(monk4),'x',...
     ilvl(monk5),tmi(monk5),'^',...
     ilvl(monk6),tmi(monk6),'s'...
     )
xlabel('average ilvl')
ylabel('TMI')
title('Monks only')
legend('T15N25','T15H25','T16N10','T16N25','T16H10','T16H25','Location','NorthEastOutside')

%% Stat weight plots
figure(20)
subplot(2,4,1)
temp=str(logical(pal+war+dk));
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Str')

subplot(2,4,2)
temp=agi(logical(dru+monk));
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Agi')

subplot(2,4,3)
temp=sta;
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Stam')

subplot(2,4,4)
temp=exp;
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Exp')

subplot(2,4,5)
temp=hit;
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Hit')

subplot(2,4,6)
temp=crit;
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('crit')

subplot(2,4,7)
temp=haste;
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Haste')

subplot(2,4,8)
temp=mast;
x=[(floor(min(temp)*20)/20):0.05:(ceil(max(temp)*20)/20)];
y=hist(temp,x);
bar(x,y)
xlim([min(x)-0.025 max(x)+0.025])
title('Mastery')

%% Bar plot for Theck
k=1;
labels={'str';'sta';'exp';'hit';'crit';'haste';'mast';'armor';'dodge';'parry'};
figure(30)
[y I]=sort([str(k) sta(k) exp(k) hit(k) crit(k) haste(k) mast(k) armor(k) dodge(k) parry(k)],2,'descend');
barh(y)
set(gca,'YTickLabel',{labels{I}})


%% table
temp=[str sta exp hit crit haste mast dodge parry];
[ilvl(1:10) temp(1:10,:)]