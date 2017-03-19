function isomerization_rate_sum = photonToIsomerisation(power_spectrum, lambda, lambda_max, photoreceptor_area)
% isomerization_rate calculates photoisomerization rate
%
%   power_spectrum
%   lambda 
%   lambda_max
%   photoreceptor_area
%
%   Description 
%   1. Get the photon flux 
%   2. calculate the absorbance spectrum using GovardovskiiNomogram template
%   3. calculate isomerization rate which is the product of absorbance 
%   spectrum , photoreceptor area and number of photons 
%   4. return sum of isomerization rate
%
import ala_laurila_lab.util.*;

photons = I2Photon(power_spectrum, lambda);
absorbance_spectrum = myGovardovskiiNomogram(lambda, lambda_max)';
isomerization_rate = photons .*absorbance_spectrum * photoreceptor_area ;
isomerization_rate_sum = sum(isomerization_rate);
end