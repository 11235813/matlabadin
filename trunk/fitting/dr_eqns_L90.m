base.str=176;
base.agi=107;
base.dodge=5.01;
base.parry=3.01;

naked.parry=3.19;
naked.dodge=3.01;
naked.str=base.str;
naked.agi=base.agi;

%% Data set 1, 0 parry rating, just STR
data = [...
1020	1624	2349	2868	3273	3877	4481	4809	5206	5931	6855	7010	7580	8184	8690	9545	9819	10566	11695
107	107	107	107	107	107	107	107	107	107	107	107	107	107	107	107	107	107	107
5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01	5.01
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
4.18	4.89	5.74	6.34	6.8	7.5	8.19	8.56	9.01	9.82	10.85	11.03	11.66	12.32	12.88	13.8	14.1	14.9	16.11
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0];

set1.str=data(1,:);
set1.agi=data(2,:);
set1.dodge=data(3,:);
set1.dodgerat=data(4,:);
set1.dodgepredr=data(5,:);
set1.parry=data(6,:);
set1.parryrat=data(7,:);
set1.parrypredr=data(8,:);

%sanity check - base str->parry conversion bounds
round(base.str./(naked.parry+[-0.01 0.01]-base.parry))

%fit variables
net_str=(set1.str-base.str)';
parry=(set1.parry)'-naked.parry;

%fit - keep known k but leave C and a free
s2p_ft=fittype('1/(1/C+0.885/(x/a))');
s2p_fo=fitoptions('Method','NonlinearLeastSquares','Lower',[200 800],'Upper',[250 1000],'StartPoint',[232 951]);
[s2p_fit s2p_gof] = fit(net_str,parry,s2p_ft,s2p_fo)

%again, with given a
s2p_ft2=fittype('1/(1/C+0.885/(x/951.158596))');
s2p_fo2=fitoptions('Method','NonlinearLeastSquares','Lower',[200],'Upper',[250],'StartPoint',[232]);
[s2p_fit s2p_gof] = fit(net_str,parry,s2p_ft2,s2p_fo2)

%% Data set 2, fixed STR, parry rating increases
data = [...
14.1	14.57	15.04	15.39	15.75	16.08	16.52	16.96	17.28	17.53	17.72	17.91	18.24
0	408	816	1116	1432	1721	2107	2493	2782	2996	3168	3340	3629
0	0.46	0.92	1.26	1.62	1.94	2.38	2.82	3.14	3.39	3.58	3.77	4.1];

set2.str=9819;
set2.agi=107;
set2.dodge=5.01;
set2.parry=data(1,:)';
set2.parryrat=data(2,:)';
set2.parrypredr=data(3,:)';

%sanity check - parry rating -> parry conversion factor, should be 885;
% ratio = set2.parryrat./set2.parrypredr
meanratio=mean(ratio(~isnan(ratio)));

%fit variables
net_str2=set2.str-base.str;
parry2=set2.parry-naked.parry;
predr_parry2=set2.parrypredr;

%fit - leave C/a free
p2p_ft=fittype('1/(1/C+0.885/(x+(9819-176)/a))');
p2p_fo=s2p_fo;
[p2p_fit p2p_gof] = fit(predr_parry2, parry2, p2p_ft, p2p_fo)

%fit 2 - use known a
p2p_ft=fittype('1/(1/C+0.885/(x+(9819-176)/951.158596))');
p2p_fo=s2p_fo2;
[p2p_fit p2p_gof] = fit(predr_parry2, parry2, p2p_ft, p2p_fo)

%% Dodge from Agi
data=[...
332	762	1082	1596	2142	2939	3259
5.04	5.08	5.12	5.18	5.24	5.33	5.36
0	0	0	0	0	0	0
0	0	0	0	0	0	0];

set3.str=176;
set3.agi=data(1,:)';
set3.dodge=data(2,:)';
set3.dodgerating=data(3,:)';
set3.dodgepredr=data(3,:)';

%fit variables
net_agi=set3.agi-base.agi;
dodge=set3.dodge-base.dodge;

%fit
a2d_ft=fittype('1/(1/65.631440+0.885/(x/a))');
a2d_fo=fitoptions('Method','NonlinearLeastSquares','Lower',[100],'Upper',[1000000],'StartPoint',[10000]);
[a2d_fit a2d_gof] = fit(net_agi,dodge,a2d_ft,a2d_fo)