% CS / WoG / EF / ES / LH / HPr / HPrsc
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)

load ability_fit_data_15961.mat

sp1=ap1./2;
sp2=ap2./2;
sp3=ap3./2;
sp4=ap4./2;

winfo.name='Club';
winfo.speed=1.9;
winfo.min=3;
winfo.max=6;
winfo.mean=4.5;
winfo.dps=2.3;


wdmin=winfo.min+ap1./14.*winfo.speed;
wdmax=winfo.max+ap1./14.*winfo.speed;
wdmean=winfo.mean+ap1./14.*winfo.speed;
ndmin=winfo.min+ap1./14.*2.4;
ndmax=winfo.max+ap1./14.*2.4;
ndmean=winfo.mean+ap1./14.*2.4;

%% fits

%CS - expected: 0.6507*(1.3*x+913)
ok=isfinite(cs_mean);
cs_ft=fittype('0.6507*(a*x+b)');
cs_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.3 913]);
[cs_fit cs_gof] = fit(ndmean(ok),cs_mean(ok),cs_ft,cs_fo)

%WoG pvp power scaling - expected: ((3694-4115)+0.377*sp)*a ?
ok=isfinite(wog2_min);
wogpvp_ft=fittype('a*x+b');
wogpvp_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 3904+0.377*sp2]);
[wogpvp_fit wogpvp_gof] = fit(pvp2(ok),wog2_min(ok),wogpvp_ft,wogpvp_fo)
[wogpvp_fit2 wogpvp_gof2] = fit(pvp2(ok),wog2_max(ok),wogpvp_ft,wogpvp_fo)

%EF - expected: (4030-4491)+0.377*sp per HP
ok=isfinite(ef2_min);
ef_ft=fittype('(4030+0.377*301)*(1+0.01*x/a)');
ef_ft2=fittype('(4491+0.377*301)*(1+0.01*x/a)');
ef_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[260]);
[ef_fit ef_gof] = fit(pvp2(ok),ef2_min(ok),ef_ft,ef_fo)
[ef_fit2 ef_gof2] = fit(pvp2(ok),ef2_max(ok),ef_ft2,ef_fo)


%EF tick - expected: (391+0.045*sp) per tick
ok=isfinite(ef2_tick);
eft_ft=fittype('(391+0.045*301)*(1+0.01*x/a)');
eft_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[260]);
[eft_fit eft_gof] = fit(pvp2(ok),ef2_tick(ok),eft_ft,eft_fo)

%ES - expected 12989 + 5.936.sp
ok=isfinite(es_mean);
es_ft=fittype('a*x+b+12000');
es_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[5.936 989]);
[es_fit es_gof] = fit(sp1(ok),es_mean(ok),es_ft,es_fo)

%LH - expected: ((3267-3993)+0.321*sp)*5 = 535 + 0.47*sp
ok=isfinite(lh1_min);
lh_ft=fittype('(a*x+b)');
lh_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.321 3267]);
[lh_fit lh_gof] = fit(sp1(ok),lh1_min(ok),lh_ft,lh_fo)
[lh_fit2 lh_gof2] = fit(sp1(ok),lh1_max(ok),lh_ft,lh_fo)

%HPr offense - dmg - expected: (14523-17750)+1.428*sp
ok=isfinite(hpr1_min);
hpr1_ft=fittype('a*x+14523');
hpr1_ft2=fittype('a*x+17750');
hpr1_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.428]);
[hpr1_fit hpr1_gof] = fit(sp1(ok),hpr1_min(ok),hpr1_ft,hpr1_fo)
[hpr1_fit2 hpr1_gof2] = fit(sp1(ok),hpr1_max(ok),hpr1_ft2,hpr1_fo)

%HPr offense - heal - expected: (9793-11970)+0.962*sp
ok=isfinite(hpr1_hmin);
hpr1h_ft=fittype('a*x+9793');
hpr1h_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.962]);
[hpr1h_fit hpr1h_gof]=fit(sp1(ok),hpr1_hmin(ok),hpr1h_ft,hpr1h_fo)

%try incorporating PvP power
hpr1h_sft=fittype('(9793+0.962*x)*(1+0.01*y/a)', 'indep', {'x', 'y'}, 'depend', 'z' );
hpr1h_sft2=fittype('(11970+0.962*x)*(1+0.01*y/a)', 'indep', {'x', 'y'}, 'depend', 'z' );
hpr1h_sfo=fitoptions(hpr1h_sft);hpr1h_sfo.StartPoint=260;
[hpr1h_sfit hpr1h_sgof] = fit([sp1(ok), pvp1(ok)],hpr1_hmin(ok),hpr1h_sft,hpr1h_sfo)
[hpr1h_sfit2 hpr1h_sgof2] = fit([sp1(ok), pvp1(ok)],hpr1_hmax(ok),hpr1h_sft2,hpr1h_sfo)

%HPr self-cast - expected: (14523-17750)+1.428*sp
ok=isfinite(hprsc1_min);
hprsc1_ft=fittype('a*x+14523');
hprsc1_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.428]);
[hprsc1_fit hprsc1_gof] = fit(sp1(ok),hprsc1_min(ok),hprsc1_ft,hprsc1_fo)

hprsc1_sft=fittype('(14523+1.428*x)*(1+0.01*y/a)', 'indep', {'x', 'y'}, 'depend', 'z' );
hprsc1_sfo=fitoptions(hpr1h_sft);hprsc1_sfo.StartPoint=260;
[hprsc1_sfit hprsc1_sgof]=fit([sp1(ok),pvp1(ok)],hprsc1_min(ok),hprsc1_sft,hprsc1_sfo)

%HPr self-cast - expected: (9793-11970)+0.962*sp
ok=isfinite(hprsc1_dmin);
hprsc1d_ft=fittype('a*x+9793');
hprsc1d_ft2=fittype('a*x+11970');
hprsc1d_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.962]);
[hprsc1d_fit hprsc1d_gof]=fit(sp1(ok),hprsc1_dmin(ok),hprsc1d_ft,hprsc1d_fo)
[hprsc1d_fit2 hprsc1d_gof2]=fit(sp1(ok),hprsc1_dmax(ok),hprsc1d_ft2,hprsc1d_fo)

%WoG surface fit
ok=isfinite(wog4_min);
wog4_ft=fittype('(4030+0.377*x)*(1+0.01*y/b)','indep',{'x','y'},'depend', 'z' );
wog4_fo=fitoptions(wog4_ft);wog4_fo.StartPoint=[260];
[wog4_sfit wog4_sgof]=fit([sp4(ok), pvp4(ok)],wog4_min(ok),wog4_ft,wog4_fo)