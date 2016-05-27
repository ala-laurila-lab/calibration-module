function power_spectrum_out = extrapolate_edges(power_spectrum, lambda)

% extrapolate_edges - To get rid of "dark noise" by extrapolating both edgs
%                     of power spectrum
%   
%   power_spectrum 
%   lambda
%   returns noise corrected power spectrum
%
%   conventions - <var>_l denotes 'left' axis contaminated by noise & 
%   <var>_r denotes 'right' axis contaminated by noise

p = power_spectrum;

%  negative values (noise) are converted to positive for convenence

pow_log = log10(abs(p)); 

[pow_max, idx_max] = max(log10(abs(p)));
lambda_max = lambda(idx_max);

% indices of curve to be extrapolated can be determined by using slope
%   slope requires equivalent x & y co-rdinates where x = lambda_max +- 50
%   and y ranges between power_spectrum/100, power_spectrum/1000
%   and the equivalent y log value is [pow_max - 2] to [pow_max - 1]. 
%   as a result idx has all the indices equivalent to of above slope

idx = find(pow_log > pow_max - 2 & ...
           pow_log < pow_max - 1 & ...
           lambda > lambda_max - 50 & ...
           lambda < lambda_max + 50 );
       
idx_l = idx(idx < idx_max);
idx_r = idx(idx > idx_max);

lambda_l = lambda(idx_l); 
lambda_r = lambda(idx_r); 

pow_l = pow_log(idx_l);
pow_r = pow_log(idx_r);

% linear fit

p_l = polyfit(lambda_l, pow_l, 1);
p_r = polyfit(lambda_r, pow_r, 1);

% extrapolation
start_l = 1;
end_l = idx_l(1) - 1;

start_r = idx_r(end) - 1;
end_r = numel(lambda);

pow_ext_l = p_l(1) * lambda(start_l : end_l) + p_l(2);
pow_ext_r = p_r(1) * lambda(start_r : end_r)  + p_r(2);

pow_out_log = pow_log;
pow_out_log(idx_l) = pow_ext_l;
pow_out_log(idx_r) = pow_ext_r;

pow_out_log(start_l : end_l) = pow_ext_l;
pow_out_log(start_r : end_r) = pow_ext_r;

power_spectrum_out = 10.^pow_out_log;


lambda_out = lambda;
lambda_out(start_l : end_l) = lambda(start_l : end_l);
lambda_out(start_l : end_l) = lambda(start_l : end_l);
end