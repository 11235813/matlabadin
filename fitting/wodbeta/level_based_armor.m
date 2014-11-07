clear;

data=[90 445
91 504
92 571
93 646
94 731
95 827
96 936
97 1059
98 1199
99 1357
100 1536
101 1670
102 1804
103 1938];


magedata=[90 356
91 403
92 457
93 517
94 585
95 662
96 749
97 847
98 959
99 1086
100 1229
101 1336
102 1443
103 1550];

level=data(:,1);
armor=data(:,2);
magearmor=magedata(:,2);

model1=0.006464588162215.*exp(0.123782410252464.*level);
model2=134.*level-11864;
[level armor round(model1) round(model2) armor-round(model1) armor-round(model2)]

magemodel1=0.005174717123423.*exp(0.123777893791586.*level);
magemodel2=107.*level-9471;

[level magearmor round(magemodel1) round(magemodel2) magearmor-round(magemodel1) magearmor-round(magemodel2)]
