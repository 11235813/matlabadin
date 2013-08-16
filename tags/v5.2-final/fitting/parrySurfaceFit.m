function [fitresult, gof] = parrySurfaceFit(baseStr, bonusStr, preParry, postParry)
%CREATESURFACEFIT1(BONUSSTR,PREPARRY,POSTPARRY)
%  Fit surface to data.
%
%  Data for 'untitled fit 1' fit:
%      X Input : bonusStr
%      Y Input : preParry
%      Z Output: postParry
%  Output:
%      fitresult : an sfit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, SFIT.

%  Auto-generated by MATLAB on 13-Sep-2012 15:15:46


%% Fit: 'untitled fit 1'.
[xInput, yInput, zOutput] = prepareSurfaceData( bonusStr, preParry, postParry );

% Set up fittype and options.
ft = fittype( '3+164/a+(x/a+y)/((x/a+y)/C+k)', 'indep', {'x', 'y'}, 'depend', 'z' );
opts = fitoptions( ft );
opts.DiffMinChange = 1e-012;
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf];
opts.MaxFunEvals = 60000;
opts.MaxIter = 40000;
opts.Robust = 'Bisquare';
opts.StartPoint = [951.158596 243 0.886];
opts.TolFun = 1e-012;
opts.TolX = 1e-012;
opts.Upper = [Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( [xInput, yInput], zOutput, ft, opts );

% Create a figure for the plots.
figure( 3 );

% Plot fit with data.
h = plot( fitresult, [xInput, yInput], zOutput );
legend( h, 'untitled fit 1', 'postParry vs. bonusStr, preParry', 'Location', 'NorthEast' );
% Label axes
xlabel( 'bonusStr' );
ylabel( 'preParry' );
zlabel( 'postParry' );
grid on

% Plot residuals.
figure(4)
h = plot( fitresult, [xInput, yInput], zOutput, 'Style', 'Residual' );
legend( h, 'untitled fit 1 - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 'bonusStr' );
ylabel( 'preParry' );
zlabel( 'postParry' );
grid on
view( -57.5, 56 );


