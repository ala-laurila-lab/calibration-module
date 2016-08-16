function ph = I2Photon( I, lambda, d_lambda )

% I2Photon Convert intensity to # of photons
%   lambda array of wavelength
%   d_lambda difference in wavelenght between arrays
%   if d_lambda is not supplied then calculate it from original lambda
%
% Description
%   1. calculate the energy of single photon
%   2. no of photons = power in wavelength [lambda, lambda + d_lambda]/ energy

if nargin < 3
    d_lambda =  diff(lambda);
    d_lambda(end + 1) = d_lambda(end);
end

h = 6.63e-34;
c = 3e+8;
E = h * c./(lambda*10^-9);
ph = (I .*d_lambda)./E;

end