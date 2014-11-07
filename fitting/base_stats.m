clear

m=1.05; %matching
k=1.05; %kings
h=0; %heroic presence, for draenei (130 @ L100)
e=0; %endurance
p=0; %potion
fl=0; %flask
fo=0; %food
fm=0; %food multiplier
t=0; %trinket

% %b & g from char sheet w/ no spec
% %fury warrior - premade gear
% b=1458; %base (w/o 5% bonus for matching)
% g=2378; %from gear (w/o any bonuses)
% g=g-124; %remove neck
% % g=g-124; %remove ring
% % g=g-124; %remove ring
% % g=g-124; %remove cloak
% g=g-210; %remove trinket
% g=g-221; %remove 2h weapon
% % g=1823; 
% % actual=[1530 3444 3617];

%ret paladin, 
% supports base & bonus floored separately w/ matching
% supports at least one floor w/ multiplier
% b=1455;
% g=2164; %prot_test setup
% g=2378; %default premade gear
% g=g-124; %remove neck
% g=g-124; %remove ring
% g=g-124; %remove ring
% g=g-124; %remove cloak
% g=g-124; %remove shield
% g=g-93; %remove weapon
% actual=[1527 2496 4023 2697 4224];

%prot paladin, premade gear, stamina
% supports floor(g*m)+b*m
b=890;
g=3250;
m=1.05;
k=1.1*1.25; %fort
actual=[934 4499 5433 5042 5976]; %

%draenei enh shaman, premade gear, testing heroic presence
% b=1281;
% g=1451;
% h=130.5;
% k=1.05;
% actual=[1597 2496 4093 2700 4297];

%draenei ret paladin, testing heroic presence
% b=1455+1;
% g=2378;
% m=1.05;
% h=65.25;
% k=1.05;

% %tauren prot paladin, premade gear, testing endurance (e), k is for fort
% b=891;
% g=3250;
% e=197.055;
% k=1.25;
% actual=[1088 0 0 4551 5693];

%L90 Fury Warr, potion testing
% b=409;
% g=456;
% fo=34.162; %food
% fl=113.947; %flask
% p=455.793; %potion
% t=176;
% actual=[429 1113 1542 1190 1619];
% actual=[429 819 1248 881 1310]; %no pot

%L92 Paladin, trinket testing
% b=662;
% g=973;
% t=188 * 2.973;
% fl=113.947; %flask
% actual=[695 1021 1106 1716 1801];
% actual=[695 1608 1723 2303 2418];

% %L100 Monk, Epicurean testing w/stam
% %supports round(fo)*fm - nothing else works
% b=891;
% g=0;
% fo=187.4999;
% fm=2;
% m=1.0;
% k=1.1;
% actual=[891 374 1265 500 1391];
% 
% %L100 Monk, Epicurean testing w/Int
% %supports round(fo*fm) & round(fo)*fm
% b=1041;
% g=0;
% fo=23.816;
% fm=2;
% m=1.0;
% k=1.05;
% actual=[1041 48 1089 102 1143];

% %L100 monk, epicurean testing w/parry
% %supports round(fo*fm) & round(fo)*fm
% b=0;
% g=0;
% fo=22.794;
% fm=2;
% m=1.0;k=1.0;
% actual=[0 46 46 46 46];

disp('================================================')

%% output calculations
B=b+h+e; %heroic presence / endurance added to base stats
f=fl+fo;
G=g+f+p;
G=g+floor(fo)*fm+round(fl)+round(p)+round(t);
G=g+round(fo)*fm+round(fl)+round(p)+round(t);
% G=g+round(fo+fl+p+t);
% G=g+floor(fo+fl+p)
a=G+floor(B*m); %gear+(b*m)


base=floor(B*m); %char sheet base

%old formulation (proven wrong)
comp=floor(G*m)+base;
out=floor(comp*k);

%new formulation 
bcomp=floor(G*m)+B*m;
bout =floor(bcomp*k);


%% display
disp('======== no spec, no buffs  =======')
disp('     base (b)       gear (g)    b+g')
disp([b g b+g])

disp('======== char sheet =======')


disp('         b      gear w/o K   Total w/o K  gear w/K    Total w/K')
disp([ actual;...
            base     floor(G*m)   floor(bcomp)  bout-base    bout])


% disp('single-floor, bonus')
% num2str([floor(g*m)*k+b*m*(k-1);
%  floor(g*m*k)+b*m*(k-1);
%  g*m*k+floor(b*m)*(k-1);
%  g*m*k+floor(b*m*(k-1))],'%4.2f')
% 
% disp('double-floor, bonus')
% num2str([floor(g*m)*k+floor(b*m)*(k-1);
%          floor(g*m*k)+floor(b*m*(k-1))],'%4.2f')
% 

% disp('many-floor, total')
% num2str([floor(g*m)*k+b*m*k;
%  floor(g*m*k)+b*m*k;
%  g*m*k+floor(b*m)*k;
%  g*m*k+floor(b*m*k);
%  floor(g*m)*k+floor(b*m)*k;
%  floor(g*m*k)+floor(b*m*k);
%  floor(g*m)*k+floor(b*m*k);
%  floor(g*m*k)+floor(b*m)*k;],'%4.2f')
  
%% out
% % [base comp out; 1530 3444 3617]'
% i=1;
% % 0-rounds
% out(i) =floor(floor((a-floor(b*m))*m+floor(b*m))*k);i=i+1;
% %begin 1-rounds
% out(i) =floor(floor((a-floor(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =floor(floor((a-round(b*m))*m+floor(b*m))*k);i=i+1;
% out(i) =floor(round((a-floor(b*m))*m+floor(b*m))*k);i=i+1;
% out(i) =round(floor((a-floor(b*m))*m+floor(b*m))*k);i=i+1;
% %end i-rounds
% %begin 2-rounds
% out(i) =floor(floor((a-round(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =floor(round((a-floor(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =floor(round((a-round(b*m))*m+floor(b*m))*k);i=i+1;
% out(i) =round(floor((a-floor(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =round(floor((a-round(b*m))*m+floor(b*m))*k);i=i+1;
% out(i) =round(round((a-floor(b*m))*m+floor(b*m))*k);i=i+1;
% %end 2-rounds
% %begin 3-rounds
% out(i) =floor(round((a-round(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =round(floor((a-round(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =round(round((a-floor(b*m))*m+round(b*m))*k);i=i+1;
% out(i) =round(round((a-round(b*m))*m+floor(b*m))*k);i=i+1;
% %end 3-rounds
% %begin 4-rounds
% out(i)=round(round((a-round(b*m))*m+round(b*m))*k);
% 
% old=round(floor((a-floor(b*m))*m+floor(b*m))*k);
% out'



%% old

% [bbase floor(bcomp) bout; actual]'

% blah =floor(floor((a-floor(b*m))*m+(b*m))*k)

% [base floor(floor((a-floor(b*m))*m)+b*m) blah; actual]'
% 
% %2:
% two=[base floor((a-base)*m)+round(b*m) out(2);1530 3444 3617]'
% 
% %7:
% seven=[base round((a-base)*m)+round(b*m) out(7);1530 3444 3617]'
% 
% %9:
% nine=[base floor((a-base)*m)+round(b*m) out(9);1530 3444 3617]'
% 
% %14:
% fourteen=[base round((a-base)*m)+round(b*m) out(2);1530 3444 3617]'