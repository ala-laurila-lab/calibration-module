
%% trying intensity to rstar
% From calibration api mode

import ala_laurila_lab.*;

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))

path = which('test-symphony-persistence.xml');

config = struct();
config.service.class = 'ala_laurila_lab.service.CalibrationService';
config.service.dataPersistence = 'test-rig-data';
config.service.logPersistence = 'test-rig-log';
config.service.persistenceXml = which('test-symphony-persistence.xml');
service = mdepin.createApplication(config, 'service');

i = service.getIntensityMeasurement('Blue');
powerPerUnitArea = i(end).getPowerPerUnitArea();
spectrum = service.getSpectralMeasurement('blue', 'led');
linearity = service.getLinearityByStimulsDuration(20, 'BlueLed');
powerSpectrumPerArea = spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;

rstarPerSecond = util.photonToIsomerisation(powerSpectrumPerArea, spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

ndf = service.getNDFMeasurement('A4B');
fluxForLed = linearity.getFluxByInput(1, 'normalized', true);
trans =  10^(-ndf(end).opticalDensity);

isomerisation = @(isomerisationPerSecond) fluxForLed * isomerisationPerSecond * trans * 1000;
rstar = isomerisation(rstarPerSecond)

clear service;
%% simple calculation
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
