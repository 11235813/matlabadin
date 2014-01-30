function [metric, ab, pc] = conf_ellipsoid_stats(v, conf)
%conf_ellipsoid_stats: Returns description of confidence ellipsoid.

% written by Douglas M. Schwarz, 24 November 2000

error(nargchk(1, 2, nargin))

if nargin == 1
   conf = 0.95;
end

n = size(v, 1);
mean_v = mean(v);

p = size(v, 2); % Dimensionality of the data.

k = finv(conf, p, n - p)*p*(n - 1)/(n - p);
[pc, score, lat] = princomp(v);
ab = diag(sqrt(k*lat));
metric = sqrt(sum(ab.^2));
end