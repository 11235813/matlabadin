% CS / Cens / SoT / SoR / SoI/ EF / HP
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)

load ability_fit_data_3.mat
sp=ap./2;

winfo.name='Club';
winfo.speed=1.9;
winfo.min=3;
winfo.max=6;
winfo.mean=4.5;
winfo.dps=2.3;


wdmin=winfo.min+ap./14.*winfo.speed;
wdmax=winfo.max+ap./14.*winfo.speed;
wdmean=winfo.mean+ap./14.*winfo.speed;
ndmin=winfo.min+ap./14.*2.4;
ndmax=winfo.max+ap./14.*2.4;
ndmean=winfo.mean+ap./14.*2.4;

%create arrays    
cs_mean=dmg.cs;
cens_mean=dmg.cens;
sot_mean=dmg.sot;
sor_mean=dmg.sor;
hp_min=dmg.prism(:,1);hp_mean=dmg.prism(:,2);hp_max=dmg.prism(:,3);

hpt_min=heal.prism(:,1);hpt_max=heal.prism(:,2);
ef_min=heal.ef(:,1);ef_max=heal.ef(:,2);ef_tick=heal.ef(:,3);
soi_mean=heal.soi;
wog_min=heal.wog(:,1);wog_max=heal.wog(:,2);

%% fits

%CS - expected: 0.6507*(1.3*x+931)
ok=[1 2 4]; %eliminate upper data points that include pvp hands
cs_ft=fittype('0.6507*(a*x+b)');
cs_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.3 931]);
[cs_fit cs_gof] = fit(ndmean(ok),cs_mean(ok),cs_ft,cs_fo)

%Censure
%expected based on tooltip: 
%(126+0.11*sp)*5 = 630 + 0.55*sp
ok=isfinite(cens_mean);
cens_ft=fittype('a*x+b');
cens_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.55 630]);
[cens_fit cens_gof] = fit(sp(ok),cens_mean(ok),cens_ft,cens_fo)

%SoT
%expected based on tooltip:
%14% weapon damage
%fit form: a*x, expect a=0.14
ok=isfinite(sot_mean);
sot_ft=fittype('a*x');
sot_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.14]);
[sot_fit sot_gof] = fit(wdmean(ok),sot_mean(ok),sot_ft,sot_fo)

%SoR
%expected based on tooltip:
%5% weapon damage
%fit form: a*x, expect a=0.05
ok=[1:5 7:8];
sor_ft=fittype('a*x');
sor_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.05]);
[sor_fit sor_gof] = fit(ndmean(ok),sor_mean(ok),sor_ft,sor_fo)

%Holy Prism DD
%expected based on tooltip:
%(12412 + 1.098.*player.sp)
%fit form a*x+b, expect a=1.098, b=12412
ok=isfinite(hp_mean);
hp_ft=fittype('1.098*x+b+10000');
hp_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[412]);
[hp_fit hp_gof] = fit(sp(ok),hp_min(ok),hp_ft,hp_fo)
[hp_fit2 hp_gof2] = fit(sp(ok),hp_max(ok),hp_ft,hp_fo)

%Holy Prism tick (heals)
%expected based on tooltip:
%8374 + 0.74*sp
%fit form a*x+b, expect a=0.74, b=8374
ok=isfinite(hpt_min);
hpt_ft=fittype('a*x+b');
hpt_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.74 8374]);
[hpt_fit hpt_gof] = fit(sp(ok),hpt_min(ok),hpt_ft,hpt_fo)
[hpt_fit2 hpt_gof2] = fit(sp(ok),hpt_max(ok),hpt_ft,hpt_fo)
%result consistent with (8374-10234)+0.823*sp, reverse effect from tooltip,
%not benefitting from SoI 5% boost

%EF - expected: (4030-4491)+0.377*sp per holy power
ok=isfinite(ef_min);
ef_ft=fittype('3*(a*x+b)');
ef_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.377 4260]);
[ef_fit ef_gof] = fit(sp(ok),ef_min(ok),ef_ft,ef_fo)
[ef_fit2 ef_gof2] = fit(sp(ok),ef_max(ok),ef_ft,ef_fo)

%EF ticks - expected: 1393+0.16*sp
eft_ft=ef_ft;
eft_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.16 1393]);
[eft_fit eft_gof] = fit(sp(ok),ef_tick(ok),eft_ft,eft_fo)

%SoI- expected: 0.15*AP+0.15*SP = 0.45*sp
ok=isfinite(soi_mean);
soi_ft=fittype('a*x');
soi_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.45]);
[soi_fit soi_gof] = fit(sp(ok),soi_mean(ok),soi_ft,soi_fo)

%WoG - expected
ok=isfinite(wog_min);
wog_ft=fittype('a*x+b');
wog_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.377 3694]);
[wog_fit wog_gof]= fit(sp(ok),wog_min(ok),wog_ft,wog_fo)
[wog_fit2 wog_gof2]= fit(sp(ok),wog_max(ok),wog_ft,wog_fo)