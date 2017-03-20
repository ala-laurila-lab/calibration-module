%% Ignore below lines of code, Go to next section please

tbUseProject('calibration-module');

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

ndf2 = service.getNDFMeasurement('A4B');
ndf3 = service.getNDFMeasurement('A1A');
trans = 10^(-(ndf2(end).opticalDensity + ndf3(end).opticalDensity));

% sample r-star table for ndf 5

disp('ndf A1A + A4B');
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

import ala_laurila_lab.*;

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))

spectrum = ala_laurila_lab.util.loadSpectralFile('src\test\resources\spectrum_aalto_rig', 'projector');
semilogy(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum());
figure;
plot(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum())
powerPerUnitArea = 0.15; % in watts for 1000 micron and led current of 100 and no ndf
powerSpectrumPerArea = spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;

rstarPerSecond = util.photonToIsomerisation(powerSpectrumPerArea, spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA)
