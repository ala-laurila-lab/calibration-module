function pow = angle_correction(pow, lambda)
% angle_correction - Cosine-corrector correction 
%   See /Users/dtakeshi/Dropbox/AlaLaurila-Lab-Yoda/Patch rig/Patch
%   rig_spectrum.opj (Origin file) for more detail. In short, correction
%   coefficient alpha is obtained as:
%   alpha = (A + B1*lambda + B2*lambda^2)*(angled CC)/(noral CC)

alpha = (-0.41692 + 0.00384 * lambda-2.31036E-6 * lambda.^2) * (5.62568/3.8547);
pow = pow./alpha;
end