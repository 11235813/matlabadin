clear
beta=1035;
C0=65.631440;
baseStr=176;

dodge_postdr = [6.03 6.21 6.54 5.45 6.26 5.80 6.60 6.43 3.91 4.25 4.56 4.85 5.04 5.28 5.39 5.68 5.98 6.31 6.58 6.86 7.07];
dodge_rating = [2896 3077 3416 2322 3128 2668 3476 3306 833 1162 1457 1738 1924 2155 2261 2553 2853 3184 3461 3747 3965];
dodge_predr = [2.80 2.97 3.30 2.24 3.02 2.58 3.36 3.19 0.80 1.12 1.41 1.68 1.86 2.08 2.18 2.47 2.76 3.08 3.34 3.62 3.8300];


str = [4914 5308 5483 5956 6123 6371 6589 6751 6430 6430 6430 6430 6430 6430 6430 6430 6430];
parry_postdr = [10.19 10.73 10.68 11.19 11.50 11.67 11.40 11.58 10.96 11.24 11.53 11.79 12.14 12.41 12.76 13.07 13.26];
parry_predr = [1.41 1.51 1.27 1.26 1.38 1.28 0.80 0.80 0.55 0.81 1.09 1.33 1.67 1.93 2.27 2.57 2.75];
parry_rating = [1460 1559 1318 1305 1429 1326 825 823 785 1252 1516 1714 1902 2202 2420 2724 3106];
%http://maintankadin.failsafedesign.com/forum/viewtopic.php?p=729671#p729671

temp=[14.38 785 0.76; 14.84 1252 1.21; 15.10 1516 1.46; 15.29 1714 1.66; 15.48 1902 1.84; 15.77 2202 2.13; 15.98 2420 2.34; 16.28 2724 2.63; 16.65 3106 3.00];
str=[str repmat(9354,1,size(temp,1))];
parry_postdr=[parry_postdr temp(:,1)'];
parry_rating=[parry_rating temp(:,2)'];
parry_predr = [parry_predr temp(:,3)'];


temp2=[3638 9.50; 4242 10.17; 4752 10.74; 5477 11.55; 6115 12.25; 6606 12.79; 7210 13.44; 7935 14.23; 8779 15.13];
parry_rating = [parry_rating repmat(2178,1,size(temp2,1))];
parry_postdr = [parry_postdr temp2(:,2)'];
str = [str temp2(:,1)'];
parry_predr = [parry_predr repmat(2.10,1,size(temp2,1))];

temp3=[1350 5.85; 2236 6.87; 2870 7.60; 3631 8.46; 4602 9.56; 5236 10.27; 5870 10.98; 6389 11.55; 7056 12.28; 7817 13.12; 8578 13.94; 9548 14.99; 10309 15.80];
parry_rating = [parry_rating repmat(1191,1,size(temp3,1))];
parry_postdr = [parry_postdr temp3(:,2)'];
str = [str temp3(:,1)'];
parry_predr = [parry_predr repmat(1.15,1,size(temp3,1))];

%dodge fit from all data
d1_ft=fittype('b+1./(1./C+k./x)');
d1_fo = fitoptions('Method','NonlinearLeastSquares','Lower',[0 2.5 0],'Upper',[150 3.5 1.5],'StartPoint',[65 3 0.95]);
[d1_fit d1_gof] = fit(dodge_predr',dodge_postdr',d1_ft,d1_fo)

d2_ft=fittype('3.01+1./(1./65.631440+k./x)');
d2_fo = fitoptions('Method','NonlinearLeastSquares','Lower',[0],'Upper',[1.5],'StartPoint',[0.95]);
[d2_fit d2_gof] = fit(dodge_predr',dodge_postdr',d2_ft,d2_fo)

%parry fit - just fitting str data from temp2
pstr1=temp2(:,1);ppost1=temp2(:,2);

ps1_ft=fittype('b+x./a');
ps1_fo=fitoptions('Method','NonlinearLeastSquares','Lower',[800 2],'Upper',[1000 6],'StartPoint',[900 3]);
[ps1_fit ps1_gof] = fit(pstr1,ppost1,ps1_ft,ps1_fo)

ps2_ft=fittype('b+176./a+1./(1./235.5+0.885./(2.1+(x-176)./a))');
ps2_fo=fitoptions('Method','NonlinearLeastSquares','Lower',[800 2],'Upper',[1000 4],'StartPoint',[900 3]);
[ps2_fit ps2_gof] = fit(pstr1,ppost1,ps2_ft,ps2_fo)

%again for temp3
pstr2=temp3(:,1);ppost2=temp3(:,2);

ps3_ft=fittype('b+x./a');
ps3_fo=fitoptions('Method','NonlinearLeastSquares','Lower',[800 2],'Upper',[1000 6],'StartPoint',[900 3]);
[ps3_fit ps3_gof] = fit(pstr2,ppost2,ps3_ft,ps3_fo)

ps4_ft=fittype('b+176./a+1./(1./235.5+0.885./(1.15+(x-176)./a))');
ps4_fo=fitoptions('Method','NonlinearLeastSquares','Lower',[800 2],'Upper',[1000 6],'StartPoint',[900 3]);
[ps4_fit ps4_gof] = fit(pstr2,ppost2,ps4_ft,ps4_fo)

%parry surface fit
p1_ft=fittype( '3.00+176./951.158596+1./(1./C+k./((x-176)./951.158596+y))', 'indep', {'x', 'y'}, 'depend', 'z' );
p1_opts = fitoptions( p1_ft );
p1_opts.Display = 'Off';
p1_opts.Lower = [200 0.5];
p1_opts.StartPoint = [235 0.88];
p1_opts.Upper = [300 1.5];

% Fit model to data.
[p1_fit p1_gof] = fit([str' parry_predr'],parry_postdr',p1_ft,p1_opts)

%parry surface fit with fewer parameters
p2_ft=fittype( '3.00+176./951.158596+1./(1./C+0.885./((x-176)./951.158596+y))', 'indep', {'x', 'y'}, 'depend', 'z' );
p2_opts = fitoptions( p2_ft );
p2_opts.Display = 'Off';
p2_opts.Lower = [200 ];
p2_opts.StartPoint = [235];
p2_opts.Upper = [300];
[p2_fit p2_gof] = fit([str' parry_predr'],parry_postdr',p2_ft,p2_opts)

%parry surface fit with fewer parameters
p3_ft=fittype( '3.00+176./a+1./(1./235.5+0.885./((x-176)./a+y))', 'indep', {'x', 'y'}, 'depend', 'z' );
p3_opts = fitoptions( p3_ft );
p3_opts.Display = 'Off';
p3_opts.Lower = [800];
p3_opts.StartPoint = [900 ];
p3_opts.Upper = [1000];
[p3_fit p3_gof] = fit([str' parry_predr'],parry_postdr',p3_ft,p3_opts)


figure(2)
h = plot( p3_fit, [str', parry_predr'], parry_postdr');
legend( h, '3.00+176./952+1./(1./235.5+0.885./((x-176)./952+y))', 'parry\_postdr vs. str, parry\_predr', 'Location', 'NorthEast' );
% Label axes
xlabel( 'str' );
ylabel( 'parry_predr' );
zlabel( 'parry_postdr' );
grid on

figure(3)
h = plot( p3_fit, [str', parry_predr'], parry_postdr', 'Style', 'Residual' );
legend( h, 'fit - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'str' );
ylabel( 'parry_predr' );
zlabel( 'parry_postdr' );
grid on
% view( -31.5, 58 );
