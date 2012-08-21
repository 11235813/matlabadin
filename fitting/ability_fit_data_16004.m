% CS / WoG / EF / ES / LH / HPr / HPrsc
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)

load ability_fit_data_16004.mat

sp1=ap1./2;
% sp2=ap2./2;
% sp_surf=ap_surf./2;

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
% nwd2=winfo.mean+ap2./14.*2.4;

%% fits
disp('---------------')
disp('---------------')
disp('---------------')
disp('---------------')

% disp('-----CS-----')
% %CS - expected: 0.6507*(1.25*x+667)
% ok=isfinite(cs1);
% cs_ft=fittype('0.6507*(a*x+b)');
% cs_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.25 791]);
% [cs1_fit cs1_gof] = fit(nwd1(ok),cs1(ok),cs_ft,cs_fo)

% disp('-----J-----')
% %J - expected: 623+0.328*AP+0.546*SP = 571+1.2020*SP
% ok=isfinite(j1);
% j_ft=fittype('a*x+b');
% j_fo=fitoptions(j_ft);j_fo.StartPoint=[1.2 623];
% [j_fit j_gof] = fit(sp1(ok),j1(ok),j_ft,j_fo)

% disp('-----WoG-----')
% %WoG surface fits
% %WoG tooltip: (4803-5351); EF tooltip: (5239-5837)
% ok=isfinite(wog1min);
% wog1min_ft=fittype('(b+0.49*x)*(1+0.01*y/530)','indep',{'x','y'},'depend', 'z' );
% wog1min_fo=fitoptions(wog1min_ft);wog1min_fo.StartPoint=[5239];
% [wog1min_sfit wog1min_sgof]=fit([sp1(ok), pvp1(ok)],wog1min(ok),wog1min_ft,wog1min_fo)
% 
% ok=isfinite(wog1max);
% wog1max_ft=fittype('(b+0.49*x)*(1+0.01*y/530)','indep',{'x','y'},'depend', 'z' );
% wog1max_fo=fitoptions(wog1max_ft);wog1max_fo.StartPoint=[5837];
% [wog1max_sfit wog1max_sgof]=fit([sp1(ok), pvp1(ok)],wog1max(ok),wog1max_ft,wog1max_fo)
% 
% disp('-----EF-----')
% %EF surface fit
% ok=isfinite(ef1min);
% ef1_ft=fittype('(b+0.49*x)*(1+0.01*y/530)','indep',{'x','y'},'depend', 'z' );
% ef1_fo=fitoptions(ef1_ft);ef1_fo.StartPoint=[5239];
% [ef1_sfit ef1_sgof]=fit([sp1(ok), pvp1(ok)],ef1min(ok),ef1_ft,ef1_fo)
% 
% disp('-----EF tick-----')
% %EF tick
% ok=isfinite(eft_surf);
% eft_surf_ft=fittype('(508+0.0585*x)*(1+0.01*y/b)','indep',{'x','y'},'depend', 'z' );
% eft_surf_fo=fitoptions(ef1_ft);eft_surf_fo.StartPoint=[530];
% [eft_sfit2 ef1_sgof2]=fit([sp_surf(ok),pvp_surf(ok)],eft_surf(ok),eft_surf_ft,eft_surf_fo)

disp('-----HotR(phys)----')
ok=isfinite(hotr1);
hotr1_ft=fittype('0.6507*a*x');
hotr1_fo=fitoptions(hotr1_ft);hotr1_fo.StartPoint=0.2;
[hotr1_fit hotr1_gof]=fit(nwd1(ok),hotr1(ok),hotr1_ft,hotr1_fo)

disp('----HotR(nova)----')
ok=isfinite(nova1);
nova1_ft=fittype('a*x');
nova1_fo=fitoptions(nova1_ft);nova1_fo.StartPoint=0.35;
[nova1_fit nova1_gof]=fit(nwd1(ok),nova1(ok),nova1_ft,nova1_fo)

disp('----Cons----')
ok=isfinite(cons1);
cons1_ft=fittype('a*x+b');
cons1_fo=fitoptions(cons1_ft);cons1_fo.StartPoint=[1000 0.18];
[cons1_fit cons1_gof]=fit(sp1(ok),cons1(ok),cons1_ft,cons1_fo)