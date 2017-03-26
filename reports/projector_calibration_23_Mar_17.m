close all;
clc;
clear;
import ala_laurila_lab.*;


ledCurrent = 100;
radius = 1000 * 10^-6/2; 
area = pi*(radius)^2; 

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))
spectrum = ala_laurila_lab.util.loadSpectralFile('src/test/resources/spectrum_aalto_rig', 'projector');

powerPerArea = @(power) power * 10^-3 / area;
powerSpectrumPerArea = @(powerPerUnitArea) spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = @(powerPerUnitArea) util.photonToIsomerisation(powerSpectrumPerArea(powerPerUnitArea), spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

figure;
plot(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum())

ndf1 = ala_laurila_lab.entity.NDFMeasurement('D1A');

ndf1.ledInput = ledCurrent;
ndf1.ledInputExponent = 1;
ndf1.powers = 0.260;
ndf1.powerExponent = 1e-3;
ndf1.powerWithNdf = 31;
ndf1.powerWithNdfExponent =  1e-6;
ndf1.referenceInput = ledCurrent;

od1 = ndf1.opticalDensity
trans1 = 10^(-ndf1.opticalDensity);

ndf3 = ala_laurila_lab.entity.NDFMeasurement('D3A');
ndf3.ledInput = ledCurrent;
ndf3.ledInputExponent = 1;
ndf3.powers = 0.260;
ndf3.powerExponent =  1e-3;
ndf3.powerWithNdf = 51.6 ;
ndf3.powerWithNdfExponent =  1e-9;
ndf3.referenceInput = ledCurrent;

od3 = ndf3.opticalDensity
trans3 = 10^(-ndf3.opticalDensity);

ndf5 = ala_laurila_lab.entity.NDFMeasurement('D5A');
ndf5.ledInput = ledCurrent;
ndf5.ledInputExponent = 1;
ndf5.powers = 0.260;
ndf5.powerExponent = 1e-3;
ndf5.powerWithNdf = 0.0013;
ndf5.powerWithNdfExponent = 1e-6;
ndf5.referenceInput = ledCurrent;

od5 = ndf5.opticalDensity
trans5 = 10^(-ndf5.opticalDensity);

rstar = rstarPerSecond(powerPerArea(0.16935))
rstar_ndf_1 = rstar * trans1
rstar_ndf_3 = rstar * trans3
rstar_ndf_5 = rstar * trans5

linearity = loadjson('src/test/resources/projector-linearity.json');

fprintf('| Ledurrents \t | rstarPerSecond | ndf 0.92 | ndf 3.7 | ndf 5.3 |\n');
fprintf('| --------- | --------- | --------- | --------- | --------- |\n')
for i = 1 : numel(linearity.ledCurrents)
     rstar = rstarPerSecond(powerPerArea(linearity.powerInMilliWattFor(i)));  % in milli watts for 1000 micron and no ndf
     rstar = round(rstar, 2);
     fprintf('| %s \t | %s | %s \t | %s \t | %s \t |\n', num2str(linearity.ledCurrents(i)), num2str(round(rstar, 2)) , num2str(round(rstar * trans1, 2)), num2str(round(rstar * trans3, 2)), num2str(round(rstar * trans5, 2)));
end