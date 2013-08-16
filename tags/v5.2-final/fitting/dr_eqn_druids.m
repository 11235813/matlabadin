%load level 85 data
load dr_eqn_druids.mat

%% agi+rating->dodge at 85
lvl85.ft=fittype('3.00+91/a+1/(1/C+k/(y+(x-91)/a))',...
    'dependent',{'z'},'independent',{'x','y'});
lvl85.fo=fitoptions('method','NonlinearLeastSquares','Lower',[50 220 0.5],'Upper',[600 253 2],'Startpoint',[505 243.5 1.3]);

[xInput, yInput, zOutput] = prepareSurfaceData( agi85, pre85, post85);
clear fit gof
[fit gof] = fit( [xInput, yInput], zOutput, lvl85.ft, lvl85.fo );
lvl85_fit=fit
lvl85_gof=gof



lvl85.ft2=fittype('3.00+91/243.58+1/(1/C+k/(y+(x-91)/243.58))',...
    'dependent',{'z'},'independent',{'x','y'});
lvl85.fo2=fitoptions('method','NonlinearLeastSquares','Lower',[50 0.5],'Upper',[600 2],'Startpoint',[505 1.3]);
clear fit gof
[fit gof] = fit( [xInput, yInput], zOutput, lvl85.ft2, lvl85.fo2 );
lvl85_fit2=fit
lvl85_gof2=gof

%surface plots
figure(2)
h = plot( lvl85_fit2, [agi85, pre85], post85);
legend( h, '3.00+91/243.58+1/(1/C+k/(y+(x-91)/243.58))', 'data points', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'post-DR dodge (%)' );
grid on

figure(3)
h = plot( lvl85_fit2, [agi85, pre85], post85,'Style','Residual');
legend( h, 'fit - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'Error in post-DR dodge (%)' );
grid on
set(gca,'view',[-70 22])

%% again at 90
lvl90.ft=fittype('3.00+102/951.158596+1/(1/C+k/(y+(x-102)/951.158596))',...
    'dependent',{'z'},'independent',{'x','y'});
lvl90.fo=fitoptions('method','NonlinearLeastSquares','Lower',[120 1],'Upper',[200 2],'Startpoint',[505 1.3]);

lvl90.ft2=fittype('3.00+102/951.158596+1/(1/C+1.222/(y+(x-102)/951.158596))',...
    'dependent',{'z'},'independent',{'x','y'});
lvl90.fo2=fitoptions('method','NonlinearLeastSquares','Lower',[120],'Upper',[200],'Startpoint',[505]);

[xInput, yInput, zOutput] = prepareSurfaceData( agi90, pre90, post90);
clear fit gof
[fit gof] = fit( [xInput, yInput], zOutput, lvl90.ft2, lvl90.fo2 );
lvl90_fit=fit
lvl90_gof=gof

%surface plots
figure(4)
h = plot( lvl90_fit, [agi90, pre90], post90);
legend( h, '3.00+102/951.158596+1/(1/C+1.422/(y+(x-102)/951.158596))', 'data points', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'post-DR dodge (%)' );
grid on

figure(5)
h = plot( lvl90_fit, [agi90, pre90], post90,'Style','Residual');
legend( h, 'fit - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'agi' );
ylabel( 'pre-DR dodge from rating (%)' );
zlabel( 'Error in post-DR dodge (%)' );
grid on
set(gca,'view',[-70 22])
