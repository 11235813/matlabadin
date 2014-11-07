% AP=3277;
% AP=3769;
% SP=AP;
% haste=1129;
% ms=281;% (4,26%)
% versR=291;% (2,24/1,12%)
% crit=289; % (5,00+2,63%)
% mast=399; % (8,00+3,63%)
% stam=3618;
% nwd=[295 548]+AP/3.5*2.4;
% wd=[295 548]+AP/3.5*2.6;
% amit=0.6503;
% 
% res=1+stam/250/261;
% vers=1+versR/13000;

%% Log 1
% disp('===================')
% %fixed damage
% sotr=round((1+1.6*AP)*vers)
% cons=round((1+0.1676*AP)*vers*1.5)
% AS=round((1+1.333*AP)*vers)
% HW=round((1+1.6*AP)*vers)
% J=round((1+0.48*AP+0.58*SP)*vers) %random 5312s in log due to HA
% cens=round((0.061776*SP)*5*vers)
% ES=round((9.142*SP)*vers) %33430 total damage in log
% 
% %weapon range
% sot=round(0.12*wd*vers)
% melee=round(wd*vers*amit)
% cs=round(nwd*vers*amit) %high values in log due to HA
% 
% %heal
% ef=round(2.64591*SP*vers*res)
% eftick=round((1+0.1*SP)*vers*1.5*res)
% fol=round(2.5*SP*vers*res)

%% Log 2 & 3
% disp('===================')
% AP=3277;
% SP=AP;
% nwd=[295 548]+AP/3.5*2.4;
% wd=[295 548]+AP/3.5*2.6;
% 
% hotr1=round(0.42*nwd*vers*amit)
% hotr2=round(0.24*nwd*vers)
% soi=round(2*0.16*AP*vers*res*1.05)
% fol=round(2.5*SP*vers*res*1.05)
% ef=round(2.64591*SP*vers*res*1.05*(1.5+5/100*(8+3.63)))
% 
% sor=round(0.05*nwd*vers)


%% LH/HPr tests: http://maintankadin.failsafedesign.com/forum/viewtopic.php?p=784716#p784716
% disp('===================')
% AP=3679;SP=AP;
% vers=1+100/13000;
% stam=4088;
% res=1+stam/250/261;
% res=1.0793;
% 
% ALH=round((0.402432*SP)*vers*res)
% ALD=round(0.51678*SP*vers)
% 
% ALH2=round((0.402432*SP)*vers*res*1.05)
% 
% HPD=round(1.65*SP*vers)
% HPH=round(1.20585*SP*vers*res)

% HPH2=round(1.20585*SP*vers*res*1.05)

%% SS tests: http://maintankadin.failsafedesign.com/forum/viewtopic.php?p=784720#p784720
% disp('===================')
% vers=1+224/13000;
% stam=4992;
% res=1+stam/250/206.2;
% spc=1.306;
% spc=0.995;
% 
% SP=4173;
% SSp=round((1+spc*SP)*vers*res)
% 
% SP=4678;
% SSh=round((1+spc*SP)*vers)
% 
% SP=3869;
% SSr=round((1+spc*SP)*vers/0.7)

%% SS Re-tests: 
disp('===================')
%tweak spc
spc=1.306;
spc=1.3059954410;
%tweak base
b=1;

%prot stats
AP=4098;SP=AP;
vers=1+324/13000;
res=1+4992/250/206;
% res=1.0962;

SSp_t=round(b+spc*SP)
SSp_a=round((b+spc*SP)*vers*res)

%ret stats
AP=3799;SP=AP;
vers=1+324/13000+0.03;
% vers=1.0549

SSr_t=round((b+spc*SP)/0.7)
SSr_a=round((b+spc*SP)/0.7*vers)
SSr_a2=round((b+spc*SP)/0.69945*vers)

%holy stats
AP=1455;SP=2617;
vers=1+324/13000;
spc=0.9948;

SSh_t=round(b+spc*SP)
SSh_a=round((b+spc*SP)*vers)