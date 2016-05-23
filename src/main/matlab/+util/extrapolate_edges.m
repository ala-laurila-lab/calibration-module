function [pow_out_lin, pow_out_log] = extrapolate_edges(power_spectrum, lambda)

% extrapolate_edges - To get rid of "dark noise" by extrapolating both edgs
%                     of power spectrum
%   
%   power_spectrum 
%   lambda
%
%   conventions - var_l denotes 'left' axis contaminated by noise & var_r
%   denotes 'right' axis contaminated by noise

p = power_spectrum;

%  negative values (noise) are converted to positive for convenence

pow_log = log10(abs(p)); 

[val_max, idx_max] = max(log10(abs(p)));
lambda_max = lambda(idx_max);

% Todo - add comments about indices logic 

idx = find(pow_log > val_max - 2 & ...
           pow_log < val_max - 1 & ...
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

pow_ext_l = p_l(1) * lambda_l + p_l(2);
pow_ext_r = p_r(1) * lambda_r + p_R(2);

pow_out_log = pow_log;
pow_out_log(1 : idx_l - 1) = pow_ext_l;
pow_out_log(idx_r + 1 : end) = pow_ext_r;

pow_out_lin = 10.^pow_out_log;

% Todo - check whether we need lambda_out as a parameter

lambda_ext_l = lambda(1 : idx_l - 1);
lambda_ext_r = lambda(idx_r + 1 : end);

lambda_out = lambda;
lambda_out(1 : idx_l -1) = lambda_ext_l;
lambda_out(idx_r + 1 : end) = lambda_ext_r;

end