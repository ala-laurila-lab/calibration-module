%% Ignore below lines of code, Go to next section please

tbUseProject('calibration-module');
%%

import ala_laurila_lab.*;
path = which('test-symphony-persistence.xml');
config = struct();
config.service.class = 'ala_laurila_lab.service.CalibrationService';
config.service.dataPersistence = 'test-rig-data';
config.service.logPersistence = 'test-rig-log';
config.service.persistenceXml = which('test-symphony-persistence.xml');
service = mdepin.createApplication(config, 'service');

javaaddpath(which('mpa-jutil-0.0.1-SNAPSHOT.jar'));
javaaddpath(which('java-uuid-generator-3.1.4.jar'));

%% Trying intensity to calculate intensity to rstar
% From calibration api mode

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))

% get all the required instances

intensity = service.getIntensityMeasurement('Blue');
spectrum = service.getSpectralMeasurement('blue', 'led');
linearity = service.getLinearityByStimulsDuration(5000, 'BlueLed');

% calculate rstar per second

powerPerUnitArea = intensity(end).getPowerPerUnitArea();
powerSpectrumPerArea = spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = util.photonToIsomerisation(powerSpectrumPerArea, spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

% get the transmitance value from ndf

ndf4 = service.getNDFMeasurement('A4A');
ndf2 = service.getNDFMeasurement('A2A');
trans = 10^(-(ndf2(end).opticalDensity + ndf4(end).opticalDensity));

% sample r-star table for ndf 5

disp('ndf A4A + A2A');
disp('rstar       voltage')
disp('------------------------')

for voltage = [56.6532853243682, 90.9947797625159, 125.95670244329, 161.932053656434, 198.742115631752, 395.363673745042, 848.984144716212, 1372.9216466916]
    flux = linearity.getFluxByInput(voltage * 10^-3, 'factorized', true);
    rstar = flux * rstarPerSecond * trans;
    disp([num2str(rstar) '      ' num2str(voltage)]);
end

clear service;

%% simple calculation for projector

close all;
clc;
import ala_laurila_lab.*;

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))

spectrum = ala_laurila_lab.util.loadSpectralFile('src/test/resources/spectrum_aalto_rig', 'projector');
linearity = loadjson('src/test/resources/projector-linearity.json');

semilogy(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum());
figure;
plot(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum())

radius = 1000 * 10^-6/2; 
area = pi*(radius)^2; 

powerPerArea = @(power) power * 10^-3 / area;
powerSpectrumPerArea = @(powerPerUnitArea) spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = @(powerPerUnitArea) util.photonToIsomerisation(powerSpectrumPerArea(powerPerUnitArea), spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);


fprintf('| Ledurrents \t | rstarPerSecond | ndf 1 | ndf 3 | ndf 5 |\n');
fprintf('| --------- | --------- | --------- | --------- | --------- |\n')
for i = 1 : numel(linearity.ledCurrents)
     rstar = rstarPerSecond(powerPerArea(linearity.powerInMilliWattFor(i)));  % in milli watts for 1000 micron and no ndf
     rstar = round(rstar, 2);
     fprintf('| %s \t | %s | %s \t | %s \t | %s \t |\n', num2str(linearity.ledCurrents(i)), num2str(round(rstar, 2)) , num2str(round(rstar * 10^(-1), 2)), num2str(round(rstar * 10^(-3), 2)), num2str(round(rstar * 10^(-5), 2)));
end

%% 