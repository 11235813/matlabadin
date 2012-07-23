%Hammer of Wrath / ES / LH data
%sourceName ="Klaudandus" and spellID =24275 and type=1 and isCritical=false and blocked=0 and (amount <4300 or amount >9200)
ap=[602 3498 6156 9212 12112 15410 17630 21382]';
sp=ap./2;

dmg.how=[2235 2323.6 2410;...
         4563 4651.7 4744;...
         6704 6803.9 6883;...
         9164 9253.6 9345;...
         11501 11594.0 11680;...
         14160 14247.6 14333;...
         15945 16041.3 16121;...
         18961 19043.2 19142];
     
     
dmg.es=[469+516+598+624+687+756+831+914+1005+5028;...
       741+(760+55)+897+987+1085+1193+1313+(1392+53)+1588+7944;...
       991+1090+1199+1319+1451+1596+1755+1931+2124+10621;...
       1278+1406+1546+1701+1871+2058+2264+2490+(2288+451)+13699;...
       1551+1705+1876+2063+2270+2497+2747+3022+3323+16619;...
       (1409+451)+2047+(1801+450)+2476+2724+2996+3296+3626+3988+19940;...
       2069+2276+2504+2754+(2579+450)+3332+3665+4032+4435+(21725+451);...
       2422+2663+(450+2480)+3223+3546+3899+4290+(4268+451)+5190+25954];
         

dmg.lh=[2610 2900.9 3155;...
        2963 3272.9 3506;...
        3311 3609.5 3840;...
        3678 3960.4 4220;...
        4029 4263.6 4581;...
        4444 4669.6 4990;...
        4736 5012.8 5250;...
        5172 5425.5 5719];
   
%create arrays    
how_min=dmg.how(:,1);how_mean=dmg.how(:,2);how_max=dmg.how(:,3);
es_mean=dmg.es;
lh_min=dmg.lh(:,1);lh_mean=dmg.lh(:,2);lh_max=dmg.lh(:,3);

%% fits

%HoW - expected: (1747-1930)+1.61*SP
how_ft=fittype('a*x+b');
how_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1.61 1930]);
[how_fit how_gof] = fit(sp,how_max,how_ft,how_fo)
[how_fit2 how_gof2] = fit(sp,how_min,how_ft,how_fo)

%ES - expected: no tooltip info 
es_ft=fittype('a*x+10000+b');
es_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[4.564 30]);
[es_fit es_gof] = fit(sp,es_mean,es_ft,es_fo)

%LH - expected: (2792+0.247*SP) every 2s
lh_ft=fittype('0.247*x+b');
lh_fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',[2000]);
[lh_fit lh_gof] = fit(sp,lh_max,lh_ft,lh_fo)
[lh_fit2 lh_gof2] = fit(sp,lh_min,lh_ft,lh_fo)
