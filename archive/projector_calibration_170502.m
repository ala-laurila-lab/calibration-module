close all;
clc;
clear;
import ala_laurila_lab.*;


ledCurrent = 100;
radius = 500 * 10^-6/2;
area = pi*(radius)^2;

LAMDA_MAX = 497;                        % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;   % um^2, collective area of rod (Murphy & Rieke (2011))
spectrum = ala_laurila_lab.util.loadSpectralFile('C:\Users\User\Documents\MATLAB\projects\calibration-module\src\test\resources\spectrum_aalto_rig', 'projector');

powerPerArea = @(power) power * 10^-3 / area;
powerSpectrumPerArea = @(powerPerUnitArea) spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = @(powerPerUnitArea) util.photonToIsomerisation(powerSpectrumPerArea(powerPerUnitArea), spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

figure;
plot(spectrum.wavelength, spectrum.getNormalizedPowerSpectrum())

ND(1)=0;
ND(2)=3.58;
ND(3)=4.49;%%!!! that is a typo. It should be 4.94! Used these light calibrations for all experiments until 20171107!
ND(4)=6.4;
ND(5)=7.49;
ND(6)=8.88;

%power we measure with optometer in mW
rstar = rstarPerSecond(powerPerArea(0.320));
NDstring=[];filler=[];fprintstring=[];
for i=2:length(ND)
    rstar_ndf(i) = rstar * 10^(-ND(i));
    NDstring=[NDstring, ' ndf ', num2str(ND(i)),' |'];
    filler=[filler, '  --------- |'];
    fprintstring=[fprintstring, ' %.3f \t |'];
end

linearity = loadjson('src/test/resources/projector-linearity.json');

linearityValues=linearity.powerInMilliWattFor;
%linearity should not be negative. but in measurements first entries can be
%lower than 0 (calibration issue of optometer). 
indLower6=find(linearity.parameters.curBlueLED<6);%all the values for which projector output is 0
%use them as baseline
linearityValues=linearityValues-nanmean(linearityValues(indLower6));
linearityValues(indLower6)=0;%and set those values below 6 to 0

% scale linearity to 1 at the measurement value (100LED current), 
linearityValues = linearityValues/linearityValues(find(linearity.ledCurrents == 100));

fprintf(['| Ledurrents \t | rstarPerSecond |',NDstring,'\n']);
fprintf(['| --------- | --------- |',filler ,'\n'])

for i = 1 : numel(linearity.ledCurrents)
    % something is wrong here!
    rstarFinal = rstar*linearityValues(i); 
%     rstar = rstarPerSecond(powerPerArea(linearityValues(i)));  % in milli watts for 500 micron, 100 LED current and no ndf
%     rstar = round(rstar, 2);
    fprintf(['| %.0f \t | %.0f |',fprintstring,'\n'], [linearity.ledCurrents(i), rstarFinal , rstarFinal.*10.^(-ND(2:end))]);

allRstar(i,:)=[linearity.ledCurrents(i), rstarFinal , rstarFinal.*10.^(-ND(2:end))];
end
% save('RstarTable_20170907.mat','allRstar')
