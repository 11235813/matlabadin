% CS / Cens / SoT / SoR / SoI/ EF / HP
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)

load ability_fit_data_15952.mat
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

%% fits

%HotR - expected: 0.6507*(0.2*x)
ok=isfinite(hotr_mean);
hotr_ft=fittype('0.6507*(a*x+b)');
hotr_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.2 0]);
[hotr_fit hotr_gof] = fit(ndmean(ok),hotr_mean(ok),hotr_ft,hotr_fo)

%HaNova - expected: 0.3*x
ok=isfinite(nova_mean);
nova_ft=fittype('a*x');
nova_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.3]);
[nova_fit nova_gof] = fit(wdmean(ok),nova_mean(ok),nova_ft,nova_fo)


%Censure - expected: (107+0.094.*sp)*5 = 535 + 0.47*sp
ok=isfinite(cens_mean);
cens_ft=fittype('a*x+b');
cens_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.47 535]);
[cens_fit cens_gof] = fit(sp(ok),cens_mean(ok),cens_ft,cens_fo)

%SoT -expected: 12% weapon damage
ok=isfinite(sot_mean);
sot_ft=fittype('a*x');
sot_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.12]);
[sot_fit sot_gof] = fit(wdmean(ok),sot_mean(ok),sot_ft,sot_fo)

%J - expected: 562+0.397*AP+0.508*SP
ok=isfinite(j_mean);
j_ft=fittype('a*x+b');
j_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.508+2*0.397 562]);
[j_fit j_gof] = fit(sp(ok),j_mean(ok),j_ft,j_fo)

%HoW - expected: 1470.5+1.288*sp
ok=isfinite(how_mean);
how_ft=fittype('a*x+b');
how_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.288 1470.5]);
[how_fit how_gof] = fit(sp(ok),how_mean(ok),how_ft,how_fo)

%EF - expcted: (4030-4491)+0.377*sp per HP
ok=isfinite(ef_min);
ef_ft=fittype('3*(a*x+b)');
ef_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.377 4030]);
[ef_fit ef_gof] = fit(sp(ok),ef_min(ok),ef_ft,ef_fo)
[ef_fit2 ef_gof2] = fit(sp(ok),ef_max(ok),ef_ft,ef_fo)

%EF tick - expected: 391+0.45*sp every 3 sec per HP
ok=isfinite(ef_tick);
eft_ft=fittype('3*(a*x+b)');
eft_fo=fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.045 391]);
[eft_fit eft_gof] = fit(sp(ok),ef_tick(ok),eft_ft,eft_fo)