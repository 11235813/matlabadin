% CS / WoG / EF / ES / LH / HPr / HPrsc
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)

load ability_fit_data_15983.mat

sp1=ap1./2;
sp2=ap2./2;
sp_surf=ap_surf./2;

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

nwd1=winfo.mean+ap1./14.*2.4;
nwd2=winfo.mean+ap2./14.*2.4;

%% fits
disp('-----CS-----')
%CS - expected: 0.6507*(1.25*x+667)
ok=isfinite(cs1);
cs_ft=fittype('0.6507*(a*x+b)');
cs_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.25 791]);
[cs1_fit cs1_gof] = fit(nwd1(ok),cs1(ok),cs_ft,cs_fo)

disp('-----J-----')
%J - expected: 623+0.328*AP+0.546*SP = 571+1.2020*SP
ok=isfinite(j1);
j_ft=fittype('a*x+b');
j_fo=fitoptions(j_ft);j_fo.StartPoint=[1.2 623];
[j_fit j_gof] = fit(sp1(ok),j1(ok),j_ft,j_fo)

disp('-----WoG-----')
%WoG surface fits
%WoG tooltip: (4803-5351); EF tooltip: (5239-5837)
ok=isfinite(wog1min);
wog1min_ft=fittype('(b+0.49*x)*(1+0.01*y/530)','indep',{'x','y'},'depend', 'z' );
wog1min_fo=fitoptions(wog1min_ft);wog1min_fo.StartPoint=[5239];
[wog1min_sfit wog1min_sgof]=fit([sp1(ok), pvp1(ok)],wog1min(ok),wog1min_ft,wog1min_fo)

ok=isfinite(wog1max);
wog1max_ft=fittype('(b+0.49*x)*(1+0.01*y/530)','indep',{'x','y'},'depend', 'z' );
wog1max_fo=fitoptions(wog1max_ft);wog1max_fo.StartPoint=[5837];
[wog1max_sfit wog1max_sgof]=fit([sp1(ok), pvp1(ok)],wog1max(ok),wog1max_ft,wog1max_fo)

disp('-----EF-----')
%EF surface fit
ok=isfinite(ef1min);
ef1_ft=fittype('(b+0.49*x)*(1+0.01*y/530)','indep',{'x','y'},'depend', 'z' );
ef1_fo=fitoptions(ef1_ft);ef1_fo.StartPoint=[5239];
[ef1_sfit ef1_sgof]=fit([sp1(ok), pvp1(ok)],ef1min(ok),ef1_ft,ef1_fo)

disp('-----EF tick-----')
%EF tick
ok=isfinite(eft_surf);
eft_surf_ft=fittype('(508+0.0585*x)*(1+0.01*y/b)','indep',{'x','y'},'depend', 'z' );
eft_surf_fo=fitoptions(ef1_ft);eft_surf_fo.StartPoint=[530];
[eft_sfit2 ef1_sgof2]=fit([sp_surf(ok),pvp_surf(ok)],eft_surf(ok),eft_surf_ft,eft_surf_fo)
 
