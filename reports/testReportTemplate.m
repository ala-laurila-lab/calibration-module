close all;
clc;
clear;
tbUseProject('calibration-module');
import ala_laurila_lab.*;

%%

% This template is only for test purpose & soon it will be replaced with
% actual reporting from hdf5 file 

% LED power calibration

LED_CURRENT  = 100;
SPOT_DIAMETER_IN_MICRO_METER = 1000;
POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT = 0.16935;

% Ndf specif inputs (If changed)
% If you know the value of ndf, just plugin in the values here (Anna's way)
NDF_IN_FILTER_WHEEL_ORDER = [0, 3.58, 4.94, 6.40, 7.49, 8.88];
% available filter wheel as of 2017-05-05, {0, 3, 5, 6 (3+3), 7 (3+4), 8 (4+3+1) }


% Mouse specfic parameters
LAMDA_MAX = 497;                            % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.5 * 1e-12;       % um^2, collective area of rod (Murphy & Rieke (2011))
%%

radius = SPOT_DIAMETER_IN_MICRO_METER * 10^-6/2; 
area = pi*(radius)^2; 

% Test spectrum measured long back ! (check the file name for its date)
% It applies only to Lightcrafter projector present in aalto 

spectrum = ala_laurila_lab.util.loadSpectralFile('src/test/resources/spectrum_aalto_rig', 'projector');

powerPerArea = @(power) power * 10^-3 / area;
powerSpectrumPerArea = @(powerPerUnitArea) spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = @(powerPerUnitArea) util.photonToIsomerisation(powerSpectrumPerArea(powerPerUnitArea), spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

rstar = rstarPerSecond(powerPerArea(POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT));

%% Linearity Normalization 

linearity = loadjson('src/test/resources/projector-linearity.json');
linearityValues = linearity.powerInMilliWattFor;

% linearity should not be negative. but in measurements first entries can be
% lower than 0 (calibration issue of optometer). 

% all the values for which projector output is 0 use them as baseline
indLower6 = find(linearity.parameters.curBlueLED < 6); 
linearityValues = linearityValues - nanmean(linearityValues(indLower6));

% and set those values below 6 to 0
linearityValues(indLower6) = 0; 

% scale linearity to 1 at the measurement value (100LED current), 
linearityValues = linearityValues/linearityValues(linearity.ledCurrents == 100);

%% Prepare rstar table

for i = 1 : numel(linearity.ledCurrents)   
    rstarFinal = rstar * linearityValues(i); 
    allRstar(i,:) = round([linearity.ledCurrents(i), rstarFinal , rstarFinal.*10.^(-NDF_IN_FILTER_WHEEL_ORDER(2:end))] ,2);  %#ok
end

ndfPositions = arrayfun(@(i) strcat('ndf', num2str(i)) , 2 : 6, 'UniformOutput', false);
rstarTable = array2table(allRstar, 'VariableNames', {'Ledurrents', 'rstarPerSecond', ndfPositions{:}}) %#ok

fname = ['rstar-table-' date];
writetable(rstarTable, ['reports/' fname '.csv'], 'filetype', 'text');
writetable(rstarTable, ['reports/' fname '.xls'], 'filetype', 'spreadsheet');

%% Log file

text = [datestr(date) ':' getenv('username')...
    ' The measured power for led ' num2str(LED_CURRENT)...
    ' for ' num2str(POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT)...
    ' (mw) having spot diameter ' num2str(SPOT_DIAMETER_IN_MICRO_METER)...
    ' (um). The ndf values in the filter wheel order ' num2str(NDF_IN_FILTER_WHEEL_ORDER) ];

fid = fopen('reports/testTeportTemplate.txt', 'a+');
fprintf(fid, '%s\n', text);
fclose(fid);