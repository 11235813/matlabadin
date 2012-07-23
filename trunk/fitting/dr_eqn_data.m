clear
beta=1035;

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

%dodge fit
ftype=fittype('3+1./(1./C+k./x)');
fopt = fitoptions('Method','NonlinearLeastSquares','Lower',[0 0],'Upper',[150 1.5],'StartPoint',[65 0.95]);
[dfit dgof] = fit(dodge_predr',dodge_postdr',ftype,fopt)

%parry fit
pstr1=temp2(:,1);ppost1=temp2(:,2);
pstr2=temp3(:,1);ppost2=temp3(:,2);
% ftype1=fittype('b+s.*x');
% ftype2=fittype('3+1./(1./C+k./(b+x))');
% fopt = fitoptions('Method','NonlinearLeastSquares','Lower',[0 0],'Upper',[150 1.5],'StartPoint',[65 0.95]);
% [p0fit p0gof] = fit(,ftype,fopt)

%parry surface fit
ftypep1=fittype( '3+a.*x+1./(1./C+k./y)', 'indep', {'x', 'y'}, 'depend', 'z' );
ftypep2=fittype( '3+1./(1./C+k./(y+a.*x))', 'indep', {'x', 'y'}, 'depend', 'z' );
opts = fitoptions( ftypep1 );
opts.Display = 'Off';
opts.Lower = [0 0 0];
opts.StartPoint = [65 0.001 0.96];
opts.Upper = [2000 0.1 1.5];

% Fit model to data.
[p1f p1gof] = fit([str' parry_predr'],parry_postdr',ftypep1,opts)
[p2f p2gof] = fit([str' parry_predr'],parry_postdr',ftypep2,opts)
