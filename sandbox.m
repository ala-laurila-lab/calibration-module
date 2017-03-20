
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
linearity = service.getLinearityByStimulsDuration(5000, 'BlueLed');
powerSpectrumPerArea = spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;

rstarPerSecond = util.photonToIsomerisation(powerSpectrumPerArea, spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

ndf2= service.getNDFMeasurement('A4B');
ndf3 = service.getNDFMeasurement('A1A');
trans =  10^(-(ndf2(end).opticalDensity + ndf3(end).opticalDensity));
% 
% for voltage = [115, 234, 363, 501, 647, 801, 969, 1141, 1316, 1502, 2525, 3716, 5073, 6599, 8296]
%     flux = linearity.getFluxByInput(voltage * 10^-3, 'normalized', true);
%     rstar = flux * rstarPerSecond * trans;    
%     disp([num2str(rstar) '      ' num2str(voltage)]);
% end

for voltage = [56.6532853243682, 90.9947797625159, 125.95670244329, 161.932053656434, 198.742115631752, 395.363673745042, 848.984144716212, 1372.9216466916]
    flux = linearity.getFluxByInput(voltage * 10^-3, 'factorized', true);
    rstar = flux * rstarPerSecond * trans;    
    disp([num2str(rstar) '      ' num2str(voltage)]);
end
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