% %WoG pvp power scaling - expected: ((3694-4115)+0.377*sp)*a ?
% ok=isfinite(wog2_min);
% wogpvp_ft=fittype('a*x+b');
% wogpvp_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 3904+0.377*sp2]);
% [wogpvp_fit wogpvp_gof] = fit(pvp2(ok),wog2_min(ok),wogpvp_ft,wogpvp_fo)
% [wogpvp_fit2 wogpvp_gof2] = fit(pvp2(ok),wog2_max(ok),wogpvp_ft,wogpvp_fo)
% 
% %EF - expected: (4030-4491)+0.377*sp per HP
% ok=isfinite(ef2_min);
% ef_ft=fittype('(4030+0.377*301)*(1+0.01*x/a)');
% ef_ft2=fittype('(4491+0.377*301)*(1+0.01*x/a)');
% ef_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[260]);
% [ef_fit ef_gof] = fit(pvp2(ok),ef2_min(ok),ef_ft,ef_fo)
% [ef_fit2 ef_gof2] = fit(pvp2(ok),ef2_max(ok),ef_ft2,ef_fo)
% 
% 
% %EF tick - expected: (391+0.045*sp) per tick
% ok=isfinite(ef2_tick);
% eft_ft=fittype('(391+0.045*301)*(1+0.01*x/a)');
% eft_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[260]);
% [eft_fit eft_gof] = fit(pvp2(ok),ef2_tick(ok),eft_ft,eft_fo)
% 
% %ES - expected 12989 + 5.936.sp
% ok=isfinite(es_mean);
% es_ft=fittype('a*x+b+12000');
% es_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[5.936 989]);
% [es_fit es_gof] = fit(sp1(ok),es_mean(ok),es_ft,es_fo)
% 
% %LH - expected: ((3267-3993)+0.321*sp)*5 = 535 + 0.47*sp
% ok=isfinite(lh1_min);
% lh_ft=fittype('(a*x+b)');
% lh_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.321 3267]);
% [lh_fit lh_gof] = fit(sp1(ok),lh1_min(ok),lh_ft,lh_fo)
% [lh_fit2 lh_gof2] = fit(sp1(ok),lh1_max(ok),lh_ft,lh_fo)
% 
% %HPr offense - dmg - expected: (14523-17750)+1.428*sp
% ok=isfinite(hpr1_min);
% hpr1_ft=fittype('a*x+14523');
% hpr1_ft2=fittype('a*x+17750');
% hpr1_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.428]);
% [hpr1_fit hpr1_gof] = fit(sp1(ok),hpr1_min(ok),hpr1_ft,hpr1_fo)
% [hpr1_fit2 hpr1_gof2] = fit(sp1(ok),hpr1_max(ok),hpr1_ft2,hpr1_fo)
% 
% %HPr offense - heal - expected: (9793-11970)+0.962*sp
% ok=isfinite(hpr1_hmin);
% hpr1h_ft=fittype('a*x+9793');
% hpr1h_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.962]);
% [hpr1h_fit hpr1h_gof]=fit(sp1(ok),hpr1_hmin(ok),hpr1h_ft,hpr1h_fo)
% 
% %try incorporating PvP power
% hpr1h_sft=fittype('(9793+0.962*x)*(1+0.01*y/a)', 'indep', {'x', 'y'}, 'depend', 'z' );
% hpr1h_sft2=fittype('(11970+0.962*x)*(1+0.01*y/a)', 'indep', {'x', 'y'}, 'depend', 'z' );
% hpr1h_sfo=fitoptions(hpr1h_sft);hpr1h_sfo.StartPoint=260;
% [hpr1h_sfit hpr1h_sgof] = fit([sp1(ok), pvp1(ok)],hpr1_hmin(ok),hpr1h_sft,hpr1h_sfo)
% [hpr1h_sfit2 hpr1h_sgof2] = fit([sp1(ok), pvp1(ok)],hpr1_hmax(ok),hpr1h_sft2,hpr1h_sfo)
% 
% %HPr self-cast - expected: (14523-17750)+1.428*sp
% ok=isfinite(hprsc1_min);
% hprsc1_ft=fittype('a*x+14523');
% hprsc1_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.428]);
% [hprsc1_fit hprsc1_gof] = fit(sp1(ok),hprsc1_min(ok),hprsc1_ft,hprsc1_fo)
% 
% hprsc1_sft=fittype('(14523+1.428*x)*(1+0.01*y/a)', 'indep', {'x', 'y'}, 'depend', 'z' );
% hprsc1_sfo=fitoptions(hpr1h_sft);hprsc1_sfo.StartPoint=260;
% [hprsc1_sfit hprsc1_sgof]=fit([sp1(ok),pvp1(ok)],hprsc1_min(ok),hprsc1_sft,hprsc1_sfo)
% 
% %HPr self-cast - expected: (9793-11970)+0.962*sp
% ok=isfinite(hprsc1_dmin);
% hprsc1d_ft=fittype('a*x+9793');
% hprsc1d_ft2=fittype('a*x+11970');
% hprsc1d_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.962]);
% [hprsc1d_fit hprsc1d_gof]=fit(sp1(ok),hprsc1_dmin(ok),hprsc1d_ft,hprsc1d_fo)
% [hprsc1d_fit2 hprsc1d_gof2]=fit(sp1(ok),hprsc1_dmax(ok),hprsc1d_ft2,hprsc1d_fo)
% 
% %WoG surface fit
% ok=isfinite(wog4_min);
% wog4_ft=fittype('(4030+0.377*x)*(1+0.01*y/b)','indep',{'x','y'},'depend', 'z' );
% wog4_fo=fitoptions(wog4_ft);wog4_fo.StartPoint=[260];
% [wog4_sfit wog4_sgof]=fit([sp4(ok), pvp4(ok)],wog4_min(ok),wog4_ft,wog4_fo)
% 
% %Hpr self-cast surface fit
% ok=isfinite(hprsc4_min);
% hprsc4_ft=fittype('(14523+1.428*x)*(1+0.01*y/b)','indep',{'x','y'},'depend', 'z' );
% hprsc4_fo=fitoptions(hprsc4_ft);hprsc4_fo.StartPoint=[260];
% [hprsc4_sfit hprsc4_sgof]=fit([sp4(ok),pvp4(ok)],hprsc4_min(ok),hprsc4_ft,hprsc4_fo)