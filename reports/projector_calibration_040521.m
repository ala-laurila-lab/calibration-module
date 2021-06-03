close all; clear; clc;
tbUseProject('calibration-module');
import ala_laurila_lab.*;

%%
% This template is only for test purpose & soon it will be replaced with
% actual reporting from hdf5 file

% LED power calibration
LED_CURRENT  = 100;
SPOT_DIAMETER_IN_MICRO_METER = 500;
POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT = 0.288;

% Ndf specif inputs (If changed)
% Plug in OD values for all NDFs here
NDF_IN_FILTER_WHEEL_1_ORDER = [0.93, 2.03, 3.30, 4.13, 0, 0];
NDF_IN_FILTER_WHEEL_2_ORDER = [0, 0, 3.30, 4.62, 0, 0];
NDF_IN_FILTER_WHEEL_ORDER = NDF_IN_FILTER_WHEEL_1_ORDER + NDF_IN_FILTER_WHEEL_2_ORDER(4);

% Mouse specfic parameters
LAMDA_MAX = 497;                            % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.63 * 1e-12;      % um^2, collective area of rod (Smeds et al., 2019)
%%

radius = SPOT_DIAMETER_IN_MICRO_METER * 10^-6/2;
area = pi*(radius)^2;

% Aalto Lightcrafter spectrum (check the file name for the measurement date)
spectrum = ala_laurila_lab.util.loadSpectralFile('src/test/resources/spectrum_aalto_rig_2019/', 'projector');

powerPerArea = @(power) power * 10^-3 / area;
powerSpectrumPerArea = @(powerPerUnitArea) spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = @(powerPerUnitArea) util.photonToIsomerisation(powerSpectrumPerArea(powerPerUnitArea), spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

import ala_laurila_lab.*;
rstar = rstarPerSecond(powerPerArea(POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT));

%% Linearity Normalization

linearity = loadjson('src/test/resources/x06_Feb_201818_58_30-linearity.json');
linearityValues = linearity.meanFlux;

% linearity should not be negative. but in measurements first entries can be
% lower than 0 (calibration issue of optometer).

% Use all values for which the projector output is 0 as a baseline estimate
indLower6 = find(linearity.ledInput < 6);
linearityValues = linearityValues - nanmean(linearityValues(indLower6));
% and set those values to 0
linearityValues(indLower6) = 0;

% scale linearity to 1 at the measurement value (100LED current),
linearityValues = linearityValues/linearityValues(linearity.ledInput == LED_CURRENT);

%% Prepare rstar table

for i = 1 : numel(linearity.ledInput)
    rstarFinal = rstar * linearityValues(i);
    allRstar(i,:) = round([linearity.ledInput(i), rstarFinal , rstarFinal.*10.^(-NDF_IN_FILTER_WHEEL_ORDER(2:end))] ,2);  %#ok
end

ndfPositions = arrayfun(@(i) strcat('ndf', num2str(i)) , 2 : 6, 'UniformOutput', false);
rstarTable = array2table(allRstar, 'VariableNames', {'Ledurrents', 'rstarPerSecond', ndfPositions{:}}) %#ok

fname = ['rstar-table-' date];
writetable(rstarTable, ['reports/' fname '.csv'], 'filetype', 'text');
writetable(rstarTable, ['reports/' fname '.xls'], 'filetype', 'spreadsheet');
save(['reports/' fname '.mat'], 'allRstar');

%% Log file

text = [datestr(date) ':' getenv('username')...
    ' The measured power for led ' num2str(LED_CURRENT)...
    ' for ' num2str(POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT)...
    ' (mw) having spot diameter ' num2str(SPOT_DIAMETER_IN_MICRO_METER)...
    ' (um). The ndf values in the filter wheel order ' num2str(NDF_IN_FILTER_WHEEL_ORDER) ];

fid = fopen('reports/reportLogs.txt', 'a+');
fprintf(fid, '%s\n', text);
fclose(fid);
