% CS / Cens / SoT / SoR / SoI/ EF / HP
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)

load ability_fit_data_4.mat
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
hotr_mean=dmg.hotr;
hanova_mean=dmg.hanova;

%% fits

%HotR - expected: 0.6507*(0.2*x)
ok=isfinite(hotr_mean);
hotr_ft=fittype('0.6507*(a*x+b)');
hotr_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.2 0]);
[hotr_fit hotr_gof] = fit(ndmean(ok),hotr_mean(ok),hotr_ft,hotr_fo)

%HaNova - expected: 0.3*x
ok=isfinite(hanova_mean);
hanova_ft=fittype('a*x');
hanova_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[0.3]);
[hanova_fit hanova_gof] = fit(wdmean(ok),hanova_mean(ok),hanova_ft,hanova_fo)
