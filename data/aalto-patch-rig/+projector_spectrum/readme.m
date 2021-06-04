%% Script to visualize the projector spectrum
% Replace this with actual folder name present in the same directory as readme
FOLDER_NAME = '2019-05-06';

% Load spectrum file measured from ocean optics spectrometer

location = fileparts(mfilename('fullpath'));
spectrum = ala_laurila_lab.util.loadSpectralFile([location filesep FOLDER_NAME], 'projector');

figure;
[~, graph] = spectrum.getPowerSpectrum(25, 500, 'um');
a = axes();
graph(a);
title(a, 'power spectrum led current 25 and spot size 500 um');

figure;
[~, graph] = spectrum.getPowerSpectrum(100, 500, 'um');
a = axes();
graph(a);
title(a, 'power spectrum led current 100 and spot size 500 um');


figure;
a = axes();
semilogy(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum());
xlabel(a, 'Wavelength in (nm)');
ylabel(a, 'power spectrum in log scale');
title(a, 'Normalized power spectrum')