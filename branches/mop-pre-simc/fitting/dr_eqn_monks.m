%monk DR data/fitting

%data imported from excel and sorted into useful fields, loaded from
%associated .mat file
load dr_eqn_monks.mat

%correct typo in data, d2d_85_post(1) should be 3.42, not 3.12
d2d_85_post(1)=3.42;

%% agi->dodge at 85
a2d85.ft=fittype('3.00+103/a+1/(1/C+k/((x-103)/a))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'C', 'a', 'k'});
a2d85.fo=fitoptions('method','NonlinearLeastSquares','Lower',[0 150 0.5],'Upper',[Inf 350 1.5],'Startpoint',[100 250 0.855]);
clear fit gof
[fit gof] = fit(a2d_85_agi,a2d_85_dodge,a2d85.ft,a2d85.fo);
a2d_85_fit=fit
a2d_85_gof=gof 

%% agi+rating->dodge at 85
d2d85.ft=fittype('3.00+103/a+1/(1/C+k/(y+(x-103)/a))',...
    'dependent',{'z'},'independent',{'x','y'});
d2d85.fo=fitoptions('method','NonlinearLeastSquares','Lower',[200 220 0.5],'Upper',[600 253 2],'Startpoint',[505 254 1.3]);
d2d_agi=[a2d_85_agi; a2d_85_agi];
d2d_pre=[d2d_85_pre; zeros(size(d2d_85_pre))];
d2d_post=[d2d_85_post; a2d_85_dodge];
[xInput, yInput, zOutput] = prepareSurfaceData( d2d_agi, d2d_pre, d2d_post);
clear fit gof
[fit gof] = fit( [xInput, yInput], zOutput, d2d85.ft, d2d85.fo   );
d2d_85_fit=fit
d2d_85_gof=gof

%surface plots
figure(2)
h = plot( d2d_85_fit, [d2d_agi, d2d_pre], d2d_post);
legend( h, '3.00+103/a+1/(1/C+k/(y+(x-103)/a))', 'data points', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'post-DR dodge (%)' );
grid on

figure(3)
h = plot( d2d_85_fit, [d2d_agi, d2d_pre], d2d_post,'Style','Residual');
legend( h, 'fit - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'Error in post-DR dodge (%)' );
grid on
set(gca,'view',[-70 22])

%% parry rating -> parry at 85
p2p85.ft = fittype('8.01+1/(1/C+k/x)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'C', 'k'});
clear fit gof
[fit gof] = fit(p2p_85_pre,p2p_85_post,p2p85.ft,'StartPoint',[100 1.4]);
p2p_85_fit1=fit
p2p_85_gof1=gof

p2p85.ft2=fittype('8.01+1/(1/C+1.422/x)');
clear fit gof
[fit gof] = fit(p2p_85_pre,p2p_85_post,p2p85.ft2,'StartPoint',[100]);
p2p_85_fit2=fit
p2p_85_gof2=gof


%% again at 90
%parry first this time
p2p90.ft = fittype('8.01+1/(1/C+k/x)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'C', 'k'});
clear fit gof
[fit gof] = fit(p2p_90_pre,p2p_90_post,p2p90.ft,'StartPoint',[100 1.4]);
p2p_90_fit1=fit
p2p_90_gof1=gof

p2p90.ft2=fittype('8.01+1/(1/C+1.422/x)');
clear fit gof
[fit gof] = fit(p2p_90_pre,p2p_90_post,p2p90.ft2,'StartPoint',[100]);
p2p_90_fit2=fit
p2p_90_gof2=gof

%% agi-> dodge at 90
a2d90.ft=fittype('3.00+111/a+1/(1/C+k/((x-111)/a))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'C', 'a', 'k'});
a2d90.fo=fitoptions('method','NonlinearLeastSquares','Lower',[0 800 1],'Upper',[Inf 1200 2],'Startpoint',[400 1000 1.422]);
clear fit gof
[fit gof] = fit(a2d_90_agi,a2d_90_dodge,a2d90.ft,a2d90.fo);
a2d_90_fit=fit
a2d_90_gof=gof 

a2d90.ft2=fittype('3.00+111/a+1/(1/C+1.422/((x-111)/a))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'C', 'a'});
a2d90.fo2=fitoptions('method','NonlinearLeastSquares','Lower',[0 800],'Upper',[Inf 1200],'Startpoint',[400 1000]);
clear fit gof
[fit gof] = fit(a2d_90_agi,a2d_90_dodge,a2d90.ft2,a2d90.fo2);
a2d_90_fit2=fit
a2d_90_gof2=gof 

a2d90.ft3=fittype('3.00+111/951.158596+1/(1/C+1.422/((x-111)/951.158596))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'C'});
a2d90.fo3=fitoptions('method','NonlinearLeastSquares','Lower',[0],'Upper',[Inf],'Startpoint',[400]);
clear fit gof
[fit gof] = fit(a2d_90_agi,a2d_90_dodge,a2d90.ft3,a2d90.fo3);
a2d_90_fit3=fit
a2d_90_gof3=gof 

%% agi+rating->dodge at 90
d2d90.ft=fittype('3.00+111/951.158596+1/(1/C+k/(y+(x-111)/951.158596))',...
    'dependent',{'z'},'independent',{'x','y'});
d2d90.fo=fitoptions('method','NonlinearLeastSquares','Lower',[200 1.3],'Upper',[600 2],'Startpoint',[505 1.5]);

d2d90.ft3=fittype('3.00+111/951.158596+1/(1/C+1.422/(y+(x-111)/951.158596))',...
    'dependent',{'z'},'independent',{'x','y'});
d2d90.fo3=fitoptions('method','NonlinearLeastSquares','Lower',[200],'Upper',[600],'Startpoint',[505]);

d2d90.ft4=fittype('roundn(3.00+111/951.158596+1/(1/C+1.422/(y+(x-111)/951.158596)),-2)',...
    'dependent',{'z'},'independent',{'x','y'});
d2d90.fo4=fitoptions('method','NonlinearLeastSquares','Lower',[200],'Upper',[600],'Startpoint',[500]);

d2d90_agi=[a2d_90_agi; a2d_90_agi];
d2d90_pre=[d2d_90_pre; zeros(size(d2d_90_pre))];
d2d90_post=[d2d_90_post; a2d_90_dodge];
[xInput, yInput, zOutput] = prepareSurfaceData( d2d90_agi, d2d90_pre, d2d90_post);
clear fit gof
[fit gof] = fit( [xInput, yInput], zOutput, d2d90.ft3, d2d90.fo3);
d2d_90_fit=fit
d2d_90_gof=gof

%surface plots
figure(4)
h = plot( d2d_90_fit, [d2d90_agi, d2d90_pre], d2d90_post);
legend( h, '3.00+111/a+1/(1/C+k/(y+(x-111)/a))', 'data points', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'post-DR dodge (%)' );
grid on

figure(5)
h = plot( d2d_90_fit, [d2d90_agi, d2d90_pre], d2d90_post,'Style','Residual');
legend( h, 'fit - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'Error in post-DR dodge (%)' );
grid on
set(gca,'view',[-70 22])
