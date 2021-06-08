
% tbUseProject('calibration-module');
import ala_laurila_lab.*;


%% Data 

SPECTRUM_DATA_FOLDER = '2019-05-06';
LED_NON_LINEARITY_FILE_NAME = 'x04_Jun_202115_17_34-non-linearity.json';


dataLocation = fileparts(which('aalto_rig_calibration_data_readme'));
intensity = loadjson(fullfile(dataLocation, 'intensity', 'latest.json'))
odTable = ndf_data_util.getOpticalDensity(dataLocation)


%% LED power 
% 
LED_CURRENT = 100;
SPOT_DIAMETER_IN_MICRO_METER = 500; % in micro meter
POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT = 0.288; % mw

%% NDF optical density 
%
% Ndf specif inputs (If changed)
% Plug in OD values for all NDFs here
NDF_IN_FILTER_WHEEL_1_ORDER = [0.93, 2.03, 3.30, 4.13, 0, 0];
NDF_IN_FILTER_WHEEL_2_ORDER = [0, 0, 3.30, 4.62, 0, 0];

%% Rstar table computation

% combinations of ndf position
ndfPosition = {'4_4', '3_4', '2_4', '1_4', '5x0_4', '5x0_3'};
NDF_IN_FILTER_WHEEL_ORDER =  [NDF_IN_FILTER_WHEEL_1_ORDER(4:-1:1) + NDF_IN_FILTER_WHEEL_2_ORDER(4), NDF_IN_FILTER_WHEEL_2_ORDER(4), NDF_IN_FILTER_WHEEL_2_ORDER(3)];
ndfs = NDF_IN_FILTER_WHEEL_ORDER;


% Mouse specfic parameters
LAMDA_MAX = 497;                            % Toda et al. 1999
ROD_PHOTORECEPTOR_AREA = 0.63 * 1e-12;      % um^2, collective area of rod (Smeds et al., 2019)


radius = SPOT_DIAMETER_IN_MICRO_METER * 10^-6/2;
area = pi*(radius)^2;

% Aalto Lightcrafter spectrum (check the file name for the measurement date)
spectrum = ala_laurila_lab.util.loadSpectralFile(fullfile(dataLocation, 'projector_spectrum', SPECTRUM_DATA_FOLDER), 'projector');

powerPerArea = @(power) power * 10^-3 / area;
powerSpectrumPerArea = @(powerPerUnitArea) spectrum.getNormalizedPowerSpectrum() * powerPerUnitArea;
rstarPerSecond = @(powerPerUnitArea) util.photonToIsomerisation(powerSpectrumPerArea(powerPerUnitArea), spectrum.wavelength, LAMDA_MAX, ROD_PHOTORECEPTOR_AREA);

import ala_laurila_lab.*;
rstar = rstarPerSecond(powerPerArea(POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT));

% Linearity Normalization

linearity = loadjson(fullfile(dataLocation, 'projector_led_nonlinearity', LED_NON_LINEARITY_FILE_NAME));
linearityValues = linearity.measurements;

% scale linearity to 1 at the measurement value (100LED current),
linearityValues = linearityValues/linearityValues(linearity.ledCurrent == LED_CURRENT);

% Prepare rstar table

for i = 1 : numel(linearity.ledCurrent)
    rstarFinal = rstar * linearityValues(i);
    allRstar(i,:) = round([linearity.ledCurrent(i), rstarFinal , rstarFinal.*10.^(-ndfs)] ,2);  %#ok
end

ndfPositions = cellfun(@(i) strcat('ndf_', i) , ndfPosition, 'UniformOutput', false);
rstarTable = array2table(allRstar, 'VariableNames', {'Ledurrents', 'rstarPerSecond', ndfPositions{:}}) %#ok

fname = 'rstar-table';
writetable(rstarTable, [dataLocation filesep fname '.csv'], 'filetype', 'text');
writetable(rstarTable, [dataLocation filesep fname '-' date '.xls'], 'filetype', 'spreadsheet');
save([dataLocation filesep fname '-' date  '.mat'], 'allRstar');

% Log file
ndfpositionText = arrayfun(@(i) strcat(i, ' ,'), ndfPositions );
text = [datestr(date) ':' getenv('username')...
    ' The measured power for led ' num2str(LED_CURRENT)...
    ' for ' num2str(POWER_MEASURED_IN_OPTOMETER_FOR_LED_CURRENT_IN_MILLIWATT)...
    ' (mw) having spot diameter ' num2str(SPOT_DIAMETER_IN_MICRO_METER)...
    ' (um). The ndf values in the filter wheel order  ' [ndfpositionText{:}] ' : '  num2str(NDF_IN_FILTER_WHEEL_ORDER) ];

fid = fopen([dataLocation filesep 'reportLogs.txt'], 'a+');
fprintf(fid, '%s\n', text);
fclose(fid);

